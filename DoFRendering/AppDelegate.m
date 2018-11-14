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
#import "DrawObjectsRenderPassEncoder.h"
#import "CircleOfConfusionPassEncoder.h"
#import "BokehPassEncoder.h"

@interface AppDelegate ()
@end

@implementation AppDelegate

-(BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    id<MTLDevice> device = MTLCreateSystemDefaultDevice();
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.rootViewController = [self viewControllerWithDevice:device
                                                           renderer:[self metalRendererForDevice:device]];
    [self.window makeKeyAndVisible];
    return true;
}

-(ViewportViewController*)viewControllerWithDevice:(id<MTLDevice>)device renderer:(MetalRenderer*)renderer
{
    ViewportViewController *controller = [[ViewportViewController alloc] initWithDevice:device renderer:renderer];
    controller.presenter = [[ViewportPresenter alloc] initWithMeshLoader:[[OBJMeshLoader alloc] initWithDevice:device]
                                                   transformationBuilder:[[ModelTransformationBuilder alloc] init]];
    controller.presenter.view = controller;
    return controller;
}

-(MetalRenderer*)metalRendererForDevice:(id<MTLDevice>)device
{
    PassDescriptorBuilder* passBuilder = [[PassDescriptorBuilder alloc] init];
    DrawObjectsRenderPassEncoder* drawObjectsEncoder = [[DrawObjectsRenderPassEncoder alloc]
                                                        initWithDevice:device
                                                        passBuilder:passBuilder];
    CircleOfConfusionPassEncoder* cocEncoder = [[CircleOfConfusionPassEncoder alloc] initWithDevice:device
                                                                                        passBuilder:passBuilder];
    BokehPassEncoder* bokehEncoder = [[BokehPassEncoder alloc] initWithDevice:device passBuilder:passBuilder];
    MetalRenderer* renderer = [[MetalRenderer alloc] initWithDevice:device
                                                 drawObjectsEncoder:drawObjectsEncoder
                                                         cocEncoder:cocEncoder
                                                       bokehEncoder:bokehEncoder];
    renderer.colorPixelFormat = MTLPixelFormatBGRA8Unorm;
    return renderer;
}

@end
