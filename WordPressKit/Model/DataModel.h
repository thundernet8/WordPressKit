//
//  DataModel.h
//  WordPressKit
//
//  Created by wuxueqian on 15/8/27.
//  Copyright (c) 2015年 wuxueqian. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <sqlite3.h>
#import "Blog.h"

//#define DBFILENAME @"FuncItems.sqlite3"

@interface DataModel : NSObject
{
    sqlite3 *db;
}

@property (nonatomic, strong) NSMutableArray *funcItems;
@property (nonatomic, strong) NSObject *funcItem;
@property (nonatomic, strong) NSMutableArray *sourceFiles;
@property (nonatomic, strong) NSObject *sourceFile;
@property (nonatomic, strong) NSObject *parentSourceFolderInfo;
@property (nonatomic, strong) NSMutableArray *catItems;
@property (nonatomic, strong) NSObject *catItem;
@property (nonatomic, strong) NSMutableArray *blogs;
@property (nonatomic, strong) NSObject *blog;


- (void)registerDefaults;
- (void)handleFirstTime;
- (void)restoreData;

// SQL
- (NSString *)dataFilePath;
- (NSString *)userDataFilePath;

- (int)queryFuncItemById : (NSInteger)id;
- (int)queryAllFuncItems;
- (int)queryFuncItemBySimilarName:(NSString *)name inCatId:(NSInteger)id;

- (int)querySourceFileById : (NSInteger)id;
- (int)querySourceFilesByParentId : (NSInteger)parentId;
- (int)querySourceFileParentIdByParentId:(NSInteger)parentId;

- (int)queryAllCatItems;
- (int)queryFuncItemsCountInCatItemId:(NSInteger)id;
- (int)queryFuncItemsInCatItemId:(NSInteger)id;

//查询博客列表
- (int)queryAllBlogs;
//查询单个博客
- (Blog *)queryBlogWithId:(NSInteger)Id;
//判断博客是否存在
- (BOOL)isExistBlogWithUrl : (NSString *)url;
//插入博客记录
- (int)insertBlogRecordWithName : (NSString *)name blogWithUrl : (NSString *)url blogWithUserName : (NSString *)username blogWithId : (NSInteger)blogId blogWithXmlrpc : (NSString *)xmlrpc isAdmin : (NSInteger)isAdmin;
//删除博客记录
- (int)deleteBlogRecordWithId : (NSInteger)id;
//更新博客记录
- (int)updateBlogRecordWithId : (NSInteger)id withName : (NSString *)name withUrl : (NSString *)url withUsername : (NSString *)username blogWithId : (NSInteger)blogId blogWithXmlrpc : (NSString *)xmlrpc isAdmin : (NSInteger)isAdmin;
//更新博客其他设置数据
- (Blog *)updateBlog:(NSInteger)id WithKeyValuePairs:(NSDictionary *)keyValuePairs;

//判断空字符串
- (BOOL) isBlankString:(NSString *)string;

//写入keyChain以保存用户名密码
- (void)writeKeyChainWithId : (NSInteger)bid UserName : (NSString *)userName passWord : (NSString *)passWord;
//读取keyChain用户名密码
- (NSString *)readKeyChainWithId : (NSInteger)bid;




@end
