//
//  ListPostsViewController.h
//  WordPressKit
//
//  Created by wuxueqian on 15/9/21.
//  Copyright (c) 2015年 wuxueqian. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Blog.h"

@interface ListPostsViewController : UITableViewController

@property (nonatomic, strong) Blog *blog;

@end