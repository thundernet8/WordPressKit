//
//  RemotePostCategory.m
//  WordPressKit
//
//  Created by wuxueqian on 15/9/23.
//  Copyright (c) 2015年 wuxueqian. All rights reserved.
//

#import "PostCategory.h"

@implementation PostCategory

- (NSString *)debugDescription {
    NSDictionary *properties = @{
                                 @"ID": self.categoryID,
                                 @"name": self.name,
                                 @"parent": self.parentID,
                                 };
    return [NSString stringWithFormat:@"<%@: %p> (%@)", NSStringFromClass([self class]), self, properties];
}

- (NSString *)description {
    return [NSString stringWithFormat:@"<%@: %p> %@[%@]", NSStringFromClass([self class]), self, self.name, self.categoryID];
}

@end
