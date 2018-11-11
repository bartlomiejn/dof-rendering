//
//  Model.m
//  DoFRendering
//
//  Created by Bartłomiej Nowak on 10/11/2018.
//  Copyright © 2018 Bartłomiej Nowak. All rights reserved.
//

#import "Model.h"

@implementation Model

-(instancetype)initWithMesh:(OBJMesh*)mesh transformation:(matrix_float4x4)transformation {
    self = [super init];
    if (self) {
        _mesh = mesh;
        _transformation = transformation;
    }
    return self;
}

@end
