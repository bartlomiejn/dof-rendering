//
//  TeapotModel.m
//  DoFRendering
//
//  Created by Bartłomiej Nowak on 10/11/2018.
//  Copyright © 2018 Bartłomiej Nowak. All rights reserved.
//

#import "TeapotModel.h"
#import <simd/simd.h>
#import "OBJModel.h"
#import "OBJGroup.h"
#import "OBJMesh.h"

@implementation TeapotModel

-(instancetype)initWithModelMatrix:(matrix_float4x4)matrix device:(id<MTLDevice>)device {
    self = [super initWithMesh:[self loadTeapotMeshToDevice:device] modelMatrix:matrix];
    return self;
}

-(OBJMesh*)loadTeapotMeshToDevice:(id<MTLDevice>)device {
    OBJGroup* group = [self loadOBJGroupFromModelNamed:@"teapot" groupNamed:@"teapot"];
    return [[OBJMesh alloc] initWithGroup:group device:device];
}

-(OBJGroup*)loadOBJGroupFromModelNamed:(NSString *)name groupNamed:(NSString *)groupName {
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:name withExtension:@"obj"];
    OBJModel *model = [[OBJModel alloc] initWithContentsOfURL:modelURL generateNormals:YES];
    return [model groupForName:groupName];
}

@end
