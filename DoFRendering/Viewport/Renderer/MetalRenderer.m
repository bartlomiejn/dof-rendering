//
//  MetalRenderer.m
//  MBE
//
//  Created by Bartłomiej Nowak on 15/11/2017.
//  Copyright © 2017 Bartłomiej Nowak. All rights reserved.
//

@import simd;
@import SpriteKit;
@import Metal;
@import QuartzCore.CAMetalLayer;
#import "MetalRenderer.h"
#import "RenderStateProvider.h"
#import "PassDescriptorBuilder.h"
#import "ModelGroup.h"
#import "MathFunctions.h"

typedef uint16_t MetalIndex;
const MTLIndexType MetalIndexType = MTLIndexTypeUInt16;
static const NSInteger inFlightBufferCount = 3;

typedef struct {
    simd_float4 position, color;
} MetalVertex;

typedef struct {
    simd_float4x4 modelMatrix;
} ModelUniforms;

typedef struct {
    simd_float4x4 viewMatrix, projectionMatrix;
} ViewProjectionUniforms;

typedef struct {
    simd_bool isVertical;
    simd_float1 blurRadius;
    simd_float2 imageDimensions;
} GaussianBlurUniforms;

typedef struct {
    simd_float1 focusDist, focusRange;
} CoCUniforms;

@interface MetalRenderer ()

// Metal top-level objects
@property (nonatomic, strong) id<MTLDevice> device;
@property (nonatomic, strong) id<MTLCommandQueue> commandQueue;

// Uniforms
@property (nonatomic, strong) NSArray<NSArray<id<MTLBuffer>>*> *modelGroupUniforms;
@property (nonatomic, strong) NSArray<id<MTLBuffer>> *viewProjectionUniforms;
@property (nonatomic, strong) NSArray<id<MTLBuffer>> *gaussianBlurUniforms;
@property (nonatomic, strong) id<MTLBuffer> circleOfConfusionUniforms;

// Textures / Stencil states
@property (nonatomic, strong) id<MTLTexture> colorTexture;
@property (nonatomic, strong) id<MTLTexture> depthTexture;
@property (nonatomic, strong) id<MTLTexture> inFocusColorTexture;
@property (nonatomic, strong) id<MTLTexture> outOfFocusColorTexture;
@property (nonatomic, strong) id<MTLTexture> blurredOutOfFocusColorTexture;
@property (nonatomic, strong) id<MTLTexture> blurredOutOfFocusColorTexture2;
@property (nonatomic, strong) id<MTLDepthStencilState> depthStencilState;

// Auxiliary
@property (nonatomic, strong) PassDescriptorBuilder *passDescriptorBuilder;
@property (nonatomic, strong) RenderStateProvider *renderStateProvider;
@property (nonatomic, strong) dispatch_semaphore_t displaySemaphore;
@property (nonatomic) MTLClearColor clearColor;
@property (assign) NSInteger currentBufferIndex;
@property (assign) float rotationX, rotationY, rotationZ, time;
@end

@implementation MetalRenderer

-(void)setDrawableModelGroup:(ModelGroup *)drawableModelGroup
{
    _drawableModelGroup = drawableModelGroup;
    if (_modelGroupUniforms.count != drawableModelGroup.count) {
        _modelGroupUniforms = [self makeModelGroupUniforms];
    }
}

-(instancetype)initWithDevice:(id<MTLDevice>)device
{
    self = [super init];
    if (self) {
        self.device = device;
        self.commandQueue = [self.device newCommandQueue];
        self.modelGroupUniforms = [self makeModelGroupUniforms];
        self.gaussianBlurUniforms = [self makeGaussianBlurUniforms];
        self.circleOfConfusionUniforms = [self makeCircleOfConfusionUniforms];
        self.renderStateProvider = [[RenderStateProvider alloc] initWithDevice:self.device];
        self.passDescriptorBuilder = [PassDescriptorBuilder new];
        self.displaySemaphore = dispatch_semaphore_create(inFlightBufferCount);
        self.clearColor = MTLClearColorMake(0.0, 0.0, 0.0, 1.0);
    }
    return self;
}

-(NSArray<id<MTLBuffer>> *)makeModelGroupUniforms
{
    NSMutableArray *drawObjectUniforms = [NSMutableArray new];
    for (int i = 0; i < _drawableModelGroup.count; i++) {
        id<MTLBuffer> buffer = [self.device newBufferWithLength:sizeof(ModelUniforms) * inFlightBufferCount
                                                        options:MTLResourceOptionCPUCacheModeDefault];
        buffer.label = [[NSString alloc] initWithFormat:@"Model %d Uniforms", i];
        [drawObjectUniforms addObject:buffer];
    }
    return drawObjectUniforms;
}

-(NSArray<id<MTLBuffer>> *)makeGaussianBlurUniforms
{
    NSMutableArray *uniforms = [NSMutableArray new];
    for (int i = 0; i < 2; i++) {
        id<MTLBuffer> buffer = [self.device newBufferWithLength:sizeof(GaussianBlurUniforms)
                                                        options:MTLResourceOptionCPUCacheModeDefault];
        buffer.label = [[NSString alloc] initWithFormat:@"Gaussian Blur Pass %d Uniforms", i];
        [uniforms addObject:buffer];
    }
    return uniforms;
}

-(id<MTLBuffer>)makeCircleOfConfusionUniforms
{
    id<MTLBuffer> buffer = [self.device newBufferWithLength:sizeof(CoCUniforms)
                                                    options:MTLResourceOptionCPUCacheModeDefault];
    buffer.label = @"Circle Of Confusion Pass Uniforms";
    return buffer;
}

#pragma mark - MetalViewDelegate

-(void)drawToDrawable:(id<CAMetalDrawable>)drawable ofSize:(CGSize)drawableSize
{
    dispatch_semaphore_wait(self.displaySemaphore, DISPATCH_TIME_FOREVER);
    self.currentBufferIndex = (self.currentBufferIndex + 1) % inFlightBufferCount;
    [self updateUniformsWith:drawableSize];
    id<MTLCommandBuffer> commandBuffer = [self.commandQueue commandBuffer];
    __weak dispatch_semaphore_t weakSemaphore = self.displaySemaphore;
    [commandBuffer addCompletedHandler:^(id<MTLCommandBuffer> commandBuffer) {
        dispatch_semaphore_signal(weakSemaphore);
    }];
    id<MTLCaptureScope> scope = [[MTLCaptureManager sharedCaptureManager] newCaptureScopeWithDevice:self.device];
    scope.label = @"Capture Scope";
    [scope beginScope];
    [self drawObjectsIn:commandBuffer with:drawableSize];
    [self maskInFocusToTextureIn:commandBuffer with:drawableSize];
    [self maskOutOfFocusToTextureIn:commandBuffer with:drawableSize];
    [self horizontalBlurOnOutOfFocusTextureIn:commandBuffer with:drawableSize];
    [self verticalBlurOnOutOfFocusTextureIn:commandBuffer with:drawableSize];
    [self compositeTexturesIn:commandBuffer to:drawable.texture with:drawableSize];
    [commandBuffer presentDrawable:drawable];
    [scope endScope];
    [commandBuffer commit];
}


-(void)adjustedDrawableSize:(CGSize)drawableSize
{
    if (self.colorTexture.width != drawableSize.width || self.colorTexture.height != drawableSize.height) {
        self.colorTexture = [self readAndRenderTargetTextureOfSize:drawableSize format:MTLPixelFormatBGRA8Unorm];
    }
    if (self.depthTexture.width != drawableSize.width || self.depthTexture.height != drawableSize.height) {
        self.depthTexture = [self readAndRenderTargetTextureOfSize:drawableSize format:MTLPixelFormatDepth32Float];
    }
    if (self.inFocusColorTexture.width != drawableSize.width
    || self.inFocusColorTexture.height != drawableSize.height) {
        self.inFocusColorTexture = [self readAndRenderTargetTextureOfSize:drawableSize format:MTLPixelFormatBGRA8Unorm];
    }
    if (self.outOfFocusColorTexture.width != drawableSize.width
    || self.outOfFocusColorTexture.height != drawableSize.height) {
        self.outOfFocusColorTexture = [self readAndRenderTargetTextureOfSize:drawableSize
                                                                      format:MTLPixelFormatBGRA8Unorm];
    }
    if (self.blurredOutOfFocusColorTexture.width != drawableSize.width
    || self.blurredOutOfFocusColorTexture.height != drawableSize.height) {
        self.blurredOutOfFocusColorTexture = [self readAndRenderTargetTextureOfSize:drawableSize
                                                                             format:MTLPixelFormatBGRA8Unorm];
    }
    
    if (self.blurredOutOfFocusColorTexture2.width != drawableSize.width
    || self.blurredOutOfFocusColorTexture2.height != drawableSize.height) {
        self.blurredOutOfFocusColorTexture2 = [self readAndRenderTargetTextureOfSize:drawableSize
                                                                              format:MTLPixelFormatBGRA8Unorm];
    }
}

-(void)drawObjectsIn:(id<MTLCommandBuffer>)commandBuffer with:(CGSize)drawableSize
{
    MTLRenderPassDescriptor *descriptor
    = [self.passDescriptorBuilder renderObjectsPassDescriptorOfSize:drawableSize
                                                         clearColor:self.clearColor
                                                 outputColorTexture:self.colorTexture
                                                 outputDepthTexture:self.depthTexture];
    id<MTLRenderCommandEncoder> encoder = [commandBuffer renderCommandEncoderWithDescriptor:descriptor];
    [encoder setLabel:@"Draw Objects Encoder"];
    [encoder setRenderPipelineState:self.renderStateProvider.drawObjectsPipelineState];
    [encoder setDepthStencilState:self.renderStateProvider.depthStencilState];
    [encoder setFrontFacingWinding:MTLWindingCounterClockwise];
    [encoder setCullMode:MTLCullModeBack];
    [encoder setVertexBuffer:_drawableModelGroup.mesh.vertexBuffer offset:0 atIndex:0];
    const NSUInteger uniformBufferOffset = sizeof(ViewProjectionUniforms) * self.currentBufferIndex;
    for (int i = 0; i < _modelGroupUniforms.count; i++) {
        [encoder setVertexBuffer:_modelGroupUniforms[i] offset:uniformBufferOffset atIndex:1];
        [encoder drawIndexedPrimitives:MTLPrimitiveTypeTriangle
                            indexCount:_drawableModelGroup.mesh.indexBuffer.length / sizeof(MetalIndex)
                             indexType:MetalIndexType
                           indexBuffer:_drawableModelGroup.mesh.indexBuffer
                     indexBufferOffset:0];
    }
    [encoder endEncoding];
}

-(void)circleOfConfusionIn:(id<MTLCommandBuffer>)commandBuffer with:(CGSize)drawableSize
{
    MTLRenderPassDescriptor *desc = [self.passDescriptorBuilder outputToDepthTextureDescriptorOfSize:drawableSize
                                                                                           toTexture:self.depthTexture];
    id<MTLRenderCommandEncoder> encoder = [commandBuffer renderCommandEncoderWithDescriptor:desc];
    [encoder setLabel:@"Circle Of Confusion Pass Encoder"];
    [encoder setRenderPipelineState:self.renderStateProvider.circleOfConfusionPipelineState];
    [encoder setFragmentBuffer:self.circleOfConfusionUniforms offset:0 atIndex:0];
    [encoder setFragmentTexture:self.colorTexture atIndex:0];
    [encoder setFragmentTexture:self.depthTexture atIndex:1];
    [encoder drawPrimitives:MTLPrimitiveTypeTriangleStrip vertexStart:0 vertexCount:4];
    [encoder endEncoding];
}

-(void)maskInFocusToTextureIn:(id<MTLCommandBuffer>)commandBuffer with:(CGSize)drawableSize
{
    MTLRenderPassDescriptor *descriptor
    = [self.passDescriptorBuilder outputToColorTextureDescriptorOfSize:drawableSize
                                                            clearColor:self.clearColor
                                                             toTexture:self.inFocusColorTexture];
    id<MTLRenderCommandEncoder> encoder = [commandBuffer renderCommandEncoderWithDescriptor:descriptor];
    [encoder setLabel:@"Mask In Focus Encoder"];
    [encoder setRenderPipelineState:self.renderStateProvider.maskFocusFieldPipelineState];
    [encoder setFragmentTexture:self.colorTexture atIndex:0];
    [encoder setFragmentTexture:self.depthTexture atIndex:1];
    [encoder drawPrimitives:MTLPrimitiveTypeTriangleStrip vertexStart:0 vertexCount:4];
    [encoder endEncoding];
}

-(void)maskOutOfFocusToTextureIn:(id<MTLCommandBuffer>)commandBuffer with:(CGSize)drawableSize
{
    MTLRenderPassDescriptor *descriptor
    = [self.passDescriptorBuilder outputToColorTextureDescriptorOfSize:drawableSize
                                                             clearColor:self.clearColor
                                                             toTexture:self.outOfFocusColorTexture];
    id<MTLRenderCommandEncoder> encoder = [commandBuffer renderCommandEncoderWithDescriptor:descriptor];
    [encoder setLabel:@"Mask Out Of Focus Encoder"];
    [encoder setRenderPipelineState:self.renderStateProvider.maskOutOfFocusFieldPipelineState];
    [encoder setFragmentTexture:self.colorTexture atIndex:0];
    [encoder setFragmentTexture:self.depthTexture atIndex:1];
    [encoder drawPrimitives:MTLPrimitiveTypeTriangleStrip vertexStart:0 vertexCount:4];
    [encoder endEncoding];
}

-(void)horizontalBlurOnOutOfFocusTextureIn:(id<MTLCommandBuffer>)commandBuffer with:(CGSize)drawableSize
{
    MTLRenderPassDescriptor *descriptor
    = [self.passDescriptorBuilder outputToColorTextureDescriptorOfSize:drawableSize
                                                            clearColor:self.clearColor
                                                             toTexture:self.blurredOutOfFocusColorTexture];
    id<MTLRenderCommandEncoder> encoder = [commandBuffer renderCommandEncoderWithDescriptor:descriptor];
    [encoder setLabel:[[NSString alloc] initWithFormat:@"Horizontal Blur Out Of Focus Encoder"]];
    [encoder setRenderPipelineState:self.renderStateProvider.applyGaussianBlurFieldPipelineState];
    [encoder setFragmentBuffer:self.gaussianBlurUniforms[0] offset:0 atIndex:0];
    [encoder setFragmentTexture:self.outOfFocusColorTexture atIndex:0];
    [encoder setFragmentTexture:self.depthTexture atIndex:1];
    [encoder drawPrimitives:MTLPrimitiveTypeTriangleStrip vertexStart:0 vertexCount:4];
    [encoder endEncoding];
}

-(void)verticalBlurOnOutOfFocusTextureIn:(id<MTLCommandBuffer>)commandBuffer with:(CGSize)drawableSize
{
    MTLRenderPassDescriptor *descriptor
    = [self.passDescriptorBuilder outputToColorTextureDescriptorOfSize:drawableSize
                                                            clearColor:self.clearColor
                                                             toTexture:self.blurredOutOfFocusColorTexture2];
    id<MTLRenderCommandEncoder> encoder = [commandBuffer renderCommandEncoderWithDescriptor:descriptor];
    [encoder setLabel:[[NSString alloc] initWithFormat:@"Vertical Blur Out Of Focus Encoder"]];
    [encoder setRenderPipelineState:self.renderStateProvider.applyGaussianBlurFieldPipelineState];
    [encoder setFragmentBuffer:self.gaussianBlurUniforms[1] offset:0 atIndex:0];
    [encoder setFragmentTexture:self.blurredOutOfFocusColorTexture atIndex:0];
    [encoder setFragmentTexture:self.depthTexture atIndex:1];
    [encoder drawPrimitives:MTLPrimitiveTypeTriangleStrip vertexStart:0 vertexCount:4];
    [encoder endEncoding];
}

-(void)compositeTexturesIn:(id<MTLCommandBuffer>)commandBuffer to:(id<MTLTexture>)texture with:(CGSize)drawableSize
{
    MTLRenderPassDescriptor *descriptor = [self.passDescriptorBuilder
                                           outputToColorTextureDescriptorOfSize:drawableSize
                                           clearColor:self.clearColor
                                           toTexture:texture];
    id<MTLRenderCommandEncoder> encoder = [commandBuffer renderCommandEncoderWithDescriptor:descriptor];
    [encoder setLabel:[[NSString alloc] initWithFormat:@"Composite Encoder"]];
    [encoder setRenderPipelineState:self.renderStateProvider.compositePipelineState];
    [encoder setFragmentTexture:self.inFocusColorTexture atIndex:0];
    [encoder setFragmentTexture:self.blurredOutOfFocusColorTexture2 atIndex:1];
    [encoder drawPrimitives:MTLPrimitiveTypeTriangleStrip vertexStart:0 vertexCount:4];
    [encoder endEncoding];
}

-(void)updateUniformsWith:(CGSize)drawableSize
{
    for (int i = 0; i < 2; i++) {
        GaussianBlurUniforms uniforms;
        uniforms.isVertical = i == 0 ? true : false;
        uniforms.imageDimensions = (vector_float2) { drawableSize.width, drawableSize.height };
        uniforms.blurRadius = 3.0;
        memcpy(self.gaussianBlurUniforms[i].contents, &uniforms, sizeof(uniforms));
    }
    
    {
        CoCUniforms uniforms;
        uniforms.focusDist = 10;
        uniforms.focusRange = 5;
        memcpy(self.circleOfConfusionUniforms.contents, &uniforms, sizeof(uniforms));
    }
        
    const NSUInteger uniformBufferOffset = sizeof(ViewProjectionUniforms) * self.currentBufferIndex;
    for (int i = 0; i < _viewProjectionUniforms; i++) {
        ViewProjectionUniforms uniforms;
        uniforms.viewMatrix = [self viewMatrix];
        uniforms.projectionMatrix = [self projectionMatrixWith:drawableSize];
        memcpy([self.drawedModelUniforms[i] contents] + uniformBufferOffset, &uniforms, sizeof(uniforms));
    }
}

-(matrix_float4x4)viewMatrix
{
    const vector_float3 cameraTranslation = { 0, 0, -5 };
    const matrix_float4x4 viewMatrix = matrix_float4x4_translation(cameraTranslation);
    return viewMatrix;
}

-(matrix_float4x4)projectionMatrixWith:(CGSize)drawableSize
{
    const float aspectRatio = drawableSize.width / drawableSize.height;
    const float fov = (2 * M_PI) / 5;
    const float near = 1.0;
    const float far = 100;
    const matrix_float4x4 projectionMatrix = matrix_float4x4_perspective(aspectRatio, fov, near, far);
    return projectionMatrix;
}

-(id<MTLTexture>)readAndRenderTargetTextureOfSize:(CGSize)size format:(MTLPixelFormat)format
{
    MTLTextureDescriptor *desc = [MTLTextureDescriptor texture2DDescriptorWithPixelFormat:format
                                                                                    width:size.width
                                                                                   height:size.height
                                                                                mipmapped:NO];
    desc.usage = MTLTextureUsageRenderTarget & MTLTextureUsageShaderRead;
    return [self.device newTextureWithDescriptor:desc];
}

@end
