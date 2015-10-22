//
//  CommentData.h
//  WordPressKit
//
//  Created by wuxueqian on 15/10/19.
//  Copyright (c) 2015年 wuxueqian. All rights reserved.
//

#import "Blog.h"
#import "Post.h"
#import "WordPressApi.h"
#import "Comment.h"
#import <sqlite3.h>
#import "CommentDataDelegate.h"

@interface CommentData()
{
    sqlite3 *db;
}

@property (nonatomic,strong) WPXMLRPCClient *client;
@property (nonatomic,strong) WordPressXMLRPCApi *api;
@property (nonatomic,strong) Post *post;
@property (nonatomic,strong) Blog *blog;

+ (CommentData *)sharedManager;
- (void)configureManagerPost:(Post *)post forBlog:(Blog *)blog;
- (void)getPostCommentsOfStatus:(NSString *)commentStatus commentType:(NSString *)commentType inCommentPage:(NSInteger)page;
- (void)fetchPostCommentsOfStatus:(NSString *)commentStatus commentType:(NSString *)commentType inCommentPage:(NSInteger)page;
- (void)maybeFetchPostCommentsOfStatus:(NSString *)commentStatus commentType:(NSString *)commentType inCommentPage:(NSInteger)page;

@end
