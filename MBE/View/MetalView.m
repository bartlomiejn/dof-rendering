//
//  MetalView.m
//  MBE
//
//  Created by Bartłomiej Nowak on 03/11/2017.
//  Copyright © 2017 Bartłomiej Nowak. All rights reserved.
//
//  Includes code taken from Metal By Example book repository at: https://github.com/metal-by-example/sample-code
//

#import "MetalView.h"
#import "MathFunctions.h"

@interface MetalView ()
@property (assign) NSTimeInterval frameDuration;
@property (strong) id<CAMetalDrawable> currentDrawable;
@property (strong) id<MTLTexture> depthTexture;
@property (nonatomic, strong) CADisplayLink* displayLink;
@end

@implementation MetalView

#pragma mark - Layer

+ (id)layerClass {
    return [CAMetalLayer class];
}

#pragma mark - Getter/Setter

- (MTLPixelFormat)colorPixelFormat {
    return _metalLayer.pixelFormat;
}

- (void)setColorPixelFormat:(MTLPixelFormat)colorPixelFormat {
    _metalLayer.pixelFormat = colorPixelFormat;
}

- (NSInteger)preferredFramesPerSecond {
    return _displayLink.preferredFramesPerSecond;
}

- (void)setPreferredFramesPerSecond:(NSInteger)preferredFramesPerSecond {
    _displayLink.preferredFramesPerSecond = preferredFramesPerSecond;
}

- (MTLRenderPassDescriptor *)currentRenderPassDescriptor
{
    MTLRenderPassDescriptor *passDescriptor = [MTLRenderPassDescriptor renderPassDescriptor];
    
    passDescriptor.colorAttachments[0].texture = [self.currentDrawable texture];
    passDescriptor.colorAttachments[0].clearColor = self.clearColor;
    passDescriptor.colorAttachments[0].storeAction = MTLStoreActionStore;
    passDescriptor.colorAttachments[0].loadAction = MTLLoadActionClear;
    
    passDescriptor.depthAttachment.texture = self.depthTexture;
    passDescriptor.depthAttachment.clearDepth = 1.0;
    passDescriptor.depthAttachment.loadAction = MTLLoadActionClear;
    passDescriptor.depthAttachment.storeAction = MTLStoreActionDontCare;
    
    passDescriptor.renderTargetWidth = self.metalLayer.drawableSize.width;
    passDescriptor.renderTargetHeight = self.metalLayer.drawableSize.height;
    
    return passDescriptor;
}

#pragma mark - Initialization

- (instancetype)initWithDevice:(id<MTLDevice>)device {
    self = [super init];
    if (self) {
        _metalLayer = (CAMetalLayer *)self.layer;
        _metalLayer.device = device;
        _clearColor = MTLClearColorMake(1.0, 1.0, 1.0, 1.0);
        self.preferredFramesPerSecond = 60;
    }
    return self;
}

#pragma mark - UIView

- (void)didMoveToSuperview {
    [super didMoveToSuperview];
    
    if (self.superview) {
        [self setupDisplayLink];
    } else {
        [self removeDisplayLink];
    }
}

- (void)setFrame:(CGRect)frame
{
    [super setFrame:frame];
    
    // During the first layout pass, we will not be in a view hierarchy, so we guess our scale
    CGFloat scale = [UIScreen mainScreen].scale;
    
    // If we've moved to a window by the time our frame is being set, we can take its scale as our own
    if (self.window) {
        scale = self.window.screen.scale;
    }
    
    CGSize drawableSize = self.bounds.size;
    
    // Since drawable size is in pixels, we need to multiply by the scale to move from points to pixels
    drawableSize.width *= scale;
    drawableSize.height *= scale;
    
    self.metalLayer.drawableSize = drawableSize;
    
    [self makeDepthTexture];
}

- (void)setupDisplayLink {
    _displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(displayLinkDidFire:)];
    [_displayLink addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSRunLoopCommonModes];
}

- (void)removeDisplayLink {
    [_displayLink invalidate];
    _displayLink = nil;
}

- (void)makeDepthTexture {
    CGSize drawableSize = self.metalLayer.drawableSize;
    
    if ([self.depthTexture width] != drawableSize.width || [self.depthTexture height] != drawableSize.height) {
        MTLTextureDescriptor *desc = [MTLTextureDescriptor texture2DDescriptorWithPixelFormat:MTLPixelFormatDepth32Float
                                                                                        width:drawableSize.width
                                                                                       height:drawableSize.height
                                                                                    mipmapped:NO];
        desc.usage = MTLTextureUsageRenderTarget;
        
        self.depthTexture = [self.metalLayer.device newTextureWithDescriptor:desc];
    }
}

#pragma mark - CADisplayLink Action

- (void)displayLinkDidFire:(CADisplayLink *)displayLink {
    _currentDrawable = [_metalLayer nextDrawable];
    _frameDuration = displayLink.duration;
    
    if ([self.delegate respondsToSelector:@selector(drawInView:)]) {
        [self.delegate drawInView:self];
    }
}

@end
