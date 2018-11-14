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

fragment half4 bokeh(TextureMappingVertex vert [[stage_in]],
                     depth2d<float, access::sample> cocTex [[texture(0)]])
{
    return half4(0);
}
