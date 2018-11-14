//
//  BokehPassEncoder.m
//  DoFRendering
//
//  Created by Bartłomiej Nowak on 14/11/2018.
//  Copyright © 2018 Bartłomiej Nowak. All rights reserved.
//

#import "BokehPassEncoder.h"

@interface BokehPassEncoder ()
@property (nonatomic, strong) id<MTLDevice> device;
@property (nonatomic, strong) PassDescriptorBuilder* passBuilder;
@end

@implementation BokehPassEncoder

-(instancetype)initWithDevice:(id<MTLDevice>)device passBuilder:(PassDescriptorBuilder*)passBuilder
{
    self = [super init];
    if (self) {
        self.device = device;
        self.passBuilder = passBuilder;
    }
    return self;
}

-(void)encodeIn:(id<MTLCommandBuffer>)commandBuffer
inputCoCTexture:(id<MTLTexture>)cocTexture
  outputTexture:(id<MTLTexture>)outputTexture
   drawableSize:(CGSize)drawableSize
     clearColor:(MTLClearColor)clearColor
{
    MTLRenderPassDescriptor* descriptor = [self.passBuilder outputToColorTextureDescriptorOfSize:drawableSize
                                                                                      clearColor:clearColor
                                                                                       toTexture:outputTexture];
    id<MTLRenderCommandEncoder> encoder = [commandBuffer renderCommandEncoderWithDescriptor:descriptor];
    [encoder setLabel:@"Circle Of Confusion Pass Encoder"];
    [encoder setRenderPipelineState:[self bokehPipelineStateOnDevice:self.device]];
    [encoder setFragmentTexture:cocTexture atIndex:0];
    [encoder drawPrimitives:MTLPrimitiveTypeTriangleStrip vertexStart:0 vertexCount:4];
    [encoder endEncoding];
}

-(id<MTLRenderPipelineState>)bokehPipelineStateOnDevice:(id<MTLDevice>)device
{
    id<MTLLibrary> library = [device newDefaultLibrary];
    MTLRenderPipelineDescriptor *descriptor = [MTLRenderPipelineDescriptor new];
    descriptor.label = @"Bokeh Pipeline State";
    descriptor.vertexFunction = [library newFunctionWithName:@"project_texture"];
    descriptor.fragmentFunction = [library newFunctionWithName:@"bokeh"];
    descriptor.colorAttachments[0].pixelFormat = MTLPixelFormatBGRA8Unorm;
    descriptor.depthAttachmentPixelFormat = MTLPixelFormatInvalid;
    NSError *error = nil;
    id<MTLRenderPipelineState> pipelineState = [device newRenderPipelineStateWithDescriptor:descriptor error:&error];
    if (!pipelineState) {
        NSLog(@"Error occurred when creating render pipeline state: %@", error);
    }
    return pipelineState;
}
@end
