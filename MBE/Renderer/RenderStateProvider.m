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
        self.applyHorizontalBlurFieldPipelineState = [self applyHorizontalBlurPipelineStateOnDevice:device];
        self.depthStencilState = [self depthStencilStateOnDevice:device];
    }
    return self;
}

-(id<MTLRenderPipelineState>)drawObjectsPipelineStateOnDevice:(id<MTLDevice>)device {
    id<MTLLibrary> library = [device newDefaultLibrary];
    MTLRenderPipelineDescriptor *descriptor = [MTLRenderPipelineDescriptor new];
    descriptor.label = @"Draw Objects Pipeline State";
    descriptor.vertexFunction = [library newFunctionWithName:@"map_vertices"];
    descriptor.fragmentFunction = [library newFunctionWithName:@"color_passthrough"];
    descriptor.colorAttachments[0].pixelFormat = MTLPixelFormatBGRA8Unorm;
    descriptor.depthAttachmentPixelFormat = MTLPixelFormatDepth32Float;
    return [self createRenderPipelineStateWith:descriptor onDevice:device];
}

-(id<MTLRenderPipelineState>)maskFocusFieldPipelineStateOnDevice:(id<MTLDevice>)device {
    id<MTLLibrary> library = [device newDefaultLibrary];
    MTLRenderPipelineDescriptor *descriptor = [MTLRenderPipelineDescriptor new];
    descriptor.label = @"Mask Focus Pipeline State";
    descriptor.vertexFunction = [library newFunctionWithName:@"map_texture"];
    descriptor.fragmentFunction = [library newFunctionWithName:@"mask_focus_field"];
    descriptor.colorAttachments[0].pixelFormat = MTLPixelFormatBGRA8Unorm;
    descriptor.depthAttachmentPixelFormat = MTLPixelFormatInvalid;
    return [self createRenderPipelineStateWith:descriptor onDevice:device];
}

-(id<MTLRenderPipelineState>)maskOutOfFocusFieldPipelineStateOnDevice:(id<MTLDevice>)device {
    id<MTLLibrary> library = [device newDefaultLibrary];
    MTLRenderPipelineDescriptor *descriptor = [MTLRenderPipelineDescriptor new];
    descriptor.label = @"Mask Out Of Focus Pipeline State";
    descriptor.vertexFunction = [library newFunctionWithName:@"map_texture"];
    descriptor.fragmentFunction = [library newFunctionWithName:@"mask_outoffocus_field"];
    descriptor.colorAttachments[0].pixelFormat = MTLPixelFormatBGRA8Unorm;
    descriptor.depthAttachmentPixelFormat = MTLPixelFormatInvalid;
    return [self createRenderPipelineStateWith:descriptor onDevice:device];
}

-(id<MTLRenderPipelineState>)applyHorizontalBlurPipelineStateOnDevice:(id<MTLDevice>)device {
    id<MTLLibrary> library = [device newDefaultLibrary];
    MTLRenderPipelineDescriptor *descriptor = [MTLRenderPipelineDescriptor new];
    descriptor.label = @"Horizontal Blur Pipeline State";
    descriptor.vertexFunction = [library newFunctionWithName:@"map_texture"];
    descriptor.fragmentFunction = [library newFunctionWithName:@"horizontal_gaussian_blur"];
    descriptor.colorAttachments[0].pixelFormat = MTLPixelFormatBGRA8Unorm;
    descriptor.depthAttachmentPixelFormat = MTLPixelFormatInvalid;
    return [self createRenderPipelineStateWith:descriptor onDevice:device];
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
