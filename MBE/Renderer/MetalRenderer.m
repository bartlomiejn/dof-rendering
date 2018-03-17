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
#import "OBJMesh.h"
#import "ShaderTypes.h"
@import Metal;
@import QuartzCore.CAMetalLayer;

typedef uint16_t MetalIndex;
const MTLIndexType MetalIndexType = MTLIndexTypeUInt16;

static const NSInteger inFlightBufferCount = 3;

@interface MetalRenderer ()
@property (strong) id<MTLDevice> device;
@property (strong) OBJMesh *mesh;
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
        [self setupUniformBuffer];
    }
    return self;
}

- (void)setupMeshFromOBJGroup:(OBJGroup*)group {
    _mesh = [[OBJMesh alloc] initWithGroup:group device:_device];
}

- (void)setupPipeline {
    _commandQueue = [_device newCommandQueue];
    
    id<MTLLibrary> library = [_device newDefaultLibrary];
    id<MTLFunction> vertexFunction = [library newFunctionWithName:@"vert_passthrough"];
    id<MTLFunction> fragFunction = [library newFunctionWithName:@"frag_passthrough"];
    
    MTLRenderPipelineDescriptor *descriptor = [MTLRenderPipelineDescriptor new];
    descriptor.vertexFunction = vertexFunction;
    descriptor.fragmentFunction = fragFunction;
    descriptor.colorAttachments[0].pixelFormat = MTLPixelFormatBGRA8Unorm;
    descriptor.depthAttachmentPixelFormat = MTLPixelFormatDepth32Float;
    _renderPipelineState = [self createRenderPipelineStateWith:descriptor];
    
    MTLDepthStencilDescriptor *depthStencilDescriptor = [MTLDepthStencilDescriptor new];
    depthStencilDescriptor.depthCompareFunction = MTLCompareFunctionLess;
    depthStencilDescriptor.depthWriteEnabled = YES;
    _depthStencilState = [_device newDepthStencilStateWithDescriptor:depthStencilDescriptor];
}

- (void)setupUniformBuffer {
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
    id<MTLRenderCommandEncoder> renderCommandEncoder = [commandBuffer renderCommandEncoderWithDescriptor:passDescriptor];
    [renderCommandEncoder setRenderPipelineState:_renderPipelineState];
    [renderCommandEncoder setDepthStencilState:_depthStencilState];
    [renderCommandEncoder setFrontFacingWinding:MTLWindingCounterClockwise];
    [renderCommandEncoder setCullMode:MTLCullModeBack];
    
    const NSUInteger uniformBufferOffset = sizeof(MetalUniforms) * self.bufferIndex;
    
    [renderCommandEncoder setVertexBuffer:self.mesh.vertexBuffer offset:0 atIndex:0];
    [renderCommandEncoder setVertexBuffer:self.uniformBuffer offset:uniformBufferOffset atIndex:1];
    [renderCommandEncoder drawIndexedPrimitives:MTLPrimitiveTypeTriangle
                                     indexCount:[self.mesh.indexBuffer length] / sizeof(MetalIndex)
                                      indexType:MetalIndexType
                                    indexBuffer:self.mesh.indexBuffer
                              indexBufferOffset:0];
    [renderCommandEncoder endEncoding];
    
    [commandBuffer presentDrawable:view.currentDrawable];
    [commandBuffer addCompletedHandler:^(id<MTLCommandBuffer> commandBuffer) {
        self.bufferIndex = (self.bufferIndex + 1) % inFlightBufferCount;
        dispatch_semaphore_signal(self.displaySemaphore);
    }];
    [commandBuffer commit];
}

- (void)updateUniformsForView:(MetalView *)view duration:(NSTimeInterval)duration {
    self.time += duration;
    self.rotationX += duration * (M_PI / 2);
    self.rotationY += duration * (M_PI / 3);
    
    float scaleFactor = sinf(5 * self.time) * 0.5 + 3;
    
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
