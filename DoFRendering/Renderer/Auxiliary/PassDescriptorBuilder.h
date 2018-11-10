//
//  PassDescriptorProvider.h
//  MBE
//
//  Created by Bartłomiej Nowak on 17.03.2018.
//  Copyright © 2018 Bartłomiej Nowak. All rights reserved.
//

@import Foundation;
@import Metal;
#import "MetalView.h"

@interface PassDescriptorBuilder : NSObject
-(MTLRenderPassDescriptor *)renderObjectsPassDescriptorOfSize:(CGSize)size
                                                   clearColor:(MTLClearColor)clearColor
                                           outputColorTexture:(id<MTLTexture>)colorTexture
                                           outputDepthTexture:(id<MTLTexture>)depthTexture;
-(MTLRenderPassDescriptor *)outputToColorTextureDescriptorOfSize:(CGSize)size
                                                      clearColor:(MTLClearColor)clearColor
                                                     toTexture:(id<MTLTexture>)colorTexture;
-(MTLRenderPassDescriptor *)outputToDepthTextureDescriptorOfSize:(CGSize)size toTexture:(id<MTLTexture>)depthTexture;
@end
