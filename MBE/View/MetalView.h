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
@import CoreGraphics;

@protocol MetalViewDelegate;

@interface MetalView : UIView
@property (nonatomic, weak) id<MetalViewDelegate> delegate;
@property (nonatomic, readonly) CAMetalLayer *metalLayer;

@property (nonatomic) NSInteger preferredFramesPerSecond;


@end

@protocol MetalViewDelegate <NSObject>
/// This method is called once per frame. Within the method, you may access
/// any of the properties of the view, and request the current render pass
/// descriptor to get a descriptor configured with renderable color and depth
/// textures.
- (void)drawInView:(MetalView *)view;
@end
