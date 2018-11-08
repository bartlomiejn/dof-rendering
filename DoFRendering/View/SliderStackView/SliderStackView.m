//
//  SliderStackView.m
//  MBE
//
//  Created by Bartłomiej Nowak on 08/11/2018.
//  Copyright © 2018 Bartłomiej Nowak. All rights reserved.
//

#import "SliderStackView.h"
#import "SliderView.h"
#import "WeakSelf.h"

@interface SliderStackView ()
@property (nonatomic, strong) NSMutableArray<SliderView*> *sliderViews;
@end

@implementation SliderStackView

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        self.axis = UILayoutConstraintAxisVertical;
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
        SliderView *view = [[UINib nibWithNibName:@"SliderView" bundle:nil] instantiateWithOwner:nil options:nil][0];
        [view setupWith:sliderViewModel];
        WEAK_SELF weakSelf = self;
        view.onValueChange = ^(float value) {
            if (weakSelf && weakSelf.onValueChange) {
                weakSelf.onValueChange((int)idx, value);
            }
        };
        [self addArrangedSubview:view];
    }];
}

@end
