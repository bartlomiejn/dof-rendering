//
//  MetalRenderer.m
//  MBE
//
//  Created by Bartłomiej Nowak on 15/11/2017.
//  Copyright © 2017 Bartłomiej Nowak. All rights reserved.
//

#import "MetalRenderer.h"
#import "MathFunctions.h"

@import simd;
@import Metal;
@import QuartzCore.CAMetalLayer;

typedef struct {
    vector_float4 position;
    vector_float4 color;
} MetalVertex;

typedef struct {
    matrix_float4x4 mvpMatrix;
} MetalUniforms;

typedef uint16_t MetalIndex;
const MTLIndexType MetalIndexType = MTLIndexTypeUInt16;

static const NSInteger inFlightBufferCount = 3;

@interface MetalRenderer ()
@property (strong) id<MTLDevice> device;
@property (strong) id<MTLBuffer> vertexBuffer;
@property (strong) id<MTLBuffer> indexBuffer;
@property (strong) id<MTLBuffer> uniformBuffer;
@property (strong) id<MTLCommandQueue> commandQueue;
@property (strong) id<MTLRenderPipelineState> renderPipelineState;
@property (strong) id<MTLDepthStencilState> depthStencilState;
@property (strong) dispatch_semaphore_t displaySemaphore;
@property (assign) NSInteger bufferIndex;
@property (assign) float rotationX, rotationY, time;
@end

@implementation MetalRenderer

- (instancetype)init
{
    self = [super init];
    if (self) {
        _device = MTLCreateSystemDefaultDevice();
        _displaySemaphore = dispatch_semaphore_create(inFlightBufferCount);
        
        [self setupPipeline];
        [self setupBuffers];
    }
    return self;
}

- (void)setupPipeline {
    
}

- (void)setupBuffers {
    
}

#pragma mark - MetalViewDelegate

- (void)drawInView:(MetalView *)view {
    
}

@end
