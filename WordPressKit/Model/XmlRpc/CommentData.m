//
//  CommentData.m
//  WordPressKit
//
//  Created by wuxueqian on 15/10/19.
//  Copyright (c) 2015年 wuxueqian. All rights reserved.
//

#import "CommentData.h"
#import "DataModel.h"

@implementation CommentData

- (instancetype)initWithBlog:(Blog *)blog inPost:(RemotePost *)post
{
    self = [super init];
    if (!self) {
        return nil;
    }
    self.client = [CommentData getClientWithBlog:blog];
    self.api = [CommentData getApiWithBlog:blog];
    self.blog = blog;
    self.post = post;
    return self;
}

/**
 *  返回文章数据库路径
 *
 *  @return 数据文件路径
 */
- (NSString *)userDataFilePath
{
    return [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/UserData.db"];
}

/**
 *  实例化WordPressXMLRPCApi
 *
 *  @param blog 博客对象，用于获取用户名密码以及xmlrpc接口地址
 *
 *  @return 返回实例化的WordPressXMLRPCApi对象
 */
+ (WordPressXMLRPCApi *)getApiWithBlog:(Blog *)blog
{
    NSString *password = [[[DataModel alloc] init] readKeyChainWithId:blog.id];
    WordPressXMLRPCApi *api = [[WordPressXMLRPCApi alloc] initWithXMLRPCEndpoint:[NSURL URLWithString:blog.xmlrpc] username:blog.userName password:password];
    return api;
}

/**
 *  实例化XMLRPCClient
 *
 *  @param blog 博客对象，用于获取用户名密码以及xmlrpc接口地址
 *
 *  @return 返回实例化的XMLRPCClient对象
 */
+ (WPXMLRPCClient *)getClientWithBlog:(Blog *)blog
{
    WPXMLRPCClient *client = [WPXMLRPCClient clientWithXMLRPCEndpoint:[NSURL URLWithString:blog.xmlrpc]];
    return client;
}

- (NSArray *)getPostCommentsOfStatus:(NSInteger)commentStatus excludeType:(NSArray *)commentType
{
    NSString *path = [self userDataFilePath];
    const char *npath = [path UTF8String];
    //打开数据库
    if (sqlite3_open(npath, &db) != SQLITE_OK) {
        NSAssert(NO, @"打开数据库文件失败");
    }else{
        NSString *sql = @"SELECT * FROM COMMENTS WHERE POSTID = ? AND SITEID = ? AND APPROVED = ? AND COMMENTTYPE NOT IN (?)";
        const char *nsql = [sql UTF8String];
        sqlite3_stmt *stmt;
        if (sqlite3_prepare_v2(db, nsql, -1, &stmt, NULL) == SQLITE_OK ){
            sqlite3_bind_int(stmt, 1, [self.post.postID intValue]);
            sqlite3_bind_int(stmt, 2, (int)self.blog.id);
            sqlite3_bind_int(stmt, 3, (int)commentStatus);
            NSString *commentTypeString = [commentType componentsJoinedByString:@","];
            sqlite3_bind_text(stmt, 4, [commentTypeString UTF8String], -1, NULL);
            NSMutableArray *comments = [NSMutableArray new];
            while (sqlite3_step(stmt) == SQLITE_ROW) {
                Comment *comment = [Comment new];
                comment.id = sqlite3_column_int(stmt, 0);
                comment.commentId = sqlite3_column_int(stmt, 1);
                comment.postId = sqlite3_column_int(stmt, 2);
                comment.author = [NSString stringWithUTF8String:(char *)sqlite3_column_text(stmt, 3)];
                comment.authorEmail = [NSString stringWithUTF8String:(char *)sqlite3_column_text(stmt, 4)];
                comment.authorUrl = [NSString stringWithUTF8String:(char *)sqlite3_column_text(stmt, 5)];
                comment.authorIP = [NSString stringWithUTF8String:(char *)sqlite3_column_text(stmt, 6)];
                comment.date = [self getDateFromStr:[NSString stringWithUTF8String:(char *)sqlite3_column_text(stmt, 7)]];
                comment.content = [NSString stringWithUTF8String:(char *)sqlite3_column_text(stmt, 8)];
                comment.approved = sqlite3_column_int(stmt, 9);
                comment.agent = [NSString stringWithUTF8String:(char *)sqlite3_column_text(stmt, 10)];
                comment.commentType = [NSString stringWithUTF8String:(char *)sqlite3_column_text(stmt, 11)];
                comment.parent = sqlite3_column_int(stmt, 12);
                comment.userId = sqlite3_column_int(stmt, 13);
                comment.siteId = sqlite3_column_int(stmt, 14);
                
                [comments addObject:comment];
                
            }
            sqlite3_finalize(stmt);
            sqlite3_close(db);
            return (NSArray *)[comments copy];
        }
        sqlite3_finalize(stmt);
        sqlite3_close(db);
        
    }
    return nil;
}

/**
 *  格式化时间字符串为时间
 *
 *  @param dateStr YYYY-MM-DD HH:MM:SS ZZZ格式的时间字符串
 *
 *  @return NSDate时间
 */
- (NSDate *)getDateFromStr:(NSString *)dateStr
{
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"YYYY-MM-DD HH:MM:SS"];
    NSDate *date = [dateFormat dateFromString:dateStr];
    return date;
}


@end
