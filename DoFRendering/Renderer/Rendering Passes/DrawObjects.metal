//
//  DrawObjects.metal
//  DoFRendering
//
//  Created by Bartłomiej Nowak on 10/11/2018.
//  Copyright © 2018 Bartłomiej Nowak. All rights reserved.
//

#include <metal_stdlib>
using namespace metal;

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
