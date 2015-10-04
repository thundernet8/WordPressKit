//
//  PostActionBarItem.m
//  WordPressKit
//
//  Created by wuxueqian on 15/10/3.
//  Copyright (c) 2015年 wuxueqian. All rights reserved.
//

#import "PostActionBarItem.h"

@implementation PostActionBarItem

+ (instancetype)itemWithTitle:(NSString *)title image:(UIImage *)image highlightedImage:(UIImage *)highlightedImage
{
    PostActionBarItem *item = [PostActionBarItem new];
    item.title = title;
    item.image = image;
    item.imageInsets = UIEdgeInsetsZero;
    item.highlightedImage = highlightedImage;
    return item;
}

@end
