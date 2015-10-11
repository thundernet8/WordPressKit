//
//  FiltersTableViewController.h
//  WordPressKit
//
//  Created by wuxueqian on 15/10/10.
//  Copyright (c) 2015年 wuxueqian. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FiltersTableViewController : UITableViewController

@property (nonatomic, copy) void(^onItemSelected)(id);
@property (nonatomic, copy) void(^onCancel)();

- (instancetype)initWithFilters:(NSArray *)filters andCurrentIndex:(NSInteger)index;
- (instancetype)initWithStyle:(UITableViewStyle)style andFilters:(NSArray *)filters andCurrentIndex:(NSInteger)index;
- (void)dismiss;

@end
