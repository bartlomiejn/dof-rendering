//
//  RenderStateProvider.h
//  MBE
//
//  Created by Bartłomiej Nowak on 17.03.2018.
//  Copyright © 2018 Bartłomiej Nowak. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Metal/Metal.h>

@interface RenderStateProvider : NSObject
@property (strong, nonatomic) id<MTLRenderPipelineState> drawObjectsPipelineState;
@property (strong, nonatomic) id<MTLRenderPipelineState> maskFocusFieldPipelineState;
@property (strong, nonatomic) id<MTLRenderPipelineState> maskOutOfFocusFieldPipelineState;
@property (strong, nonatomic) id<MTLRenderPipelineState> applyGaussianBlurFieldPipelineState;
@property (strong, nonatomic) id<MTLRenderPipelineState> compositePipelineState;
@property (strong, nonatomic) id<MTLDepthStencilState> depthStencilState;
-(instancetype)initWithDevice:(id<MTLDevice>)device;
@end
