//
//  DrawObjectsRenderingPass.h
//  DoFRendering
//
//  Created by Bartłomiej Nowak on 10/11/2018.
//  Copyright © 2018 Bartłomiej Nowak. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PassDescriptorBuilder.h"
#import "OBJMesh.h"

NS_ASSUME_NONNULL_BEGIN

@interface DrawObjectsRenderingPass : NSObject
//-(instancetype)initWithMesh:(OBJMesh*)mesh passBuilder:(PassDescriptorBuilder*)passBuilder outputColor:(id<MTLTexture>)colorTex outputDepth:(id<MTLTexture>)depthTex;
@end

NS_ASSUME_NONNULL_END
