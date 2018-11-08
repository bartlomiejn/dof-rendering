//
//  PassDescriptorProvider.m
//  MBE
//
//  Created by Bartłomiej Nowak on 17.03.2018.
//  Copyright © 2018 Bartłomiej Nowak. All rights reserved.
//

#import "PassDescriptorBuilder.h"

@interface PassDescriptorBuilder ()
@end

@implementation PassDescriptorBuilder

-(MTLRenderPassDescriptor *)renderObjectsPassDescriptorOfSize:(CGSize)size
                                                   clearColor:(MTLClearColor)clearColor
                                           outputColorTexture:(id<MTLTexture>)colorTexture
                                           outputDepthTexture:(id<MTLTexture>)depthTexture
{
    MTLRenderPassDescriptor *descriptor = [MTLRenderPassDescriptor renderPassDescriptor];
    descriptor.colorAttachments[0].texture = colorTexture;
    descriptor.colorAttachments[0].clearColor = clearColor;
    descriptor.colorAttachments[0].loadAction = MTLLoadActionClear;
    descriptor.colorAttachments[0].storeAction = MTLStoreActionStore;
    descriptor.depthAttachment.texture = depthTexture;
    descriptor.depthAttachment.clearDepth = 1.0;
    descriptor.depthAttachment.loadAction = MTLLoadActionClear;
    descriptor.depthAttachment.storeAction = MTLStoreActionStore;
    descriptor.renderTargetWidth = size.width;
    descriptor.renderTargetHeight = size.height;
    return descriptor;
}

-(MTLRenderPassDescriptor *)outputToColorTextureDescriptorOfSize:(CGSize)size
                                                      clearColor:(MTLClearColor)clearColor
                                                       toTexture:(id<MTLTexture>)colorTexture
{
    MTLRenderPassDescriptor *descriptor = [MTLRenderPassDescriptor renderPassDescriptor];
    descriptor.colorAttachments[0].texture = colorTexture;
    descriptor.colorAttachments[0].clearColor = clearColor;
    descriptor.colorAttachments[0].loadAction = MTLLoadActionLoad;
    descriptor.colorAttachments[0].storeAction = MTLStoreActionStore;
    descriptor.renderTargetWidth = size.width;
    descriptor.renderTargetHeight = size.height;
    return descriptor;
}

-(MTLRenderPassDescriptor *)outputToDepthTextureDescriptorOfSize:(CGSize)size toTexture:(id<MTLTexture>)depthTexture
{
    MTLRenderPassDescriptor *descriptor = [MTLRenderPassDescriptor renderPassDescriptor];
    descriptor.depthAttachment.texture = depthTexture;
    descriptor.depthAttachment.loadAction = MTLLoadActionLoad;
    descriptor.depthAttachment.storeAction = MTLStoreActionStore;
    descriptor.renderTargetWidth = size.width;
    descriptor.renderTargetHeight = size.height;
    return descriptor;
}

@end
