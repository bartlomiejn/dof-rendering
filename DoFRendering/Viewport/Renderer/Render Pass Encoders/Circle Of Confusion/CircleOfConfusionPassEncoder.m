//
//  CircleOfConfusionPassEncoder.m
//  DoFRendering
//
//  Created by Bartłomiej Nowak on 14/11/2018.
//  Copyright © 2018 Bartłomiej Nowak. All rights reserved.
//

#import "CircleOfConfusionPassEncoder.h"
#import "PassDescriptorBuilder.h"
#import "CoCUniforms.h"

@interface CircleOfConfusionPassEncoder ()
@property (nonatomic, strong) PassDescriptorBuilder* passBuilder;
@property (nonatomic, strong) id<MTLDevice> device;
@property (nonatomic, strong) id<MTLRenderPipelineState> pipelineState;
@property (nonatomic, strong) id<MTLBuffer> uniforms;
@end

@implementation CircleOfConfusionPassEncoder

-(instancetype)initWithDevice:(id<MTLDevice>)device passBuilder:(PassDescriptorBuilder*)passBuilder
{
    self = [super init];
    if (self) {
        self.passBuilder = passBuilder;
        self.device = device;
        self.pipelineState = [self circleOfConfusionPipelineStateOnDevice:device];
        self.uniforms = [self makeUniforms];
    }
    return self;
}

-(id<MTLRenderPipelineState>)circleOfConfusionPipelineStateOnDevice:(id<MTLDevice>)device
{
    id<MTLLibrary> library = [device newDefaultLibrary];
    MTLRenderPipelineDescriptor *descriptor = [MTLRenderPipelineDescriptor new];
    descriptor.label = @"Circle Of Confusion Pipeline State";
    descriptor.vertexFunction = [library newFunctionWithName:@"project_texture"];
    descriptor.fragmentFunction = [library newFunctionWithName:@"circle_of_confusion_pass"];
    descriptor.colorAttachments[0].pixelFormat = MTLPixelFormatR8Snorm;
    descriptor.depthAttachmentPixelFormat = MTLPixelFormatInvalid;
    NSError *error = nil;
    id<MTLRenderPipelineState> pipelineState = [device newRenderPipelineStateWithDescriptor:descriptor error:&error];
    if (!pipelineState) {
        NSLog(@"Error occurred when creating render pipeline state: %@", error);
    }
    return pipelineState;
}

-(id<MTLBuffer>)makeUniforms
{
    id<MTLBuffer> buffer = [self.device newBufferWithLength:sizeof(CoCUniforms)
                                                    options:MTLResourceOptionCPUCacheModeDefault];
    buffer.label = @"Circle Of Confusion Pass Uniforms";
    return buffer;
}

#pragma mark - CircleOfConfusionPassEncoder

-(void)encodeIn:(id<MTLCommandBuffer>)commandBuffer
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
    [encoder setRenderPipelineState:self.pipelineState];
    [encoder setFragmentTexture:depthTexture atIndex:0];
    [encoder setFragmentBuffer:self.uniforms offset:0 atIndex:0];
    [encoder drawPrimitives:MTLPrimitiveTypeTriangleStrip vertexStart:0 vertexCount:4];
    [encoder endEncoding];
}

-(void)updateUniformsWithFocusDistance:(float)focusDistance focusRange:(float)focusRange
{
    CoCUniforms cocUniforms = (CoCUniforms) { .focusDist = focusDistance, .focusRange = focusRange };
    memcpy(self.uniforms.contents, &cocUniforms, sizeof(CoCUniforms));
}

@end
