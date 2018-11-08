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
@property (nonatomic, strong) CADisplayLink* displayLink;
@end

@implementation MetalView

+ (id)layerClass {
    return [CAMetalLayer class];
}

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

- (instancetype)initWithDevice:(id<MTLDevice>)device {
    self = [super init];
    if (self) {
        _metalLayer = (CAMetalLayer *)self.layer;
        _metalLayer.device = device;
        _clearColor = MTLClearColorMake(0.0, 0.0, 0.0, 1.0);
        self.preferredFramesPerSecond = 60;
    }
    return self;
}

- (void)didMoveToSuperview {
    [super didMoveToSuperview];
    
    if (self.superview) {
        [self setupDisplayLink];
    } else {
        [self removeDisplayLink];
    }
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    // During the first layout pass, we will not be in a view hierarchy, so we take the screen scale
    // If we've moved to a window by the time our frame is being set, we can take its scale as our own
    CGFloat scale = [UIScreen mainScreen].scale;
    if (self.window) {
        scale = self.window.screen.scale;
    }
    
    // Since drawable size is in pixels, we need to multiply by the scale to move from points to pixels
    CGSize drawableSize = self.bounds.size;
    drawableSize.width *= scale;
    drawableSize.height *= scale;
    
    self.metalLayer.drawableSize = drawableSize;
    
    if ([_delegate respondsToSelector:@selector(frameAdjustedForView:)])
        [self.delegate frameAdjustedForView:self];
}

- (void)setupDisplayLink {
    _displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(displayLinkDidFire:)];
    [_displayLink addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSRunLoopCommonModes];
}

- (void)removeDisplayLink {
    [_displayLink invalidate];
    _displayLink = nil;
}

- (void)displayLinkDidFire:(CADisplayLink *)displayLink {
    _currentDrawable = [_metalLayer nextDrawable];
    _frameDuration = displayLink.duration;
    
    if ([self.delegate respondsToSelector:@selector(drawInView:)])
        [self.delegate drawInView:self];
}

@end
