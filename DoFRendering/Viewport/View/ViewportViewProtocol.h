//
//  ViewportViewProtocol.h
//  DoFRendering
//
//  Created by Bartłomiej Nowak on 08/11/2018.
//  Copyright © 2018 Bartłomiej Nowak. All rights reserved.
//

#ifndef ViewportViewProtocol_h
#define ViewportViewProtocol_h

#import "SliderStackViewModel.h"
#import "ModelGroup.h"

@protocol ViewportViewProtocol <NSObject>
- (void)presentSliders:(SliderStackViewModel*)viewModel;
- (void)drawModelGroup:(ModelGroup*)modelGroup;
- (void)setDrawBokehRadius:(float)bokehRadius;
- (void)setDrawFocusDistance:(float)focusDistance focusRange:(float)focusRange;
- (void)drawNextFrameTo:(id<CAMetalDrawable>)drawable ofSize:(CGSize)drawableSize;
@end

#endif /* ViewportViewProtocol_h */
