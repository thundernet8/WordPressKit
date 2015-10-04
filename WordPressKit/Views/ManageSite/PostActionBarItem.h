//
//  PostActionBarItem.h
//  WordPressKit
//
//  Created by wuxueqian on 15/10/3.
//  Copyright (c) 2015年 wuxueqian. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

typedef void(^PostActionBarItemCallback)();

@interface PostActionBarItem : NSObject

@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) UIImage *image;
@property (nonatomic, assign) UIEdgeInsets imageInsets;
@property (nonatomic, strong) UIImage *highlightedImage;
@property (nonatomic, copy) PostActionBarItemCallback callback;

+ (instancetype)itemWithTitle:(NSString *)title image:(UIImage *)image highlightedImage:(UIImage *)image;

@end
