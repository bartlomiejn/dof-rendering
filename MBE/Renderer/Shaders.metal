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
 Masks RGB near field using inverted D texture as mask.
 */
fragment half4
mask_focus_field(TextureMappingVertex mappingVertex [[stage_in]],
                 texture2d<float, access::sample> colorTexture [[texture(0)]],
                 texture2d<float, access::sample> depthTexture [[texture(1)]]) {
    float4 colorFrag = colorTexture.sample(sampl, mappingVertex.textureCoordinate);
    colorFrag.a = (1.0 - depthTexture.sample(sampl, mappingVertex.textureCoordinate).r);
    return half4(colorFrag);
}

/**
 Masks RGB far field using D texture as mask.
 TODO: Merge with above with inersion passed as parameter to uniform
 */
fragment half4
mask_outoffocus_field(TextureMappingVertex mappingVertex [[stage_in]],
                      texture2d<float, access::sample> colorTexture [[texture(0)]],
                      texture2d<float, access::sample> depthTexture [[texture(1)]]) {
    float4 colorFrag = colorTexture.sample(sampl, mappingVertex.textureCoordinate);
    colorFrag.a = depthTexture.sample(sampl, mappingVertex.textureCoordinate).r;
    return half4(colorFrag);
}

typedef struct {
    float blurRadius;
    float2 imageDimensions;
} GaussianBlurUniforms;

/**
 Applies horizontal gaussian blur to texture.
 */
fragment half4
horizontal_gaussian_blur(TextureMappingVertex mappingVertex [[stage_in]],
                         constant GaussianBlurUniforms *uniforms [[buffer(0)]],
                         texture2d<float, access::sample> colorTexture [[texture(0)]],
                         texture2d<float, access::sample> depthTexture [[texture(1)]]) {
    float2 texCoord = mappingVertex.textureCoordinate;
    float4 sum = float4(0.0);
    float blurStep = uniforms->blurRadius / uniforms->imageDimensions.x;
    sum += colorTexture.sample(sampl, float2(texCoord.x - 4.0*blurStep, texCoord.y)) * 0.0162162162;
    sum += colorTexture.sample(sampl, float2(texCoord.x - 3.0*blurStep, texCoord.y)) * 0.0540540541;
    sum += colorTexture.sample(sampl, float2(texCoord.x - 2.0*blurStep, texCoord.y)) * 0.1216216216;
    sum += colorTexture.sample(sampl, float2(texCoord.x - 1.0*blurStep, texCoord.y)) * 0.1945945946;
    sum += colorTexture.sample(sampl, texCoord) * 0.2270270270;
    sum += colorTexture.sample(sampl, float2(texCoord.x + 1.0*blurStep, texCoord.y)) * 0.1945945946;
    sum += colorTexture.sample(sampl, float2(texCoord.x + 2.0*blurStep, texCoord.y)) * 0.1216216216;
    sum += colorTexture.sample(sampl, float2(texCoord.x + 3.0*blurStep, texCoord.y)) * 0.0540540541;
    sum += colorTexture.sample(sampl, float2(texCoord.x + 4.0*blurStep, texCoord.y)) * 0.0162162162;
    half4 frag = half4(colorTexture.sample(sampl, texCoord));
    frag.a = 1.0;
    frag *= half4(sum);
    return frag;
}

