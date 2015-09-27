//
//  PostControll.h
//  WordPressKit
//
//  Created by wuxueqian on 15/9/24.
//  Copyright (c) 2015年 wuxueqian. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Blog.h"
#import "WordPressApi.h"
#import <sqlite3.h>

@interface PostControll : NSObject
{
    sqlite3 *db;
}

@property (nonatomic,strong) WPXMLRPCClient *client;
@property (nonatomic,strong) WordPressXMLRPCApi *api;
@property (nonatomic,strong) NSArray *posts;
@property (nonatomic,strong) Blog *blog;
@property (nonatomic,assign) BOOL syncing;

- (instancetype)initWithBlog:(Blog *)blog;

+ (void)syncPostsWithBlog:(Blog *)blog postType:(NSString *)postType;

+ (void)getPostsOfType:(NSString *)postType
               forBlog:(Blog *)blog
               options:(NSDictionary *)options
               success:(void (^)(NSArray *posts))success
               failure:(void (^)(NSError *error))failure;
- (void)getDBPostsofType:(NSString *)postType ForBlog:(Blog *)blog number:(NSInteger)number;
- (void)needsSyncPostsForBlog:(Blog *)blog forTimeInterval:(NSInteger)timeInterval postType:(NSString *)postType;



@end
