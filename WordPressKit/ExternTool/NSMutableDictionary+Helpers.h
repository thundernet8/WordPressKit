//
//  NSMutableDictionary+Helpers.h
//  WordPressKit
//
//  Created by wuxueqian on 15/9/23.
//  Copyright (c) 2015年 wuxueqian. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSMutableDictionary (Helpers)

- (void)setValueIfNotNil:(id)value forKey:(NSString *)key;

@end
