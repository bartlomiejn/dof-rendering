//
//  MetalView.m
//  MBE
//
//  Created by Bartłomiej Nowak on 03/11/2017.
//  Copyright © 2017 Bartłomiej Nowak. All rights reserved.
//

#import "MetalView.h"

typedef struct
{
    vector_float4 position;
    vector_float4 color;
} MetalVertex;

@interface MetalView ()
@property (readonly) CAMetalLayer *metalLayer;
@property (strong) id<MTLDevice> device;
@property (strong) id<MTLBuffer> vertexBuffer;
@property (strong) id<MTLRenderPipelineState> pipelineState;
@property (strong) CADisplayLink *displayLink;
@end

@implementation MetalView

static const MetalVertex vertices[] =
{
    { .position = { 0.0, 0.5, 0, 1 },   .color = { 1, 0, 0, 1 } },
    { .position = { -0.5, -0.5, 0, 1 }, .color = { 0, 1, 0, 1 } },
    { .position = { 0.5, -0.5, 0, 1 },  .color = { 0, 0, 1, 1 } }
};

+ (id)layerClass
{
    return [CAMetalLayer class];
}

- (instancetype)init
{
    self = [super init];
    if (self)
    {
        [self setup];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self)
    {
        [self setup];
    }
    return self;
}

- (void)setup
{
    _metalLayer = (CAMetalLayer *)self.layer;
    [self setupDevice];
    [self setupBuffers];
    [self setupPipeline];
}

- (void)setupDevice
{
    _device = MTLCreateSystemDefaultDevice();
    _metalLayer.device = _device;
    _metalLayer.pixelFormat = MTLPixelFormatBGRA8Unorm;
}

- (void)setupBuffers
{
    _vertexBuffer = [_device newBufferWithBytes:vertices
                                         length:sizeof(vertices)
                                        options:MTLResourceOptionCPUCacheModeDefault];
}

- (void)setupPipeline
{
    id<MTLLibrary> library = [_device newDefaultLibrary];
    
    id<MTLFunction> vertexFunc = [library newFunctionWithName:@"vert_passthrough"];
    id<MTLFunction> fragFunc = [library newFunctionWithName:@"frag_passthrough"];
    
    MTLRenderPipelineDescriptor *pipelineDescriptor = [MTLRenderPipelineDescriptor new];
    pipelineDescriptor.vertexFunction = vertexFunc;
    pipelineDescriptor.fragmentFunction = fragFunc;
    pipelineDescriptor.colorAttachments[0].pixelFormat = _metalLayer.pixelFormat;
    
    _pipelineState = [_device newRenderPipelineStateWithDescriptor:pipelineDescriptor error:nil];
}

- (void)didMoveToSuperview
{
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

- (void)redraw
{
    id<CAMetalDrawable> drawable = [_metalLayer nextDrawable];
    id<MTLTexture> frameBufferTexture = drawable.texture;
    
    MTLRenderPassDescriptor *passDescriptor = [MTLRenderPassDescriptor renderPassDescriptor];
    passDescriptor.colorAttachments[0].texture = frameBufferTexture;
    passDescriptor.colorAttachments[0].clearColor = MTLClearColorMake(0.85, 0.85, 0.85, 1.0);
    passDescriptor.colorAttachments[0].loadAction = MTLLoadActionClear;
    passDescriptor.colorAttachments[0].storeAction = MTLStoreActionStore;
    
    id<MTLCommandQueue> queue = [_device newCommandQueue];
    id<MTLCommandBuffer> buffer = [queue commandBuffer];
    id<MTLRenderCommandEncoder> commandEncoder = [buffer renderCommandEncoderWithDescriptor:passDescriptor];
    [commandEncoder setRenderPipelineState:_pipelineState];
    [commandEncoder setVertexBuffer:_vertexBuffer offset:0 atIndex:0];
    [commandEncoder drawPrimitives:MTLPrimitiveTypeTriangle vertexStart:0 vertexCount:3];
    [commandEncoder endEncoding];
    
    [buffer presentDrawable:drawable];
    [buffer commit];
}

- (void)displayLinkDidFire:(CADisplayLink *)link
{
    [self redraw];
}

@end
