//
//  SliderStackViewModel.m
//  MBE
//
//  Created by Bartłomiej Nowak on 08/11/2018.
//  Copyright © 2018 Bartłomiej Nowak. All rights reserved.
//

#import "SliderStackViewModel.h"

@implementation SliderStackViewModel

-(instancetype)initWith:(NSArray<SliderViewModel*>*)viewModels {
    self = [super init];
    if (self) {
        self.sliders = viewModels;
    }
    return self;
}

@end
