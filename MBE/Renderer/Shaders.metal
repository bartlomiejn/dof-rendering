//
//  Shaders.metal
//  MBE
//
//  Created by Bartłomiej Nowak on 03/11/2017.
//  Copyright © 2017 Bartłomiej Nowak. All rights reserved.
//

#include <metal_stdlib>
using namespace metal;

#pragma mark - Draw Objects

typedef struct {
    float4 position [[position]];
    float4 color;
} MetalVertex;
typedef struct {
    float4x4 modelMatrix;
    float4x4 viewMatrix;
    float4x4 projectionMatrix;
} RenderObjectUniforms;

vertex MetalVertex
map_vertices(device MetalVertex *inputVerts [[buffer(0)]],
             constant RenderObjectUniforms *uniforms [[buffer(1)]],
             uint vid [[vertex_id]]) {
    float4x4 mvpMatrix = uniforms->projectionMatrix * (uniforms->viewMatrix * uniforms->modelMatrix);
    
    MetalVertex outputVert;
    outputVert.position = mvpMatrix * inputVerts[vid].position;
    outputVert.color = inputVerts[vid].color;
    return outputVert;
}

fragment half4
color_passthrough(MetalVertex inputVert [[stage_in]]) {
    return half4(inputVert.color);
}

#pragma mark - Bloom

typedef struct {
    float4 renderedCoordinate [[position]];
    float2 textureCoordinate;
} TextureMappingVertex;

/**
 Maps provided vertices to corners of drawable texture.
 */
vertex TextureMappingVertex
map_texture(unsigned int vertex_id [[ vertex_id ]]) {
    
    float4x4 renderedCoordinates = float4x4(float4(-1.0, -1.0, 0.0, 1.0),
                                            float4( 1.0, -1.0, 0.0, 1.0),
                                            float4(-1.0,  1.0, 0.0, 1.0),
                                            float4( 1.0,  1.0, 0.0, 1.0));
    float4x2 textureCoordinates = float4x2(float2(0.0, 1.0),
                                           float2(1.0, 1.0),
                                           float2(0.0, 0.0),
                                           float2(1.0, 0.0));
    
    TextureMappingVertex outVertex;
    outVertex.renderedCoordinate = renderedCoordinates[vertex_id];
    outVertex.textureCoordinate = textureCoordinates[vertex_id];
    return outVertex;
}

constexpr sampler sampl(address::clamp_to_zero, filter::linear, coord::normalized);

/**
 Adds DoF effect from provided color and depth texture.
 */
fragment half4
dof_blur_texture(TextureMappingVertex mappingVertex [[stage_in]],
                 texture2d<float, access::sample> colorTexture [[texture(0)]],
                 texture2d<float, access::sample> depthTexture [[texture(1)]]) {
//    Bloom code
//    half4 bloomSum(0.0, 0.0, 0.0, 0.0);
//    for (int i = -2; i <= 2; i++) {
//        for (int j = -2; i <= 2; i++) {
//            float2 offset = float2(i, j) * float2(0.005, 0.005);
//            bloomSum += half4(colorTexture.sample(sampl, mappingVertex.textureCoordinate + offset));
//        }
//    }
//    half4 bloomedPixel = (bloomSum / 25.0) + half4(colorTexture.sample(sampl, mappingVertex.textureCoordinate));
    
    return half4(colorTexture.sample(sampl, mappingVertex.textureCoordinate));
}

