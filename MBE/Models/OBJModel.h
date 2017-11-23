//
//  OBJModel.h
//  MBE
//
//  Created by Bartłomiej Nowak on 23/11/2017.
//  Copyright © 2017 Bartłomiej Nowak. All rights reserved.
//

#import "OBJIndex.h"
@import Foundation;

@interface OBJModel : NSObject
- (instancetype)initWithContentsOfURL:(NSURL*)url;
- (OBJGroup)groupAtIndex:(int)index;
@end
