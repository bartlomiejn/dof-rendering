//
//  PipelineStateBuilder.h
//  DoFRendering
//
//  Created by Bartłomiej Nowak on 17.03.2018.
//  Copyright © 2018 Bartłomiej Nowak. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Metal/Metal.h>

@interface PipelineStateBuilder : NSObject
@property (strong, nonatomic) id<MTLRenderPipelineState> maskFocusFieldPipelineState;
@property (strong, nonatomic) id<MTLRenderPipelineState> maskOutOfFocusFieldPipelineState;
@property (strong, nonatomic) id<MTLRenderPipelineState> applyGaussianBlurFieldPipelineState;
@property (strong, nonatomic) id<MTLRenderPipelineState> compositePipelineState;
-(instancetype)initWithDevice:(id<MTLDevice>)device;
@end
