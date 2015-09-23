//
//  RemotePostCategory.h
//  WordPressKit
//
//  Created by wuxueqian on 15/9/23.
//  Copyright (c) 2015年 wuxueqian. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RemotePostCategory : NSObject

@property (nonatomic, strong) NSNumber *categoryID;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSNumber *parentID;

@end
