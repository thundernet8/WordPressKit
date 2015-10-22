//
//  PostCommentsViewController.h
//  WordPressKit
//
//  Created by wuxueqian on 15/10/20.
//  Copyright (c) 2015年 wuxueqian. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Post.h"
#import "Blog.h"

@interface PostCommentsViewController : UITableViewController

@property (nonatomic, strong) Post *post;
@property (nonatomic, strong) Blog *blog;

@end
