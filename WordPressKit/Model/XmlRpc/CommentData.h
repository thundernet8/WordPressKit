//
//  CommentData.h
//  WordPressKit
//
//  Created by wuxueqian on 15/10/19.
//  Copyright (c) 2015年 wuxueqian. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Blog.h"
#import "RemotePost.h"
#import "WordPressApi.h"
#import "Comment.h"
#import <sqlite3.h>

@interface CommentData : NSObject
{
    sqlite3 *db;
}

@property (nonatomic,strong) WPXMLRPCClient *client;
@property (nonatomic,strong) WordPressXMLRPCApi *api;
@property (nonatomic,strong) RemotePost *post;
@property (nonatomic,strong) Blog *blog;

- (instancetype)initWithBlog:(Blog *)blog inPost:(RemotePost *)post;
- (NSArray *)getPostCommentsOfStatus:(NSInteger)commentStatus excludeType:(NSArray *)commentType;

@end
