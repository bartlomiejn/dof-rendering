//
//  TeapotModel.h
//  DoFRendering
//
//  Created by Bartłomiej Nowak on 10/11/2018.
//  Copyright © 2018 Bartłomiej Nowak. All rights reserved.
//

@import Foundation;
@import Metal;
#import "Model.h"

NS_ASSUME_NONNULL_BEGIN

@interface TeapotModel : Model
-(instancetype)initWithModelMatrix:(matrix_float4x4)matrix device:(id<MTLDevice>)device;
@end

NS_ASSUME_NONNULL_END
