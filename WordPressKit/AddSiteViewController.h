//
//  AddSiteViewController.h
//  WordPressKit
//
//  Created by wuxueqian on 15/9/14.
//  Copyright (c) 2015年 wuxueqian. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Blog.h"

@class DataModel;

@interface AddSiteViewController : UIViewController

@property (nonatomic, strong) DataModel *dataModel;
@property (strong, nonatomic) Blog *blog;

@end
