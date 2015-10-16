//
//  FunctionsViewController.h
//  WordPressKit
//
//  Created by wuxueqian on 15/8/25.
//  Copyright (c) 2015年 wuxueqian. All rights reserved.
//

#import <UIKit/UIKit.h>

@class DataModel;
@class CatItem;

@interface FunctionsViewController : UIViewController

@property (nonatomic, strong) DataModel *dataModel;
@property (nonatomic, strong) CatItem *catItem;

@end
