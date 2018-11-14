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
#import "DrawObjectsPassEncoder.h"
#import "CircleOfConfusionPassEncoder.h"
#import "BokehPassEncoder.h"
#import "PostFilterPassEncoder.h"
#import "ModelGroup.h"

@interface MetalRenderer : NSObject
@property (nonatomic) MTLPixelFormat colorPixelFormat;
@property (nonatomic, strong) ModelGroup *drawableModelGroup;
-(instancetype)initWithDevice:(id<MTLDevice>)device
           drawObjectsEncoder:(DrawObjectsPassEncoder*)drawObjectsEncoder
                   cocEncoder:(CircleOfConfusionPassEncoder*)cocEncoder
                 bokehEncoder:(BokehPassEncoder*)bokehEncoder
            postFilterEncoder:(PostFilterPassEncoder*)postFilterEncoder;
-(void)setFocusDistance:(float)focusDistance focusRange:(float)focusRange;
-(void)drawToDrawable:(id<CAMetalDrawable>)drawable ofSize:(CGSize)drawableSize;
-(void)adjustedDrawableSize:(CGSize)drawableSize;
@end
