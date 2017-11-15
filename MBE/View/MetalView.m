//
//  MetalView.m
//  MBE
//
//  Created by Bartłomiej Nowak on 03/11/2017.
//  Copyright © 2017 Bartłomiej Nowak. All rights reserved.
//

#import "MetalView.h"
#import "MathFunctions.h"

typedef struct
{
    vector_float4 position;
    vector_float4 color;
} MetalVertex;

typedef uint16_t MetalIndex;
const MTLIndexType MetalIndexType = MTLIndexTypeUInt16;

@interface MetalView ()
@property (strong) id<MTLDevice> device;
@property (strong) id<MTLCommandQueue> commandQueue;
@property (strong) id<MTLRenderPipelineState> pipelineState;
@property (strong) id<CAMetalDrawable> currentDrawable;
@property (strong) id<MTLBuffer> cubeVertexBuffer;
@property (strong) id<MTLBuffer> cubeIndexBuffer;

@property (assign) float time, rotationX, rotationY;

@property (readonly) CAMetalLayer* metalLayer;
@property (strong) CADisplayLink* displayLink;
@end

@implementation MetalView

#pragma mark - UIView

+ (id)layerClass {
    return [CAMetalLayer class];
}

- (instancetype)init {
    self = [super init];
    if (self) {
        [self setup];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)coder {
    self = [super initWithCoder:coder];
    if (self) {
        [self setup];
    }
    return self;
}

- (void)didMoveToSuperview {
    [super didMoveToSuperview];
    
    if (self.superview)
    {
        _displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(displayLinkDidFire:)];
        [_displayLink addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSRunLoopCommonModes];
    }
    else
    {
        [_displayLink invalidate];
        _displayLink = nil;
    }
    
}

#pragma mark - CADisplayLink Action

- (void)displayLinkDidFire:(CADisplayLink *)link {
    [self redraw];
}

- (void)redraw {
    _currentDrawable = [_metalLayer nextDrawable];
    
    MTLRenderPassDescriptor *passDescriptor = [self passDescriptorWithOutputTexture:_currentDrawable.texture];
    
    id<MTLCommandBuffer> buffer = [_commandQueue commandBuffer];
    id<MTLRenderCommandEncoder> commandEncoder = [buffer renderCommandEncoderWithDescriptor:passDescriptor];
    
    [commandEncoder setRenderPipelineState:_pipelineState];
    [commandEncoder setVertexBuffer:_cubeVertexBuffer offset:0 atIndex:0];
    [commandEncoder drawPrimitives:MTLPrimitiveTypeTriangle vertexStart:0 vertexCount:3];
    [commandEncoder endEncoding];
    
    [buffer presentDrawable:_currentDrawable];
    [buffer commit];
}

#pragma mark - Auxiliary

- (void)setup {
    _metalLayer = (CAMetalLayer *)self.layer;
    
    [self setupDevice];
    [self setupBuffers];
    [self setupPipeline];
}

- (void)setupDevice {
    _device = MTLCreateSystemDefaultDevice();
    _commandQueue = [_device newCommandQueue];
    
    _metalLayer.device = _device;
    _metalLayer.pixelFormat = MTLPixelFormatBGRA8Unorm;
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
    
    _cubeVertexBuffer = [_device newBufferWithBytes:vertices
                                         length:sizeof(vertices)
                                        options:MTLResourceOptionCPUCacheModeDefault];
    _cubeIndexBuffer = [_device newBufferWithBytes:indices
                                         length:sizeof(indices)
                                        options:MTLResourceOptionCPUCacheModeDefault];
}

- (void)setupPipeline {
    id<MTLLibrary> library = [_device newDefaultLibrary];
    id<MTLFunction> vertexFunction = [library newFunctionWithName:@"vert_passthrough"];
    id<MTLFunction> fragFunction = [library newFunctionWithName:@"frag_passthrough"];
    
    MTLRenderPipelineDescriptor *descriptor = [self pipelineDescriptorWithVertexFunction:vertexFunction
                                                                        fragmentFunction:fragFunction
                                                                             pixelFormat:_metalLayer.pixelFormat];
    
    _pipelineState = [_device newRenderPipelineStateWithDescriptor:descriptor error:nil];
}

/**
 * Encodes graphics state for a configured graphics rendering pipeline, to use with MTLRenderCommandEncoder to encode
 * commands for a rendering pass. Should be set before any draw calls.
 */
- (MTLRenderPipelineDescriptor *)pipelineDescriptorWithVertexFunction:(id<MTLFunction>)vertexFunction
                                                     fragmentFunction:(id<MTLFunction>)fragmentFunction
                                                          pixelFormat:(MTLPixelFormat)format {
    
    MTLRenderPipelineDescriptor *pipelineDescriptor = [MTLRenderPipelineDescriptor new];
    pipelineDescriptor.vertexFunction = vertexFunction;
    pipelineDescriptor.fragmentFunction = fragmentFunction;
    pipelineDescriptor.colorAttachments[0].pixelFormat = format;
    return pipelineDescriptor;
}

/**
 * Group of render targets that serve as the output destination for pixels generated by a render pass.
 */
- (MTLRenderPassDescriptor *)passDescriptorWithOutputTexture:(id<MTLTexture>)texture {
    MTLRenderPassDescriptor *descriptor = [MTLRenderPassDescriptor renderPassDescriptor];
    descriptor.colorAttachments[0].texture = texture;
    descriptor.colorAttachments[0].clearColor = MTLClearColorMake(0.85, 0.85, 0.85, 1.0);
    descriptor.colorAttachments[0].loadAction = MTLLoadActionClear;
    descriptor.colorAttachments[0].storeAction = MTLStoreActionStore;
    return descriptor;
}

- (matrix_float4x4)worldTransformation {
    float scaleFactor = sinf(5 * _time) * 0.25 + 1;
    
    vector_float3 xAxis = { 1, 0, 0 };
    vector_float3 yAxis = { 0, 1, 0 };
    
    matrix_float4x4 xRot = matrix_float4x4_rotation(xAxis, _rotationX);
    matrix_float4x4 yRot = matrix_float4x4_rotation(yAxis, _rotationY);
    
    matrix_float4x4 scale = matrix_float4x4_uniform_scale(scaleFactor);
    
    matrix_float4x4 modelMatrix = matrix_multiply(matrix_multiply(xRot, yRot), scale);
    
    return modelMatrix;
}

@end
