//
//  ViewProjectionUniforms.h
//  DoFRendering
//
//  Created by Bartłomiej Nowak on 12/11/2018.
//  Copyright © 2018 Bartłomiej Nowak. All rights reserved.
//

#ifndef ViewProjectionUniforms_h
#define ViewProjectionUniforms_h

typedef struct {
    simd_float4x4 viewMatrix, projectionMatrix;
} ViewProjectionUniforms;

#endif /* ViewProjectionUniforms_h */
