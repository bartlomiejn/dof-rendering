//
//  MBETypes.h
//  MBE
//
//  Created by Bartłomiej Nowak on 16.03.2018.
//  Copyright © 2018 Bartłomiej Nowak. All rights reserved.
//

#ifndef MBETypes_h
#define MBETypes_h

#import <simd/simd.h>
#import <Metal/Metal.h>

typedef uint16_t MBEIndex;
const MTLIndexType MBEIndexType = MTLIndexTypeUInt16;

typedef struct __attribute((packed))
{
    vector_float4 position;
    vector_float4 normal;
} MBEVertex;

typedef struct __attribute((packed))
{
    matrix_float4x4 modelViewProjectionMatrix;
    matrix_float4x4 modelViewMatrix;
    matrix_float3x3 normalMatrix;
} MBEUniforms;


#endif /* MBETypes_h */
