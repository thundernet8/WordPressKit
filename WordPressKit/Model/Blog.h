//
//  Blog.h
//  WordPressKit
//
//  Created by wuxueqian on 15/9/16.
//  Copyright (c) 2015年 wuxueqian. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WPXMLRPCClient.h"

@interface Blog : NSObject

@property (nonatomic, assign) NSInteger id;
@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *url;
@property (nonatomic, copy) NSString *userName;
@property (nonatomic, assign) NSInteger blogId;
@property (nonatomic, assign) NSInteger isAdmin;
@property (nonatomic, copy) NSString *password;
@property (nonatomic, copy) NSString *xmlrpc;

//只读属性
@property (nonatomic, strong,  readonly) WPXMLRPCClient *api;

- (NSArray *)getXMLRPCArgsWithExtra:(id)extra withDBRecordId:(NSInteger)rid;

@end
