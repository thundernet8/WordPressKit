//
//  SiteToolsViewController.h
//  WordPressKit
//
//  Created by wuxueqian on 15/9/20.
//  Copyright (c) 2015年 wuxueqian. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Blog.h"

@interface SiteToolsViewController : UITableViewController

@property (nonatomic, strong) Blog *blog;
@property (nonatomic, copy) void(^blogChanged)();

@end
