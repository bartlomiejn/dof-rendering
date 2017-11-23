//
//  OBJMesh.h
//  MBE
//
//  Created by Bartłomiej Nowak on 23/11/2017.
//  Copyright © 2017 Bartłomiej Nowak. All rights reserved.
//

#import "Mesh.h"
#import "OBJGroup.h"
@import Foundation;
@import Metal;

@interface OBJMesh : Mesh
- (instancetype)initWithGroup:(OBJGroup *)group device:(id<MTLDevice>)device;
@end
