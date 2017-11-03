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
@property (readwrite) id<MTLDevice> device;
@end

@implementation MetalView

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
    [self makeDevice];
    [self makeBuffers];
}

- (void)makeDevice
{
    _device = MTLCreateSystemDefaultDevice();
    _metalLayer.device = _device;
    _metalLayer.pixelFormat = MTLPixelFormatBGRA8Unorm;
}

- (void)makeBuffers
{
    static const MetalVertex vertices[] =
    {
        { .position = { 0.0, 0.5, 0, 1 }, .color = { 1, 0, 0, 1 } },
        { .position = { -0.5, -0.5, 0, 1 }, .color = { 0, 1, 0, 1 } },
        { .position = { 0.5, -0.5, 0, 1 }, .color = { 0, 0, 1, 1 } }
    };
}

- (void)didMoveToWindow
{
    [self redraw];
}

- (void)redraw
{
    id<CAMetalDrawable> drawable = [_metalLayer nextDrawable];
    id<MTLTexture> texture = drawable.texture;
    
    MTLRenderPassDescriptor *passDescriptor = [MTLRenderPassDescriptor renderPassDescriptor];
    passDescriptor.colorAttachments[0].texture = texture;
    passDescriptor.colorAttachments[0].loadAction = MTLLoadActionClear;
    passDescriptor.colorAttachments[0].storeAction = MTLStoreActionStore;
    passDescriptor.colorAttachments[0].clearColor = MTLClearColorMake(1.0, 0.0, 0.0, 1.0);
    
    id<MTLCommandQueue> queue = [_device newCommandQueue];
    id<MTLCommandBuffer> buffer = [queue commandBuffer];
    id<MTLRenderCommandEncoder> encoder = [buffer renderCommandEncoderWithDescriptor:passDescriptor];
    [encoder endEncoding];
    
    [buffer presentDrawable:drawable];
    [buffer commit];
}

@end
