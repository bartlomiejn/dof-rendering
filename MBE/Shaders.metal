//
//  Shaders.metal
//  MBE
//
//  Created by Bartłomiej Nowak on 03/11/2017.
//  Copyright © 2017 Bartłomiej Nowak. All rights reserved.
//

#include <metal_stdlib>
using namespace metal;

struct Vertex
{
    float4 position [[position]];
    float4 color;
};

vertex Vertex vert_passthrough(device Vertex *vertices [[buffer(0)]], uint vert_id [[vertex_id]])
{
    return vertices[vert_id];
}

fragment float4 frag_passthrough(Vertex in_vert [[stage_in]])
{
    return in_vert.color;
}
