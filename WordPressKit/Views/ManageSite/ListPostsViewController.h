//
//  ListPostsViewController.h
//  WordPressKit
//
//  Created by wuxueqian on 15/9/21.
//  Copyright (c) 2015年 wuxueqian. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Blog.h"
#import "RemotePost.h"

@class PostControll;

//@protocol PostCellDelegate <NSObject>
//
//@optional
//
//- (void)configCellWithPost:(RemotePost *)post inBlog:(Blog *)blog;
//
//@end

@interface ListPostsViewController : UITableViewController

@property (nonatomic, strong) Blog *blog;
@property (nonatomic, strong) PostControll *pc;

//@property (weak, nonatomic) id<PostCellDelegate>delegate;

@end
