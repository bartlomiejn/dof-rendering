//
//  SliderView.m
//  DoFRendering
//
//  Created by Bartłomiej Nowak on 08/11/2018.
//  Copyright © 2018 Bartłomiej Nowak. All rights reserved.
//

#import "SliderView.h"

@implementation SliderView

-(void)setupWith:(SliderViewModel*)viewModel {
    self.parameterNameLabel.text = viewModel.name;
    self.slider.maximumValue = viewModel.maxValue;
    self.slider.value = viewModel.currentValue;
    self.slider.minimumValue = viewModel.minValue;
}

- (IBAction)sliderValueChanged:(UISlider*)slider {
    if (self.onValueChange) {
        self.onValueChange(slider.value);
    }
}

@end
