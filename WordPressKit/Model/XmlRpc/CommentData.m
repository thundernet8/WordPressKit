//
//  CommentData.m
//  WordPressKit
//
//  Created by wuxueqian on 15/10/19.
//  Copyright (c) 2015年 wuxueqian. All rights reserved.
//

#import "CommentData.h"
#import "DataModel.h"
#import "Blog.h"
#import "Post.h"
#import "WordPressXMLRPCApi.h"
#import "WPMapFilterReduce.h"
#import "NSDictionary+SafeExpectations.h"

extern NSInteger numOfCommentsPerPage;
static const NSInteger timeInterval = 300;

@interface CommentData()

@property (nonatomic,weak) NSArray *comments;

@end

@implementation CommentData

static CommentData *sharedManager = nil;
static NSInteger changedCommentsNum = 0;

+ (CommentData *)sharedManager
{
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        sharedManager = [[self alloc] init];
    });
    return sharedManager;
}

- (void)configureManagerPost:(Post *)post forBlog:(Blog *)blog;
{
    if (!self) {
        return;
    }
    _client = [CommentData getClientWithBlog:blog];
    _api = [CommentData getApiWithBlog:blog];
    _blog = blog;
    _post = post;
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

- (void)getPostCommentsOfStatus:(NSString *)commentStatus commentType:(NSString *)commentType inCommentPage:(NSInteger)page
{
    NSString *path = [self userDataFilePath];
    const char *npath = [path UTF8String];
    //打开数据库
    if (sqlite3_open(npath, &db) != SQLITE_OK) {
        NSAssert(NO, @"打开数据库文件失败");
    }else{
        NSString *sql = @"SELECT * FROM COMMENTS WHERE POSTID = ? AND SITEID = ? AND STATUS = ? AND TYPE = ? ORDER BY COMMENTID DESC LIMIT ?, ?";
        const char *nsql = [sql UTF8String];
        sqlite3_stmt *stmt;        
        if (sqlite3_prepare_v2(db, nsql, -1, &stmt, NULL) == SQLITE_OK ){
            sqlite3_bind_int(stmt, 1, [self.post.postID intValue]);
            sqlite3_bind_int(stmt, 2, (int)self.blog.id);
            sqlite3_bind_text(stmt, 3, [commentStatus UTF8String], -1, NULL);
            sqlite3_bind_text(stmt, 4, [commentType UTF8String], -1, NULL);
            sqlite3_bind_int(stmt, 5, (int)(numOfCommentsPerPage*(page-1)));
            sqlite3_bind_int(stmt, 6, (int)numOfCommentsPerPage);
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
                comment.status = [NSString stringWithUTF8String:(char *)sqlite3_column_text(stmt, 9)];
                comment.agent = sqlite3_column_text(stmt, 10) ? [NSString stringWithUTF8String:(char *)sqlite3_column_text(stmt, 10)] : @"";
                comment.type = [NSString stringWithUTF8String:(char *)sqlite3_column_text(stmt, 11)];
                comment.parent = sqlite3_column_int(stmt, 12);
                comment.userId = sqlite3_column_int(stmt, 13);
                comment.siteId = sqlite3_column_int(stmt, 14);
                comment.link = [NSString stringWithUTF8String:(char *)sqlite3_column_text(stmt, 15)];
                comment.postTitle = [NSString stringWithUTF8String:(char *)sqlite3_column_text(stmt, 16)];
                
                [comments addObject:comment];
                
            }
            [self.delegate queryDBCommentsSuccess:comments];
        }else{
            NSError *err = [[NSError alloc] initWithDomain:[NSString stringWithUTF8String:nsql] code:-1 userInfo:nil];
            [self.delegate queryDBCommentsFailure:err];
        }
        sqlite3_finalize(stmt);
        sqlite3_close(db);
    }
}

- (void)fetchPostCommentsOfStatus:(NSString *)commentStatus commentType:(NSString *)commentType inCommentPage:(NSInteger)page
{
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    NSDictionary *extraParameters = @{
                                      @"number": [NSNumber numberWithInteger: numOfCommentsPerPage],
                                      @"post_id": _post.postID,
                                      @"status": commentStatus,
                                      @"offset": [NSNumber numberWithInteger:(page-1)*numOfCommentsPerPage]
                                      };
    NSArray *parameters = [_blog getXMLRPCArgsWithExtra:extraParameters];
    [self.client callMethod:@"wp.getComments"
                 parameters:parameters
                    success:^(AFHTTPRequestOperation *operation, id responseObject) {
                        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
                        NSAssert([responseObject isKindOfClass:[NSArray class]], @"Response should be an array.");
                        NSArray *comments = [self remoteCommentsFromXMLRPCArray:responseObject];
                        [self writeCommentsToDB:comments];
                    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
                        [self.delegate fetchServerCommentsFailure:error];
                    }];
}

- (void)writeCommentsToDB:(NSArray *)comments
{
    if (comments.count == 0) {
        [self.delegate writeDBCommentsSuccess:_comments];
        return;
    }
    _comments = comments;
    for (Comment *comment in comments) {
        [self writeCommentToDB:comment];
    }
    //记录文章评论同步时间
    [self postCommentsLastSynced:_post.postID];
    
}

- (void)writeCommentToDB:(Comment *)comment
{
    NSString *path = [self userDataFilePath];
    const char *npath = [path UTF8String];
    //打开数据库
    if (sqlite3_open(npath, &db) != SQLITE_OK) {
        NSAssert(NO, @"打开数据库文件失败");
    }else{
        //判断post是否已存在,不存在则插入,存在则更新
        NSString *sql;
        if ([self existComment:comment.commentId inBlog:_blog.id]) {
            sql = [NSString stringWithFormat:@"UPDATE COMMENTS SET POSTID = %i, AUTHOR = ?, AUTHOREMAIL = ?, AUTHORURL = ?, AUTHORIP = ?, DATE = ?, CONTENT = ?, STATUS = ?, TYPE = ?, PARENT = %i, USERID = %i, POSTTITLE = ?, LINK = ? WHERE COMMENTID = %i AND SITEID = %i",[_post.postID intValue],(int)comment.parent,(int)comment.userId,(int)comment.commentId,(int)comment.siteId];
        }else{
            sql = [NSString stringWithFormat:@"INSERT INTO COMMENTS (COMMENTID,POSTID,AUTHOR,AUTHOREMAIL,AUTHORURL,AUTHORIP,DATE,CONTENT,STATUS,TYPE,PARENT,USERID,SITEID,POSTTITLE,LINK) VALUES(%i,%i,?,?,?,?,?,?,?,?,%i,%i,%i,?,?)",(int)comment.commentId,[_post.postID intValue],(int)comment.siteId,(int)comment.userId,(int)comment.siteId];
        }
        const char *nsql = [sql UTF8String];
        sqlite3_stmt *stmt;
        if (sqlite3_prepare_v2(db, nsql, -1, &stmt, NULL) == SQLITE_OK ){
            //bind
            sqlite3_bind_text(stmt, 1, [comment.author UTF8String], -1, NULL);
            sqlite3_bind_text(stmt, 2, [comment.authorEmail UTF8String], -1, NULL);
            sqlite3_bind_text(stmt, 3, [comment.authorUrl UTF8String], -1, NULL);
            sqlite3_bind_text(stmt, 4, [comment.authorIP UTF8String], -1, NULL);
            sqlite3_bind_text(stmt, 5, [[self getDateStr:comment.date] UTF8String], -1, NULL);
            sqlite3_bind_text(stmt, 6, [comment.content UTF8String], -1, NULL);
            sqlite3_bind_text(stmt, 7, [comment.status UTF8String], -1, NULL);
            sqlite3_bind_text(stmt, 8, [comment.type UTF8String], -1, NULL);
            sqlite3_bind_text(stmt, 9, [comment.postTitle UTF8String], -1, NULL);
            sqlite3_bind_text(stmt, 10, [comment.link UTF8String], -1, NULL);
            if (sqlite3_step(stmt) == SQLITE_DONE) {
                //插入计数加1
                changedCommentsNum ++;
                if (changedCommentsNum == _comments.count) {
                    [self.delegate writeDBCommentsSuccess:_comments];
                }
            }
        }
        sqlite3_finalize(stmt);
        sqlite3_close(db);
    }
}

- (void)maybeFetchPostCommentsOfStatus:(NSString *)commentStatus commentType:(NSString *)commentType inCommentPage:(NSInteger)page
{
    int nowTimestamp = [[NSDate date] timeIntervalSince1970];
    int lastSyncTimestamp = [self getPostCommentsLastSyncTimestamp:_post.postID];
    if (lastSyncTimestamp + timeInterval < nowTimestamp) {
        //获取远程服务器评论
        [self fetchPostCommentsOfStatus:commentStatus commentType:commentType inCommentPage:page];
    }
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
    [dateFormat setDateFormat:@"YYYY-MM-DD HH:MM:SS ZZZ"];
    NSDate *date = [dateFormat dateFromString:dateStr];
    return date;
}

/**
 *  格式化时间为字符串
 *
 *  @param date NSDate对象
 *
 *  @return 时间字符串
 */
- (NSString *)getDateStr:(NSDate *)date
{
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"YYYY-MM-DD HH:MM:SS ZZZ"];
    NSString *dateStr = [dateFormat stringFromDate:date];
    return dateStr;
}

- (int)getPostCommentsLastSyncTimestamp:(NSNumber *)postId
{
    NSString *path = [self userDataFilePath];
    const char *npath = [path UTF8String];
    //打开数据库
    if (sqlite3_open(npath, &db) != SQLITE_OK) {
        NSAssert(NO, @"打开数据库文件失败");
    }else{
        NSString *sql = @"SELECT LASTSYNCCOMMENT FROM POSTS WHERE POSTID = ?";
        const char *nsql = [sql UTF8String];
        sqlite3_stmt *stmt;
        if (sqlite3_prepare_v2(db, nsql, -1, &stmt, NULL) == SQLITE_OK ){
            sqlite3_bind_int(stmt, 1, [postId intValue]);
            if (sqlite3_step(stmt) == SQLITE_ROW) {
                int lastSyncTimestamp = sqlite3_column_int(stmt, 0);
                sqlite3_finalize(stmt);
                //sqlite3_close(db);
                return lastSyncTimestamp;
            }else{
                sqlite3_finalize(stmt);
                //sqlite3_close(db);
                return 0;
            }
        }
        sqlite3_finalize(stmt);
        //sqlite3_close(db);
    }
    return 0;
}

- (void)postCommentsLastSynced:(NSNumber *)postId
{
    int timestamp = (int)[[NSDate date] timeIntervalSince1970];
    NSString *path = [self userDataFilePath];
    const char *npath = [path UTF8String];
    //打开数据库
    if (sqlite3_open(npath, &db) != SQLITE_OK) {
        NSAssert(NO, @"打开数据库文件失败");
    }else{
        NSString *sql = @"UPDATE POSTS SET LASTSYNCCOMMENT = ? WHERE POSTID = ?";
        const char *nsql = [sql UTF8String];
        sqlite3_stmt *stmt;
        if (sqlite3_prepare_v2(db, nsql, -1, &stmt, NULL) == SQLITE_OK ){
            sqlite3_bind_int(stmt, 1, timestamp);
            sqlite3_bind_int(stmt, 2, [postId intValue]);
            if (sqlite3_step(stmt) == SQLITE_DONE) {
                //
            }
        }
        sqlite3_finalize(stmt);
        sqlite3_close(db);
    }
}
     
#pragma mark - Private methods

- (NSArray *)remoteCommentsFromXMLRPCArray:(NSArray *)xmlrpcArray
{
    return [xmlrpcArray wp_map:^id(NSDictionary *xmlrpcComment) {
        return [self remoteCommentFromXMLRPCDictionary:xmlrpcComment];
    }];
}

- (Comment *)remoteCommentFromXMLRPCDictionary:(NSDictionary *)xmlrpcDictionary
{
    Comment *comment = [Comment new];
    comment.author = xmlrpcDictionary[@"author"];
    comment.authorEmail = xmlrpcDictionary[@"author_email"];
    comment.authorUrl = xmlrpcDictionary[@"author_url"];
    comment.authorIP = xmlrpcDictionary[@"author_ip"];
    comment.commentId = [[xmlrpcDictionary numberForKey:@"comment_id"] integerValue];
    comment.content = xmlrpcDictionary[@"content"];
    comment.date = xmlrpcDictionary[@"date_created_gmt"];
    comment.link = xmlrpcDictionary[@"link"];
    comment.parent = [[xmlrpcDictionary numberForKey:@"parent"] integerValue];
    comment.postId = [[xmlrpcDictionary numberForKey:@"post_id"] integerValue];
    comment.postTitle = xmlrpcDictionary[@"post_title"];
    comment.status = xmlrpcDictionary[@"status"];
    comment.type = xmlrpcDictionary[@"type"];
    comment.userId = [[xmlrpcDictionary numberForKey:@"user_id"] integerValue];
    comment.siteId = _blog.id;
    return comment;
}

- (BOOL)existComment:(NSInteger)commentID inBlog:(NSInteger)blogID
{
    NSString *path = [self userDataFilePath];
    const char *npath = [path UTF8String];
    //打开数据库
    if (sqlite3_open(npath, &db) != SQLITE_OK) {
        NSAssert(NO, @"打开数据库文件失败");
    }else{
        NSString *sql = @"SELECT * FROM COMMENTS WHERE COMMENTID = ? AND SITEID = ?";
        const char *nsql = [sql UTF8String];
        sqlite3_stmt *stmt;
        if (sqlite3_prepare_v2(db, nsql, -1, &stmt, NULL) == SQLITE_OK ){
            sqlite3_bind_int(stmt, 1, (int)commentID);
            sqlite3_bind_int(stmt, 2, (int)_blog.id);
            if (sqlite3_step(stmt) == SQLITE_ROW) {
                sqlite3_finalize(stmt);
                //sqlite3_close(db);
                return YES;
            }
        }
        sqlite3_finalize(stmt);
        //sqlite3_close(db);
        
    }
    return NO;
}


@end
