//
//  ViewportViewController.m
//  MBE
//
//  Created by Bartłomiej Nowak on 03/11/2017.
//  Copyright © 2017 Bartłomiej Nowak. All rights reserved.
//

#import "ViewportViewController.h"
#import "SliderStackView.h"
#import "SliderStackViewModel.h"
#import "MetalRenderer.h"
#import "MetalView.h"
#import "WeakSelf.h"

@interface ViewportViewController ()
@property (nonatomic, strong) MetalRenderer* renderer;
@property (nonatomic, strong) MetalView* metalView;
@property (nonatomic, strong) NSArray<TeapotModel*>* models;
@end

@implementation ViewportViewController

#pragma mark - UIViewController

- (BOOL)prefersStatusBarHidden {
    return YES;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [_presenter viewDidLoad];
    id<MTLDevice> device = MTLCreateSystemDefaultDevice();
    MTLPixelFormat colorPixelFormat = MTLPixelFormatBGRA8Unorm;
    [self setupMetalViewWithDevice:device colorFormat:colorPixelFormat];
    [self setupRendererWithDevice:device colorFormat:colorPixelFormat];
    _metalView.delegate = self;
}

- (void)setupMetalViewWithDevice:(id<MTLDevice>)device colorFormat:(MTLPixelFormat)format {
    MetalView *view = [[MetalView alloc] initWithDevice:device];
    view.colorPixelFormat = format;
    [self.view addSubview:view];
    view.translatesAutoresizingMaskIntoConstraints = false;
    [NSLayoutConstraint activateConstraints:@[[self.view.topAnchor constraintEqualToAnchor:[view topAnchor]],
                                              [self.view.bottomAnchor constraintEqualToAnchor:[view bottomAnchor]],
                                              [self.view.leadingAnchor constraintEqualToAnchor:[view leadingAnchor]],
                                              [self.view.trailingAnchor
                                               constraintEqualToAnchor:[view trailingAnchor]]]];
    _metalView = view;
}

- (void)setupRendererWithDevice:(id<MTLDevice>)device colorFormat:(MTLPixelFormat)format {
    _renderer = [[MetalRenderer alloc] initWithDevice:device];
    _renderer.colorPixelFormat = format;
}


#pragma mark - MetalViewDelegate

-(void)drawToDrawable:(id<CAMetalDrawable>)drawable ofSize:(CGSize)drawableSize frameDuration:(float)frameDuration {
    [_presenter willRenderNextFrameTo:drawable ofSize:drawableSize frameDuration:frameDuration];
}

-(void)adjustedDrawableSize:(CGSize)drawableSize {
    [_renderer adjustedDrawableSize:drawableSize];
}

#pragma mark - ViewportViewProtocol

- (void)presentSliders:(SliderStackViewModel*)viewModel {
    SliderStackView *stackView = [[SliderStackView alloc] init];
    [stackView setupWith:viewModel];
    WEAK_SELF weakSelf = self;
    stackView.onValueChange = ^(int idx, float value) {
        [weakSelf.presenter sliderValueChangedFor:idx with:value];
    };
    stackView.translatesAutoresizingMaskIntoConstraints = false;
    [self.view addSubview:stackView];
    [NSLayoutConstraint activateConstraints:@[[stackView.bottomAnchor constraintEqualToAnchor:self.view.bottomAnchor],
                                              [stackView.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor],
                                              [stackView.trailingAnchor
                                               constraintEqualToAnchor:self.view.trailingAnchor]]];
}

- (void)presentModels:(NSArray<Model*>*)models {
    _renderer.drawedModels = models;
}

- (void)drawNextFrameTo:(id<CAMetalDrawable>)drawable ofSize:(CGSize)drawableSize {
    [_renderer drawToDrawable:drawable ofSize:drawableSize];
}

@end
