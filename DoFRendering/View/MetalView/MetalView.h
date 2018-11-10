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

@interface MetalView : UIView
@property (nonatomic, weak) id<MetalViewDelegate> delegate;
@property (nonatomic, readonly) CAMetalLayer* metalLayer;
@property (nonatomic) MTLPixelFormat colorPixelFormat;
@property (nonatomic) NSInteger preferredFramesPerSecond;
@property (nonatomic, readonly) MTLRenderPassDescriptor *currentRenderPassDescriptor;
/// The duration (in seconds) of the previous frame. Valid only in drawInView: method.
@property (nonatomic, readonly) NSTimeInterval frameDuration;
/// The view's layer's current drawable. Valid only in drawInView: method.
@property (nonatomic, readonly) id<CAMetalDrawable> currentDrawable;
- (instancetype)initWithDevice:(id<MTLDevice>)device;
@end
