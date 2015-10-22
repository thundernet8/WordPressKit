//
//  CustomPostsListViewController.h
//  WordPressKit
//
//  Created by wuxueqian on 15/10/18.
//  Copyright (c) 2015年 wuxueqian. All rights reserved.
//

#import "SCPullRefreshViewController.h"
#import "Blog.h"
#import "Post.h"

@class PostControll;

@interface CustomPostsListViewController : SCPullRefreshViewController

@property (nonatomic, strong) Blog *blog;
@property (nonatomic, strong) PostControll *pc;
@property (nonatomic, weak) NSArray *blogInfo;

@end
