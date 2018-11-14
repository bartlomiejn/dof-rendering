//
//  ViewportPresenter.m
//  DoFRendering
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
                                                                                 maxValue:2.0f
                                                                             currentValue:0.8f
                                                                                 minValue:0.005f],
                                                    [[SliderViewModel alloc] initWithName:@"Focus Range"
                                                                                 maxValue:2.0f
                                                                             currentValue:0.22f
                                                                                 minValue:0.005f],
                                                    [[SliderViewModel alloc] initWithName:@"Bokeh Radius"
                                                                                 maxValue:20.0f
                                                                             currentValue:3.0f
                                                                                 minValue:1.0f]]];
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
    [self.view presentSliders:_sliderViewModels];
    [self.view drawModelGroup:_teapotGroup];
    [self.view setDrawFocusDistance:self.sliderViewModels.sliders[0].currentValue
                         focusRange:self.sliderViewModels.sliders[1].currentValue];
    [self.view setDrawBokehRadius:self.sliderViewModels.sliders[2].currentValue];
}

- (void)sliderValueChangedFor:(int)idx with:(float)value
{
    if (idx >= self.sliderViewModels.sliders.count) {
        return;
    }
    self.sliderViewModels.sliders[idx].currentValue = value;
    switch (idx) {
        case 0:
        case 1:
            [self.view setDrawFocusDistance:self.sliderViewModels.sliders[0].currentValue
                                 focusRange:self.sliderViewModels.sliders[1].currentValue];
            break;
        case 2:
            [self.view setDrawBokehRadius:self.sliderViewModels.sliders[2].currentValue];
            break;
    }
}

-(void)willRenderNextFrameTo:(id<CAMetalDrawable>)drawable
                      ofSize:(CGSize)drawableSize
               frameDuration:(float)frameDuration
{
    [self updateAndDrawTeapotModelGroupFor:frameDuration];
    [self.view drawNextFrameTo:drawable ofSize:drawableSize];
}

-(void)updateAndDrawTeapotModelGroupFor:(float)frameDuration {
    [self.builder addLastFrameDuration:frameDuration];
    for (int offset = 0; offset < self.teapotGroup.count; offset++) {
        self.teapotGroup.transformations[offset] = [self.builder transformationMatrixForModelIndex:offset];
    }
    [self.view drawModelGroup:self.teapotGroup];
}

@end
