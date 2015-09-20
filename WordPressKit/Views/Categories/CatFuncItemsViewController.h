//
//  CatFuncItemsViewController.h
//  WordPressKit
//
//  Created by wuxueqian on 15/9/12.
//  Copyright (c) 2015年 wuxueqian. All rights reserved.
//

#import <UIKit/UIKit.h>

@class DataModel;
@class CatItem;

@interface CatFuncItemsViewController : UITableViewController

@property (nonatomic, strong) DataModel *dataModel;
@property (nonatomic, strong) CatItem *catItem;

@end
