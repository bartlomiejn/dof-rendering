//
//  MetalRenderer.h
//  MBE
//
//  Created by Bartłomiej Nowak on 15/11/2017.
//  Copyright © 2017 Bartłomiej Nowak. All rights reserved.
//
//  Includes code taken from Metal By Example book repository at: https://github.com/metal-by-example/sample-code
//

#import <Foundation/Foundation.h>
#import "MetalView.h"

@interface MetalRenderer : NSObject <MetalViewDelegate>
@property (nonatomic) MTLPixelFormat colorPixelFormat;
- (instancetype)initWithDevice:(id<MTLDevice>)device;
@end
