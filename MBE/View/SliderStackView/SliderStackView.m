//
//  SliderStackView.m
//  MBE
//
//  Created by Bartłomiej Nowak on 08/11/2018.
//  Copyright © 2018 Bartłomiej Nowak. All rights reserved.
//

#import "SliderStackView.h"
#import "SliderView.h"

@interface SliderStackView ()
@property (nonatomic, strong) NSMutableArray<SliderView*> *sliderViews;
@end

@implementation SliderStackView

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
    }
    return self;
}

-(void)setupWith:(SliderStackViewModel*)viewModel {
    for (UIView* view in self.arrangedSubviews) {
        [self removeArrangedSubview:view];
        [view removeFromSuperview];
    }
    self.sliderViews = [@[] mutableCopy];
    [viewModel.sliders enumerateObjectsUsingBlock:^(SliderViewModel *sliderViewModel, NSUInteger idx, BOOL *stop) {
        SliderView *view = [[SliderView alloc] init];
        [view setupWith:sliderViewModel];
        view.onValueChange = ^(float value) {
            if (self.onValueChange) {
                self.onValueChange((int)idx, value);
            }
        };
        [self addArrangedSubview:view];
    }];
}

@end
