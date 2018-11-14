//
//  BokehPassEncoder.h
//  DoFRendering
//
//  Created by Bartłomiej Nowak on 14/11/2018.
//  Copyright © 2018 Bartłomiej Nowak. All rights reserved.
//

@import Foundation;
@import Metal;
#import "PassDescriptorBuilder.h"

NS_ASSUME_NONNULL_BEGIN

@interface BokehPassEncoder : NSObject
-(instancetype)initWithDevice:(id<MTLDevice>)device passBuilder:(PassDescriptorBuilder*)passBuilder;
-(void)encodeIn:(id<MTLCommandBuffer>)commandBuffer
inputCoCTexture:(id<MTLTexture>)cocTexture
  outputTexture:(id<MTLTexture>)outputTexture
   drawableSize:(CGSize)drawableSize
     clearColor:(MTLClearColor)clearColor;
@end

NS_ASSUME_NONNULL_END
