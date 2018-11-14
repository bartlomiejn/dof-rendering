//
//  MetalRenderer.m
//  DoFRendering
//
//  Created by Bartłomiej Nowak on 15/11/2017.
//  Copyright © 2017 Bartłomiej Nowak. All rights reserved.
//

@import simd;
@import SpriteKit;
@import Metal;
@import QuartzCore.CAMetalLayer;
#import "MetalRenderer.h"
#import "MetalRendererProperties.h"
#import "DrawObjectsPassEncoder.h"
#import "CircleOfConfusionPassEncoder.h"
#import "BokehPassEncoder.h"
#import "PostFilterPassEncoder.h"
#import "ModelGroup.h"

@interface MetalRenderer ()
@property (nonatomic, strong) id<MTLDevice> device;
@property (nonatomic, strong) id<MTLCommandQueue> commandQueue;
@property (nonatomic, strong) DrawObjectsPassEncoder* drawObjectsEncoder;
@property (nonatomic, strong) CircleOfConfusionPassEncoder* cocEncoder;
@property (nonatomic, strong) BokehPassEncoder* bokehEncoder;
@property (nonatomic, strong) PostFilterPassEncoder* postFilterEncoder;
@property (nonatomic, strong) id<MTLTexture> colorTexture;
@property (nonatomic, strong) id<MTLTexture> depthTexture;
@property (nonatomic, strong) id<MTLTexture> cocTexture;
@property (nonatomic, strong) id<MTLTexture> bokehTexture;
@property (nonatomic, strong) dispatch_semaphore_t tripleBufferSemaphore;
@property (assign) NSInteger currentTripleBufferIndex;
@property (nonatomic) MTLClearColor clearColor;
@property (nonatomic) CGSize lastDrawableSize;
@end

@implementation MetalRenderer

-(instancetype)initWithDevice:(id<MTLDevice>)device
           drawObjectsEncoder:(DrawObjectsPassEncoder*)drawObjectsEncoder
                   cocEncoder:(CircleOfConfusionPassEncoder*)cocEncoder
                 bokehEncoder:(BokehPassEncoder*)bokehEncoder
            postFilterEncoder:(PostFilterPassEncoder*)postFilterEncoder
{
    self = [super init];
    if (self) {
        self.device = device;
        self.commandQueue = [self.device newCommandQueue];
        self.drawObjectsEncoder = drawObjectsEncoder;
        self.cocEncoder = cocEncoder;
        self.bokehEncoder = bokehEncoder;
        self.postFilterEncoder = postFilterEncoder;
        self.tripleBufferSemaphore = dispatch_semaphore_create(inFlightBufferCount);
        self.clearColor = MTLClearColorMake(0.0, 0.0, 0.0, 1.0);
    }
    return self;
}

-(void)setBokehRadius:(float)bokehRadius
{
    [self.bokehEncoder updateBokehRadius:bokehRadius];
}

-(void)setFocusDistance:(float)focusDistance focusRange:(float)focusRange {
    [self.cocEncoder updateUniformsWithFocusDistance:focusDistance focusRange:focusRange];
}

-(void)drawToDrawable:(id<CAMetalDrawable>)drawable ofSize:(CGSize)drawableSize
{
    dispatch_semaphore_wait(self.tripleBufferSemaphore, DISPATCH_TIME_FOREVER);
    self.currentTripleBufferIndex = (self.currentTripleBufferIndex + 1) % inFlightBufferCount;
    id<MTLCommandBuffer> commandBuffer = [self.commandQueue commandBuffer];
    id<MTLCaptureScope> scope = [self makeCaptureScope];
    [scope beginScope];
    [self addSignalSemaphoreCompletedHandlerTo:commandBuffer];
    [self.drawObjectsEncoder encodeDrawModelGroup:_drawableModelGroup
                                  inCommandBuffer:commandBuffer
                               tripleBufferingIdx:(int)self.currentTripleBufferIndex
                                   outputColorTex:self.colorTexture
                                   outputDepthTex:self.depthTexture
                                cameraTranslation:(vector_float3){ 0.0f, 0.0f, -5.0f }
                                       drawableSz:drawableSize
                                       clearColor:self.clearColor];
    [self.cocEncoder encodeIn:commandBuffer
            inputDepthTexture:self.depthTexture
                outputTexture:self.cocTexture
                 drawableSize:drawableSize
                   clearColor:self.clearColor];
    [self.bokehEncoder encodeIn:commandBuffer
              inputColorTexture:self.colorTexture
                  outputTexture:self.bokehTexture
                   drawableSize:drawableSize
                     clearColor:self.clearColor];
    [self.postFilterEncoder encodeIn:commandBuffer
                   inputColorTexture:self.bokehTexture
                       outputTexture:drawable.texture
                        drawableSize:drawableSize
                          clearColor:self.clearColor];
    [commandBuffer presentDrawable:drawable];
    [scope endScope];
    [commandBuffer commit];
}

-(void)adjustedDrawableSize:(CGSize)drawableSize
{
    if (self.lastDrawableSize.width != drawableSize.width || self.lastDrawableSize.height != drawableSize.height) {
        self.colorTexture = [self readAndRenderTargetTextureOfSize:drawableSize format:MTLPixelFormatBGRA8Unorm];
        self.depthTexture = [self readAndRenderTargetTextureOfSize:drawableSize format:MTLPixelFormatDepth32Float];
        self.cocTexture = [self readAndRenderTargetTextureOfSize:drawableSize format:MTLPixelFormatR8Snorm];
        self.bokehTexture = [self readAndRenderTargetTextureOfSize:CGSizeMake(drawableSize.width / 2.0,
                                                                              drawableSize.height / 2.0)
                                                            format:MTLPixelFormatBGRA8Unorm];
    }
    self.lastDrawableSize = drawableSize;
}

-(id<MTLCaptureScope>)makeCaptureScope
{
    id<MTLCaptureScope> scope = [[MTLCaptureManager sharedCaptureManager] newCaptureScopeWithDevice:self.device];
    scope.label = @"Capture Scope";
    return scope;
}

-(void)addSignalSemaphoreCompletedHandlerTo:(id<MTLCommandBuffer>)commandBuffer
{
    __weak dispatch_semaphore_t weakSemaphore = self.tripleBufferSemaphore;
    [commandBuffer addCompletedHandler:^(id<MTLCommandBuffer> commandBuffer) {
        dispatch_semaphore_signal(weakSemaphore);
        if (commandBuffer.error) {
            NSLog(@"Frame finished with error: %@", commandBuffer.error);
        }
    }];
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
