//
//  Comment.h
//  WordPressKit
//
//  Created by wuxueqian on 15/10/19.
//  Copyright (c) 2015年 wuxueqian. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Comment : NSObject

@property (nonatomic) NSInteger id;
@property (nonatomic) NSInteger commentId;
@property (nonatomic) NSInteger postId;
@property (nonatomic, copy) NSString *author;
@property (nonatomic, copy) NSString *authorEmail;
@property (nonatomic, copy) NSString *authorUrl;
@property (nonatomic, copy) NSString *authorIP;
@property (nonatomic, copy) NSDate *date;
@property (nonatomic, copy) NSString *content;
@property (nonatomic) NSInteger approved;
@property (nonatomic, copy) NSString *agent;
@property (nonatomic, copy) NSString *commentType;
@property (nonatomic) NSInteger parent;
@property (nonatomic) NSInteger userId;
@property (nonatomic) NSInteger siteId;

@end
