//
//  ViewController.m
//  MBE
//
//  Created by Bartłomiej Nowak on 03/11/2017.
//  Copyright © 2017 Bartłomiej Nowak. All rights reserved.
//

#import "ViewController.h"
#import "MetalRenderer.h"
#import "MetalView.h"

@interface ViewController ()
@property (nonatomic, strong) MetalRenderer* renderer;
@end

@implementation ViewController

#pragma mark - Get / Set

- (MetalView *)metalView {
    return (MetalView *)self.view;
}

#pragma mark - UIViewController

- (BOOL)prefersStatusBarHidden {
    return YES;
}

- (void)loadView {
    id<MTLDevice> device = MTLCreateSystemDefaultDevice();
    MTLPixelFormat colorPixelFormat = MTLPixelFormatBGRA8Unorm;
    
    [self setupViewWithDevice:device colorFormat:colorPixelFormat];
    [self setupRendererWithDevice:device colorFormat:colorPixelFormat];
    
    self.metalView.delegate = _renderer;
}

- (void)setupViewWithDevice:(id<MTLDevice>)device colorFormat:(MTLPixelFormat)format {
    MetalView *view = [[MetalView alloc] initWithDevice:device];
    view.colorPixelFormat = format;
    self.view = view;
}

- (void)setupRendererWithDevice:(id<MTLDevice>)device colorFormat:(MTLPixelFormat)format {
    _renderer = [[MetalRenderer alloc] initWithDevice:device];
    _renderer.colorPixelFormat = format;
}

@end
