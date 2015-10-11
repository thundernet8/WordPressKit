//
//  PostStatusType.h
//  WordPressKit
//
//  Created by wuxueqian on 15/10/10.
//  Copyright (c) 2015年 wuxueqian. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PostStatusType : NSObject

@property (nonatomic, strong) NSString *postStatus;
@property (nonatomic, strong) NSString *postStatusText;

+ (NSArray *)newPostStatusFilterWithPostType:(NSString *)postType;

@end
