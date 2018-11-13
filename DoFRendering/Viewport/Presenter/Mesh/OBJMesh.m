//
//  OBJMesh.m
//  DoFRendering
//
//  Created by Bartłomiej Nowak on 23/11/2017.
//  Copyright © 2017 Bartłomiej Nowak. All rights reserved.
//

#import "OBJMesh.h"

@implementation OBJMesh

- (instancetype)initWithGroup:(OBJGroup *)group device:(id<MTLDevice>)device
{
    id<MTLBuffer> vertexBuffer = [device newBufferWithBytes:[group.vertexData bytes]
                                                     length:[group.vertexData length]
                                                    options:MTLResourceOptionCPUCacheModeDefault];
    [self.vertexBuffer setLabel:[NSString stringWithFormat:@"Vertices (%@)", group.name]];
    id<MTLBuffer> indexBuffer = [device newBufferWithBytes:[group.indexData bytes]
                                                    length:[group.indexData length]
                                                   options:MTLResourceOptionCPUCacheModeDefault];
    [self.indexBuffer setLabel:[NSString stringWithFormat:@"Indices (%@)", group.name]];
    self = [super initWithVertexBuffer:vertexBuffer indexBuffer:indexBuffer];
    return self;
}

@end
