//
//  ViewportPresenter.h
//  MBE
//
//  Created by Bartłomiej Nowak on 08/11/2018.
//  Copyright © 2018 Bartłomiej Nowak. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ViewportViewProtocol.h"

NS_ASSUME_NONNULL_BEGIN

@interface ViewportPresenter : NSObject
@property (nonatomic, weak) id<ViewportViewProtocol> view;
-(void)viewDidLoad;
-(void)sliderValueChangedFor:(int)idx with:(float)value;
-(void)willRenderNextFrameWithDuration:(float)frameDuration;
@end

NS_ASSUME_NONNULL_END
