//
//  CommentDataDelegate.h
//  WordPressKit
//
//  Created by wuxueqian on 15/10/20.
//  Copyright (c) 2015年 wuxueqian. All rights reserved.
//

#import <Foundation/Foundation.h>

@class Comment;

@protocol CommentDateDelegate <NSObject>

@optional

//服务器获取评论失败回调
- (void)fetchServerCommentsFailure:(NSError *)err;
//评论数据写入数据库成功回调
- (void)writeDBCommentsSuccess:(NSArray *)Comments;
//评论数据写入数据库失败回调
- (void)writeDBCommentsFailure:(NSError *)err;
//数据库查询评论成功回调
- (void)queryDBCommentsSuccess:(NSMutableArray *)Comments;
//数据库查询评论失败回调
- (void)queryDBCommentsFailure:(NSError *)err;
//服务器插入评论成功回调
- (void)insertServerCommentSuccess:(Comment *)comment;
//服务器插入评论失败回调
- (void)insertServerCommentFailure:(NSError *)err;
//数据库插入评论成功回调
- (void)insertDBCommentSuccess:(Comment *)comment;
//数据库插入评论失败回调
- (void)insertDBCommentFailure:(NSError *)err;

@end

@interface CommentData : NSObject

@property (nonatomic, weak) id<CommentDateDelegate>delegate;

@end
