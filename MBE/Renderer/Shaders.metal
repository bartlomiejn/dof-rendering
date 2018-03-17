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
    float4x4 modelViewProjectionMatrix;
} MetalUniforms;

vertex MetalVertex vert_passthrough(device MetalVertex *inputVerts [[buffer(0)]],
                               constant MetalUniforms *uniforms [[buffer(1)]],
                               uint vid [[vertex_id]]) {
    MetalVertex outputVert;
    outputVert.position = uniforms->modelViewProjectionMatrix * inputVerts[vid].position;
    outputVert.color = inputVerts[vid].color;
    return outputVert;
}

fragment half4 frag_passthrough(MetalVertex inputVert [[stage_in]]) {
    return half4(inputVert.color);
}

#pragma mark - Bloom

fragment half4 frag_bloom(MetalVertex inputVert [[stage_in]]) {
    return half4(inputVert.color);
}
