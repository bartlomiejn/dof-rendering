//
//  OBJMesh.m
//  DoFRendering
//
//  Created by Bartłomiej Nowak on 23/11/2017.
//  Copyright © 2017 Bartłomiej Nowak. All rights reserved.
//

#import "OBJMesh.h"

@implementation OBJMesh

@synthesize indexBuffer = _indexBuffer;
@synthesize vertexBuffer = _vertexBuffer;

- (instancetype)initWithGroup:(OBJGroup *)group device:(id<MTLDevice>)device
{
    self = [super init];
    if (self) {
        _vertexBuffer = [device newBufferWithBytes:[group.vertexData bytes]
                                            length:[group.vertexData length]
                                           options:MTLResourceOptionCPUCacheModeDefault];
        [_vertexBuffer setLabel:[NSString stringWithFormat:@"Vertices (%@)", group.name]];
        
        _indexBuffer = [device newBufferWithBytes:[group.indexData bytes]
                                           length:[group.indexData length]
                                          options:MTLResourceOptionCPUCacheModeDefault];
        [_indexBuffer setLabel:[NSString stringWithFormat:@"Indices (%@)", group.name]];
    }
    return self;
}

@end
