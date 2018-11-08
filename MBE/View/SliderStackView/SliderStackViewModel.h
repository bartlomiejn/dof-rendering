//
//  SliderStackViewModel.h
//  MBE
//
//  Created by Bartłomiej Nowak on 08/11/2018.
//  Copyright © 2018 Bartłomiej Nowak. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SliderViewModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface SliderStackViewModel : NSObject
@property (nonatomic) NSArray<SliderViewModel*> *sliders;
@end

NS_ASSUME_NONNULL_END
