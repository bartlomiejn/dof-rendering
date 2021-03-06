//
//  Mesh.h
//  DoFRendering
//
//  Created by Bartłomiej Nowak on 23/11/2017.
//  Copyright © 2017 Bartłomiej Nowak. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Metal/Metal.h>

@interface Mesh : NSObject
@property (nonatomic, readonly) id<MTLBuffer> vertexBuffer;
@property (nonatomic, readonly) id<MTLBuffer> indexBuffer;
-(instancetype)initWithVertexBuffer:(id<MTLBuffer>)vertexBuffer indexBuffer:(id<MTLBuffer>)indexBuffer;
@end
