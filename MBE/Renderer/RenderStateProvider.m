//
//  RenderStateProvider.m
//  MBE
//
//  Created by Bartłomiej Nowak on 17.03.2018.
//  Copyright © 2018 Bartłomiej Nowak. All rights reserved.
//

#import "RenderStateProvider.h"

@interface RenderStateProvider ()
@end

@implementation RenderStateProvider

-(instancetype)initWithDevice:(id<MTLDevice>)device {
    self = [super init];
    if (self) {
        self.drawObjectsPipelineState = [self drawObjectsPipelineStateOnDevice:device];
        self.maskFocusFieldPipelineState = [self maskFocusFieldPipelineStateOnDevice:device];
        self.maskOutOfFocusFieldPipelineState = [self maskOutOfFocusFieldPipelineStateOnDevice:device];
        self.depthStencilState = [self depthStencilStateOnDevice:device];
    }
    return self;
}

-(id<MTLRenderPipelineState>)drawObjectsPipelineStateOnDevice:(id<MTLDevice>)device {
    id<MTLLibrary> library = [device newDefaultLibrary];
    MTLRenderPipelineDescriptor *renderObjectsDescriptor = [MTLRenderPipelineDescriptor new];
    renderObjectsDescriptor.vertexFunction = [library newFunctionWithName:@"map_vertices"];
    renderObjectsDescriptor.fragmentFunction = [library newFunctionWithName:@"color_passthrough"];
    renderObjectsDescriptor.colorAttachments[0].pixelFormat = MTLPixelFormatBGRA8Unorm;
    renderObjectsDescriptor.depthAttachmentPixelFormat = MTLPixelFormatDepth32Float;
    return [self createRenderPipelineStateWith:renderObjectsDescriptor onDevice:device];
}

-(id<MTLRenderPipelineState>)maskFocusFieldPipelineStateOnDevice:(id<MTLDevice>)device {
    id<MTLLibrary> library = [device newDefaultLibrary];
    MTLRenderPipelineDescriptor *bloomDescriptor = [MTLRenderPipelineDescriptor new];
    bloomDescriptor.vertexFunction = [library newFunctionWithName:@"map_texture"];
    bloomDescriptor.fragmentFunction = [library newFunctionWithName:@"mask_focus_field"];
    bloomDescriptor.colorAttachments[0].pixelFormat = MTLPixelFormatBGRA8Unorm;
    bloomDescriptor.depthAttachmentPixelFormat = MTLPixelFormatInvalid;
    return [self createRenderPipelineStateWith:bloomDescriptor onDevice:device];
}

-(id<MTLRenderPipelineState>)maskOutOfFocusFieldPipelineStateOnDevice:(id<MTLDevice>)device {
    id<MTLLibrary> library = [device newDefaultLibrary];
    MTLRenderPipelineDescriptor *bloomDescriptor = [MTLRenderPipelineDescriptor new];
    bloomDescriptor.vertexFunction = [library newFunctionWithName:@"map_texture"];
    bloomDescriptor.fragmentFunction = [library newFunctionWithName:@"mask_outoffocus_field"];
    bloomDescriptor.colorAttachments[0].pixelFormat = MTLPixelFormatBGRA8Unorm;
    bloomDescriptor.depthAttachmentPixelFormat = MTLPixelFormatInvalid;
    return [self createRenderPipelineStateWith:bloomDescriptor onDevice:device];
}

-(id<MTLDepthStencilState>)depthStencilStateOnDevice:(id<MTLDevice>)device {
    MTLDepthStencilDescriptor *depthStencilDescriptor = [MTLDepthStencilDescriptor new];
    depthStencilDescriptor.depthCompareFunction = MTLCompareFunctionLess;
    depthStencilDescriptor.depthWriteEnabled = YES;
    return [device newDepthStencilStateWithDescriptor:depthStencilDescriptor];
}

-(id<MTLRenderPipelineState>)createRenderPipelineStateWith:(MTLRenderPipelineDescriptor*)descriptor
                                                  onDevice:(id<MTLDevice>)device {
    // TODO: Real error handling
    NSError *error = nil;
    id<MTLRenderPipelineState> pipelineState = [device newRenderPipelineStateWithDescriptor:descriptor error:&error];
    if (!pipelineState) {
        NSLog(@"Error occurred when creating render pipeline state: %@", error);
    }
    return pipelineState;
}


@end
