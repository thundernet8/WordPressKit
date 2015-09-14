//
//  FuncItemViewController.h
//  WordPressKit
//
//  Created by wuxueqian on 15/8/26.
//  Copyright (c) 2015年 wuxueqian. All rights reserved.
//

#import <UIKit/UIKit.h>

@class FuncItem;
@class DataModel;

@interface FuncItemViewController : UIViewController

@property (nonatomic, strong) FuncItem *funcItem;

@property (nonatomic, strong) DataModel *dataModel;

@end
