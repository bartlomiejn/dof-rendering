//
//  PassDescriptorProvider.h
//  MBE
//
//  Created by Bartłomiej Nowak on 17.03.2018.
//  Copyright © 2018 Bartłomiej Nowak. All rights reserved.
//

#import "MetalView.h"
#import <Foundation/Foundation.h>
#import <Metal/Metal.h>

@interface PassDescriptorBuilder : NSObject
-(MTLRenderPassDescriptor *)renderObjectsPassDescriptorForView:(MetalView *)view
                                            outputColorTexture:(id<MTLTexture>)colorTexture
                                            outputDepthTexture:(id<MTLTexture>)depthTexture;
-(MTLRenderPassDescriptor *)outputToColorTextureDescriptorForView:(MetalView *)view
                                                      withTexture:(id<MTLTexture>)colorTexture;
@end
