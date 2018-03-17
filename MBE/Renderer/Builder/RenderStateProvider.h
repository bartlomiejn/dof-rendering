//
//  RenderPipelineStateBuilder.h
//  MBE
//
//  Created by Bartłomiej Nowak on 17.03.2018.
//  Copyright © 2018 Bartłomiej Nowak. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Metal/Metal.h>

@interface RenderStateProvider : NSObject
@property (strong, nonatomic) id<MTLRenderPipelineState> renderObjectsPipelineState;
@property (strong, nonatomic) id<MTLRenderPipelineState> applyBloomPipelineState;
@property (strong, nonatomic) id<MTLDepthStencilState> depthStencilState;
-(instancetype)initWithDevice:(id<MTLDevice>)device;
@end
