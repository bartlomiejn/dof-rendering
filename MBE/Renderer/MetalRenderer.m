//
//  MetalRenderer.m
//  MBE
//
//  Created by Bartłomiej Nowak on 15/11/2017.
//  Copyright © 2017 Bartłomiej Nowak. All rights reserved.
//
//  Includes code taken from Metal By Example book repository at: https://github.com/metal-by-example/sample-code
//

#import "MetalRenderer.h"
#import "MathFunctions.h"

@import simd;
@import Metal;
@import QuartzCore.CAMetalLayer;

typedef struct {
    vector_float4 position;
    vector_float4 color;
} MetalVertex;

typedef struct {
    matrix_float4x4 modelViewProjectionMatrix;
} MetalUniforms;

typedef uint16_t MetalIndex;
const MTLIndexType MetalIndexType = MTLIndexTypeUInt16;

static const NSInteger inFlightBufferCount = 3;

@interface MetalRenderer ()
@property (strong) id<MTLDevice> device;
@property (strong) id<MTLBuffer> vertexBuffer;
@property (strong) id<MTLBuffer> indexBuffer;
@property (strong) id<MTLBuffer> uniformBuffer;
@property (strong) id<MTLCommandQueue> commandQueue;
@property (strong) id<MTLRenderPipelineState> renderPipelineState;
@property (strong) id<MTLDepthStencilState> depthStencilState;
@property (strong) dispatch_semaphore_t displaySemaphore;
@property (assign) NSInteger bufferIndex;
@property (assign) float rotationX, rotationY, time;
@end

@implementation MetalRenderer

- (instancetype)initWithDevice:(id<MTLDevice>)device
{
    self = [super init];
    if (self) {
        _device = device;
        _displaySemaphore = dispatch_semaphore_create(inFlightBufferCount);
        
        [self setupPipeline];
        [self setupBuffers];
    }
    return self;
}

- (void)setupPipeline {
    _commandQueue = [_device newCommandQueue];
    
    id<MTLLibrary> library = [_device newDefaultLibrary];
    id<MTLFunction> vertexFunction = [library newFunctionWithName:@"vert_passthrough"];
    id<MTLFunction> fragFunction = [library newFunctionWithName:@"frag_passthrough"];
    
    MTLRenderPipelineDescriptor *descriptor = [self createPipelineDescriptorWithVertexFunction:vertexFunction
                                                                              fragmentFunction:fragFunction
                                                                                   pixelFormat:MTLPixelFormatBGRA8Unorm];
    
    _renderPipelineState = [self createRenderPipelineStateWith:descriptor];
    _depthStencilState = [self createDepthStencilState];
}

/**
 * Encodes information about depth and stencil buffer operations.
 */
- (id<MTLDepthStencilState>)createDepthStencilState {
    MTLDepthStencilDescriptor *depthStencilDescriptor = [MTLDepthStencilDescriptor new];
    depthStencilDescriptor.depthCompareFunction = MTLCompareFunctionLess;
    depthStencilDescriptor.depthWriteEnabled = YES;
    return [_device newDepthStencilStateWithDescriptor:depthStencilDescriptor];
}

/**
 * Encodes graphics state for a configured graphics rendering pipeline, to use with MTLRenderCommandEncoder to encode
 * commands for a rendering pass. Set it before any draw calls.
 */
- (MTLRenderPipelineDescriptor *)createPipelineDescriptorWithVertexFunction:(id<MTLFunction>)vertexFunction
                                                           fragmentFunction:(id<MTLFunction>)fragmentFunction
                                                                pixelFormat:(MTLPixelFormat)format {
    MTLRenderPipelineDescriptor *descriptor = [MTLRenderPipelineDescriptor new];
    descriptor.vertexFunction = vertexFunction;
    descriptor.fragmentFunction = fragmentFunction;
    descriptor.colorAttachments[0].pixelFormat = format;
    descriptor.depthAttachmentPixelFormat = MTLPixelFormatDepth32Float;
    return descriptor;
}

- (void)setupBuffers {
    static const MetalVertex vertices[] = {
        { .position = { -1, 1, 1, 1 }, .color = { 0, 1, 1, 1 } },
        { .position = { -1, -1, 1, 1 }, .color = { 0, 0, 1, 1 } },
        { .position = { 1, -1, 1, 1 }, .color = { 1, 0, 1, 1 } },
        { .position = { 1, 1, 1, 1 }, .color = { 1, 1, 1, 1 } },
        { .position = { -1, 1, -1, 1 }, .color = { 0, 1, 0, 1 } },
        { .position = { -1, -1, -1, 1 }, .color = { 0, 0, 0, 1 } },
        { .position = { 1, -1, -1, 1 }, .color = { 1, 0, 0, 1 } },
        { .position = { 1, 1, -1, 1 }, .color = { 1, 1, 0, 1 } }
    };
    
    static const MetalIndex indices[] = {
        3, 2, 6, 6, 7, 3,
        4, 5, 1, 1, 0, 4,
        4, 0, 3, 3, 7, 4,
        1, 5, 6, 6, 2, 1,
        0, 1, 2, 2, 3, 0,
        7, 6, 5, 5, 4, 7
    };
    
    _vertexBuffer = [_device newBufferWithBytes:vertices
                                         length:sizeof(vertices)
                                        options:MTLResourceOptionCPUCacheModeDefault];
    _vertexBuffer.label = @"Vertices";
    
    _indexBuffer = [_device newBufferWithBytes:indices
                                        length:sizeof(indices)
                                       options:MTLResourceOptionCPUCacheModeDefault];
    _indexBuffer.label = @"Indices";
    
    _uniformBuffer = [_device newBufferWithLength:sizeof(MetalUniforms) * inFlightBufferCount
                                          options:MTLResourceOptionCPUCacheModeDefault];
    _uniformBuffer.label = @"Uniforms";
}

- (id<MTLRenderPipelineState>)createRenderPipelineStateWith:(MTLRenderPipelineDescriptor *)descriptor {
    NSError *error = nil;
    id<MTLRenderPipelineState> pipelineState = [_device newRenderPipelineStateWithDescriptor:descriptor error:&error];
    
    if (!pipelineState) {
        NSLog(@"Error occurred when creating render pipeline state: %@", error);
    }
    
    return pipelineState;
}

#pragma mark - MetalViewDelegate

- (void)drawInView:(MetalView *)view {
    dispatch_semaphore_wait(self.displaySemaphore, DISPATCH_TIME_FOREVER);
    
    [self updateUniformsForView:view duration:view.frameDuration];
    
    id<MTLCommandBuffer> commandBuffer = [self.commandQueue commandBuffer];
    
    MTLRenderPassDescriptor *passDescriptor = [view currentRenderPassDescriptor];
    
    id<MTLRenderCommandEncoder> renderPass = [self createRenderCommandEncoderWithCommandBuffer:commandBuffer
                                                                                 andDescriptor:passDescriptor];
    
    const NSUInteger uniformBufferOffset = sizeof(MetalUniforms) * self.bufferIndex;
    
    [renderPass setVertexBuffer:self.vertexBuffer offset:0 atIndex:0];
    [renderPass setVertexBuffer:self.uniformBuffer offset:uniformBufferOffset atIndex:1];
    
    [renderPass drawIndexedPrimitives:MTLPrimitiveTypeTriangle
                           indexCount:[self.indexBuffer length] / sizeof(MetalIndex)
                            indexType:MetalIndexType
                          indexBuffer:self.indexBuffer
                    indexBufferOffset:0];
    
    [renderPass endEncoding];
    
    [commandBuffer presentDrawable:view.currentDrawable];
    
    [commandBuffer addCompletedHandler:^(id<MTLCommandBuffer> commandBuffer) {
        self.bufferIndex = (self.bufferIndex + 1) % inFlightBufferCount;
        dispatch_semaphore_signal(self.displaySemaphore);
    }];
    
    [commandBuffer commit];
}

- (id<MTLRenderCommandEncoder>)createRenderCommandEncoderWithCommandBuffer:(id<MTLCommandBuffer>)buffer
                                                             andDescriptor:(MTLRenderPassDescriptor *)descriptor {
    
    id<MTLRenderCommandEncoder> renderCommandEncoder = [buffer renderCommandEncoderWithDescriptor:descriptor];
    [renderCommandEncoder setRenderPipelineState:_renderPipelineState];
    [renderCommandEncoder setDepthStencilState:_depthStencilState];
    [renderCommandEncoder setFrontFacingWinding:MTLWindingCounterClockwise];
    [renderCommandEncoder setCullMode:MTLCullModeBack];
    return renderCommandEncoder;
}

- (void)updateUniformsForView:(MetalView *)view duration:(NSTimeInterval)duration {
    self.time += duration;
    self.rotationX += duration * (M_PI / 2);
    self.rotationY += duration * (M_PI / 3);
    
    float scaleFactor = sinf(5 * self.time) * 0.25 + 1;
    
    const vector_float3 translation = { 0, 0, 0 };
    const vector_float3 xAxis = { 1, 0, 0 };
    const vector_float3 yAxis = { 0, 1, 0 };
    const matrix_float4x4 xRot = matrix_float4x4_rotation(xAxis, self.rotationX);
    const matrix_float4x4 yRot = matrix_float4x4_rotation(yAxis, self.rotationY);
    const matrix_float4x4 scale = matrix_float4x4_uniform_scale(scaleFactor);

    const matrix_float4x4 transMatrix = matrix_float4x4_translation(translation);
    const matrix_float4x4 rotMatrix = matrix_multiply(xRot, yRot);
    const matrix_float4x4 transRotMatrix = matrix_multiply(transMatrix, rotMatrix);
    
    const matrix_float4x4 modelMatrix = matrix_multiply(transRotMatrix, scale);
    
    const vector_float3 cameraTranslation = { 0, 0, -5 };
    const matrix_float4x4 viewMatrix = matrix_float4x4_translation(cameraTranslation);
    
    const CGSize drawableSize = view.metalLayer.drawableSize;
    const float aspect = drawableSize.width / drawableSize.height;
    const float fov = (2 * M_PI) / 5;
    const float near = 1;
    const float far = 100;
    const matrix_float4x4 projectionMatrix = matrix_float4x4_perspective(aspect, fov, near, far);
    
    MetalUniforms uniforms;
    uniforms.modelViewProjectionMatrix = matrix_multiply(projectionMatrix, matrix_multiply(viewMatrix, modelMatrix));
    
    const NSUInteger uniformBufferOffset = sizeof(MetalUniforms) * self.bufferIndex;
    memcpy([self.uniformBuffer contents] + uniformBufferOffset, &uniforms, sizeof(uniforms));
}

@end
