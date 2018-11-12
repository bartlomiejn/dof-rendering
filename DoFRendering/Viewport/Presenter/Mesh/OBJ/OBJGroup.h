//
//  OBJGroup.h
//  DoFRendering
//
//  Created by Bartłomiej Nowak on 23/11/2017.
//  Copyright © 2017 Bartłomiej Nowak. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface OBJGroup : NSObject
- (instancetype)initWithName:(NSString *)name;
@property (copy) NSString *name;
@property (copy) NSData *vertexData;
@property (copy) NSData *indexData;
@end
