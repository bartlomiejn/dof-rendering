//
//  ViewportPresenter.m
//  MBE
//
//  Created by Bartłomiej Nowak on 08/11/2018.
//  Copyright © 2018 Bartłomiej Nowak. All rights reserved.
//

#import "ViewportPresenter.h"
#import "SliderStackViewModel.h"
#import "SliderViewModel.h"

@interface ViewportPresenter ()
@property (nonatomic, strong) SliderStackViewModel *sliders;
@end

@implementation ViewportPresenter

- (instancetype)init {
    self = [super init];
    if (self) {
        _sliders = [[SliderStackViewModel alloc] initWith:@[[[SliderViewModel alloc] initWithName:@"Focus Distance"
                                                                                         maxValue:100.0
                                                                                     currentValue:10.0
                                                                                         minValue:0.1],
                                                            [[SliderViewModel alloc] initWithName:@"Focus Range"
                                                                                         maxValue:20.0
                                                                                     currentValue:5.0
                                                                                         minValue:0.1]]];
    }
    return self;
}

- (void)viewDidLoad {
    [_view presentSliders:_sliders];
}

- (void)sliderValueChangedFor:(int)idx with:(float)value {
    if (idx >= _sliders.sliders.count) {
        return;
    }
    _sliders.sliders[idx].currentValue = value;
}

@end
