//
//  OBJModel.h
//  MBE
//
//  Created by Bartłomiej Nowak on 23/11/2017.
//  Copyright © 2017 Bartłomiej Nowak. All rights reserved.
//

#import "OBJGroup.h"
@import Foundation;

@interface OBJModel : NSObject
@property (nonatomic, readonly) NSArray *groups;
- (instancetype)initWithContentsOfURL:(NSURL *)url;
- (OBJGroup *)groupAtIndex:(int)index;
@end
