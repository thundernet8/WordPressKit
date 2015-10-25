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

@end
