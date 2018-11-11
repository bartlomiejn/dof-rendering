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
#import "ModelGroup.h"
#import "OBJMesh.h"
#import "MathFunctions.h"

@interface ViewportPresenter ()
@property (nonatomic, strong) ModelTransformationBuilder* builder;
@property (nonatomic, strong) SliderStackViewModel* sliderViewModels;
@property (nonatomic, strong) ModelGroup* teapotGroup;
@end

@implementation ViewportPresenter

#pragma mark - Init

-(instancetype)initWithMeshLoader:(OBJMeshLoader*)loader transformationBuilder:(ModelTransformationBuilder*)builder
{
    self = [super init];
    if (self) {
        _builder = builder;
        _sliderViewModels = [self makeSliders];
        _teapotGroup = [self makeTeapotGroupWith:[loader meshFromFilename:@"teapot" groupName:@"teapot"]];
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

-(ModelGroup*)makeTeapotGroupWith:(OBJMesh*)mesh
{
    int transformationsCount = 3;
    matrix_float4x4* transformations = malloc(sizeof(matrix_float4x4)*transformationsCount);
    if (transformations == nil) {
        return nil;
    }
    for (int i = 0; i < transformationsCount; i++) {
        transformations[i] = [self.builder transformationMatrixForModelIndex:i];
    }
    return [[ModelGroup alloc] initWithMesh:mesh transformations:transformations count:transformationsCount];
}

#pragma mark - ViewportPresenter

- (void)viewDidLoad
{
    [_view presentSliders:_sliderViewModels];
    [_view presentModelGroup:_teapotGroup];
}

- (void)sliderValueChangedFor:(int)idx with:(float)value
{
    if (idx >= _sliderViewModels.sliders.count) {
        return;
    }
    _sliderViewModels.sliders[idx].currentValue = value;
}

-(void)willRenderNextFrameTo:(id<CAMetalDrawable>)drawable
                      ofSize:(CGSize)drawableSize
               frameDuration:(float)frameDuration
{
    [self updateTeapotModelGroupFor:frameDuration];
    [_view presentModelGroup:_teapotGroup];
    [_view drawNextFrameTo:drawable ofSize:drawableSize];
}

-(void)updateTeapotModelGroupFor:(float)frameDuration {
    [_builder addLastFrameDuration:frameDuration];
    for (int offset = 0; offset < _teapotGroup.count; offset++) {
        _teapotGroup.transformations[offset] = [self.builder transformationMatrixForModelIndex:offset];
    }
}

@end
