//
//  AppDelegate.m
//  DoFRendering
//
//  Created by Bartłomiej Nowak on 03/11/2017.
//  Copyright © 2017 Bartłomiej Nowak. All rights reserved.
//

#import "AppDelegate.h"
#import "ViewportViewController.h"

@interface AppDelegate ()
@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    ViewportViewController *controller = [ViewportViewController new];
    controller.presenter = [[ViewportPresenter alloc] initWithMeshLoader:[[OBJMeshLoader alloc] init]
                                                   transformationBuilder:[[ModelTransformationBuilder alloc] init]];
    controller.presenter.view = controller;
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.rootViewController = controller;
    [self.window makeKeyAndVisible];
    return true;
}

@end
