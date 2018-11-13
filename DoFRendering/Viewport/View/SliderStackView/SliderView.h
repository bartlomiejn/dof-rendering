//
//  SliderView.h
//  DoFRendering
//
//  Created by Bartłomiej Nowak on 08/11/2018.
//  Copyright © 2018 Bartłomiej Nowak. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SliderViewModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface SliderView : UIView
@property (weak, nonatomic) IBOutlet UILabel *parameterNameLabel;
@property (weak, nonatomic) IBOutlet UISlider *slider;
@property (nonatomic) void (^onValueChange)(float);
-(void)setupWith:(SliderViewModel*)viewModel;
@end

NS_ASSUME_NONNULL_END
