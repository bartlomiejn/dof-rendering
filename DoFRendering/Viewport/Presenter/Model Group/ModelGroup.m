//
//  ModelGroup.m
//  DoFRendering
//
//  Created by Bartłomiej Nowak on 11/11/2018.
//  Copyright © 2018 Bartłomiej Nowak. All rights reserved.
//

#import "ModelGroup.h"

@implementation ModelGroup

-(instancetype)initWithMesh:(OBJMesh*)mesh transformations:(matrix_float4x4*)transformations count:(int)count
{
    self = [super init];
    if (self) {
        _mesh = mesh;
        _transformations = transformations;
        _count = count;
    }
    return self;
}

- (void)dealloc
{
    free(_transformations);
}

@end
