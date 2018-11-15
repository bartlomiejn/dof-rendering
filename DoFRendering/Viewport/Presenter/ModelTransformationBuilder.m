//
//  ModelTransformationBuilder.m
//  DoFRendering
//
//  Created by Bartłomiej Nowak on 11/11/2018.
//  Copyright © 2018 Bartłomiej Nowak. All rights reserved.
//

#import "ModelTransformationBuilder.h"
#import "MathFunctions.h"

@interface ModelTransformationBuilder ()
@property (nonatomic) float elapsedTime, xRotation, yRotation, zRotation;
@end

@implementation ModelTransformationBuilder

- (instancetype)init
{
    self = [super init];
    if (self) {
        _elapsedTime = 0.0f;
        _xRotation = 0.0f;
        _yRotation = 0.0f;
        _zRotation = 0.0f;
    }
    return self;
}

-(void)addLastFrameDuration:(float)frameDuration
{
    _elapsedTime += frameDuration;
    _xRotation += frameDuration * (M_PI / 2);
    _yRotation += frameDuration * (M_PI / 3);
    _zRotation = 0;
}

-(matrix_float4x4)transformationMatrixForModelIndex:(int)index
{
    matrix_float4x4 translationMatrix = [self teapotTranslationForIndex:index];
    matrix_float4x4 rotationMatrix = [self teapotRotationForIndex:index];
    matrix_float4x4 scaleMatrix = matrix_float4x4_uniform_scale(3.0);
    return matrix_multiply(matrix_multiply(translationMatrix, rotationMatrix), scaleMatrix);
}

-(matrix_float4x4)teapotTranslationForIndex:(int)index
{
    vector_float3 translation;
    if (index == 1) {
        translation = (vector_float3) { 0.0, 1.0, 0.0 };
    } else if (index == 2) {
        translation = (vector_float3) { 0.8, 12.0, -20.0 };
    } else {
        translation = (vector_float3) { -0.7, -1.1, -3.0 };
    }
    return matrix_float4x4_translation(translation);
}

-(matrix_float4x4)teapotRotationForIndex:(int)index
{
    vector_float3 xAxis = { 1, 0, 0 };
    vector_float3 yAxis = { 0, 1, 0 };
    vector_float3 zAxis = { 0, 0, 1 };
    matrix_float4x4 xRotation = matrix_float4x4_rotation(xAxis, _xRotation);
    matrix_float4x4 yRotation = matrix_float4x4_rotation(yAxis, _yRotation);
    matrix_float4x4 zRotation = matrix_float4x4_rotation(zAxis, _zRotation);
    return matrix_multiply(matrix_multiply(xRotation, yRotation), zRotation);
}

@end
