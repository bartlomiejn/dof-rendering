//
//  OBJModel.h
//  MBE
//
//  Created by Bartłomiej Nowak on 23/11/2017.
//  Copyright © 2017 Bartłomiej Nowak. All rights reserved.
//

#import "OBJGroup.h"
#import <Foundation/Foundation.h>

@interface OBJModel : NSObject
/// Index 0 corresponds to an unnamed group that collects all the geometry
/// declared outside of explicit "g" statements. Therefore, if your file
/// contains explicit groups, you'll probably want to start from index 1,
/// which will be the group beginning at the first group statement.
@property (nonatomic, readonly) NSArray *groups;
- (instancetype)initWithContentsOfURL:(NSURL *)url generateNormals:(BOOL)generateNormals;
- (OBJGroup *)groupForName:(NSString *)groupName;
@end
