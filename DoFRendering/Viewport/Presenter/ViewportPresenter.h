//
//  ViewportPresenter.h
//  DoFRendering
//
//  Created by Bartłomiej Nowak on 08/11/2018.
//  Copyright © 2018 Bartłomiej Nowak. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ViewportViewProtocol.h"
#import "OBJMeshLoader.h"
#import "ModelTransformationBuilder.h"

NS_ASSUME_NONNULL_BEGIN

@interface ViewportPresenter : NSObject
@property (nonatomic, weak) id<ViewportViewProtocol> view;
-(instancetype)initWithMeshLoader:(OBJMeshLoader*)loader transformationBuilder:(ModelTransformationBuilder*)builder;
-(void)viewDidLoad;
-(void)sliderValueChangedFor:(int)idx with:(float)value;
-(void)willRenderNextFrameTo:(id<CAMetalDrawable>)drawable
                      ofSize:(CGSize)drawableSize
               frameDuration:(float)frameDuration;
@end

NS_ASSUME_NONNULL_END
