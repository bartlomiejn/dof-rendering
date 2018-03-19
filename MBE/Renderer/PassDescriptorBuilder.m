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

-(MTLRenderPassDescriptor *)renderObjectsPassDescriptorForView:(MetalView *)view
                                            outputColorTexture:(id<MTLTexture>)colorTexture
                                            outputDepthTexture:(id<MTLTexture>)depthTexture {
    MTLRenderPassDescriptor *descriptor = [MTLRenderPassDescriptor renderPassDescriptor];
    descriptor.colorAttachments[0].texture = colorTexture;
    descriptor.colorAttachments[0].clearColor = view.clearColor;
    descriptor.colorAttachments[0].loadAction = MTLLoadActionClear;
    descriptor.colorAttachments[0].storeAction = MTLStoreActionStore;
    descriptor.depthAttachment.texture = depthTexture;
    descriptor.depthAttachment.clearDepth = 1.0;
    descriptor.depthAttachment.loadAction = MTLLoadActionClear;
    descriptor.depthAttachment.storeAction = MTLStoreActionStore;
    descriptor.renderTargetWidth = view.metalLayer.drawableSize.width;
    descriptor.renderTargetHeight = view.metalLayer.drawableSize.height;
    return descriptor;
}

-(MTLRenderPassDescriptor *)outputToColorTextureDescriptorForView:(MetalView *)view
                                                      withTexture:(id<MTLTexture>)colorTexture {
    MTLRenderPassDescriptor *descriptor = [MTLRenderPassDescriptor renderPassDescriptor];
    descriptor.colorAttachments[0].texture = colorTexture;
    descriptor.colorAttachments[0].clearColor = view.clearColor;
    descriptor.colorAttachments[0].storeAction = MTLStoreActionStore;
    descriptor.colorAttachments[0].loadAction = MTLLoadActionLoad;
    descriptor.renderTargetWidth = view.metalLayer.drawableSize.width;
    descriptor.renderTargetHeight = view.metalLayer.drawableSize.height;
    return descriptor;
}

@end
