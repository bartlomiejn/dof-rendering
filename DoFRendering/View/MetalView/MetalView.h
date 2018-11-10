//
//  MetalView.h
//  MBE
//
//  Created by Bartłomiej Nowak on 03/11/2017.
//  Copyright © 2017 Bartłomiej Nowak. All rights reserved.
//

@import UIKit;
@import Metal;
@import MetalKit;
@import QuartzCore.CAMetalLayer;
#import "MetalViewDelegate.h"

@protocol MetalViewDelegate;

@interface MetalView : UIView
@property (nonatomic, weak) id<MetalViewDelegate> delegate;
@property (nonatomic, readonly) CAMetalLayer* metalLayer;
@property (nonatomic, assign) MTLClearColor clearColor;
@property (nonatomic) MTLPixelFormat colorPixelFormat;
@property (nonatomic) NSInteger preferredFramesPerSecond;
/**
 Render pass descriptor configured to use the current drawable's texture as
 primary color attachment and internal depth texture of same size as its depth
 attachment texture.
 */
@property (nonatomic, readonly) MTLRenderPassDescriptor *currentRenderPassDescriptor;
/**
 The duration (in seconds) of the previous frame. Valid only in drawInView: method.
 */
@property (nonatomic, readonly) NSTimeInterval frameDuration;
/**
 The view's layer's current drawable. Valid only in drawInView: method.
 */
@property (nonatomic, readonly) id<CAMetalDrawable> currentDrawable;
- (instancetype)initWithDevice:(id<MTLDevice>)device;
@end
