//
//  SiteSettingViewController.h
//  WordPressKit
//
//  Created by wuxueqian on 15/10/5.
//  Copyright (c) 2015年 wuxueqian. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Blog.h"

@interface SiteSettingViewController : UITableViewController

@property (nonatomic, strong) Blog *blog;
@property (nonatomic, copy) void(^blogChanged)(Blog *);

@end
