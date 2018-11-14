//
//  ViewportViewController.m
//  DoFRendering
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
@property (nonatomic, strong) id<MTLDevice> device;
@property (nonatomic, strong) MetalRenderer* renderer;
@property (nonatomic, strong) MetalView* metalView;
@end

@implementation ViewportViewController

#pragma mark - UIViewController

-(instancetype)initWithDevice:(id<MTLDevice>)device renderer:(MetalRenderer*)renderer
{
    self = [super init];
    if (self) {
        self.device = device;
        self.renderer = renderer;
    }
    return self;
}

- (BOOL)prefersStatusBarHidden
{
    return true;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setupMetalView];
    [self.presenter viewDidLoad];
}

- (void)setupMetalView
{
    MetalView *view = [[MetalView alloc] initWithDevice:self.device];
    view.colorPixelFormat = [self.renderer colorPixelFormat];
    [self.view addSubview:view];
    view.translatesAutoresizingMaskIntoConstraints = false;
    [NSLayoutConstraint activateConstraints:@[[self.view.topAnchor constraintEqualToAnchor:[view topAnchor]],
                                              [self.view.bottomAnchor constraintEqualToAnchor:[view bottomAnchor]],
                                              [self.view.leadingAnchor constraintEqualToAnchor:[view leadingAnchor]],
                                              [self.view.trailingAnchor
                                               constraintEqualToAnchor:[view trailingAnchor]]]];
    self.metalView = view;
    self.metalView.delegate = self;
}


#pragma mark - MetalViewDelegate

-(void)drawToDrawable:(id<CAMetalDrawable>)drawable ofSize:(CGSize)drawableSize frameDuration:(float)frameDuration
{
    [self.presenter willRenderNextFrameTo:drawable ofSize:drawableSize frameDuration:frameDuration];
}

-(void)adjustedDrawableSize:(CGSize)drawableSize
{
    [self.renderer adjustedDrawableSize:drawableSize];
}

#pragma mark - ViewportViewProtocol

- (void)presentSliders:(SliderStackViewModel*)viewModel
{
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

- (void)presentModelGroup:(ModelGroup*)modelGroup
{
    self.renderer.drawableModelGroup = modelGroup;
}

- (void)drawNextFrameTo:(id<CAMetalDrawable>)drawable ofSize:(CGSize)drawableSize
{
    [self.renderer drawToDrawable:drawable ofSize:drawableSize];
}

@end
