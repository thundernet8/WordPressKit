//
//  SiteSettingInputViewController.h
//  WordPressKit
//
//  Created by wuxueqian on 15/10/25.
//  Copyright (c) 2015年 wuxueqian. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SiteSettingInputViewController : UIViewController

@property (nonatomic, strong) NSDictionary *settingObject;
@property (nonatomic, copy) void(^onValueChanged)(NSString *, NSString *, BOOL);

@end
