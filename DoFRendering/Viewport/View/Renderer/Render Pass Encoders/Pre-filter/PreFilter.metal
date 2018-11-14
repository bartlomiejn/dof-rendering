//
//  PreFilter.metal
//  DoFRendering
//
//  Created by Bartłomiej Nowak on 14/11/2018.
//  Copyright © 2018 Bartłomiej Nowak. All rights reserved.
//

#include <metal_stdlib>
using namespace metal;
#include "../TextureMappingVertex.h"

constexpr sampler texSampler(address::clamp_to_zero, filter::linear, coord::normalized);

/// Downsamples CoC texture, taking the most extreme value out of the four texels
fragment half4 downsample_coc(TextureMappingVertex vert [[stage_in]],
                              constant float2& texelSize [[buffer(0)]],
                              texture2d<float, access::sample> cocTex [[texture(0)]])
{
    float4 o = texelSize.xyxy * float2(-0.5, 0.5).xxyy;
    half coc0 = cocTex.sample(texSampler, vert.textureCoordinate + o.xy).r;
    half coc1 = cocTex.sample(texSampler, vert.textureCoordinate + o.zy).r;
    half coc2 = cocTex.sample(texSampler, vert.textureCoordinate + o.xw).r;
    half coc3 = cocTex.sample(texSampler, vert.textureCoordinate + o.zw).r;
    half cocMin = min(min(min(coc0, coc1), coc2), coc3);
    half cocMax = max(max(max(coc0, coc1), coc2), coc3);
    return cocMax >= -cocMin ? cocMax : cocMin;
}


