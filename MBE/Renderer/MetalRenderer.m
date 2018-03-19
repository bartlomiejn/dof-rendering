//
//  MetalRenderer.m
//  MBE
//
//  Created by Bartłomiej Nowak on 15/11/2017.
//  Copyright © 2017 Bartłomiej Nowak. All rights reserved.
//

#import "MetalRenderer.h"
#import "MathFunctions.h"
#import "OBJMesh.h"
#import "ShaderTypes.h"
#import "RenderStateProvider.h"
#import "PassDescriptorBuilder.h"
#import <simd/simd.h>
#import <SpriteKit/SpriteKit.h>
@import Metal;
@import QuartzCore.CAMetalLayer;

typedef uint16_t MetalIndex;
const MTLIndexType MetalIndexType = MTLIndexTypeUInt16;
static const NSInteger inFlightBufferCount = 3;

typedef struct __attribute((packed)) {
    vector_float4 position;
    vector_float4 color;
} MetalVertex;

typedef struct __attribute((packed)) {
    matrix_float4x4 modelMatrix;
    matrix_float4x4 viewMatrix;
    matrix_float4x4 projectionMatrix;
} RenderObjectUniforms;

typedef struct __attribute((packed)) {
    vector_float2 imageDimensions;
    float blurRadius;
} GaussianBlurUniforms;

@interface MetalRenderer ()
@property (strong) id<MTLDevice> device;
@property (strong) OBJMesh *mesh;
@property (strong) id<MTLCommandQueue> commandQueue;
@property (strong, nonatomic) PassDescriptorBuilder *passDescriptorBuilder;
@property (strong, nonatomic) RenderStateProvider *renderStateProvider;
@property (strong) NSArray<id<MTLBuffer>> *drawObjectUniforms;
@property (strong) id<MTLBuffer> gaussianBlurUniforms;
@property (strong) id<MTLTexture> colorTexture;
@property (strong) id<MTLTexture> depthTexture;
@property (strong) id<MTLTexture> inFocusColorTexture;
@property (strong) id<MTLTexture> outOfFocusColorTexture;
@property (strong) id<MTLDepthStencilState> depthStencilState;
@property (strong) dispatch_semaphore_t displaySemaphore;
@property (assign) NSInteger bufferIndex;
@property (assign) float rotationX, rotationY, rotationZ, time;
@end

@implementation MetalRenderer

-(instancetype)initWithDevice:(id<MTLDevice>)device {
    self = [super init];
    if (self) {
        self.device = device;
        self.displaySemaphore = dispatch_semaphore_create(inFlightBufferCount);
        self.commandQueue = [self.device newCommandQueue];
        self.renderStateProvider = [[RenderStateProvider alloc] initWithDevice:self.device];
        self.passDescriptorBuilder = [[PassDescriptorBuilder alloc] init];
        self.drawObjectUniforms = [self makeDrawObjectUniforms];
        self.gaussianBlurUniforms = [self makeGaussianBlurUniforms];
    }
    return self;
}

-(NSArray<id<MTLBuffer>> *)makeDrawObjectUniforms {
    int teapotCount = 3;
    NSMutableArray *drawObjectUniforms = [[NSMutableArray alloc] init];
    for (int i = 0; i < teapotCount; i++) {
        id<MTLBuffer> buffer = [self.device newBufferWithLength:sizeof(RenderObjectUniforms) * inFlightBufferCount
                                                        options:MTLResourceOptionCPUCacheModeDefault];
        buffer.label = [[NSString alloc] initWithFormat:@"Teapot Uniforms %d", i];
        [drawObjectUniforms addObject:buffer];
    }
    return drawObjectUniforms;
}

-(id<MTLBuffer>)makeGaussianBlurUniforms {
    id<MTLBuffer> buffer = [self.device newBufferWithLength:sizeof(GaussianBlurUniforms)
                                                    options:MTLResourceOptionCPUCacheModeDefault];
    buffer.label = @"Gaussian Blur Uniforms";
    return buffer;
}

-(void)setupMeshFromOBJGroup:(OBJGroup*)group {
    self.mesh = [[OBJMesh alloc] initWithGroup:group device:self.device];
}

#pragma mark - MetalViewDelegate

-(void)drawInView:(MetalView *)view {
    dispatch_semaphore_wait(self.displaySemaphore, DISPATCH_TIME_FOREVER);
    [self updateUniformsForView:view duration:view.frameDuration];
    
    id<MTLCommandBuffer> commandBuffer = [self.commandQueue commandBuffer];
    [commandBuffer addCompletedHandler:^(id<MTLCommandBuffer> commandBuffer) {
        self.bufferIndex = (self.bufferIndex + 1) % inFlightBufferCount;
        dispatch_semaphore_signal(self.displaySemaphore);
    }];
    
    id<MTLCaptureScope> scope = [[MTLCaptureManager sharedCaptureManager] newCaptureScopeWithDevice:self.device];
    scope.label = @"Capture Scope";
    [scope beginScope];
    [self drawObjectsInView:view withCommandBuffer:commandBuffer];
    [self maskInFocusInView:view withCommandBuffer:commandBuffer];
    [self maskOutOfFocusInView:view withCommandBuffer:commandBuffer];
    [self applyHorizontalBlurOnOutOfFocusTextureInView:view withCommandBuffer:commandBuffer];
    [commandBuffer presentDrawable:view.currentDrawable];
    [scope endScope];
    
    [commandBuffer commit];
}

-(void)frameAdjustedForView:(MetalView *)view {
    CGSize drawableSize = view.metalLayer.drawableSize;
    if (self.colorTexture.width != drawableSize.width || self.colorTexture.height != drawableSize.height) {
        self.colorTexture = [self readAndRenderTargetUsageTextureOfSize:drawableSize format:MTLPixelFormatBGRA8Unorm];
    }
    if (self.depthTexture.width != drawableSize.width || self.depthTexture.height != drawableSize.height) {
        self.depthTexture = [self readAndRenderTargetUsageTextureOfSize:drawableSize format:MTLPixelFormatDepth32Float];
    }
    if (self.inFocusColorTexture.width != drawableSize.width
        || self.inFocusColorTexture.height != drawableSize.height) {
        self.inFocusColorTexture = [self readAndRenderTargetUsageTextureOfSize:drawableSize format:MTLPixelFormatBGRA8Unorm];
    }
    if (self.outOfFocusColorTexture.width != drawableSize.width
        || self.outOfFocusColorTexture.height != drawableSize.height) {
        self.outOfFocusColorTexture = [self readAndRenderTargetUsageTextureOfSize:drawableSize
                                                                      format:MTLPixelFormatBGRA8Unorm];
    }
}


-(void)drawObjectsInView:(MetalView *)view withCommandBuffer:(id<MTLCommandBuffer>)commandBuffer {
    MTLRenderPassDescriptor *descriptor
        = [self.passDescriptorBuilder renderObjectsPassDescriptorOfSize:view.metalLayer.drawableSize
                                                             clearColor:view.clearColor
                                                     outputColorTexture:self.colorTexture
                                                     outputDepthTexture:self.depthTexture];
    id<MTLRenderCommandEncoder> encoder = [commandBuffer renderCommandEncoderWithDescriptor:descriptor];
    [encoder setLabel:@"Draw Objects Encoder"];
    [encoder setRenderPipelineState:_renderStateProvider.drawObjectsPipelineState];
    [encoder setDepthStencilState:_renderStateProvider.depthStencilState];
    [encoder setFrontFacingWinding:MTLWindingCounterClockwise];
    [encoder setCullMode:MTLCullModeBack];
    [encoder setVertexBuffer:self.mesh.vertexBuffer offset:0 atIndex:0];
    const NSUInteger uniformBufferOffset = sizeof(RenderObjectUniforms) * self.bufferIndex;
    for (int i = 0; i < self.drawObjectUniforms.count; i++) {
        [encoder setVertexBuffer:self.drawObjectUniforms[i] offset:uniformBufferOffset atIndex:1];
        [encoder drawIndexedPrimitives:MTLPrimitiveTypeTriangle
                            indexCount:[self.mesh.indexBuffer length] / sizeof(MetalIndex)
                             indexType:MetalIndexType
                           indexBuffer:self.mesh.indexBuffer
                     indexBufferOffset:0];
    }
    [encoder endEncoding];
}

-(void)maskInFocusInView:(MetalView *)view withCommandBuffer:(id<MTLCommandBuffer>)commandBuffer {
    MTLRenderPassDescriptor *descriptor
        = [self.passDescriptorBuilder outputToColorTextureDescriptorOfSize:view.metalLayer.drawableSize
                                                                clearColor:view.clearColor
                                                               withTexture:self.inFocusColorTexture];
    id<MTLRenderCommandEncoder> encoder = [commandBuffer renderCommandEncoderWithDescriptor:descriptor];
    [encoder setLabel:@"Mask In Focus Encoder"];
    [encoder setRenderPipelineState:_renderStateProvider.maskFocusFieldPipelineState];
    [encoder setFragmentTexture:self.colorTexture atIndex:0];
    [encoder setFragmentTexture:self.depthTexture atIndex:1];
    [encoder drawPrimitives:MTLPrimitiveTypeTriangleStrip vertexStart:0 vertexCount:4];
    [encoder endEncoding];
}

-(void)maskOutOfFocusInView:(MetalView *)view withCommandBuffer:(id<MTLCommandBuffer>)commandBuffer {
    MTLRenderPassDescriptor *descriptor
        = [self.passDescriptorBuilder outputToColorTextureDescriptorOfSize:view.metalLayer.drawableSize
                                                                 clearColor:view.clearColor
                                                                withTexture:self.outOfFocusColorTexture];
    id<MTLRenderCommandEncoder> encoder = [commandBuffer renderCommandEncoderWithDescriptor:descriptor];
    [encoder setLabel:@"Mask Out Of Focus Encoder"];
    [encoder setRenderPipelineState:_renderStateProvider.maskOutOfFocusFieldPipelineState];
    [encoder setFragmentTexture:self.colorTexture atIndex:0];
    [encoder setFragmentTexture:self.depthTexture atIndex:1];
    [encoder drawPrimitives:MTLPrimitiveTypeTriangleStrip vertexStart:0 vertexCount:4];
    [encoder endEncoding];
}

-(void)applyHorizontalBlurOnOutOfFocusTextureInView:(MetalView *)view
                                   withCommandBuffer:(id<MTLCommandBuffer>)commandBuffer {
    MTLRenderPassDescriptor *descriptor
        = [self.passDescriptorBuilder outputToColorTextureDescriptorOfSize:view.metalLayer.drawableSize
                                                                clearColor:view.clearColor
                                                               withTexture:self.outOfFocusColorTexture];
    id<MTLRenderCommandEncoder> encoder = [commandBuffer renderCommandEncoderWithDescriptor:descriptor];
    [encoder setLabel:@"Horizontal Blur Out Of Focus Encoder"];
    [encoder setRenderPipelineState:_renderStateProvider.applyHorizontalBlurFieldPipelineState];
    [encoder setVertexBuffer:self.gaussianBlurUniforms offset:0 atIndex:0];
    [encoder setFragmentTexture:self.colorTexture atIndex:0];
    [encoder setFragmentTexture:self.depthTexture atIndex:1];
    [encoder drawPrimitives:MTLPrimitiveTypeTriangleStrip vertexStart:0 vertexCount:4];
    [encoder endEncoding];
}

-(void)updateUniformsForView:(MetalView *)view duration:(NSTimeInterval)duration {
    self.time += duration;
    self.rotationX += duration * (M_PI / 2);
    self.rotationY += duration * (M_PI / 3);
    self.rotationZ = 0;
    
    GaussianBlurUniforms uniforms;
    uniforms.blurRadius = 5.0;
    uniforms.imageDimensions = (vector_float2) {
        view.metalLayer.drawableSize.width,
        view.metalLayer.drawableSize.height
    };
    memcpy(self.gaussianBlurUniforms.contents, &uniforms, sizeof(uniforms));
    
    const NSUInteger uniformBufferOffset = sizeof(RenderObjectUniforms) * self.bufferIndex;
    for (int i = 0; i < self.drawObjectUniforms.count; i++) {
        RenderObjectUniforms uniforms;
        uniforms.modelMatrix = [self modelMatrixForTeapotIndex:i];
        uniforms.viewMatrix = [self viewMatrix];
        uniforms.projectionMatrix = [self projectionMatrixForView:view];
        memcpy([self.drawObjectUniforms[i] contents] + uniformBufferOffset, &uniforms, sizeof(uniforms));
    }
}

-(matrix_float4x4)modelMatrixForTeapotIndex:(int)index {
    vector_float3 translation;
    if (index == 1) {
        translation = (vector_float3){ 0, 0, 0 };
    } else if (index == 2) {
        translation = (vector_float3){ 0.8, 4.1, -20.0 };
    } else {
        translation = (vector_float3){ -0.7, -4.1, -3.0 };
    }
    const matrix_float4x4 transMatrix = matrix_float4x4_translation(translation);
    
    const vector_float3 xAxis = { 1, 0, 0 };
    const vector_float3 yAxis = { 0, 1, 0 };
    const vector_float3 zAxis = { 0, 0, 1 };
    const matrix_float4x4 xRot = matrix_float4x4_rotation(xAxis, self.rotationX);
    const matrix_float4x4 yRot = matrix_float4x4_rotation(yAxis, self.rotationY);
    const matrix_float4x4 zRot = matrix_float4x4_rotation(zAxis, self.rotationZ);
    const matrix_float4x4 rotMatrix = matrix_multiply(matrix_multiply(xRot, yRot), zRot);
    
    float scaleFactor;
    if (index == 1) {
        scaleFactor = sinf(5 * self.time) * 0.5 + 3;
    } else if (index == 2) {
        scaleFactor = sinf(5 * self.time) * 0.5 + 6;
    } else {
        scaleFactor = sinf(5 * self.time) * 0.5 + 3;
    }
    const matrix_float4x4 scaleMatrix = matrix_float4x4_uniform_scale(scaleFactor);
    
    return matrix_multiply(matrix_multiply(transMatrix, rotMatrix), scaleMatrix);
}

-(matrix_float4x4)viewMatrix {
    const vector_float3 cameraTranslation = { 0, 0, -5 };
    const matrix_float4x4 viewMatrix = matrix_float4x4_translation(cameraTranslation);
    return viewMatrix;
}

-(matrix_float4x4)projectionMatrixForView:(MetalView *)view {
    const CGSize drawableSize = view.metalLayer.drawableSize;
    const float aspect = drawableSize.width / drawableSize.height;
    const float fov = (2 * M_PI) / 5;
    const float near = 1;
    const float far = 100;
    const matrix_float4x4 projectionMatrix = matrix_float4x4_perspective(aspect, fov, near, far);
    return projectionMatrix;
}

-(id<MTLTexture>)readAndRenderTargetUsageTextureOfSize:(CGSize)size format:(MTLPixelFormat)format {
    MTLTextureDescriptor *desc = [MTLTextureDescriptor texture2DDescriptorWithPixelFormat:format
                                                                                    width:size.width
                                                                                   height:size.height
                                                                                mipmapped:NO];
    desc.usage = MTLTextureUsageRenderTarget & MTLTextureUsageShaderRead;
    return [self.device newTextureWithDescriptor:desc];
}

@end
