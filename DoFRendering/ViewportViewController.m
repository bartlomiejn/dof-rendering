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
#import "OBJMesh.h"
#import "OBJModel.h"
#import "OBJGroup.h"
#import "WeakSelf.h"

@interface ViewportViewController ()
@property (nonatomic, strong) MetalRenderer* renderer;
@property (nonatomic, strong) MetalView* metalView;
@end

@implementation ViewportViewController

#pragma mark - UIViewController

- (BOOL)prefersStatusBarHidden {
    return YES;
}

- (void)loadView {
    self.view = [[UIView alloc] init];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    id<MTLDevice> device = MTLCreateSystemDefaultDevice();
    MTLPixelFormat colorPixelFormat = MTLPixelFormatBGRA8Unorm;
    [self setupMetalViewWithDevice:device colorFormat:colorPixelFormat];
    [self setupRendererWithDevice:device colorFormat:colorPixelFormat];
    _metalView.delegate = _renderer;
    [_presenter viewDidLoad];
}

- (void)setupMetalViewWithDevice:(id<MTLDevice>)device colorFormat:(MTLPixelFormat)format {
    MetalView *view = [[MetalView alloc] initWithDevice:device];
    view.colorPixelFormat = format;
    [self.view addSubview:view];
    view.translatesAutoresizingMaskIntoConstraints = false;
    [NSLayoutConstraint activateConstraints:@[[self.view.topAnchor constraintEqualToAnchor:[view topAnchor]],
                                              [self.view.bottomAnchor constraintEqualToAnchor:[view bottomAnchor]],
                                              [self.view.leadingAnchor constraintEqualToAnchor:[view leadingAnchor]],
                                              [self.view.trailingAnchor constraintEqualToAnchor:[view trailingAnchor]]]];
    _metalView = view;
}

- (void)setupRendererWithDevice:(id<MTLDevice>)device colorFormat:(MTLPixelFormat)format {
    _renderer = [[MetalRenderer alloc] initWithDevice:device];
    _renderer.colorPixelFormat = format;
    [_renderer setupMeshFromOBJGroup:[self loadOBJGroupFromModelNamed:@"teapot" groupNamed:@"teapot"]];
}

- (OBJGroup *)loadOBJGroupFromModelNamed:(NSString *)name groupNamed:(NSString *)groupName {
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:name withExtension:@"obj"];
    OBJModel *model = [[OBJModel alloc] initWithContentsOfURL:modelURL generateNormals:YES];
    return [model groupForName:groupName];
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
                                              [stackView.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor]]];
}

@end
