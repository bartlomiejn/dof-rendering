//
//  DrawObjectsRenderPassEncoder.m
//  DoFRendering
//
//  Created by Bartłomiej Nowak on 10/11/2018.
//  Copyright © 2018 Bartłomiej Nowak. All rights reserved.
//

#import "DrawObjectsRenderPassEncoder.h"
#import "MetalRendererProperties.h"
#import "MathFunctions.h"

@interface DrawObjectsRenderPassEncoder ()
@property (nonatomic, strong) id<MTLDevice> device;
@property (nonatomic, strong) PassDescriptorBuilder* passBuilder;
@property (nonatomic, strong) RenderStateProvider* provider;
@property (nonatomic, strong) id<MTLBuffer> viewProjectionUniformsBuffer;
@property (nonatomic, strong) NSArray<NSArray<id<MTLBuffer>>*>* modelGroupUniformBuffers;
@property (nonatomic) MTLClearColor clearColor;
@end

@implementation DrawObjectsRenderPassEncoder

-(instancetype)initWithDevice:(id<MTLDevice>)device
                  passBuilder:(PassDescriptorBuilder*)passBuilder
        pipelineStateProvider:(RenderStateProvider*)provider
                   clearColor:(MTLClearColor)clearColor
{
    self = [super init];
    if (self) {
        self.device = device;
        self.passBuilder = passBuilder;
        self.provider = provider;
        self.viewProjectionUniformsBuffer = [self makeViewProjectionUniformsBufferOn:device];
        self.modelGroupUniformBuffers = @[];
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

//-(NSArray<id<MTLBuffer>> *)makeModelGroupUniforms
//{
//    NSMutableArray *drawObjectUniforms = [NSMutableArray new];
//    for (int i = 0; i < _drawableModelGroup.count; i++) {
//        id<MTLBuffer> buffer = [self.device newBufferWithLength:sizeof(ModelUniforms) * inFlightBufferCount
//                                                        options:MTLResourceOptionCPUCacheModeDefault];
//        buffer.label = [[NSString alloc] initWithFormat:@"Model %d Uniforms", i];
//        [drawObjectUniforms addObject:buffer];
//    }
//    return drawObjectUniforms;
//}


-(void)encodeDrawModelGroup:(ModelGroup*)modelGroup
            inCommandBuffer:(id<MTLCommandBuffer>)commandBuffer
         tripleBufferingIdx:(int)currentBufferIndex
             outputColorTex:(id<MTLTexture>)colorTexture
             outputDepthTex:(id<MTLTexture>)depthTexture
          cameraTranslation:(vector_float3)translation
                 drawableSz:(CGSize)size
{
    [self updateViewProjectionUniformsWith:currentBufferIndex drawableSize:size];
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
    const NSUInteger uniformBufferOffset = sizeof(ViewProjectionUniforms) * currentBufferIndex;
    for (int i = 0; i < self.modelGroupUniformBuffers.count; i++) {
        [encoder setVertexBuffer:self.modelGroupUniformBuffers[i] offset:uniformBufferOffset atIndex:1];
        [encoder drawIndexedPrimitives:MTLPrimitiveTypeTriangle
                            indexCount:modelGroup.mesh.indexBuffer.length / sizeof(MetalIndex)
                             indexType:MetalIndexType
                           indexBuffer:modelGroup.mesh.indexBuffer
                     indexBufferOffset:0];
    }
    [encoder endEncoding];
}

-(void)updateViewProjectionUniformsWith:(int)currentTripleBufferingIdx drawableSize:(CGSize)size
{
    const NSUInteger uniformBufferOffset = sizeof(ViewProjectionUniforms) * currentTripleBufferingIdx;
    for (int i = 0; i < inFlightBufferCount; i++) {
        ViewProjectionUniforms uniforms;
        uniforms.viewMatrix = [self viewMatrix];
        uniforms.projectionMatrix = [self projectionMatrixWith:size];
        memcpy([self.drawedModelUniforms[i] contents] + uniformBufferOffset, &uniforms, sizeof(uniforms));
    }
}

-(matrix_float4x4)viewMatrix
{
    const vector_float3 cameraTranslation = { 0, 0, -5 };
    const matrix_float4x4 viewMatrix = matrix_float4x4_translation(cameraTranslation);
    return viewMatrix;
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
