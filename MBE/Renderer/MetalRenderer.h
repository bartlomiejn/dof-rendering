//
//  MetalRenderer.h
//  MBE
//
//  Created by Bartłomiej Nowak on 15/11/2017.
//  Copyright © 2017 Bartłomiej Nowak. All rights reserved.
//
//  Includes code taken from Metal By Example book repository at: https://github.com/metal-by-example/sample-code
//

#import "MetalView.h"
#import "OBJGroup.h"
#import <Foundation/Foundation.h>

@interface MetalRenderer : NSObject <MetalViewDelegate>
@property (nonatomic) MTLPixelFormat colorPixelFormat;
- (instancetype)initWithDevice:(id<MTLDevice>)device;
- (void)setupMeshFromOBJGroup:(OBJGroup*)group;
@end
