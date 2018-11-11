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
#import "Model.h"
#import "OBJMesh.h"
#import "MathFunctions.h"

@interface ViewportPresenter ()
@property (nonatomic, strong) ModelTransformationBuilder* builder;
@property (nonatomic, strong) SliderStackViewModel* sliders;
@property (nonatomic, strong) OBJMesh* teapotMesh;
@property (nonatomic, strong) NSArray<Model*>* teapots;
@end

@implementation ViewportPresenter

#pragma mark - Init

-(instancetype)initWithMeshLoader:(OBJMeshLoader*)loader transformationBuilder:(ModelTransformationBuilder*)builder
{
    self = [super init];
    if (self) {
        _builder = builder;
        _sliders = [self makeSliders];
        _teapotMesh = [loader meshFromFilename:@"teapot" groupName:@"teapot"];
        _teapots = [self makeTeapotModels];
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

-(NSArray<Model*>*)makeTeapotModels
{
    NSMutableArray<Model*>* models;
    for (int i = 0; i < 3; i++) {
        [models addObject:[[Model alloc] initWithMesh:_teapotMesh
                                       transformation:[_builder transformationMatrixForModelIndex:i]]];
    }
    return models;
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
    [self updateTeapotModelsWith:frameDuration];
    [_view presentModels:_teapots];
    [_view drawNextFrameTo:drawable ofSize:drawableSize];
}

-(void)updateTeapotModelsWith:(float)frameDuration {
    [_builder addLastFrameDuration:frameDuration];
    [_teapots enumerateObjectsUsingBlock:^(Model *teapot, NSUInteger idx, BOOL* stop) {
        teapot.transformation = [self.builder transformationMatrixForModelIndex:(int)idx];
    }];
}

@end
