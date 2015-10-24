//
//  PostControll.m
//  WordPressKit
//
//  Created by wuxueqian on 15/9/24.
//  Copyright (c) 2015年 wuxueqian. All rights reserved.
//

#import "PostControll.h"

#import "WordPressXMLRPCApi.h"
#import "WPMapFilterReduce.h"
#import "Post.h"
#import "PostCategory.h"
#import "NSDictionary+SafeExpectations.h"
#import "NSString+Util.h"

#import "DataModel.h"

extern NSString * const PostStatusDraft;
extern NSString * const PostStatusPending;
extern NSString * const PostStatusPrivate;
extern NSString * const PostStatusPublish;
extern NSString * const PostStatusScheduled;
extern NSString * const PostStatusTrash;

static NSString * postTypePC = @"post";
static NSInteger numOfPostsPerPagePC = 10;
static NSUInteger pagePC = 1;
static NSString * postStatusPC = @"publish";

extern NSInteger numOfPostsPerPageA;
extern NSInteger numOfPostsPerPageB;
extern NSInteger numOfPostsPerPageC;
extern NSUInteger pageA;
extern NSUInteger pageB;
extern NSUInteger pageC;
extern NSString * postStatusA;
extern NSString * postStatusB;
extern NSString * postStatusC;

static NSInteger changedPostsNum = 0;
static NSInteger insertedPostsNum = 0;

@interface PostControll()

+ (WordPressXMLRPCApi *)getApiWithBlog:(Blog *)blog;
+ (WPXMLRPCClient *)getClientWithBlog:(Blog *)blog;
+ (NSArray *)remotePostsFromXMLRPCArray:(NSArray *)xmlrpcArray;
+ (Post *)remotePostFromXMLRPCDictionary:(NSDictionary *)xmlrpcDictionary;
+ (NSString *)statusForPostStatus:(NSString *)status andDate:(NSDate *)date;
+ (NSArray *)tagsFromXMLRPCTermsArray:(NSArray *)terms;
+ (NSArray *)remoteCategoriesFromXMLRPCTermsArray:(NSArray *)terms;
+ (PostCategory *)remoteCategoryFromXMLRPCDictionary:(NSDictionary *)xmlrpcCategory;
+ (void)writePostsToDB:(NSArray *)posts inBlog:(Blog *)blog postType:(NSString *)postType;
- (void)writePostToDB:(Post *)post inBlog:(Blog *)blog needNotification:(BOOL)needNotification;
- (NSString *)userDataFilePath;
- (BOOL)existPost:(NSNumber *)postId inBlogId:(NSInteger)blogId;
- (NSDate *)getDateFromStr:(NSString *)dateStr;
- (NSString *)getDateStr:(NSDate *)date;
- (void)insertCats:(NSArray *)categories;
- (void)insertCat:(PostCategory *)category;
- (BOOL)existCategory:(NSNumber *)categoryId;
- (PostCategory *)queryCategoryWithId:(NSNumber *)categoryId;
- (void)siteLastSynced:(NSNumber *)siteid;
- (int)getSiteLastSyncTimestamp:(NSInteger)siteid;
- (void)configSyncStatus:(BOOL)status ForBlog:(Blog *)blog;
- (void)configNetworkStatus:(BOOL)status;
- (NSString *)getExcerptofPost:(Post *)post;
- (NSDateComponents *)differenceBetweenDate:(NSDate*)fromDateTime andDate:(NSDate*)toDateTime;

@end

@implementation PostControll


- (instancetype)initWithBlog:(Blog *)blog
{
    self = [super init];
    if (!self) {
        return nil;
    }
    self.client = [PostControll getClientWithBlog:blog];
    self.api = [PostControll getApiWithBlog:blog];
    self.blog = blog;
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

/**
 *  根据请求调用方文章类型决定一些全局变量
 *
 *  @param postType 文章类型,一般为post或page
 */
+ (void)configureStaticVariablesWithPostType:(NSString *)postType
{
    if ([postType isEqualToString:@"post"]) {
        numOfPostsPerPagePC = numOfPostsPerPageA;
        pagePC = pageA;
        postStatusPC = postStatusA;
    }else if ([postType isEqualToString:@"page"]){
        numOfPostsPerPagePC = numOfPostsPerPageB;
        pagePC = pageB;
        postStatusPC = postStatusB;
    }else{
        numOfPostsPerPagePC = numOfPostsPerPageC;
        pagePC = pageC;
        postStatusPC = postStatusC;
    }
    postTypePC = postType;
}

/**
 *  抓取远程服务器文章数据并实现数据持久化
 *
 *  @param blog 博客对象，用于获取用户名密码以及xmlrpc接口地址
 */
+ (void)syncPostsWithBlog:(Blog *)blog postType:(NSString *)postType page:(NSInteger)page
{
    //修改全局变量
    [self configureStaticVariablesWithPostType:postType];
    
    PostControll *pc = [[PostControll alloc] initWithBlog:blog];
    [pc configSyncStatus:YES ForBlog:blog];
    NSDictionary *options = @{@"offset": [NSNumber numberWithInteger:(page-1)*numOfPostsPerPagePC]};
    [self getPostsOfType:postType forBlog:blog options:options success:^(NSArray *posts) {
        [self writePostsToDB:posts inBlog:blog postType:postType];
        [pc configSyncStatus:NO ForBlog:blog];
        [pc configNetworkStatus:YES];
        
    } failure:^(NSError *error) {
        //*****************************//
        NSLog(@"sync error: %@",error.description);
        [pc configSyncStatus:NO ForBlog:blog];
        [pc configNetworkStatus:NO];
        
    }];
}

/**
 *  将文章数组对象写入数据库
 *
 *  @param posts 格式化的文章数组对象
 *  @param blog  博客对象,区别文章归属
 */
+ (void)writePostsToDB:(NSArray *)posts inBlog:(Blog *)blog postType:(NSString *)postType
{
    if (!posts || posts.count == 0) {
        //广播通知ListPostsViewController
        NSDictionary *info = @{@"insertedPostsNum" : [NSNumber numberWithInteger:insertedPostsNum],@"netWorkOk" : @YES};
        [[NSNotificationCenter defaultCenter] postNotificationName:@"writePostsToDBNotification" object:nil userInfo:info];
        return;
    }
    PostControll *pc = [[self alloc] initWithBlog:blog];
    insertedPostsNum = changedPostsNum = 0;
    for (Post *post in posts) {
        [pc writePostToDB:post inBlog:blog needNotification:!(changedPostsNum+1!=posts.count)];
    }
    //记录博客同步时间
    [pc siteLastSynced:[NSNumber numberWithInt:(int)blog.id]];
    pc = nil;
    
}

/**
 *  判断文章是否存在于数据库
 *
 *  @param postId 判断的文章Id
 *  @param blogId 博客的Id
 *
 *  @return 存在则返回YES,否则NO
 */
- (BOOL)existPost:(NSNumber *)postId inBlogId:(NSInteger)blogId
{
    NSString *path = [self userDataFilePath];
    const char *npath = [path UTF8String];
    //打开数据库
    if (sqlite3_open(npath, &db) != SQLITE_OK) {
        NSAssert(NO, @"打开数据库文件失败");
    }else{
        NSString *sql = @"SELECT * FROM POSTS WHERE POSTID = ? AND SITEID = ?";
        const char *nsql = [sql UTF8String];
        sqlite3_stmt *stmt;
        if (sqlite3_prepare_v2(db, nsql, -1, &stmt, NULL) == SQLITE_OK ){
            sqlite3_bind_int(stmt, 1, [postId intValue]);
            sqlite3_bind_int(stmt, 2, (int)self.blog.id);
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

/**
 *  将文章对象写入数据库
 *
 *  @param post 格式化的单个文章对象
 *  @param blog 博客对象,区别文章归属
 */
- (void)writePostToDB:(Post *)post inBlog:(Blog *)blog needNotification:(BOOL)needNotification;
{
    int siteid = (int)blog.id;
    //将categories数组写入对应表，重组category id为字符串写入post对应字段
    NSMutableArray *catIds = [NSMutableArray new];
    for (PostCategory *cat in post.categories) {
        [self insertCat:cat];
        [catIds addObject:cat.categoryID];
    
    }
    NSString *catStr = [catIds componentsJoinedByString:@","];
    //tag
    NSString *tagStr = [post.tags componentsJoinedByString:@","];
    //metaData
    NSData *metaData = [NSJSONSerialization dataWithJSONObject:post.metadata options:NSJSONWritingPrettyPrinted error:nil];
    NSString *metaStr = [[NSString alloc] initWithData:metaData encoding:NSUTF8StringEncoding];
    
    NSString *path = [self userDataFilePath];
    const char *npath = [path UTF8String];
    //打开数据库
    if (sqlite3_open(npath, &db) != SQLITE_OK) {
        NSAssert(NO, @"打开数据库文件失败");
    }else{
        //判断post是否已存在,不存在则插入,存在则更新
        NSString *sql;
        if ([self existPost:post.postID inBlogId:siteid]) {
            sql = [NSString stringWithFormat:@"UPDATE POSTS SET SITEID = %i, AUTHORAVATAR = ?, AUTHORNAME = ?, AUTHOREMAIL = ?, AUTHORURL = ?, AUTHORID = %i, DATE = ?, TITLE = ?, URL = ?, SHORTURL = ?, CONTENT = ?, EXCERPT = ?, SLUG = ?, STATUS = ?, PASSWORD = ?, PARENTID = %i, POSTTHUMBNAILID = %i, POSTTHUMBNAILPATH = ?, TYPE = ?, FORMAT = ?, COMMENTCOUNT = %i, CATEGORIES = ?, TAGS = ?, PATHFORDISPLAYIMAGE = ?, METADATA = ? WHERE POSTID = %i",siteid,[post.authorID intValue],[post.parentID intValue],[post.postThumbnailID intValue],[post.commentCount intValue],[post.postID intValue]];
        }else{
          sql = [NSString stringWithFormat:@"INSERT INTO POSTS (POSTID, SITEID, AUTHORAVATAR, AUTHORNAME, AUTHOREMAIL, AUTHORURL, AUTHORID, DATE, TITLE, URL, SHORTURL, CONTENT, EXCERPT, SLUG, STATUS, PASSWORD, PARENTID, POSTTHUMBNAILID, POSTTHUMBNAILPATH, TYPE, FORMAT, COMMENTCOUNT, CATEGORIES, TAGS, PATHFORDISPLAYIMAGE, METADATA) VALUES(%i, %i,?,?,?,?,%i,?,?,?,?,?,?,?,?,?,%i,%i,?,?,?,%i,?,?,?,?)",[post.postID intValue],siteid,[post.authorID intValue],[post.parentID intValue],[post.postThumbnailID intValue],[post.commentCount intValue]];
            insertedPostsNum++;
        }
        const char *nsql = [sql UTF8String];
        sqlite3_stmt *stmt;
        if (sqlite3_prepare_v2(db, nsql, -1, &stmt, NULL) == SQLITE_OK ){
            //bind
            sqlite3_bind_text(stmt, 1, [post.authorAvatarURL UTF8String], -1, NULL);
            sqlite3_bind_text(stmt, 2, [post.authorDisplayName UTF8String], -1, NULL);
            sqlite3_bind_text(stmt, 3, [post.authorEmail UTF8String], -1, NULL);
            sqlite3_bind_text(stmt, 4, [post.authorURL UTF8String], -1, NULL);
            sqlite3_bind_text(stmt, 5, [[self getDateStr:post.date] UTF8String], -1, NULL);
            sqlite3_bind_text(stmt, 6, [post.title UTF8String], -1, NULL);
            sqlite3_bind_text(stmt, 7, [[post.URL absoluteString] UTF8String], -1, NULL);
            sqlite3_bind_text(stmt, 8, [[post.shortURL absoluteString] UTF8String], -1, NULL);
            sqlite3_bind_text(stmt, 9, [post.content UTF8String], -1, NULL);
            //NSString *excerpt = [self getExcerptofPost:post];
            sqlite3_bind_text(stmt, 10, [post.excerpt UTF8String], -1, NULL);
            sqlite3_bind_text(stmt, 11, [post.slug UTF8String], -1, NULL);
            sqlite3_bind_text(stmt, 12, [post.status UTF8String], -1, NULL);
            sqlite3_bind_text(stmt, 13, [post.password UTF8String], -1, NULL);
            sqlite3_bind_text(stmt, 14, [post.postThumbnailPath UTF8String], -1, NULL);
            sqlite3_bind_text(stmt, 15, [post.type UTF8String], -1, NULL);
            sqlite3_bind_text(stmt, 16, [post.format UTF8String], -1, NULL);
            sqlite3_bind_text(stmt, 17, [catStr UTF8String], -1, NULL);
            sqlite3_bind_text(stmt, 18, [tagStr UTF8String], -1, NULL);
            sqlite3_bind_text(stmt, 19, [post.pathForDisplayImage UTF8String], -1, NULL);
            sqlite3_bind_text(stmt, 20, [metaStr UTF8String], -1, NULL);
            if (sqlite3_step(stmt) == SQLITE_DONE) {
                //插入计数加1
                changedPostsNum ++;
            }
        }
        sqlite3_finalize(stmt);
        sqlite3_close(db);
    }
    if (needNotification) {
        //广播通知ListPostsViewController
        NSDictionary *info = @{@"insertedPostsNum" : [NSNumber numberWithInteger:insertedPostsNum],@"netWorkOk" : @YES};
        [[NSNotificationCenter defaultCenter] postNotificationName:@"writePostsToDBNotification" object:nil userInfo:info];
    }
}

/**
 *  通过XMLRPC API抓取远程服务器的文章或页面
 *
 *  @param postType WordPress的文章类型，主要为post或page
 *  @param blog     博客对象，用于获取用户名密码以及xmlrpc接口地址
 *  @param options  额外的WordPress查询文章参数
 *  @param success  Block-返回文章数组
 *  @param failure  Block-返回错误描述
 */
+ (void)getPostsOfType:(NSString *)postType
               forBlog:(Blog *)blog
               options:(NSDictionary *)options
               success:(void (^)(NSArray *posts))success
               failure:(void (^)(NSError *error))failure {
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    WPXMLRPCClient *client = [self getClientWithBlog:blog];
    //NSArray *statuses = @[PostStatusDraft, PostStatusPending, PostStatusPrivate, PostStatusPublish, PostStatusScheduled, PostStatusTrash];
    //NSString *postStatus = [statuses componentsJoinedByString:@","];
    NSDictionary *extraParameters = @{
                                      @"number": [NSNumber numberWithInteger: numOfPostsPerPagePC],
                                      @"post_type": postType,
                                      @"post_status": postStatusPC,
                                      @"offset": [NSNumber numberWithInteger:(pagePC-1)*numOfPostsPerPagePC]
                                      };
    if (options) {
        NSMutableDictionary *mutableParameters = [extraParameters mutableCopy];
        [mutableParameters addEntriesFromDictionary:options];
        extraParameters = [NSDictionary dictionaryWithDictionary:mutableParameters];
    }
    NSArray *parameters = [blog getXMLRPCArgsWithExtra:extraParameters];
    [client  callMethod:@"wp.getPosts"
              parameters:parameters
                 success:^(AFHTTPRequestOperation *operation, id responseObject) {
                     NSAssert([responseObject isKindOfClass:[NSArray class]], @"Response should be an array.");
                     if (success) {
                         [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
                         success([self remotePostsFromXMLRPCArray:responseObject]);
                     }
                 } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                     if (failure) {
                         [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
                         failure(error);
                     }
                 }];
}

+ (NSArray *)remotePostsFromXMLRPCArray:(NSArray *)xmlrpcArray {
    return [xmlrpcArray wp_map:^id(NSDictionary *xmlrpcPost) {
        return [self remotePostFromXMLRPCDictionary:xmlrpcPost];
    }];
}

+ (Post *)remotePostFromXMLRPCDictionary:(NSDictionary *)xmlrpcDictionary {
    Post *post = [Post new];
    
    post.postID = [xmlrpcDictionary numberForKey:@"post_id"];
    post.date = xmlrpcDictionary[@"post_date_gmt"];
    if (xmlrpcDictionary[@"link"]) {
        post.URL = [NSURL URLWithString:xmlrpcDictionary[@"link"]];
    }
    post.title = xmlrpcDictionary[@"post_title"];
    post.content = xmlrpcDictionary[@"post_content"];
    post.excerpt = xmlrpcDictionary[@"post_excerpt"];
    post.slug = xmlrpcDictionary[@"post_name"];
    post.authorID = [xmlrpcDictionary numberForKey:@"post_author"];
    post.status = [self statusForPostStatus:xmlrpcDictionary[@"post_status"] andDate:post.date];
    post.password = xmlrpcDictionary[@"post_password"];
    if ([post.password isEmpty]) {
        post.password = nil;
    }
    post.parentID = [xmlrpcDictionary numberForKey:@"post_parent"];
    // When there is no featured image, post_thumbnail is an empty array :(
    NSDictionary *thumbnailDict = [xmlrpcDictionary dictionaryForKey:@"post_thumbnail"];
    post.postThumbnailID = [thumbnailDict numberForKey:@"attachment_id"];
    post.postThumbnailPath = [thumbnailDict stringForKey:@"link"];
    post.type = xmlrpcDictionary[@"post_type"];
    post.format = xmlrpcDictionary[@"post_format"];
    
    post.metadata = xmlrpcDictionary[@"custom_fields"];
    //post.commentCount = [xmlrpcDictionary numberForKey:@"comment_count"];
    NSArray *terms = [xmlrpcDictionary arrayForKey:@"terms"];
    post.tags = [self tagsFromXMLRPCTermsArray:terms];
    post.categories = [self remoteCategoriesFromXMLRPCTermsArray:terms];
    
    // Pick an image to use for display
    if (post.postThumbnailPath) {
        post.pathForDisplayImage = post.postThumbnailPath;
    } else {
        // parse content for a suitable image.
        //post.pathForDisplayImage = [DisplayableImageHelper searchPostContentForImageToDisplay:post.content];
        post.pathForDisplayImage = nil;
    }
    
    return post;
}

+ (NSString *)statusForPostStatus:(NSString *)status andDate:(NSDate *)date
{
    // Scheduled posts are synced with a post_status of 'publish' but we want to
    // work with a status of 'future' from within the app.
    if (date == [date laterDate:[NSDate date]]) {
        return PostStatusScheduled;
    }
    return status;
}

+ (NSArray *)tagsFromXMLRPCTermsArray:(NSArray *)terms {
    NSArray *tags = [terms filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"taxonomy = 'post_tag' AND name != NIL"]];
    return [tags valueForKey:@"name"];
}

+ (NSArray *)remoteCategoriesFromXMLRPCTermsArray:(NSArray *)terms {
    return [[terms wp_filter:^BOOL(NSDictionary *category) {
        return [[category stringForKey:@"taxonomy"] isEqualToString:@"category"];
    }] wp_map:^id(NSDictionary *category) {
        return [self remoteCategoryFromXMLRPCDictionary:category];
    }];
}

+ (PostCategory *)remoteCategoryFromXMLRPCDictionary:(NSDictionary *)xmlrpcCategory {
    PostCategory *category = [PostCategory new];
    category.categoryID = [xmlrpcCategory numberForKey:@"term_id"];
    category.name = [xmlrpcCategory stringForKey:@"name"];
    category.parentID = [xmlrpcCategory numberForKey:@"parent"];
    return category;
}

/**
 *  从数据库查询获取最新的文章数据
 *
 *  @param postType   WordPress文章类型
 *  @param postStatus WordPress 文章状态
 *  @param blog       博客对象
 *  @param number     查询文章的数量
 */
- (void)getDBPostsofType:(NSString *)postType postStatus:(NSString *)postStatus ForBlog:(Blog *)blog number:(NSInteger)number
{
    //修改全局变量
    [PostControll configureStaticVariablesWithPostType:postType];
    
    NSString *path = [self userDataFilePath];
    const char *npath = [path UTF8String];
    //打开数据库
    if (sqlite3_open(npath, &db) != SQLITE_OK) {
        NSAssert(NO, @"打开数据库文件失败");
    }else{
        NSString *sql = [NSString stringWithFormat:@"SELECT * FROM POSTS WHERE TYPE = '%@' AND STATUS = '%@' AND SITEID = %i ORDER BY POSTID DESC LIMIT %i",postType,postStatus,(int)blog.id,(int)number];
        const char *nsql = [sql UTF8String];
        sqlite3_stmt *stmt;
        if (sqlite3_prepare_v2(db, nsql, -1, &stmt, NULL) == SQLITE_OK) {
            NSMutableArray *results = [[NSMutableArray alloc] init];
            while (sqlite3_step(stmt) == SQLITE_ROW) {
                Post *post = [[Post alloc] init];
                // col 0 为自增序号，无需记录至post对象
                post.postID = [NSNumber numberWithInt:sqlite3_column_int(stmt, 1)];
                post.siteID = [NSNumber numberWithInt:sqlite3_column_int(stmt, 2)];
                post.authorAvatarURL = sqlite3_column_text(stmt, 3) ? [NSString stringWithUTF8String:(char *)sqlite3_column_text(stmt, 3)] : @"";
                post.authorDisplayName = sqlite3_column_text(stmt, 4) ? [NSString stringWithUTF8String:(char *)sqlite3_column_text(stmt, 4)] : @"";
                post.authorEmail = sqlite3_column_text(stmt, 5) ? [NSString stringWithUTF8String:(char *)sqlite3_column_text(stmt, 5)] : @"";
                post.authorURL = sqlite3_column_text(stmt, 6) ? [NSString stringWithUTF8String:(char *)sqlite3_column_text(stmt, 6)] : @"";
                post.authorID = [NSNumber numberWithInt:sqlite3_column_int(stmt, 7)];
                post.date = [self getDateFromStr:[NSString stringWithUTF8String:(char *)sqlite3_column_text(stmt, 8)]];
                post.title = [NSString stringWithUTF8String:(char *)sqlite3_column_text(stmt, 9)];
                post.URL = [NSURL URLWithString:[NSString stringWithUTF8String:(char *)sqlite3_column_text(stmt, 10)]];
                post.shortURL = sqlite3_column_text(stmt, 11) ? [NSURL URLWithString:[NSString stringWithUTF8String:(char *)sqlite3_column_text(stmt, 11)]] : nil;
                post.content = sqlite3_column_text(stmt, 12) ? [NSString stringWithUTF8String:(char *)sqlite3_column_text(stmt, 12)] : @"";
                post.excerpt = sqlite3_column_text(stmt, 13) ? [NSString stringWithUTF8String:(char *)sqlite3_column_text(stmt, 13)] : @"";
                post.slug = sqlite3_column_text(stmt, 14) ? [NSString stringWithUTF8String:(char *)sqlite3_column_text(stmt, 14)] : @"";
                post.status = [NSString stringWithUTF8String:(char *)sqlite3_column_text(stmt, 15)];
                post.password = sqlite3_column_text(stmt, 16) ? [NSString stringWithUTF8String:(char *)sqlite3_column_text(stmt, 16)] : @"";
                post.parentID = [NSNumber numberWithInt:sqlite3_column_int(stmt, 17)];
                post.postThumbnailID = [NSNumber numberWithInt:sqlite3_column_int(stmt, 18)];
                post.postThumbnailPath = sqlite3_column_text(stmt, 19) ? [NSString stringWithUTF8String:(char *)sqlite3_column_text(stmt, 19)] : @"";
                post.type = [NSString stringWithUTF8String:(char *)sqlite3_column_text(stmt, 20)];
                post.format = [NSString stringWithUTF8String:(char *)sqlite3_column_text(stmt, 21)];
                post.commentCount = [NSNumber numberWithInt:sqlite3_column_int(stmt, 22)];
                //categories
                NSArray *catIds = [[NSString stringWithUTF8String:(char *)sqlite3_column_text(stmt, 23)] componentsSeparatedByString:@","];
                NSMutableArray *cats = [NSMutableArray new];
                for (NSString *catId in catIds) {
                    NSNumber *categoryId = [NSNumber numberWithInteger:[catId integerValue]];
                    PostCategory *category = [self queryCategoryWithId:categoryId];
                    if (category) {
                        [cats addObject:category];
                    }
                }
                post.categories = [cats copy];
                //tags
                NSArray *tagNames = sqlite3_column_text(stmt, 24) ? [[NSString stringWithUTF8String:(char *)sqlite3_column_text(stmt, 24)] componentsSeparatedByString:@","] : nil;
                post.tags = tagNames;
                
                post.pathForDisplayImage = sqlite3_column_text(stmt, 25) ? [NSString stringWithUTF8String:(char *)sqlite3_column_text(stmt, 25)] : @"";
                
                //meta
                NSString *metaStr = [NSString stringWithUTF8String:(char *)sqlite3_column_text(stmt, 26)];
                NSArray *metaArr = [NSJSONSerialization JSONObjectWithData:[metaStr dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableLeaves error:nil];
                post.metadata = metaArr;
                post.lastSyncComment = sqlite3_column_int(stmt, 27);
                
                [results addObject:post];
                
            }
            self.posts = results;
            
            //广播通知PostsListViewController
            NSDictionary *info = @{@"queryedDBPostsCount" : [NSNumber numberWithInteger:results.count]};
            [[NSNotificationCenter defaultCenter] postNotificationName:@"queryedDBPostsNotification" object:nil userInfo:info];
            
        }
        sqlite3_finalize(stmt);
        sqlite3_close(db);
    }
    
}

/**
 *  从数据库查询获取最新的文章数据
 *
 *  @param postType   WordPress文章类型
 *  @param postStatus WordPress 文章状态
 *  @param blog       博客对象
 *  @param page       页码
 *
 *  @return Posts数组
 */
- (NSArray *)loadMoreDBPostsofType:(NSString *)postType postStatus:(NSString *)postStatus ForBlog:(Blog *)blog page:(NSInteger)page
{
    //修改全局变量
    [PostControll configureStaticVariablesWithPostType:postType];
    NSString *path = [self userDataFilePath];
    const char *npath = [path UTF8String];
    //打开数据库
    if (sqlite3_open(npath, &db) != SQLITE_OK) {
        NSAssert(NO, @"打开数据库文件失败");
    }else{
        NSString *sql = [NSString stringWithFormat:@"SELECT * FROM POSTS WHERE TYPE = '%@' AND STATUS = '%@' AND SITEID = %i ORDER BY POSTID DESC LIMIT %li,%i",postType,postStatus,(int)blog.id,(int)numOfPostsPerPagePC*(page-1),(int)numOfPostsPerPagePC];
        const char *nsql = [sql UTF8String];
        sqlite3_stmt *stmt;
        if (sqlite3_prepare_v2(db, nsql, -1, &stmt, NULL) == SQLITE_OK) {
            NSMutableArray *results = [[NSMutableArray alloc] init];
            while (sqlite3_step(stmt) == SQLITE_ROW) {
                Post *post = [[Post alloc] init];
                // col 0 为自增序号，无需记录至post对象
                post.postID = [NSNumber numberWithInt:sqlite3_column_int(stmt, 1)];
                post.siteID = [NSNumber numberWithInt:sqlite3_column_int(stmt, 2)];
                post.authorAvatarURL = sqlite3_column_text(stmt, 3) ? [NSString stringWithUTF8String:(char *)sqlite3_column_text(stmt, 3)] : @"";
                post.authorDisplayName = sqlite3_column_text(stmt, 4) ? [NSString stringWithUTF8String:(char *)sqlite3_column_text(stmt, 4)] : @"";
                post.authorEmail = sqlite3_column_text(stmt, 5) ? [NSString stringWithUTF8String:(char *)sqlite3_column_text(stmt, 5)] : @"";
                post.authorURL = sqlite3_column_text(stmt, 6) ? [NSString stringWithUTF8String:(char *)sqlite3_column_text(stmt, 6)] : @"";
                post.authorID = [NSNumber numberWithInt:sqlite3_column_int(stmt, 7)];
                post.date = [self getDateFromStr:[NSString stringWithUTF8String:(char *)sqlite3_column_text(stmt, 8)]];
                post.title = [NSString stringWithUTF8String:(char *)sqlite3_column_text(stmt, 9)];
                post.URL = [NSURL URLWithString:[NSString stringWithUTF8String:(char *)sqlite3_column_text(stmt, 10)]];
                post.shortURL = sqlite3_column_text(stmt, 11) ? [NSURL URLWithString:[NSString stringWithUTF8String:(char *)sqlite3_column_text(stmt, 11)]] : nil;
                post.content = sqlite3_column_text(stmt, 12) ? [NSString stringWithUTF8String:(char *)sqlite3_column_text(stmt, 12)] : @"";
                post.excerpt = sqlite3_column_text(stmt, 13) ? [NSString stringWithUTF8String:(char *)sqlite3_column_text(stmt, 13)] : @"";
                post.slug = sqlite3_column_text(stmt, 14) ? [NSString stringWithUTF8String:(char *)sqlite3_column_text(stmt, 14)] : @"";
                post.status = [NSString stringWithUTF8String:(char *)sqlite3_column_text(stmt, 15)];
                post.password = sqlite3_column_text(stmt, 16) ? [NSString stringWithUTF8String:(char *)sqlite3_column_text(stmt, 16)] : @"";
                post.parentID = [NSNumber numberWithInt:sqlite3_column_int(stmt, 17)];
                post.postThumbnailID = [NSNumber numberWithInt:sqlite3_column_int(stmt, 18)];
                post.postThumbnailPath = sqlite3_column_text(stmt, 19) ? [NSString stringWithUTF8String:(char *)sqlite3_column_text(stmt, 19)] : @"";
                post.type = [NSString stringWithUTF8String:(char *)sqlite3_column_text(stmt, 20)];
                post.format = [NSString stringWithUTF8String:(char *)sqlite3_column_text(stmt, 21)];
                post.commentCount = [NSNumber numberWithInt:sqlite3_column_int(stmt, 22)];
                //categories
                NSArray *catIds = [[NSString stringWithUTF8String:(char *)sqlite3_column_text(stmt, 23)] componentsSeparatedByString:@","];
                NSMutableArray *cats = [NSMutableArray new];
                for (NSString *catId in catIds) {
                    NSNumber *categoryId = [NSNumber numberWithInteger:[catId integerValue]];
                    PostCategory *category = [self queryCategoryWithId:categoryId];
                    if (category) {
                        [cats addObject:category];
                    }
                }
                post.categories = [cats copy];
                //tags
                NSArray *tagNames = sqlite3_column_text(stmt, 24) ? [[NSString stringWithUTF8String:(char *)sqlite3_column_text(stmt, 24)] componentsSeparatedByString:@","] : nil;
                post.tags = tagNames;
                
                post.pathForDisplayImage = sqlite3_column_text(stmt, 25) ? [NSString stringWithUTF8String:(char *)sqlite3_column_text(stmt, 25)] : @"";
                
                //meta
                NSString *metaStr = [NSString stringWithUTF8String:(char *)sqlite3_column_text(stmt, 26)];
                NSArray *metaArr = [NSJSONSerialization JSONObjectWithData:[metaStr dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableLeaves error:nil];
                post.metadata = metaArr;
                
                [results addObject:post];
                
            }
            //合并posts
            NSLog(@"old posts: %lu \r\nloadmore count: %lu \r\npage is %i\r\n",(unsigned long)self.posts.count,(unsigned long)results.count,(int)page);
            self.posts = [self.posts arrayByAddingObjectsFromArray:results];
            
            //广播通知PostListsViewController
            NSDictionary *info = @{@"queryedDBPostsCount" : [NSNumber numberWithInteger:results.count]};
            [[NSNotificationCenter defaultCenter] postNotificationName:@"queryedDBPostsNotification" object:nil userInfo:info];
            return results;
            
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
    [dateFormat setDateFormat:@"YYYY-MM-DD HH:MM:SS"];
    NSString *dateStr = [dateFormat stringFromDate:date];
    return dateStr;
}

/**
 *  将文章分类数组对象插入数据库
 *
 *  @param categories 文章分类数组对象
 */
- (void)insertCats:(NSArray *)categories
{
    for (PostCategory *category in categories) {
        [self insertCat:category];
    }
}

/**
 *  将文章分类对象插入数据库
 *
 *  @param category 文章分类对象
 */
- (void)insertCat:(PostCategory *)category
{
    //检查是否存在该分类
    if ([self existCategory:category.categoryID]) {
        return;
    }
    NSString *path = [self userDataFilePath];
    const char *npath = [path UTF8String];
    //打开数据库
    if (sqlite3_open(npath, &db) != SQLITE_OK) {
        NSAssert(NO, @"打开数据库文件失败");
    }else{
        const char *sql = [[NSString stringWithFormat:@"INSERT INTO CATEGORIES (CATEGORYID,NAME,PARENTID) VALUES(%i,'%@',%i)",[category.categoryID intValue],category.name,[category.parentID intValue]] UTF8String];
        sqlite3_stmt *stmt;
        if (sqlite3_prepare_v2(db, sql, -1, &stmt, NULL) == SQLITE_OK) {
            if (sqlite3_step(stmt) == SQLITE_DONE) {
                //return;
            }
        }
        sqlite3_finalize(stmt);
        sqlite3_close(db);
    }
}

/**
 *  判断分类是否存在于数据库
 *
 *  @param categoryId 判断的分类Id
 *
 *  @return 存在则返回YES,否则NO
 */
- (BOOL)existCategory:(NSNumber *)categoryId
{
    NSString *path = [self userDataFilePath];
    const char *npath = [path UTF8String];
    //打开数据库
    if (sqlite3_open(npath, &db) != SQLITE_OK) {
        NSAssert(NO, @"打开数据库文件失败");
    }else{
        NSString *sql = @"SELECT * FROM CATEGORIES WHERE CATEGORYID = ?";
        const char *nsql = [sql UTF8String];
        sqlite3_stmt *stmt;
        if (sqlite3_prepare_v2(db, nsql, -1, &stmt, NULL) == SQLITE_OK ){
            sqlite3_bind_int(stmt, 1, [categoryId intValue]);
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

- (PostCategory *)queryCategoryWithId:(NSNumber *)categoryId
{
    NSString *path = [self userDataFilePath];
    const char *npath = [path UTF8String];
    //打开数据库
    if (sqlite3_open(npath, &db) != SQLITE_OK) {
        NSAssert(NO, @"打开数据库文件失败");
    }else{
        NSString *sql = @"SELECT * FROM CATEGORIES WHERE CATEGORYID = ?";
        const char *nsql = [sql UTF8String];
        sqlite3_stmt *stmt;
        if (sqlite3_prepare_v2(db, nsql, -1, &stmt, NULL) == SQLITE_OK ){
            sqlite3_bind_int(stmt, 1, [categoryId intValue]);
            if (sqlite3_step(stmt) == SQLITE_ROW) {
                PostCategory *cat = [PostCategory new];
                cat.categoryID = [NSNumber numberWithInt:sqlite3_column_int(stmt, 1)];
                cat.name = [NSString stringWithUTF8String:(char *)sqlite3_column_text(stmt, 2)];
                cat.parentID = [NSNumber numberWithInt:sqlite3_column_int(stmt, 1)];
                sqlite3_finalize(stmt);
                //sqlite3_close(db);
                return cat;
            }
        }
        sqlite3_finalize(stmt);
        //sqlite3_close(db);
    }
    return nil;
}

/**
 *  记录指定博客数据库最近更新时间

 *
 *  @param siteid 博客在数据库记录序号
 */
- (void)siteLastSynced:(NSNumber *)siteid
{
    int timestamp = (int)[[NSDate date] timeIntervalSince1970];
    NSString *path = [self userDataFilePath];
    const char *npath = [path UTF8String];
    //打开数据库
    if (sqlite3_open(npath, &db) != SQLITE_OK) {
        NSAssert(NO, @"打开数据库文件失败");
    }else{
        NSString *sql = @"UPDATE BLOGS SET LASTSYNC = ? WHERE ID = ?";
        const char *nsql = [sql UTF8String];
        sqlite3_stmt *stmt;
        if (sqlite3_prepare_v2(db, nsql, -1, &stmt, NULL) == SQLITE_OK ){
            sqlite3_bind_int(stmt, 1, timestamp);
            sqlite3_bind_int(stmt, 2, [siteid intValue]);
            if (sqlite3_step(stmt) == SQLITE_DONE) {
                //
            }
        }
        sqlite3_finalize(stmt);
        sqlite3_close(db);
    }
}

/**
 *  获取指定博客上次同步时间戳
 *
 *  @param siteid 博客在数据库记录的序号
 *
 *  @return 最后一次同步时间戳
 */
- (int)getSiteLastSyncTimestamp:(NSInteger)siteid
{
    NSString *path = [self userDataFilePath];
    const char *npath = [path UTF8String];
    //打开数据库
    if (sqlite3_open(npath, &db) != SQLITE_OK) {
        NSAssert(NO, @"打开数据库文件失败");
    }else{
        NSString *sql = @"SELECT LASTSYNC FROM BLOGS WHERE ID = ?";
        const char *nsql = [sql UTF8String];
        sqlite3_stmt *stmt;
        if (sqlite3_prepare_v2(db, nsql, -1, &stmt, NULL) == SQLITE_OK ){
            sqlite3_bind_int(stmt, 1, (int)siteid);
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

/**
 *  变更网络同步状态
 *
 *  @param status 是否正在同步
 *  @param blog   博客对象
 */
- (void)configSyncStatus:(BOOL)status ForBlog:(Blog *)blog
{
    self.syncing = status;
}

/**
 *  根据上次同步时间以及设定的更新最小间隔决定是否从网络同步
 *
 *  @param blog         博客对象
 *  @param timeInterval 最小更新间隔时间,单位为秒
 *  @param postType     文章类型,一般为post或page
 */
- (void)needsSyncPostsForBlog:(Blog *)blog forTimeInterval:(NSInteger)timeInterval postType:(NSString *)postType
{
    //修改全局变量
    [PostControll configureStaticVariablesWithPostType:postType];
    
    int nowTimestamp = [[NSDate date] timeIntervalSince1970];
    int lastSyncTimestamp = [self getSiteLastSyncTimestamp:blog.id];
    if (lastSyncTimestamp + timeInterval < nowTimestamp) {
        [PostControll syncPostsWithBlog:blog postType:postType page:pagePC];
        //DDLogError(@"last is %i and now is %i",lastSyncTimestamp,nowTimestamp);
    }
}

/**
 *  最新网络请求失败或成功状态
 *
 *  @param status 网络请求是否成功
 */
- (void)configNetworkStatus:(BOOL)status
{
    self.networkFailure = status;
    if (!status) {
        //广播通知ListPostsViewController网络加载失败
        NSDictionary *info = @{@"insertedPostsNum" : [NSNumber numberWithInt:0],@"netWorkOk" : @NO};
        [[NSNotificationCenter defaultCenter] postNotificationName:@"writePostsToDBNotification" object:nil userInfo:info];
    }
}

/**
 *  获取文章的摘要
 *
 *  @param post post对象
 *
 *  @return 摘要
 */
- (NSString *)getExcerptofPost:(Post *)post
{
    NSString *content = [post.excerpt isEmpty] ? post.content : post.excerpt;
    NSAttributedString *str = [[NSAttributedString alloc] initWithData:[content dataUsingEncoding:NSUnicodeStringEncoding] options:@{ NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType } documentAttributes:nil error:nil];
    content = [str string];
//    content = [content stringByReplacingOccurrencesOfString:@"\r" withString:@""];
//    content = [content stringByReplacingOccurrencesOfString:@"\n" withString:@""];
    NSUInteger length = content.length > 200 ? 200 : content.length;
    content = [content substringWithRange:NSMakeRange(0, length)];
    return content;
}

#pragma mark - postType page 特殊按时间多节处理
//计算两个日期之间的差别
- (NSDateComponents *)differenceBetweenDate:(NSDate*)fromDateTime andDate:(NSDate*)toDateTime
{
    NSDate *fromDate;
    NSDate *toDate;
    
    NSCalendar *calendar = [NSCalendar currentCalendar];
    
    [calendar rangeOfUnit:NSCalendarUnitDay startDate:&fromDate
                 interval:NULL forDate:fromDateTime];
    [calendar rangeOfUnit:NSCalendarUnitDay startDate:&toDate
                 interval:NULL forDate:toDateTime];
    
    NSDateComponents *difference = [calendar components:NSCalendarUnitDay fromDate:fromDate toDate:toDate options:0];
    
    return difference;
}

- (NSArray *)walkPages:(NSArray *)posts
{
    if (posts && posts.count > 0) {
        NSString *headerTitle = @"十年前";
        NSInteger rows = 0;
        NSInteger index = posts.count;
        NSString *lastDiffType = @"";
        NSMutableArray *results = [NSMutableArray new];
        NSDictionary *result;
        NSDate *nowDate = [NSDate date];
        //反转posts 旧的排前
        posts = [[posts reverseObjectEnumerator] allObjects];
        for (Post *post in posts) {
            NSDateComponents *diff = [self differenceBetweenDate:nowDate andDate:post.date];
            if (ABS(diff.day) >= 365*10) {
                rows ++;
            }else if (ABS(diff.day) >= 365*5){
                if ([lastDiffType isEqualToString:@"fiveYears"]) {
                    rows++;
                }else if (rows > 0){
                    result = @{@"headerTitle":headerTitle,@"rows":[NSNumber numberWithInteger:rows],@"index":[NSNumber numberWithInteger:index]};
                    [results addObject:result];
                    rows = 1;
                }else{
                    rows = 1;
                }
                lastDiffType = @"fiveYears";
                headerTitle = @"五年前";
            }else if (ABS(diff.day) >= 365*3){
                if ([lastDiffType isEqualToString:@"threeYears"]) {
                    rows++;
                }else if (rows > 0){
                    result = @{@"headerTitle":headerTitle,@"rows":[NSNumber numberWithInteger:rows],@"index":[NSNumber numberWithInteger:index]};
                    [results addObject:result];
                    rows = 1;
                }else{
                    rows = 1;
                }
                lastDiffType = @"threeYears";
                headerTitle = @"三年前";
            }else if (ABS(diff.day) >= 365*2){
                if ([lastDiffType isEqualToString:@"twoYears"]) {
                    rows++;
                }else if (rows > 0){
                    result = @{@"headerTitle":headerTitle,@"rows":[NSNumber numberWithInteger:rows],@"index":[NSNumber numberWithInteger:index]};
                    [results addObject:result];
                    rows = 1;
                }else{
                    rows = 1;
                }
                lastDiffType = @"twoYears";
                headerTitle = @"两年前";
            }else if (ABS(diff.day) >= 365){
                if ([lastDiffType isEqualToString:@"oneYears"]) {
                    rows++;
                }else if (rows > 0){
                    result = @{@"headerTitle":headerTitle,@"rows":[NSNumber numberWithInteger:rows],@"index":[NSNumber numberWithInteger:index]};
                    [results addObject:result];
                    rows = 1;
                }else{
                    rows = 1;
                }
                lastDiffType = @"oneYears";
                headerTitle = @"一年前";
            }else if (ABS(diff.day) >= 30*6){
                if ([lastDiffType isEqualToString:@"halfYears"]) {
                    rows++;
                }else if (rows > 0){
                    result = @{@"headerTitle":headerTitle,@"rows":[NSNumber numberWithInteger:rows],@"index":[NSNumber numberWithInteger:index]};
                    [results addObject:result];
                    rows = 1;
                }else{
                    rows = 1;
                }
                lastDiffType = @"halfYears";
                headerTitle = @"半年前";
            }else if (ABS(diff.day) >= 30*3){
                if ([lastDiffType isEqualToString:@"threeMonths"]) {
                    rows++;
                }else if (rows > 0){
                    result = @{@"headerTitle":headerTitle,@"rows":[NSNumber numberWithInteger:rows],@"index":[NSNumber numberWithInteger:index]};
                    [results addObject:result];
                    rows = 1;
                }else{
                    rows = 1;
                }
                lastDiffType = @"threeMonths";
                headerTitle = @"三个月前";
            }else if (ABS(diff.day) >= 30*2){
                if ([lastDiffType isEqualToString:@"twoMonths"]) {
                    rows++;
                }else if (rows > 0){
                    result = @{@"headerTitle":headerTitle,@"rows":[NSNumber numberWithInteger:rows],@"index":[NSNumber numberWithInteger:index]};
                    [results addObject:result];
                    rows = 1;
                }else{
                    rows = 1;
                }
                lastDiffType = @"twoMonths";
                headerTitle = @"两个月前";
            }else if (ABS(diff.day) >= 30){
                if ([lastDiffType isEqualToString:@"oneMonths"]) {
                    rows++;
                }else if (rows > 0){
                    result = @{@"headerTitle":headerTitle,@"rows":[NSNumber numberWithInteger:rows],@"index":[NSNumber numberWithInteger:index]};
                    [results addObject:result];
                    rows = 1;
                }else{
                    rows = 1;
                }
                lastDiffType = @"oneMonths";
                headerTitle = @"一个月前";
            }else if (ABS(diff.day) >= 7*2){
                if ([lastDiffType isEqualToString:@"twoWeeks"]) {
                    rows++;
                }else if (rows > 0){
                    result = @{@"headerTitle":headerTitle,@"rows":[NSNumber numberWithInteger:rows],@"index":[NSNumber numberWithInteger:index]};
                    [results addObject:result];
                    rows = 1;
                }else{
                    rows = 1;
                }
                lastDiffType = @"twoWeeks";
                headerTitle = @"两周前";
            }else if (ABS(diff.day) >= 7){
                if ([lastDiffType isEqualToString:@"oneWeeks"]) {
                    rows++;
                }else if (rows > 0){
                    result = @{@"headerTitle":headerTitle,@"rows":[NSNumber numberWithInteger:rows],@"index":[NSNumber numberWithInteger:index]};
                    [results addObject:result];
                    rows = 1;
                }else{
                    rows = 1;
                }
                lastDiffType = @"oneWeeks";
                headerTitle = @"一周前";
            }else{
                if ([lastDiffType isEqualToString:@"inWeeks"]) {
                    rows++;
                }else if (rows > 0){
                    result = @{@"headerTitle":headerTitle,@"rows":[NSNumber numberWithInteger:rows],@"index":[NSNumber numberWithInteger:index]};
                    [results addObject:result];
                    rows = 1;
                }else{
                    rows = 1;
                }
                lastDiffType = @"inWeeks";
                headerTitle = @"一周内";
            }
            index--;
        }
        if (rows > 0) {
            result = @{@"headerTitle":headerTitle,@"rows":[NSNumber numberWithInteger:rows],@"index":[NSNumber numberWithInteger:index]};
            [results addObject:result];
        }
        return [[results reverseObjectEnumerator] allObjects];
    }
    return nil;
}

#pragma mark - site options


#pragma mark - single post
- (void)getPostWithID:(NSNumber *)postID
              forBlog:(Blog *)blog
              success:(void (^)(Post *post))success
              failure:(void (^)(NSError *))failure
{
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    NSArray *parameters = [self getXMLRPCArgsWithExtra:postID inBlog:blog];
    WPXMLRPCClient *client = [PostControll getClientWithBlog:blog];
    [client callMethod:@"wp.getPost"
              parameters:parameters
                 success:^(AFHTTPRequestOperation *operation, id responseObject) {
                     if (success) {
                         [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
                         success([PostControll remotePostFromXMLRPCDictionary:responseObject]);
                     }
                 } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                     if (failure) {
                         [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
                         failure(error);
                     }
                 }];
}

- (NSArray *)getXMLRPCArgsWithExtra:(id)extra inBlog:(Blog *)blog
{
    NSMutableArray *result = [NSMutableArray array];
    NSString *password = [[[DataModel alloc] init] readKeyChainWithId:blog.id];
    
    [result addObject:[NSNumber numberWithInteger:blog.blogId]];
    [result addObject:blog.userName];
    [result addObject:password];
    
    if ([extra isKindOfClass:[NSArray class]]) {
        [result addObjectsFromArray:extra];
    } else if (extra != nil) {
        [result addObject:extra];
    }
    
    return [NSArray arrayWithArray:result];
}


@end
