//
//  DrawObjectsPassEncoder.m
//  DoFRendering
//
//  Created by Bartłomiej Nowak on 10/11/2018.
//  Copyright © 2018 Bartłomiej Nowak. All rights reserved.
//

#import "DrawObjectsPassEncoder.h"
#import "MetalRendererProperties.h"
#import "ViewProjectionUniforms.h"
#import "ModelUniforms.h"
#import "MathFunctions.h"

@interface DrawObjectsPassEncoder ()
@property (nonatomic, strong) id<MTLDevice> device;
@property (nonatomic, strong) id<MTLRenderPipelineState> pipelineState;
@property (nonatomic, strong) id<MTLDepthStencilState> depthStencilState;
@property (nonatomic, strong) id<MTLBuffer> viewProjectionUniformsBuffer;
@property (nonatomic, strong) id<MTLBuffer> modelGroupUniformsBuffer;
@property (nonatomic) int modelGroupUniformsBufferCount;
@end

@implementation DrawObjectsPassEncoder

-(instancetype)initWithDevice:(id<MTLDevice>)device
{
    self = [super init];
    if (self) {
        self.device = device;
        self.pipelineState = [self drawObjectsPipelineStateOnDevice:device];
        self.depthStencilState = [self depthStencilStateOnDevice:device];
        self.viewProjectionUniformsBuffer = [self makeViewProjectionUniformsBufferOn:device];
        self.modelGroupUniformsBuffer = [self makeModelGroupUniformsBufferOn:device uniformCount:0];
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
    NSError *error = nil;
    id<MTLRenderPipelineState> pipelineState = [device newRenderPipelineStateWithDescriptor:descriptor error:&error];
    if (!pipelineState) {
        NSLog(@"Error occurred when creating render pipeline state: %@", error);
    }
    return pipelineState;
}

-(id<MTLDepthStencilState>)depthStencilStateOnDevice:(id<MTLDevice>)device {
    MTLDepthStencilDescriptor *depthStencilDescriptor = [MTLDepthStencilDescriptor new];
    depthStencilDescriptor.depthCompareFunction = MTLCompareFunctionLess;
    depthStencilDescriptor.depthWriteEnabled = YES;
    return [device newDepthStencilStateWithDescriptor:depthStencilDescriptor];
}

-(id<MTLBuffer>)makeViewProjectionUniformsBufferOn:(id<MTLDevice>)device
{
    id<MTLBuffer> buffer = [self.device newBufferWithLength:sizeof(ViewProjectionUniforms) * tripleBufferCount
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
                 clearColor:(MTLClearColor)clearColor
{
    [self updateModelUniformsFor:modelGroup];
    [self updateViewProjectionUniformsAt:currentBufferIndex cameraTranslation:translation drawableSize:size];
    MTLRenderPassDescriptor *descriptor = [self renderObjectsPassDescriptorOfSize:size
                                                                       clearColor:clearColor
                                                               outputColorTexture:colorTexture
                                                               outputDepthTexture:depthTexture];
    id<MTLRenderCommandEncoder> encoder = [commandBuffer renderCommandEncoderWithDescriptor:descriptor];
    [encoder setLabel:@"Draw Objects"];
    [encoder setRenderPipelineState:self.pipelineState];
    [encoder setDepthStencilState:self.depthStencilState];
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
    // If our next modelGroup count is bigger than our uniforms buffer, expand it
    if (modelGroup.count > self.modelGroupUniformsBufferCount) {
        self.modelGroupUniformsBuffer = [self makeModelGroupUniformsBufferOn:self.device uniformCount:modelGroup.count];
    }
    ModelUniforms modelGroupUniforms[modelGroup.count];
    for (int i = 0; i < modelGroup.count; i++) {
        modelGroupUniforms[i] = (ModelUniforms) { modelGroup.transformations[i] };
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


-(MTLRenderPassDescriptor *)renderObjectsPassDescriptorOfSize:(CGSize)size
                                                   clearColor:(MTLClearColor)clearColor
                                           outputColorTexture:(id<MTLTexture>)colorTexture
                                           outputDepthTexture:(id<MTLTexture>)depthTexture
{
    MTLRenderPassDescriptor *descriptor = [MTLRenderPassDescriptor renderPassDescriptor];
    descriptor.colorAttachments[0].texture = colorTexture;
    descriptor.colorAttachments[0].clearColor = clearColor;
    descriptor.colorAttachments[0].loadAction = MTLLoadActionClear;
    descriptor.colorAttachments[0].storeAction = MTLStoreActionStore;
    descriptor.depthAttachment.texture = depthTexture;
    descriptor.depthAttachment.clearDepth = 1.0;
    descriptor.depthAttachment.loadAction = MTLLoadActionClear;
    descriptor.depthAttachment.storeAction = MTLStoreActionStore;
    descriptor.renderTargetWidth = size.width;
    descriptor.renderTargetHeight = size.height;
    return descriptor;
}

-(matrix_float4x4)projectionMatrixWith:(CGSize)drawableSize
{
    const float aspectRatio = drawableSize.width / drawableSize.height;
    const float fov = (2 * M_PI) / 5;
    const float near = 1.0;
    const float far = 100;
    return matrix_float4x4_perspective(aspectRatio, fov, near, far);
}

@end
