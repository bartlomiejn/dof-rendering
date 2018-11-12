//
//  DrawObjectsRenderPassEncoder.m
//  DoFRendering
//
//  Created by Bartłomiej Nowak on 10/11/2018.
//  Copyright © 2018 Bartłomiej Nowak. All rights reserved.
//

#import "DrawObjectsRenderPassEncoder.h"
#import "MetalRendererProperties.h"
#import "ViewProjectionUniforms.h"
#import "ModelUniforms.h"
#import "MathFunctions.h"

@interface DrawObjectsRenderPassEncoder ()
@property (nonatomic, strong) id<MTLDevice> device;
@property (nonatomic, strong) PassDescriptorBuilder* passBuilder;
@property (nonatomic, strong) PipelineStateProvider* provider;
@property (nonatomic, strong) id<MTLBuffer> viewProjectionUniformsBuffer;
@property (nonatomic, strong) id<MTLBuffer> modelGroupUniformsBuffer;
@property (nonatomic) int modelGroupUniformsBufferCount;
@property (nonatomic) MTLClearColor clearColor;
@end

@implementation DrawObjectsRenderPassEncoder

-(instancetype)initWithDevice:(id<MTLDevice>)device
                  passBuilder:(PassDescriptorBuilder*)passBuilder
        pipelineStateProvider:(PipelineStateProvider*)provider
                   clearColor:(MTLClearColor)clearColor
{
    self = [super init];
    if (self) {
        self.device = device;
        self.passBuilder = passBuilder;
        self.provider = provider;
        self.viewProjectionUniformsBuffer = [self makeViewProjectionUniformsBufferOn:device];
        self.modelGroupUniformsBuffer = [self makeModelGroupUniformsBufferOn:device uniformCount:0];
        self.clearColor = clearColor;
    }
    return self;
}

-(id<MTLBuffer>)makeViewProjectionUniformsBufferOn:(id<MTLDevice>)device
{
    id<MTLBuffer> buffer = [self.device newBufferWithLength:sizeof(ViewProjectionUniforms) * inFlightBufferCount
                                                    options:MTLResourceOptionCPUCacheModeDefault];
    buffer.label = @"View Projection Uniforms Buffer";
    return buffer;
}

-(id<MTLBuffer>)makeModelGroupUniformsBufferOn:(id<MTLDevice>)device uniformCount:(int)count
{
    self.modelGroupUniformsBufferCount = count;
    if (count == 0) {
        return nil;
    }
    id<MTLBuffer> buffer = [self.device newBufferWithLength:sizeof(ModelUniforms) * count
                                                    options:MTLResourceOptionCPUCacheModeDefault];
    buffer.label = @"Model Uniforms Buffer";
    return buffer;
}

-(void)encodeDrawModelGroup:(ModelGroup*)modelGroup
            inCommandBuffer:(id<MTLCommandBuffer>)commandBuffer
         tripleBufferingIdx:(int)currentBufferIndex
             outputColorTex:(id<MTLTexture>)colorTexture
             outputDepthTex:(id<MTLTexture>)depthTexture
          cameraTranslation:(vector_float3)translation
                 drawableSz:(CGSize)size
{
    [self updateModelUniformsFor:modelGroup];
    [self updateViewProjectionUniformsAt:currentBufferIndex cameraTranslation:translation drawableSize:size];
    MTLRenderPassDescriptor *descriptor = [self.passBuilder renderObjectsPassDescriptorOfSize:size
                                                                                   clearColor:self.clearColor
                                                                           outputColorTexture:colorTexture
                                                                           outputDepthTexture:depthTexture];
    id<MTLRenderCommandEncoder> encoder = [commandBuffer renderCommandEncoderWithDescriptor:descriptor];
    [encoder setLabel:@"Draw Objects Encoder"];
    [encoder setRenderPipelineState:self.provider.drawObjectsPipelineState];
    [encoder setDepthStencilState:self.provider.depthStencilState];
    [encoder setFrontFacingWinding:MTLWindingCounterClockwise];
    [encoder setCullMode:MTLCullModeBack];
    [encoder setVertexBuffer:modelGroup.mesh.vertexBuffer offset:0 atIndex:0];
    [encoder setVertexBuffer:self.viewProjectionUniformsBuffer
                      offset:[self currentViewProjectionBufferOffsetFrom:currentBufferIndex]
                     atIndex:1];
    for (int i = 0; i < modelGroup.count; i++) {
        [encoder setVertexBuffer:self.modelGroupUniformsBuffer offset:sizeof(ModelUniforms)*i atIndex:2];
        [encoder drawIndexedPrimitives:MTLPrimitiveTypeTriangle
                            indexCount:modelGroup.mesh.indexBuffer.length / sizeof(MetalIndex)
                             indexType:MetalIndexType
                           indexBuffer:modelGroup.mesh.indexBuffer
                     indexBufferOffset:0];
    }
    [encoder endEncoding];
}

-(const NSUInteger)currentViewProjectionBufferOffsetFrom:(int)currentTripleBufferingIndex
{
    return sizeof(ViewProjectionUniforms) * currentTripleBufferingIndex;
}

-(void)updateModelUniformsFor:(ModelGroup*)modelGroup
{
    // If our currently rendered modelGroup size is bigger than
    if (modelGroup.count > self.modelGroupUniformsBufferCount) {
        self.modelGroupUniformsBuffer = [self makeModelGroupUniformsBufferOn:self.device uniformCount:modelGroup.count];
    }
    ModelUniforms modelGroupUniforms[modelGroup.count];
    for (int i = 0; i < modelGroup.count; i++) {
        modelGroupUniforms[i] = (ModelUniforms){ modelGroup.transformations[i] };
    }
    memcpy([self.modelGroupUniformsBuffer contents], &modelGroupUniforms, sizeof(ModelUniforms)*modelGroup.count);
}

-(void)updateViewProjectionUniformsAt:(int)currentTripleBufferingIdx
                    cameraTranslation:(vector_float3)translation
                         drawableSize:(CGSize)size
{
    const NSUInteger uniformBufferOffset = sizeof(ViewProjectionUniforms) * currentTripleBufferingIdx;
    ViewProjectionUniforms uniforms = (ViewProjectionUniforms) {
        .viewMatrix = matrix_float4x4_translation(translation),
        .projectionMatrix = [self projectionMatrixWith:size]
    };
    memcpy([self.viewProjectionUniformsBuffer contents] + uniformBufferOffset, &uniforms, sizeof(uniforms));
}

-(matrix_float4x4)projectionMatrixWith:(CGSize)drawableSize
{
    const float aspectRatio = drawableSize.width / drawableSize.height;
    const float fov = (2 * M_PI) / 5;
    const float near = 1.0;
    const float far = 100;
    const matrix_float4x4 projectionMatrix = matrix_float4x4_perspective(aspectRatio, fov, near, far);
    return projectionMatrix;
}

@end
