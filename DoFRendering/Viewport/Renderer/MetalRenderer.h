//
//  MetalRenderer.h
//  MBE
//
//  Created by Bartłomiej Nowak on 15/11/2017.
//  Copyright © 2017 Bartłomiej Nowak. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MetalView.h"
#import "Model.h"

@interface MetalRenderer : NSObject
@property (nonatomic) MTLPixelFormat colorPixelFormat;
@property (nonatomic, strong) NSArray<Model*> *drawedModels;
- (instancetype)initWithDevice:(id<MTLDevice>)device;
-(void)drawToDrawable:(id<CAMetalDrawable>)drawable ofSize:(CGSize)drawableSize;
-(void)adjustedDrawableSize:(CGSize)drawableSize;
@end
