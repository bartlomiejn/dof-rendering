//
//  Bokeh.metal
//  DoFRendering
//
//  Created by Bartłomiej Nowak on 14/11/2018.
//  Copyright © 2018 Bartłomiej Nowak. All rights reserved.
//

#include <metal_stdlib>
using namespace metal;
#include "../../TextureMappingVertex.h"

constexpr sampler texSampler(address::clamp_to_zero, filter::linear, coord::normalized);

fragment half4 bokeh(TextureMappingVertex vert [[stage_in]],
                     constant float2& texelSize [[buffer(0)]],
                     texture2d<float, access::sample> colorTex [[texture(0)]])
{
    half3 color = 0;
    for (int u=-4; u<=4; u++) {
        for (int v=-4; v<=4; v++) {
            float2 o = float2(u, v) * texelSize.xy;
            color += (half3)colorTex.sample(texSampler, vert.textureCoordinate + o).rgb;
        }
    }
//    color *= 1.0 / 9;
    return half4(color, 1);
}
