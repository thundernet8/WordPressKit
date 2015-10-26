//
//  OptionData.m
//  WordPressKit
//
//  Created by wuxueqian on 15/10/25.
//  Copyright (c) 2015年 wuxueqian. All rights reserved.
//

#import "OptionData.h"
#import "KeychainItemWrapper.h"
#import "PostControll.h"

@interface OptionData()

@property (nonatomic,strong) Blog *blog;

@end

@implementation OptionData

static OptionData *sharedManager = nil;

+ (OptionData *)sharedManager
{
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        sharedManager = [[self alloc] init];
    });
    return sharedManager;
}


- (void)updateBlog:(Blog *)blog withTitle:(NSString *)title
{
    [self configureManagerWithBlog:blog];
    NSDictionary *extraParameters = @{@"blog_title":title};
    NSArray *parameters = [_blog getXMLRPCArgsWithExtra:extraParameters];

    [self.client callMethod:@"wp.setOptions" parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"response is %@",responseObject);
        [self.delegate updateBlogTitleFinished:title];
        [self updateDBForBlog:blog withTitle:title];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"error is %@",error.localizedDescription);
        [self.delegate updateBlogTitleFailure:error];
    }];
}

- (void)updateBlog:(Blog *)blog withSubTitle:(NSString *)subTitle
{
    [self configureManagerWithBlog:blog];
    NSDictionary *extraParameters = @{@"blog_tagline":subTitle};
    NSArray *parameters = [_blog getXMLRPCArgsWithExtra:extraParameters];
    
    [self.client callMethod:@"wp.setOptions" parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"response is %@",responseObject);
        [self.delegate updateBlogSubTitleFinished:subTitle];
        [self updateDBForBlog:blog withSubTitle:subTitle];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"error is %@",error.localizedDescription);
        [self.delegate updateBlogSubTitleFailure:error];
    }];
}

- (void)verifyBlog:(Blog *)blog withUserPassword:(NSString *)password
{
    [self configureManagerWithBlog:blog];
    NSMutableArray *para = [NSMutableArray array];
    [para addObject:[NSNumber numberWithInteger:blog.blogId]];
    [para addObject:blog.userName];
    [para addObject:password];
    NSArray *parameters = [NSArray arrayWithArray:para];
    [self.client callMethod:@"wp.getOptions" parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"response is %@",responseObject);
        [self.delegate verifyUserPasswordFinished:password];
        [self updateDBForBlog:blog withUserPassword:password];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"error is %@",error.localizedDescription);
        [self.delegate verifyUserPasswordFailure:error];
    }];
}

- (void)fetchCategoriesOfBlog:(Blog *)blog
{
    [self queryDBCategoriesForBlog:blog];
}

- (void)fetchRemoteCategoriesOfBlog:(Blog *)blog
{
    [self configureManagerWithBlog:blog];
    NSString *extraParameters = @"category";
    NSArray *parameters = [_blog getXMLRPCArgsWithExtra:extraParameters];
    [self.client callMethod:@"wp.getTerms" parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        [self.delegate fetchCategoriesFinished:[self categoriesFromXMLCategoryArray:responseObject]];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [self.delegate fetchCategoriesFailure:error];
    }];
}

- (void)fetchFormatsOfBlog:(Blog *)blog
{
    [self queryDBFormatsForBlog:blog];
}

- (void)fetchRemoteFormatsOfBlog:(Blog *)blog
{
    [self configureManagerWithBlog:blog];
    NSArray *parameters = [_blog getXMLRPCArgsWithExtra:nil];
    [self.client callMethod:@"wp.getPostFormats" parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        [self.delegate fetchFormatsFinished:[self postFormatsFromXMLFormatArray:responseObject]];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [self.delegate fetchCategoriesFailure:error];
    }];
}

//查询博客的默认分类
- (PostCategory *)getDefaultCategoryForBlog:(Blog *)blog
{
    NSString *path = self.userDataFilePath;
    const char *npath = [path UTF8String];
    //打开数据库
    if (sqlite3_open(npath, &db) != SQLITE_OK) {
        NSAssert(NO, @"打开数据库文件失败");
    }else{
        NSString *sql = @"SELECT * FROM CATEGORIES WHERE CATEGORYID = (SELECT DEFAULTCATID FROM BLOGS WHERE ID = ?)";
        const char *nsql = [sql UTF8String];
        sqlite3_stmt *stmt;
        if (sqlite3_prepare_v2(db, nsql, -1, &stmt, NULL) == SQLITE_OK ){
            sqlite3_bind_int(stmt, 1, (int)blog.id);
            if (sqlite3_step(stmt) == SQLITE_ROW) {
                PostCategory *cat = [PostCategory new];
                cat.categoryID = [NSNumber numberWithInt:sqlite3_column_int(stmt, 1)];
                cat.name = [NSString stringWithUTF8String:(char *)sqlite3_column_text(stmt, 2)];
                cat.parentID = [NSNumber numberWithInt:sqlite3_column_int(stmt, 3)];
                cat.siteID = [NSNumber numberWithInt:sqlite3_column_int(stmt, 4)];
                sqlite3_finalize(stmt);
                sqlite3_close(db);
                return cat;
            }
        }
        sqlite3_finalize(stmt);
        sqlite3_close(db);
    }
    return nil;
}

//获取博客默认文章形式
- (PostFormat *)getDefaultPostFormatForBlog:(Blog *)blog
{
    NSString *path = self.userDataFilePath;
    const char *npath = [path UTF8String];
    //打开数据库
    if (sqlite3_open(npath, &db) != SQLITE_OK) {
        NSAssert(NO, @"打开数据库文件失败");
    }else{
        NSString *sql = @"SELECT * FROM FORMATS WHERE NAME = (SELECT DEFAULTFORMAT FROM BLOGS WHERE ID = ?)";
        const char *nsql = [sql UTF8String];
        sqlite3_stmt *stmt;
        if (sqlite3_prepare_v2(db, nsql, -1, &stmt, NULL) == SQLITE_OK ){
            sqlite3_bind_int(stmt, 1, (int)blog.id);
            if (sqlite3_step(stmt) == SQLITE_ROW) {
                PostFormat *format = [PostFormat new];
                format.id = [NSNumber numberWithInt:sqlite3_column_int(stmt, 0)];
                format.name = [NSString stringWithUTF8String:(char *)sqlite3_column_text(stmt, 1)];
                format.slug = [NSString stringWithUTF8String:(char *)sqlite3_column_text(stmt, 2)];
                format.siteID = [NSNumber numberWithInt:sqlite3_column_int(stmt, 3)];
                sqlite3_finalize(stmt);
                sqlite3_close(db);
                return format;
            }
        }
        sqlite3_finalize(stmt);
        sqlite3_close(db);
    }
    return nil;
}

//更新博客的默认值 （分类/文章形式）
- (void)updateBlog:(Blog *)blog
{
    NSString *path = self.userDataFilePath;
    const char *npath = [path UTF8String];
    //打开数据库
    if (sqlite3_open(npath, &db) != SQLITE_OK) {
        NSAssert(NO, @"打开数据库文件失败");
    }else{
        NSString *defaultCat = blog.defaultCat ? blog.defaultCat : @"";
        NSString *defaultFormat = blog.defaultFormat ? blog.defaultFormat : @"";
        NSString *sql = [NSString stringWithFormat:@"UPDATE BLOGS SET DEFAULTCATID = %i, DEFAULTCAT = '%@', DEFAULTFORMAT = '%@' WHERE ID = %i",(int)blog.defaultCatId,defaultCat,defaultFormat,(int)blog.id];
        const char *nsql = [sql UTF8String];
        sqlite3_stmt *stmt;
        if (sqlite3_prepare_v2(db, nsql, -1, &stmt, NULL) == SQLITE_OK ){
            if (sqlite3_step(stmt) == SQLITE_DONE) {
                sqlite3_finalize(stmt);
                sqlite3_close(db);
                return;
            }
        }
        sqlite3_finalize(stmt);
        sqlite3_close(db);
    }
}

#pragma mark - private methods
- (void)configureManagerWithBlog:(Blog *)blog;
{
    if (!self) {
        return;
    }
    _client = [OptionData getClientWithBlog:blog];
    _api = [OptionData getApiWithBlog:blog];
    _blog = blog;
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

//更新数据库中的内容
- (void)updateDBForBlog:(Blog *)blog withTitle:(NSString *)title
{
    NSString *path = self.userDataFilePath;
    const char *npath = [path UTF8String];
    //打开数据库
    if (sqlite3_open(npath, &db) != SQLITE_OK) {
        NSAssert(NO, @"打开数据库文件失败");
    }else{
        NSString *sql = @"UPDATE BLOGS SET NAME = ? WHERE ID = ?";
        const char *nsql = [sql UTF8String];
        sqlite3_stmt *stmt;
        if (sqlite3_prepare_v2(db, nsql, -1, &stmt, NULL) == SQLITE_OK ){
            sqlite3_bind_text(stmt, 1, [title UTF8String], -1, NULL);
            sqlite3_bind_int(stmt, 2, (int)blog.id);
            if (sqlite3_step(stmt) == SQLITE_DONE) {
                sqlite3_finalize(stmt);
                sqlite3_close(db);
                return;
            }
        }
        sqlite3_finalize(stmt);
        sqlite3_close(db);
    }
    return;
}

- (void)updateDBForBlog:(Blog *)blog withSubTitle:(NSString *)subTitle
{
    NSString *path = self.userDataFilePath;
    const char *npath = [path UTF8String];
    //打开数据库
    if (sqlite3_open(npath, &db) != SQLITE_OK) {
        NSAssert(NO, @"打开数据库文件失败");
    }else{
        NSString *sql = @"UPDATE BLOGS SET SUBTITLE = ? WHERE ID = ?";
        const char *nsql = [sql UTF8String];
        sqlite3_stmt *stmt;
        if (sqlite3_prepare_v2(db, nsql, -1, &stmt, NULL) == SQLITE_OK ){
            sqlite3_bind_text(stmt, 1, [subTitle UTF8String], -1, NULL);
            sqlite3_bind_int(stmt, 2, (int)blog.id);
            if (sqlite3_step(stmt) == SQLITE_DONE) {
                sqlite3_finalize(stmt);
                sqlite3_close(db);
                return;
            }
        }
        sqlite3_finalize(stmt);
        sqlite3_close(db);
    }
    return;
}

- (void)updateDBForBlog:(Blog *)blog withUserPassword:(NSString *)password
{
    KeychainItemWrapper *keyChain = [[KeychainItemWrapper alloc] initWithIdentifier:@"com.wuxueqian.WordPressKit" accessGroup:nil];
    NSDictionary *Pwds = [keyChain objectForKey:(__bridge id)kSecValueData];
    Pwds = (Pwds && Pwds.count > 0) ? Pwds : [[NSDictionary alloc] init];
    NSMutableDictionary *newPwds = [Pwds mutableCopy];
    //添加或更新密码
    [newPwds setObject:password forKey:[NSString stringWithFormat:@"Blog%i",(int)blog.id]];
    [keyChain setObject:newPwds forKey:(__bridge id)kSecValueData];
}

//查询数据库分类
- (void)queryDBCategoriesForBlog:(Blog *)blog
{
    NSString *path = self.userDataFilePath;
    const char *npath = [path UTF8String];
    //打开数据库
    if (sqlite3_open(npath, &db) != SQLITE_OK) {
        NSAssert(NO, @"打开数据库文件失败");
    }else{
        NSString *sql = @"SELECT * FROM CATEGORIES WHERE SITEID = ? ORDER BY CATEGORYID ASC";
        const char *nsql = [sql UTF8String];
        sqlite3_stmt *stmt;
        if (sqlite3_prepare_v2(db, nsql, -1, &stmt, NULL) == SQLITE_OK ){
            sqlite3_bind_int(stmt, 1, (int)blog.id);
            NSMutableArray *cats = [NSMutableArray new];
            while (sqlite3_step(stmt) == SQLITE_ROW) {
                PostCategory *cat = [[PostCategory alloc] init];
                cat.categoryID = [NSNumber numberWithInt:sqlite3_column_int(stmt, 1)];
                cat.name = [NSString stringWithUTF8String:(char *)sqlite3_column_text(stmt, 2)];
                cat.parentID = [NSNumber numberWithInt:sqlite3_column_int(stmt, 3)];
                cat.siteID = [NSNumber numberWithInt:sqlite3_column_int(stmt, 4)];
                [cats addObject:cat];
            }
            if (cats.count > 0) {
                [self.delegate fetchCategoriesFinished:cats];
            }else{
                [self fetchRemoteCategoriesOfBlog:blog];
            }
        }
        sqlite3_finalize(stmt);
        sqlite3_close(db);
    }
}

//查询数据库文章形式
- (void)queryDBFormatsForBlog:(Blog *)blog
{
    NSString *path = self.userDataFilePath;
    const char *npath = [path UTF8String];
    //打开数据库
    if (sqlite3_open(npath, &db) != SQLITE_OK) {
        NSAssert(NO, @"打开数据库文件失败");
    }else{
        NSString *sql = @"SELECT * FROM FORMATS WHERE SITEID = ? ORDER BY ID ASC";
        const char *nsql = [sql UTF8String];
        sqlite3_stmt *stmt;
        if (sqlite3_prepare_v2(db, nsql, -1, &stmt, NULL) == SQLITE_OK ){
            sqlite3_bind_int(stmt, 1, (int)blog.id);
            NSMutableArray *formats = [NSMutableArray new];
            while (sqlite3_step(stmt) == SQLITE_ROW) {
                PostFormat *format = [[PostFormat alloc] init];
                format.id = [NSNumber numberWithInt:sqlite3_column_int(stmt, 0)];
                format.name = [NSString stringWithUTF8String:(char *)sqlite3_column_text(stmt, 1)];
                format.slug = [NSString stringWithUTF8String:(char *)sqlite3_column_text(stmt, 2)];
                format.siteID = [NSNumber numberWithInt:sqlite3_column_int(stmt, 3)];
                [formats addObject:format];
            }
            if (formats.count > 0) {
                [self.delegate fetchFormatsFinished:formats];
            }else{
                [self fetchRemoteFormatsOfBlog:blog];
            }
        }
        sqlite3_finalize(stmt);
        sqlite3_close(db);
    }
}

//过滤转换网络请求返回的分类
- (NSArray *)categoriesFromXMLCategoryArray:(NSArray *)categories
{
    NSMutableArray *cats = [NSMutableArray new];
    for (NSDictionary *catDict in categories) {
        PostCategory *cat = [PostCategory new];
        cat.categoryID = [catDict objectForKey:@"term_id"];
        cat.name = [catDict objectForKey:@"name"];
        cat.parentID = [catDict objectForKey:@"parent"];
        cat.siteID = [NSNumber numberWithInteger:_blog.id];
        [cats addObject:cat];
    }
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [self writeCategoriesToDB:cats];
    });
    return [[[NSArray arrayWithArray:cats] reverseObjectEnumerator] allObjects];
}

//过滤转换网络请求返回的文章形式
- (NSArray *)postFormatsFromXMLFormatArray:(NSArray *)postFormats
{
    NSMutableArray *formats = [NSMutableArray new];
    for (NSString *key in postFormats) {
        PostFormat *format = [PostFormat new];
        format.name = [postFormats valueForKey:key];
        format.slug = key;
        format.siteID = [NSNumber numberWithInteger:_blog.id];
        [formats addObject:format];
    }
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [self writePostFormatsToDB:formats];
    });
    return [NSArray arrayWithArray:formats];
}

//分类写入数据库
- (void)writeCategoriesToDB:(NSArray *)categories
{
    PostControll *pc = [[PostControll alloc] initWithBlog:_blog];
    [pc insertCats:categories];
}

//文章形式写入数据库
- (void)writePostFormatsToDB:(NSArray *)postFormats
{
    for (PostFormat *format in postFormats) {
        [self insertFormat:format];
    }
}

- (void)insertFormat:(PostFormat *)format
{
    //检查是否存在该文章形式
    if ([self existPostFormat:format.slug]) {
        return;
    }
    NSString *path = [self userDataFilePath];
    const char *npath = [path UTF8String];
    //打开数据库
    if (sqlite3_open(npath, &db) != SQLITE_OK) {
        NSAssert(NO, @"打开数据库文件失败");
    }else{
        const char *sql = [[NSString stringWithFormat:@"INSERT INTO FORMATS (NAME,SLUG,SITEID) VALUES('%@','%@',%i)",format.name,format.slug,[format.siteID intValue]] UTF8String];
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

//判断文章形式是否存在于数据库
- (BOOL)existPostFormat:(NSString *)slug
{
    NSString *path = [self userDataFilePath];
    const char *npath = [path UTF8String];
    //打开数据库
    if (sqlite3_open(npath, &db) != SQLITE_OK) {
        NSAssert(NO, @"打开数据库文件失败");
    }else{
        NSString *sql = @"SELECT * FROM FORMATS WHERE SLUG = ?";
        const char *nsql = [sql UTF8String];
        sqlite3_stmt *stmt;
        if (sqlite3_prepare_v2(db, nsql, -1, &stmt, NULL) == SQLITE_OK ){
            sqlite3_bind_text(stmt, 1, [slug UTF8String], -1, NULL);
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
