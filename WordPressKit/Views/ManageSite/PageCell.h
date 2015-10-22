//
//  PageCell.h
//  WordPressKit
//
//  Created by wuxueqian on 15/10/13.
//  Copyright (c) 2015年 wuxueqian. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Post.h"
#import "Blog.h"

@interface PageCell : UITableViewCell


- (void)configCellWithPost:(Post *)post inBlog:(Blog *)blog;

@end
