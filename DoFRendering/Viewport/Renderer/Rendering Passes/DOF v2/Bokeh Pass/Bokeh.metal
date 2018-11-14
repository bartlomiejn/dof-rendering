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

// From https://github.com/Unity-Technologies/PostProcessing/blob/v2/PostProcessing/Shaders/Builtins/DiskKernels.hlsl
static constant int diskKernelSampleCount = 16;
static constant float2 diskKernel[diskKernelSampleCount] = {
    float2(0, 0),
    float2(0.54545456, 0),
    float2(0.16855472, 0.5187581),
    float2(-0.44128203, 0.3206101),
    float2(-0.44128197, -0.3206102),
    float2(0.1685548, -0.5187581),
    float2(1, 0),
    float2(0.809017, 0.58778524),
    float2(0.30901697, 0.95105654),
    float2(-0.30901703, 0.9510565),
    float2(-0.80901706, 0.5877852),
    float2(-1, 0),
    float2(-0.80901694, -0.58778536),
    float2(-0.30901664, -0.9510566),
    float2(0.30901712, -0.9510565),
    float2(0.80901694, -0.5877853),
};

constexpr sampler texSampler(address::clamp_to_zero, filter::linear, coord::normalized);

fragment half4 bokeh(TextureMappingVertex vert [[stage_in]],
                     constant float2& texelSize [[buffer(0)]],
                     texture2d<float, access::sample> colorTex [[texture(0)]])
{
    half3 color = 0;
    for (int k=0; k<diskKernelSampleCount; k++) {
        float2 o = diskKernel[k];
        o *= texelSize.xy;
        color += (half3)colorTex.sample(texSampler, vert.textureCoordinate + o).rgb;
    }
    color *= 1.0 / diskKernelSampleCount;
    return half4(color, 1);
}
