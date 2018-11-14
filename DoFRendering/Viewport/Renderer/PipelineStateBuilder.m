//
//  PipelineStateBuilder.m
//  DoFRendering
//
//  Created by Bartłomiej Nowak on 17.03.2018.
//  Copyright © 2018 Bartłomiej Nowak. All rights reserved.
//

#import "PipelineStateBuilder.h"

@implementation PipelineStateBuilder

-(instancetype)initWithDevice:(id<MTLDevice>)device {
    self = [super init];
    if (self) {
        self.maskFocusFieldPipelineState = [self maskFocusFieldPipelineStateOnDevice:device];
        self.maskOutOfFocusFieldPipelineState = [self maskOutOfFocusFieldPipelineStateOnDevice:device];
        self.applyGaussianBlurFieldPipelineState = [self applyGaussianBlurPipelineStateOnDevice:device];
        self.compositePipelineState = [self compositePipelineStateOnDevice:device];
    }
    return self;
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
    return [self BGRA8UNormProjectTexturePipelineStateWithLabel:@"Gaussian Blur Pipeline State"
                                                       onDevice:device
                                               fragmentFunction:@"gaussian_blur"];
}

-(id<MTLRenderPipelineState>)compositePipelineStateOnDevice:(id<MTLDevice>)device {
    return [self BGRA8UNormProjectTexturePipelineStateWithLabel:@"Composite Pipeline State"
                                                       onDevice:device
                                               fragmentFunction:@"composite_textures"];
}

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
