//
//  SinglePostViewController.h
//  WordPressKit
//
//  Created by wuxueqian on 15/10/15.
//  Copyright (c) 2015年 wuxueqian. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Post.h"
#import "Blog.h"

@interface SinglePostViewController : UIViewController

@property (nonatomic, strong) Post *post;
@property (nonatomic, strong) Blog *blog;

@end
