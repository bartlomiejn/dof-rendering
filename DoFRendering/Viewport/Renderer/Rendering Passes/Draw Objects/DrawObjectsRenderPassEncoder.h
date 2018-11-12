//
//  DrawObjectsRenderPassEncoder.h
//  DoFRendering
//
//  Created by Bartłomiej Nowak on 10/11/2018.
//  Copyright © 2018 Bartłomiej Nowak. All rights reserved.
//

@import Foundation;
@import Metal;
#import "PassDescriptorBuilder.h"
#import "RenderStateProvider.h"
#import "ViewProjectionUniforms.h"
#import "ModelGroup.h"

NS_ASSUME_NONNULL_BEGIN

@interface DrawObjectsRenderPassEncoder : NSObject
-(instancetype)initWithDevice:(id<MTLDevice>)device
                  passBuilder:(PassDescriptorBuilder*)passBuilder
        pipelineStateProvider:(RenderStateProvider*)provider
                   clearColor:(MTLClearColor)clearColor;
-(void)encodeDrawModelGroup:(ModelGroup*)modelGroup
            inCommandBuffer:(id<MTLCommandBuffer>)commandBuffer
         tripleBufferingIdx:(int)currentBufferIndex
             outputColorTex:(id<MTLTexture>)colorTexture
             outputDepthTex:(id<MTLTexture>)depthTexture
          cameraTranslation:(vector_float3)translation
                 drawableSz:(CGSize)size;
@end

NS_ASSUME_NONNULL_END
