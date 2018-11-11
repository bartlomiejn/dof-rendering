//
//  ModelGroup.h
//  DoFRendering
//
//  Created by Bartłomiej Nowak on 11/11/2018.
//  Copyright © 2018 Bartłomiej Nowak. All rights reserved.
//

@import Foundation;
@import simd;
#import "OBJMesh.h"

NS_ASSUME_NONNULL_BEGIN

@interface ModelGroup : NSObject
@property (nonatomic, strong) OBJMesh* mesh;
@property (nonatomic) matrix_float4x4 *transformations;
@property (nonatomic) int count;
-(instancetype)initWithMesh:(OBJMesh*)mesh transformations:(matrix_float4x4*)transformations count:(int)count;
@end

NS_ASSUME_NONNULL_END
