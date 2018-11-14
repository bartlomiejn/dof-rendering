//
//  AppDelegate.m
//  DoFRendering
//
//  Created by Bartłomiej Nowak on 03/11/2017.
//  Copyright © 2017 Bartłomiej Nowak. All rights reserved.
//

#import "AppDelegate.h"
#import "ViewportViewController.h"
#import "MetalRenderer.h"
#import "PassDescriptorBuilder.h"
#import "PipelineStateBuilder.h"
#import "DrawObjectsRenderPassEncoder.h"
#import "CircleOfConfusionPassEncoder.h"
#import "BokehPassEncoder.h"

@interface AppDelegate ()
@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    id<MTLDevice> device = MTLCreateSystemDefaultDevice();
    PassDescriptorBuilder* passBuilder = [[PassDescriptorBuilder alloc] init];
    PipelineStateBuilder* pipelineStateBuilder = [[PipelineStateBuilder alloc] initWithDevice:device];
    DrawObjectsRenderPassEncoder* drawObjectsEncoder = [[DrawObjectsRenderPassEncoder alloc]
                                                        initWithDevice:device
                                                        passBuilder:passBuilder
                                                        pipelineStateBuilder:pipelineStateBuilder];
    CircleOfConfusionPassEncoder* cocEncoder = [[CircleOfConfusionPassEncoder alloc] initWithDevice:device
                                                                                        passBuilder:passBuilder];
    BokehPassEncoder* bokehEncoder = [[BokehPassEncoder alloc] initWithDevice:device passBuilder:passBuilder];
    MetalRenderer* renderer = [[MetalRenderer alloc] initWithDevice:device
                                                 drawObjectsEncoder:drawObjectsEncoder
                                                         cocEncoder:cocEncoder
                                                       bokehEncoder:bokehEncoder];
    renderer.colorPixelFormat = MTLPixelFormatBGRA8Unorm;
    ViewportViewController *controller = [[ViewportViewController alloc] initWithDevice:device renderer:renderer];
    controller.presenter = [[ViewportPresenter alloc] initWithMeshLoader:[[OBJMeshLoader alloc] initWithDevice:device]
                                                   transformationBuilder:[[ModelTransformationBuilder alloc] init]];
    controller.presenter.view = controller;
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.rootViewController = controller;
    [self.window makeKeyAndVisible];
    return true;
}

@end
