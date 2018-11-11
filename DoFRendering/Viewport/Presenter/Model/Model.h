//
//  Model.h
//  DoFRendering
//
//  Created by Bartłomiej Nowak on 10/11/2018.
//  Copyright © 2018 Bartłomiej Nowak. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <simd/simd.h>
#import "OBJMesh.h"

NS_ASSUME_NONNULL_BEGIN

@interface Model : NSObject
@property (nonatomic, strong) OBJMesh* mesh;
@property (nonatomic) matrix_float4x4 transformation;
-(instancetype)initWithMesh:(OBJMesh*)mesh transformation:(matrix_float4x4)transformation;
@end

NS_ASSUME_NONNULL_END
