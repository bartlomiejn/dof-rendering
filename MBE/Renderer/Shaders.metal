//
//  Shaders.metal
//  MBE
//
//  Created by Bartłomiej Nowak on 03/11/2017.
//  Copyright © 2017 Bartłomiej Nowak. All rights reserved.
//

#include <metal_stdlib>
using namespace metal;

struct Vertex {
    float4 position [[position]];
    float4 color;
};

struct Uniforms {
    float4x4 modelViewProjectionMatrix;
};

vertex Vertex vert_passthrough(device Vertex *in_verts [[buffer(0)]],
                               constant Uniforms *uniforms [[buffer(1)]],
                               uint vid [[vertex_id]]) {
    
    Vertex out_vert;
    out_vert.position = uniforms->modelViewProjectionMatrix * in_verts[vid].position;
    out_vert.color = in_verts[vid].color;
    return out_vert;
}

fragment half4 frag_passthrough(Vertex in_vert [[stage_in]]) {
    return half4(in_vert.color);
}
