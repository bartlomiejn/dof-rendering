//
//  ViewportPresenter.m
//  MBE
//
//  Created by Bartłomiej Nowak on 08/11/2018.
//  Copyright © 2018 Bartłomiej Nowak. All rights reserved.
//

#import <simd/simd.h>
#import "ViewportPresenter.h"
#import "SliderStackViewModel.h"
#import "SliderViewModel.h"
#import "TeapotModel.h"
#import "OBJModel.h"
#import "OBJMesh.h"
#import "OBJGroup.h"
#import "MathFunctions.h"

@interface ViewportPresenter ()
@property (nonatomic, strong) SliderStackViewModel* sliders;
@property (nonatomic, strong) OBJMesh* teapotMesh;
@property (nonatomic, strong) NSArray<Model*>* teapots;
@property (nonatomic) float elapsedTime, xRotation, yRotation, zRotation;
@end

@implementation ViewportPresenter

#pragma mark - Init

- (instancetype)initWithDevice:(id<MTLDevice>)device
{
    self = [super init];
    if (self) {
        _elapsedTime = 0.0f;
        _sliders = [self makeSliders];
        _teapotMesh = [self createTeapotMeshIn:device];
        _teapots = [self createTeapotModels];
    }
    return self;
}

-(SliderStackViewModel*)makeSliders
{
    return [[SliderStackViewModel alloc] initWith:@[[[SliderViewModel alloc] initWithName:@"Focus Distance"
                                                                                 maxValue:100.0f
                                                                             currentValue:10.0f
                                                                                 minValue:0.1f],
                                                    [[SliderViewModel alloc] initWithName:@"Focus Range"
                                                                                 maxValue:20.0f
                                                                             currentValue:5.0f
                                                                                 minValue:0.1f]]];
}

-(NSArray<Model*>*)createTeapotModels
{
    NSMutableArray<Model*>* models;
    for (int i = 0; i < 3; i++) {
        Model *model = [[Model alloc] initWithMesh:_teapotMesh modelMatrix:[self modelMatrixForTeapotIndex:i]];
        [models addObject:model];
    }
    return models;
}

-(void)updateTeapotModels {
    [_teapots enumerateObjectsUsingBlock:^(Model *teapot, NSUInteger idx, BOOL* stop) {
        teapot.modelMatrix = [self modelMatrixForTeapotIndex:(int)idx];
    }];
}

-(OBJMesh*)createTeapotMeshIn:(id<MTLDevice>)device
{
    OBJGroup* group = [self loadOBJGroupFromModelNamed:@"teapot" groupNamed:@"teapot"];
    return [[OBJMesh alloc] initWithGroup:group device:device];
}

-(OBJGroup*)loadOBJGroupFromModelNamed:(NSString *)name groupNamed:(NSString *)groupName
{
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:name withExtension:@"obj"];
    OBJModel *model = [[OBJModel alloc] initWithContentsOfURL:modelURL generateNormals:YES];
    return [model groupForName:groupName];
}


-(matrix_float4x4)modelMatrixForTeapotIndex:(int)index
{
    const matrix_float4x4 translationMatrix = [self teapotTranslationForIndex:index];
    const matrix_float4x4 rotationMatrix = [self teapotRotationForIndex:index];
    const matrix_float4x4 scaleMatrix = [self teapotScaleForIndex:index];
    return matrix_multiply(matrix_multiply(translationMatrix, rotationMatrix), scaleMatrix);
}

-(matrix_float4x4)teapotTranslationForIndex:(int)index
{
    vector_float3 translation;
    if (index == 1) {
        translation = (vector_float3) { 0, 0, sinf(5 * _elapsedTime) * 0.5 + 1.5 };
    } else if (index == 2) {
        translation = (vector_float3) { 0.8, 12, -20.0 };
    } else {
        translation = (vector_float3) { -0.7, -4.1, -3.0 };
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

-(matrix_float4x4)teapotScaleForIndex:(int)index
{
    float scaleFactor;
    if (index == 1) {
        scaleFactor = 2.8;
    } else if (index == 2) {
        scaleFactor = sinf(5 * _elapsedTime) * 0.5 + 6;
    } else {
        scaleFactor = sinf(5 * _elapsedTime) * 0.5 + 3;
    }
    return matrix_float4x4_uniform_scale(scaleFactor);
}

#pragma mark - ViewportPresenter

- (void)viewDidLoad
{
    [_view presentSliders:_sliders];
    [_view presentModels:_teapots];
}

- (void)sliderValueChangedFor:(int)idx with:(float)value
{
    if (idx >= _sliders.sliders.count) {
        return;
    }
    _sliders.sliders[idx].currentValue = value;
}

-(void)willRenderNextFrameTo:(id<CAMetalDrawable>)drawable
                      ofSize:(CGSize)drawableSize
               frameDuration:(float)frameDuration
{
    _elapsedTime += frameDuration;
    _xRotation += frameDuration * (M_PI / 2);
    _yRotation += frameDuration * (M_PI / 3);
    _zRotation = 0;
    [self updateTeapotModels];
    [_view presentModels:_teapots];
    [_view drawNextFrameTo:drawable ofSize:drawableSize];
}

@end
