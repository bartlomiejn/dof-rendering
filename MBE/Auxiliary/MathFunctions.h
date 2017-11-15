//
//  MathFunctions.h
//  MBE
//
//  Created by Bartłomiej Nowak on 15/11/2017.
//  Copyright © 2017 Bartłomiej Nowak. All rights reserved.
//
//  Code taken from Metal By Example book repository at: https://github.com/metal-by-example/sample-code

#ifndef MathFunctions_h
#define MathFunctions_h

@import simd;

/// Builds a translation matrix that translates by the supplied vector
matrix_float4x4 matrix_float4x4_translation(vector_float3 t);

/// Builds a scale matrix that uniformly scales all axes by the supplied factor
matrix_float4x4 matrix_float4x4_uniform_scale(float scale);

/// Builds a rotation matrix that rotates about the supplied axis by an
/// angle (given in radians). The axis should be normalized.
matrix_float4x4 matrix_float4x4_rotation(vector_float3 axis, float angle);

/// Builds a symmetric perspective projection matrix with the supplied aspect ratio,
/// vertical field of view (in radians), and near and far distances
matrix_float4x4 matrix_float4x4_perspective(float aspect, float fovy, float near, float far);

#endif /* MathFunctions_h */
