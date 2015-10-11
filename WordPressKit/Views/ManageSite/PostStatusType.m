//
//  PostStatusType.m
//  WordPressKit
//
//  Created by wuxueqian on 15/10/10.
//  Copyright (c) 2015年 wuxueqian. All rights reserved.
//

#import "PostStatusType.h"

NSString * const PostStatusDraft = @"draft";
NSString * const PostStatusPending = @"pending";
NSString * const PostStatusPrivate = @"private";
NSString * const PostStatusPublish = @"publish";
NSString * const PostStatusScheduled = @"future";
NSString * const PostStatusTrash = @"trash";

@implementation PostStatusType

/**
 *  根据文章类型(Post/Page)返回文章状态过滤器数组
 *
 *  @param postType 文章类型
 *
 *  @return 文章状态过滤器数组
 */
+ (NSArray *)newPostStatusFilterWithPostType:(NSString *)postType
{
    if ([postType isEqualToString:@"post"]) {
        return @[
                 [self newPublishedFilter],
                 [self newFutureFilter],
                 [self newDraftFilter],
                 [self newPendingFilter],
                 [self newTrashedFilter]
                 ];
    }
    return @[
             [self newPublishedFilter],
             [self newFutureFilter],
             [self newDraftFilter],
             [self newTrashedFilter]
             ];
}

+ (instancetype)newPublishedFilter
{
    PostStatusType *filter = [PostStatusType new];
    filter.postStatus = PostStatusPublish;
    filter.postStatusText = @"已发布";
    return filter;
}

+ (instancetype)newDraftFilter
{
    PostStatusType *filter = [PostStatusType new];
    filter.postStatus = PostStatusDraft;
    filter.postStatusText = @"草稿";
    return filter;
}

+ (instancetype)newFutureFilter
{
    PostStatusType *filter = [PostStatusType new];
    filter.postStatus = PostStatusScheduled;
    filter.postStatusText = @"定时发布";
    return filter;
}

+ (instancetype)newPendingFilter
{
    PostStatusType *filter = [PostStatusType new];
    filter.postStatus = PostStatusPending;
    filter.postStatusText = @"待审核";
    return filter;
}

+ (instancetype)newTrashedFilter
{
    PostStatusType *filter = [PostStatusType new];
    filter.postStatus = PostStatusTrash;
    filter.postStatusText = @"已删除";
    return filter;
}

- (instancetype)init
{
    self = [super init];
    return self;
}


@end
