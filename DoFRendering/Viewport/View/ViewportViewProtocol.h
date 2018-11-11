//
//  ViewportViewProtocol.h
//  MBE
//
//  Created by Bartłomiej Nowak on 08/11/2018.
//  Copyright © 2018 Bartłomiej Nowak. All rights reserved.
//

#ifndef ViewportViewProtocol_h
#define ViewportViewProtocol_h

#import "SliderStackViewModel.h"
#import "TeapotModel.h"

@protocol ViewportViewProtocol <NSObject>
- (void)presentSliders:(SliderStackViewModel*)viewModel;
- (void)presentModels:(NSArray<Model*>*)models;
- (void)drawNextFrameTo:(id<CAMetalDrawable>)drawable ofSize:(CGSize)drawableSize;
@end

#endif /* ViewportViewProtocol_h */
