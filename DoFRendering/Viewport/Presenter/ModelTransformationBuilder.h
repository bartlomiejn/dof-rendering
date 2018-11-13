//
//  ModelTransformationBuilder.h
//  DoFRendering
//
//  Created by Bartłomiej Nowak on 11/11/2018.
//  Copyright © 2018 Bartłomiej Nowak. All rights reserved.
//

@import Foundation;
@import simd;

NS_ASSUME_NONNULL_BEGIN

@interface ModelTransformationBuilder : NSObject
-(instancetype)init;
-(void)addLastFrameDuration:(float)frameDuration;
-(matrix_float4x4)transformationMatrixForModelIndex:(int)index;
@end

NS_ASSUME_NONNULL_END
