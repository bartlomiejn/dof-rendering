//
//  ShaderTypes.h
//  MBE
//
//  Created by Bartłomiej Nowak on 17.03.2018.
//  Copyright © 2018 Bartłomiej Nowak. All rights reserved.
//

#ifndef ShaderTypes_h
#define ShaderTypes_h

#include <simd/simd.h>

typedef struct {
    vector_float4 position;
    vector_float4 color;
} MetalVertex;

typedef struct {
    matrix_float4x4 modelViewProjectionMatrix;
} MetalUniforms;

#endif /* ShaderTypes_h */
