//
//  MetalView.m
//  MBE
//
//  Created by Bartłomiej Nowak on 03/11/2017.
//  Copyright © 2017 Bartłomiej Nowak. All rights reserved.
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
    
    CGFloat scale = [UIScreen mainScreen].scale;
    if (self.window) {
        scale = self.window.screen.scale;
    }
    
    // Drawable size is in pixels
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
    
    if ([self.delegate respondsToSelector:@selector(drawInView:)]) {
        [self.delegate drawInView:self
                  currentDrawable:currentDrawable
                     drawableSize:_metalLayer.drawableSize
                    frameDuration:_frameDuration];
    }
}

@end
