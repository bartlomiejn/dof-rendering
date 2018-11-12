//
//  SliderViewModel.m
//  DoFRendering
//
//  Created by Bartłomiej Nowak on 08/11/2018.
//  Copyright © 2018 Bartłomiej Nowak. All rights reserved.
//

#import "SliderViewModel.h"

@implementation SliderViewModel

-(instancetype)initWithName:(NSString*)name
                   maxValue:(float)maxValue
               currentValue:(float)currentValue
                   minValue:(float)minValue {
    self = [super init];
    if (self) {
        self.name = name;
        self.maxValue = maxValue;
        self.currentValue = currentValue;
        self.minValue = minValue;
    }
    return self;
}

@end
