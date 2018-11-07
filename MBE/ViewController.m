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
#import "OBJMesh.h"
#import "OBJModel.h"
#import "OBJGroup.h"

@interface ViewController ()
@property (nonatomic, strong) MetalRenderer* renderer;
@end

@implementation ViewController

- (MetalView *)metalView {
    return (MetalView *)self.view;
}

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
    [_renderer setupMeshFromOBJGroup:[self loadOBJGroupFromModelNamed:@"teapot" groupNamed:@"teapot"]];
}

- (OBJGroup *)loadOBJGroupFromModelNamed:(NSString *)name groupNamed:(NSString *)groupName {
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:name withExtension:@"obj"];
    OBJModel *model = [[OBJModel alloc] initWithContentsOfURL:modelURL generateNormals:YES];
    return [model groupForName:groupName];
}

@end
