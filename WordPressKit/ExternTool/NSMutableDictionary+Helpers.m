//
//  NSMutableDictionary+Helpers.m
//  WordPressKit
//
//  Created by wuxueqian on 15/9/23.
//  Copyright (c) 2015年 wuxueqian. All rights reserved.
//

#import "NSMutableDictionary+Helpers.h"

@implementation NSMutableDictionary (Helpers)

- (void)setValueIfNotNil:(id)value forKey:(NSString *)key
{
    if (value != nil) {
        self[key] = value;
    }
}

@end
