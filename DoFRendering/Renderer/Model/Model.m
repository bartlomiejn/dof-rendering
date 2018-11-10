//
//  Model.m
//  DoFRendering
//
//  Created by Bartłomiej Nowak on 10/11/2018.
//  Copyright © 2018 Bartłomiej Nowak. All rights reserved.
//

#import "Model.h"

@implementation Model

-(instancetype)initWithMesh:(OBJMesh*)mesh modelMatrix:(matrix_float4x4)modelMatrix {
    self = [super init];
    if (self) {
        _mesh = mesh;
        _modelMatrix = modelMatrix;
    }
    return self;
}

@end
