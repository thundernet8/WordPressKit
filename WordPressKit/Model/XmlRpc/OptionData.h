//
//  OptionData.h
//  WordPressKit
//
//  Created by wuxueqian on 15/10/25.
//  Copyright (c) 2015年 wuxueqian. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Blog.h"
#import "DataModel.h"
#import <sqlite3.h>
#import "OptionDataDelegate.h"
#import "WordPressApi.h"
#import "PostCategory.h"
#import "PostFormat.h"

@interface OptionData()
{
    sqlite3 *db;
}

@property (nonatomic,strong) WPXMLRPCClient *client;
@property (nonatomic,strong) WordPressXMLRPCApi *api;

+ (OptionData *)sharedManager;
- (void)updateBlog:(Blog *)blog withTitle:(NSString *)title;
- (void)updateBlog:(Blog *)blog withSubTitle:(NSString *)subTitle;
- (void)verifyBlog:(Blog *)blog withUserPassword:(NSString *)password;
- (void)fetchCategoriesOfBlog:(Blog *)blog;
- (void)fetchRemoteCategoriesOfBlog:(Blog *)blog;
- (void)fetchFormatsOfBlog:(Blog *)blog;
- (void)fetchRemoteFormatsOfBlog:(Blog *)blog;

- (PostCategory *)getDefaultCategoryForBlog:(Blog *)blog;
- (PostFormat *)getDefaultPostFormatForBlog:(Blog *)blog;

- (void)updateBlog:(Blog *)blog;

@end
