//
//  SliderStackView.h
//  DoFRendering
//
//  Created by Bartłomiej Nowak on 08/11/2018.
//  Copyright © 2018 Bartłomiej Nowak. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SliderStackViewModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface SliderStackView : UIStackView
@property (nonatomic) void (^onValueChange)(int, float);
-(void)setupWith:(SliderStackViewModel*)viewModel;
@end

NS_ASSUME_NONNULL_END
