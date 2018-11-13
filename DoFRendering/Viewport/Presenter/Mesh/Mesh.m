//
//  Mesh.m
//  DoFRendering
//
//  Created by Bartłomiej Nowak on 23/11/2017.
//  Copyright © 2017 Bartłomiej Nowak. All rights reserved.
//

#import "Mesh.h"

@interface Mesh ()
@property (nonatomic) id<MTLBuffer> vertexBuffer;
@property (nonatomic) id<MTLBuffer> indexBuffer;
@end

@implementation Mesh

-(instancetype)initWithVertexBuffer:(id<MTLBuffer>)vertexBuffer indexBuffer:(id<MTLBuffer>)indexBuffer {
    self = [super init];
    if (self) {
        self.vertexBuffer = vertexBuffer;
        self.indexBuffer = indexBuffer;
    }
    return self;
}

@end
