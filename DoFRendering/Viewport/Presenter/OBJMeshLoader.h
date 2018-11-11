//
//  OBJMeshLoader.h
//  DoFRendering
//
//  Created by Bartłomiej Nowak on 11/11/2018.
//  Copyright © 2018 Bartłomiej Nowak. All rights reserved.
//

@import Foundation;
@import Metal;
#import "OBJMesh.h"

NS_ASSUME_NONNULL_BEGIN

@interface OBJMeshLoader : NSObject
-(instancetype)initWithDevice:(id<MTLDevice>)device;
-(OBJMesh*)meshFromFilename:(NSString*)filename groupName:(NSString*)groupName;
@end

NS_ASSUME_NONNULL_END
