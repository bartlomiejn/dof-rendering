//
//  RenderStateProvider.m
//  MBE
//
//  Created by Bartłomiej Nowak on 17.03.2018.
//  Copyright © 2018 Bartłomiej Nowak. All rights reserved.
//

#import "RenderStateProvider.h"

@implementation RenderStateProvider

#pragma mark - Public

-(instancetype)initWithDevice:(id<MTLDevice>)device {
    self = [super init];
    if (self) {
        self.drawObjectsPipelineState = [self drawObjectsPipelineStateOnDevice:device];
        self.circleOfConfusionPipelineState = [self circleOfConfusionPipelineStateOnDevice:device];
        self.maskFocusFieldPipelineState = [self maskFocusFieldPipelineStateOnDevice:device];
        self.maskOutOfFocusFieldPipelineState = [self maskOutOfFocusFieldPipelineStateOnDevice:device];
        self.applyGaussianBlurFieldPipelineState = [self applyGaussianBlurPipelineStateOnDevice:device];
        self.compositePipelineState = [self compositePipelineStateOnDevice:device];
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

-(id<MTLRenderPipelineState>)circleOfConfusionPipelineStateOnDevice:(id<MTLDevice>)device {
    id<MTLLibrary> library = [device newDefaultLibrary];
    MTLRenderPipelineDescriptor *descriptor = [MTLRenderPipelineDescriptor new];
    descriptor.label = @"Circle Of Confusion Pipeline State";
    descriptor.vertexFunction = [library newFunctionWithName:@"project_texture"];
    descriptor.fragmentFunction = [library newFunctionWithName:@"circle_of_confusion_pass"];
    descriptor.colorAttachments[0].pixelFormat = MTLPixelFormatInvalid;
    descriptor.depthAttachmentPixelFormat = MTLPixelFormatDepth32Float;
    return [self createRenderPipelineStateWith:descriptor onDevice:device];
}

-(id<MTLRenderPipelineState>)maskFocusFieldPipelineStateOnDevice:(id<MTLDevice>)device {
    return [self BGRA8UNormProjectTexturePipelineStateWithLabel:@"Mask Focus Pipeline State"
                                                       onDevice:device
                                               fragmentFunction:@"mask_focus_field"];
}

-(id<MTLRenderPipelineState>)maskOutOfFocusFieldPipelineStateOnDevice:(id<MTLDevice>)device {
    return [self BGRA8UNormProjectTexturePipelineStateWithLabel:@"Mask Out Of Focus Pipeline State"
                                                       onDevice:device
                                               fragmentFunction:@"mask_outoffocus_field"];
}

-(id<MTLRenderPipelineState>)applyGaussianBlurPipelineStateOnDevice:(id<MTLDevice>)device {
    return [self BGRA8UNormProjectTexturePipelineStateWithLabel:@"Single Side Gaussian Blur Pipeline State"
                                                       onDevice:device
                                               fragmentFunction:@"gaussian_blur"];
}

-(id<MTLRenderPipelineState>)compositePipelineStateOnDevice:(id<MTLDevice>)device {
    return [self BGRA8UNormProjectTexturePipelineStateWithLabel:@"Composite Pipeline State"
                                                       onDevice:device
                                               fragmentFunction:@"composite_textures"];
}

-(id<MTLDepthStencilState>)depthStencilStateOnDevice:(id<MTLDevice>)device {
    MTLDepthStencilDescriptor *depthStencilDescriptor = [MTLDepthStencilDescriptor new];
    depthStencilDescriptor.depthCompareFunction = MTLCompareFunctionLess;
    depthStencilDescriptor.depthWriteEnabled = YES;
    return [device newDepthStencilStateWithDescriptor:depthStencilDescriptor];
}

#pragma mark - Private

-(id<MTLRenderPipelineState>)BGRA8UNormProjectTexturePipelineStateWithLabel:(NSString*)label
                                                                   onDevice:(id<MTLDevice>)device
                                                           fragmentFunction:(NSString*)fragFunctionName {
    id<MTLLibrary> library = [device newDefaultLibrary];
    MTLRenderPipelineDescriptor *descriptor = [MTLRenderPipelineDescriptor new];
    descriptor.label = label;
    descriptor.vertexFunction = [library newFunctionWithName:@"project_texture"];
    descriptor.fragmentFunction = [library newFunctionWithName:fragFunctionName];
    descriptor.colorAttachments[0].pixelFormat = MTLPixelFormatBGRA8Unorm;
    descriptor.depthAttachmentPixelFormat = MTLPixelFormatInvalid;
    return [self createRenderPipelineStateWith:descriptor onDevice:device];
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
