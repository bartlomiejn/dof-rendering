//
//  OBJMeshLoader.m
//  DoFRendering
//
//  Created by Bartłomiej Nowak on 11/11/2018.
//  Copyright © 2018 Bartłomiej Nowak. All rights reserved.
//

#import "OBJMeshLoader.h"
#import "OBJGroup.h"
#import "OBJModel.h"

@interface OBJMeshLoader ()
@property (nonatomic, strong) id<MTLDevice> device;
@end

@implementation OBJMeshLoader

-(instancetype)initWithDevice:(id<MTLDevice>)device
{
    self = [super init];
    if (self) {
        _device = device;
    }
    return self;
}

-(OBJMesh*)meshFromFilename:(NSString*)filename groupName:(NSString*)groupName
{
    OBJGroup* group = [self loadOBJGroupFromModelNamed:filename groupNamed:groupName];
    return [[OBJMesh alloc] initWithGroup:group device:_device];
}

-(OBJGroup*)loadOBJGroupFromModelNamed:(NSString *)name groupNamed:(NSString *)groupName
{
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:name withExtension:@"obj"];
    OBJModel *model = [[OBJModel alloc] initWithContentsOfURL:modelURL generateNormals:YES];
    return [model groupForName:groupName];
}

@end
