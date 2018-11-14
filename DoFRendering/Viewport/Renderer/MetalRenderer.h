//
//  MetalRenderer.h
//  DoFRendering
//
//  Created by Bartłomiej Nowak on 15/11/2017.
//  Copyright © 2017 Bartłomiej Nowak. All rights reserved.
//

@import Foundation;
#import "MetalView.h"
#import "PassDescriptorBuilder.h"
#import "DrawObjectsRenderPassEncoder.h"
#import "CircleOfConfusionPassEncoder.h"
#import "BokehPassEncoder.h"
#import "ModelGroup.h"

@interface MetalRenderer : NSObject
@property (nonatomic) MTLPixelFormat colorPixelFormat;
@property (nonatomic, strong) ModelGroup *drawableModelGroup;
-(instancetype)initWithDevice:(id<MTLDevice>)device
           drawObjectsEncoder:(DrawObjectsRenderPassEncoder*)drawObjectsEncoder
                   cocEncoder:(CircleOfConfusionPassEncoder*)cocEncoder
                 bokehEncoder:(BokehPassEncoder*)bokehEncoder;
-(void)setFocusDistance:(float)focusDistance focusRange:(float)focusRange;
-(void)drawToDrawable:(id<CAMetalDrawable>)drawable ofSize:(CGSize)drawableSize;
-(void)adjustedDrawableSize:(CGSize)drawableSize;
@end
