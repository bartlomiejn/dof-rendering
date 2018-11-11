//
//  OBJGroup.m
//  MBE
//
//  Created by Bartłomiej Nowak on 23/11/2017.
//  Copyright © 2017 Bartłomiej Nowak. All rights reserved.
//

#import "OBJGroup.h"
#import "MBETypes.h"

@implementation OBJGroup

- (instancetype)initWithName:(NSString *)name
{
    if ((self = [super init]))
    {
        _name = [name copy];
    }
    return self;
}

- (NSString *)description
{
    size_t vertCount = self.vertexData.length / sizeof(MBEVertex);
    size_t indexCount = self.indexData.length / sizeof(MBEIndex);
    return [NSString stringWithFormat:@"<MBEOBJMesh %p> (\"%@\", %d vertices, %d indices)",
            self, self.name, (int)vertCount, (int)indexCount];
}

@end
