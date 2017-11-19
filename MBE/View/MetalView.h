//
//  MetalView.h
//  MBE
//
//  Created by Bartłomiej Nowak on 03/11/2017.
//  Copyright © 2017 Bartłomiej Nowak. All rights reserved.
//
//  Includes code taken from Metal By Example book repository at: https://github.com/metal-by-example/sample-code
//

@import UIKit;
@import Metal;
@import MetalKit;
@import QuartzCore.CAMetalLayer;

@protocol MetalViewDelegate;

@interface MetalView : UIView

#pragma mark - Public properties

@property (nonatomic, weak) id<MetalViewDelegate> delegate;

@property (nonatomic, readonly) CAMetalLayer *metalLayer;

@property (nonatomic, assign) MTLClearColor clearColor;
@property (nonatomic) MTLPixelFormat colorPixelFormat;
@property (nonatomic) NSInteger preferredFramesPerSecond;

/// Render pass descriptor configured to use the current drawable's texture as primary color attachment and internal
/// depth texture of same size as its depth attachment texture.
@property (nonatomic, readonly) MTLRenderPassDescriptor *currentRenderPassDescriptor;

#pragma mark - Valid only in drawInView delegate method

/// The duration (in seconds) of the previous frame.
@property (nonatomic, readonly) NSTimeInterval frameDuration;
/// The view's layer's current drawable.
@property (nonatomic, readonly) id<CAMetalDrawable> currentDrawable;

@end

@protocol MetalViewDelegate <NSObject>
/// This method is called once per frame. Within the method, you may access
/// any of the properties of the view and request the current render pass
/// descriptor to get a descriptor configured with renderable color and depth
/// textures.
- (void)drawInView:(MetalView *)view;
@end
