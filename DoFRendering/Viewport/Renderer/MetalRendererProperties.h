//
//  MetalRendererProperties.h
//  DoFRendering
//
//  Created by Bartłomiej Nowak on 12/11/2018.
//  Copyright © 2018 Bartłomiej Nowak. All rights reserved.
//

#ifndef MetalRendererProperties_h
#define MetalRendererProperties_h

#import <Metal/Metal.h>
#import <simd/simd.h>

typedef uint16_t MetalIndex;
const MTLIndexType MetalIndexType = MTLIndexTypeUInt16;
static const NSInteger inFlightBufferCount = 3;

typedef struct __attribute((packed))
{
    vector_float4 position;
    vector_float4 normal;
} OBJMeshVertex;

#endif /* MetalRendererProperties_h */
