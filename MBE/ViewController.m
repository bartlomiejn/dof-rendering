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

- (MetalView *)metalView {
    return (MetalView *)self.view;
}

- (BOOL)prefersStatusBarHidden {
    return YES;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _renderer = [MetalRenderer new];
    self.metalView.delegate = _renderer;
}

@end
