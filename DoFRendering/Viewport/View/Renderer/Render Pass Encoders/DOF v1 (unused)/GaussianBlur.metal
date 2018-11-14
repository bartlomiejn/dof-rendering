//
//  GaussianBlur.metal
//  DoFRendering
//
//  Created by Bartłomiej Nowak on 14/11/2018.
//  Copyright © 2018 Bartłomiej Nowak. All rights reserved.
//

#include <metal_stdlib>
using namespace metal;
#include "../TextureMappingVertex.h"

constexpr sampler texSampler(address::clamp_to_zero, filter::linear, coord::normalized);

typedef struct {
    bool isVertical;
    float blurRadius;
    float2 imageDimensions;
} GaussianBlurUniforms;

/// Applies horizontal or vertical approximated gaussian blur to texture.
fragment half4
gaussian_blur(TextureMappingVertex mappingVertex [[stage_in]],
              constant GaussianBlurUniforms *uniforms [[buffer(0)]],
              texture2d<float, access::sample> colorTexture [[texture(0)]],
              depth2d<float, access::sample> depthTexture [[texture(1)]])
{
    float2 texCoord = mappingVertex.textureCoordinate;
    
    // Reduce X step to 0.0 if isVertical, vice versa for Y
    float xBlurOffsetStep = uniforms->blurRadius / uniforms->imageDimensions.x * (uniforms->isVertical ? 0.0 : 1.0);
    float yBlurOffsetStep = uniforms->blurRadius / uniforms->imageDimensions.x * (uniforms->isVertical ? 1.0 : 0.0);
    
    float4 sum = float4(0.0);
    sum += colorTexture.sample(texSampler, float2(texCoord.x - 4.0*xBlurOffsetStep, texCoord.y - 4.0*yBlurOffsetStep)) * 0.0162162162;
    sum += colorTexture.sample(texSampler, float2(texCoord.x - 3.0*xBlurOffsetStep, texCoord.y - 3.0*yBlurOffsetStep)) * 0.0540540541;
    sum += colorTexture.sample(texSampler, float2(texCoord.x - 2.0*xBlurOffsetStep, texCoord.y - 2.0*yBlurOffsetStep)) * 0.1216216216;
    sum += colorTexture.sample(texSampler, float2(texCoord.x - 1.0*xBlurOffsetStep, texCoord.y - 1.0*yBlurOffsetStep)) * 0.1945945946;
    sum += colorTexture.sample(texSampler, texCoord) * 0.2270270270;
    sum += colorTexture.sample(texSampler, float2(texCoord.x + 1.0*xBlurOffsetStep, texCoord.y + 1.0*yBlurOffsetStep)) * 0.1945945946;
    sum += colorTexture.sample(texSampler, float2(texCoord.x + 2.0*xBlurOffsetStep, texCoord.y + 2.0*yBlurOffsetStep)) * 0.1216216216;
    sum += colorTexture.sample(texSampler, float2(texCoord.x + 3.0*xBlurOffsetStep, texCoord.y + 3.0*yBlurOffsetStep)) * 0.0540540541;
    sum += colorTexture.sample(texSampler, float2(texCoord.x + 4.0*xBlurOffsetStep, texCoord.y + 4.0*yBlurOffsetStep)) * 0.0162162162;
    return half4(sum);
}
