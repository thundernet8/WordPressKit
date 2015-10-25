//
//  OptionDataDelegate.h
//  WordPressKit
//
//  Created by wuxueqian on 15/10/25.
//  Copyright (c) 2015年 wuxueqian. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol OptionDataDelegate <NSObject>

@optional

- (void)updateBlogTitleFinished:(NSString *)title;
- (void)updateBlogTitleFailure:(NSError *)error;

- (void)updateBlogSubTitleFinished:(NSString *)subtitle;
- (void)updateBlogSubTitleFailure:(NSError *)error;

- (void)verifyUserPasswordFinished:(NSString *)password;
- (void)verifyUserPasswordFailure:(NSError *)error;

@end

@interface OptionData : NSObject

@property (nonatomic,weak) id<OptionDataDelegate>delegate;

@end