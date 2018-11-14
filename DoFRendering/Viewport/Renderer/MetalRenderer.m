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
#import "PassDescriptorBuilder.h"
#import "DrawObjectsRenderPassEncoder.h"
#import "CircleOfConfusionPassEncoder.h"
#import "BokehPassEncoder.h"
#import "MetalRendererProperties.h"
#import "ViewProjectionUniforms.h"
#import "MathFunctions.h"
#import "ModelUniforms.h"
#import "ModelGroup.h"

// TODO: Encapsulate other rendering passes and move uniforms struct definitions to their own files

typedef struct {
    simd_float4 position, color;
} MetalVertex;

typedef struct {
    simd_bool isVertical;
    simd_float1 blurRadius;
    simd_float2 imageDimensions;
} GaussianBlurUniforms;

@interface MetalRenderer ()
@property (nonatomic, strong) id<MTLDevice> device;
@property (nonatomic, strong) id<MTLCommandQueue> commandQueue;
@property (nonatomic, strong) DrawObjectsRenderPassEncoder* drawObjectsEncoder;
@property (nonatomic, strong) CircleOfConfusionPassEncoder* cocEncoder;
@property (nonatomic, strong) BokehPassEncoder* bokehEncoder;
@property (nonatomic, strong) id<MTLTexture> colorTexture;
@property (nonatomic, strong) id<MTLTexture> depthTexture;
@property (nonatomic, strong) id<MTLTexture> cocTexture;
@property (nonatomic, strong) dispatch_semaphore_t displaySemaphore;
@property (nonatomic) MTLClearColor clearColor;
@property (assign) NSInteger currentTripleBufferingIndex;
@end

@implementation MetalRenderer

-(instancetype)initWithDevice:(id<MTLDevice>)device
           drawObjectsEncoder:(DrawObjectsRenderPassEncoder*)drawObjectsEncoder
                   cocEncoder:(CircleOfConfusionPassEncoder*)cocEncoder
                 bokehEncoder:(BokehPassEncoder*)bokehEncoder
{
    self = [super init];
    if (self) {
        self.device = device;
        self.commandQueue = [self.device newCommandQueue];
        self.drawObjectsEncoder = drawObjectsEncoder;
        self.cocEncoder = cocEncoder;
        self.bokehEncoder = bokehEncoder;
        self.displaySemaphore = dispatch_semaphore_create(inFlightBufferCount);
        self.clearColor = MTLClearColorMake(0.0, 0.0, 0.0, 1.0);
    }
    return self;
}

-(void)setFocusDistance:(float)focusDistance focusRange:(float)focusRange {
    [self.cocEncoder updateUniformsWithFocusDistance:focusDistance focusRange:focusRange];
}

-(void)drawToDrawable:(id<CAMetalDrawable>)drawable ofSize:(CGSize)drawableSize
{
    dispatch_semaphore_wait(self.displaySemaphore, DISPATCH_TIME_FOREVER);
    self.currentTripleBufferingIndex = (self.currentTripleBufferingIndex + 1) % inFlightBufferCount;
    id<MTLCommandBuffer> commandBuffer = [self.commandQueue commandBuffer];
    id<MTLCaptureScope> scope = [self makeCaptureScope];
    [scope beginScope];
    [self addSignalSemaphoreCompletedHandlerTo:commandBuffer];
    [self.drawObjectsEncoder encodeDrawModelGroup:_drawableModelGroup
                                  inCommandBuffer:commandBuffer
                               tripleBufferingIdx:(int)self.currentTripleBufferingIndex
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
                  outputTexture:drawable.texture
                   drawableSize:drawableSize
                     clearColor:self.clearColor];
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
    if (self.cocTexture.width != drawableSize.width || self.cocTexture.width != drawableSize.width) {
        self.cocTexture = [self readAndRenderTargetTextureOfSize:drawableSize format:MTLPixelFormatR8Snorm];
    }
}

-(id<MTLCaptureScope>)makeCaptureScope {
    id<MTLCaptureScope> scope = [[MTLCaptureManager sharedCaptureManager] newCaptureScopeWithDevice:self.device];
    scope.label = @"Capture Scope";
    return scope;
}

-(void)addSignalSemaphoreCompletedHandlerTo:(id<MTLCommandBuffer>)commandBuffer
{
    __weak dispatch_semaphore_t weakSemaphore = self.displaySemaphore;
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
