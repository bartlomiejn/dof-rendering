//
//  BokehPassEncoder.m
//  DoFRendering
//
//  Created by Bartłomiej Nowak on 14/11/2018.
//  Copyright © 2018 Bartłomiej Nowak. All rights reserved.
//

#import "BokehPassEncoder.h"

@interface BokehPassEncoder ()
@property (nonatomic, strong) PassDescriptorBuilder* passBuilder;
@property (nonatomic, strong) id<MTLDevice> device;
@property (nonatomic, strong) id<MTLRenderPipelineState> pipelineState;
@property (nonatomic, strong) id<MTLBuffer> texelSizeUniformBuffer;
@end

@implementation BokehPassEncoder

-(instancetype)initWithDevice:(id<MTLDevice>)device passBuilder:(PassDescriptorBuilder*)passBuilder
{
    self = [super init];
    if (self) {
        self.passBuilder = passBuilder;
        self.device = device;
        self.pipelineState = [self bokehPipelineStateOnDevice:device];
        self.texelSizeUniformBuffer = [self makeTexelSizeUniformBuffer];
    }
    return self;
}

-(id<MTLBuffer>)makeTexelSizeUniformBuffer
{
    simd_float2 texelSize = { 0.005f, 0.005f };
    id<MTLBuffer> buffer = [self.device newBufferWithLength:sizeof(simd_float2)
                                                    options:MTLResourceOptionCPUCacheModeDefault];
    buffer.label = @"Texel Size Uniform";
    memcpy(buffer.contents, &texelSize, sizeof(simd_float2));
    return buffer;
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

-(void)  encodeIn:(id<MTLCommandBuffer>)commandBuffer
inputColorTexture:(id<MTLTexture>)colorTexture
    outputTexture:(id<MTLTexture>)outputTexture
     drawableSize:(CGSize)drawableSize
       clearColor:(MTLClearColor)clearColor
{
    MTLRenderPassDescriptor* descriptor = [self.passBuilder outputToColorTextureDescriptorOfSize:drawableSize
                                                                                      clearColor:clearColor
                                                                                       toTexture:outputTexture];
    id<MTLRenderCommandEncoder> encoder = [commandBuffer renderCommandEncoderWithDescriptor:descriptor];
    [encoder setLabel:@"Bokeh Pass Encoder"];
    [encoder setRenderPipelineState:self.pipelineState];
    [encoder setFragmentTexture:colorTexture atIndex:0];
    [encoder setFragmentBuffer:self.texelSizeUniformBuffer offset:0 atIndex:0];
    [encoder drawPrimitives:MTLPrimitiveTypeTriangleStrip vertexStart:0 vertexCount:4];
    [encoder endEncoding];
}

@end
