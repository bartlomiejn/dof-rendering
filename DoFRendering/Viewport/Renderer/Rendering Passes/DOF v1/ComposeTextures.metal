//
//  ComposeTextures.metal
//  DoFRendering
//
//  Created by Bartłomiej Nowak on 03/11/2017.
//  Copyright © 2017 Bartłomiej Nowak. All rights reserved.
//

#include <metal_stdlib>
using namespace metal;
#include "../TextureMappingVertex.h"

constexpr sampler texSampler(address::clamp_to_zero, filter::linear, coord::normalized);

fragment half4
composite_textures(TextureMappingVertex mappingVertex [[stage_in]],
                   texture2d<float, access::sample> focusTexture [[texture(0)]],
                   texture2d<float, access::sample> outOfFocusTexture [[texture(1)]])
{
    float4 fSample = focusTexture.sample(texSampler, mappingVertex.textureCoordinate);
    float3 fRgb = fSample.rgb * fSample.a;
    float4 oofSample = outOfFocusTexture.sample(texSampler, mappingVertex.textureCoordinate);
    float3 oofRgb = oofSample.rgb * oofSample.a;
    return half4(fRgb.r + oofRgb.r, fRgb.g + oofRgb.g, fRgb.b + oofRgb.b, 255.0);
}
