//
//  SettingFilterTableViewController.h
//  WordPressKit
//
//  Created by wuxueqian on 15/10/25.
//  Copyright (c) 2015年 wuxueqian. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Blog.h"

@interface SettingFilterTableViewController : UITableViewController

@property (nonatomic, copy) void(^onItemSelected)(id);
@property (nonatomic, copy) void(^onCancel)();
@property (nonatomic, strong) Blog *blog;

- (instancetype)initWithCurrentFilter:(id)filter forFilterType:(NSString *)type;
- (instancetype)initWithStyle:(UITableViewStyle)style andCurrentFilter:(id)currentFilter forFilterType:(NSString *)type;
- (void)dismiss;

@end
