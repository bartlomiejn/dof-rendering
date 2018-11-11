//
//  SliderViewModel.h
//  MBE
//
//  Created by Bartłomiej Nowak on 08/11/2018.
//  Copyright © 2018 Bartłomiej Nowak. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface SliderViewModel : NSObject
@property (nonatomic) NSString *name;
@property (nonatomic) float maxValue;
@property (nonatomic) float currentValue;
@property (nonatomic) float minValue;
-(instancetype)initWithName:(NSString*)name
                   maxValue:(float)maxValue
               currentValue:(float)currentValue
                   minValue:(float)minValue;
@end

NS_ASSUME_NONNULL_END
