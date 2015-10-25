//
//  OptionData.m
//  WordPressKit
//
//  Created by wuxueqian on 15/10/25.
//  Copyright (c) 2015年 wuxueqian. All rights reserved.
//

#import "OptionData.h"
#import "KeychainItemWrapper.h"

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
    NSMutableArray *result = [NSMutableArray array];
    [result addObject:[NSNumber numberWithInteger:blog.blogId]];
    [result addObject:blog.userName];
    [result addObject:password];
    NSArray *parameters = [NSArray arrayWithArray:result];
    [self.client callMethod:@"wp.getOptions" parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"response is %@",responseObject);
        [self.delegate verifyUserPasswordFinished:password];
        [self updateDBForBlog:blog withUserPassword:password];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"error is %@",error.localizedDescription);
        [self.delegate verifyUserPasswordFailure:error];
    }];
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

@end
