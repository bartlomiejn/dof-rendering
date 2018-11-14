//
//  CircleOfConfusionPassEncoder.m
//  DoFRendering
//
//  Created by Bartłomiej Nowak on 14/11/2018.
//  Copyright © 2018 Bartłomiej Nowak. All rights reserved.
//

#import "CircleOfConfusionPassEncoder.h"
#import "PassDescriptorBuilder.h"
#import "PipelineStateBuilder.h"

@interface CircleOfConfusionPassEncoder ()
@property (nonatomic, strong) id<MTLDevice> device;
@property (nonatomic, strong) PassDescriptorBuilder* passBuilder;
@end

@implementation CircleOfConfusionPassEncoder

-(instancetype)initWithDevice:(id<MTLDevice>)device passBuilder:(PassDescriptorBuilder*)passBuilder
{
    self = [super init];
    if (self) {
        self.device = device;
        self.passBuilder = passBuilder;
    }
    return self;
}

-(void)encodeCircleOfConfusionPassIn:(id<MTLCommandBuffer>)commandBuffer
                   inputDepthTexture:(id<MTLTexture>)depthTexture
                       outputTexture:(id<MTLTexture>)outputTexture
                        drawableSize:(CGSize)drawableSize
                          clearColor:(MTLClearColor)clearColor
{
    MTLRenderPassDescriptor* descriptor = [self.passBuilder outputToColorTextureDescriptorOfSize:drawableSize
                                                                                      clearColor:clearColor
                                                                                       toTexture:outputTexture];
    id<MTLRenderCommandEncoder> encoder = [commandBuffer renderCommandEncoderWithDescriptor:descriptor];
    [encoder setLabel:@"Circle Of Confusion Pass Encoder"];
    [encoder setRenderPipelineState:[self circleOfConfusionPipelineStateOnDevice:self.device]];
    [encoder setFragmentTexture:depthTexture atIndex:0];
    [encoder drawPrimitives:MTLPrimitiveTypeTriangleStrip vertexStart:0 vertexCount:4];
    [encoder endEncoding];
}

-(id<MTLRenderPipelineState>)circleOfConfusionPipelineStateOnDevice:(id<MTLDevice>)device
{
    id<MTLLibrary> library = [device newDefaultLibrary];
    MTLRenderPipelineDescriptor *descriptor = [MTLRenderPipelineDescriptor new];
    descriptor.label = @"Circle Of Confusion Pipeline State";
    descriptor.vertexFunction = [library newFunctionWithName:@"project_texture"];
    descriptor.fragmentFunction = [library newFunctionWithName:@"circle_of_confusion_pass"];
    descriptor.colorAttachments[0].pixelFormat = MTLPixelFormatInvalid;
    descriptor.depthAttachmentPixelFormat = MTLPixelFormatDepth32Float;
    NSError *error = nil;
    id<MTLRenderPipelineState> pipelineState = [device newRenderPipelineStateWithDescriptor:descriptor error:&error];
    if (!pipelineState) {
        NSLog(@"Error occurred when creating render pipeline state: %@", error);
    }
    return pipelineState;
}

@end
