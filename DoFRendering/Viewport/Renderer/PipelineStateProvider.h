//
//  PipelineStateProvider.h
//  DoFRendering
//
//  Created by Bartłomiej Nowak on 17.03.2018.
//  Copyright © 2018 Bartłomiej Nowak. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Metal/Metal.h>

@interface PipelineStateProvider : NSObject
-(instancetype)initWithDevice:(id<MTLDevice>)device;
@property (strong, nonatomic) id<MTLRenderPipelineState> drawObjectsPipelineState;
@property (strong, nonatomic) id<MTLDepthStencilState> depthStencilState;

#pragma mark - DOF v1

@property (strong, nonatomic) id<MTLRenderPipelineState> maskFocusFieldPipelineState;
@property (strong, nonatomic) id<MTLRenderPipelineState> maskOutOfFocusFieldPipelineState;
@property (strong, nonatomic) id<MTLRenderPipelineState> applyGaussianBlurFieldPipelineState;
@property (strong, nonatomic) id<MTLRenderPipelineState> compositePipelineState;

#pragma mark - DOF v2

@property (strong, nonatomic) id<MTLRenderPipelineState> circleOfConfusionPipelineState;
@end
