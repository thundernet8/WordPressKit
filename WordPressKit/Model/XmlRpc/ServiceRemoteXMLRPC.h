//
//  ServiceRemoteXMLRPC.h
//  WordPressKit
//
//  Created by wuxueqian on 15/9/23.
//  Copyright (c) 2015年 wuxueqian. All rights reserved.
//

#import <Foundation/Foundation.h>

@class WPXMLRPCClient;

@protocol ServiceRemoteXMLRPC <NSObject>

- (id)initWithApi:(WPXMLRPCClient *)api;

@end
