//
//  Shaders.metal
//  MBE
//
//  Created by Bartłomiej Nowak on 03/11/2017.
//  Copyright © 2017 Bartłomiej Nowak. All rights reserved.
//

#include <metal_stdlib>
#include "ShaderTypes.h"
using namespace metal;

struct Vertex {
    float4 position [[position]];
    float4 color;
};

struct Uniforms {
    float4x4 modelViewProjectionMatrix;
};

vertex Vertex vert_passthrough(device Vertex *inputVerts [[buffer(0)]],
                               constant Uniforms *uniforms [[buffer(1)]],
                               uint vid [[vertex_id]]) {
    
    Vertex outputVert;
    outputVert.position = uniforms->modelViewProjectionMatrix * inputVerts[vid].position;
    outputVert.color = inputVerts[vid].color;
    return outputVert;
}

fragment half4 frag_passthrough(Vertex inputVert [[stage_in]]) {
    return half4(inputVert.color);
}
