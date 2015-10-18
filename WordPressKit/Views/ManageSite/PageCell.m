//
//  PageCell.m
//  WordPressKit
//
//  Created by wuxueqian on 15/10/13.
//  Copyright (c) 2015年 wuxueqian. All rights reserved.
//

#import "PageCell.h"
#import "NSString+Util.h"
#import <stdlib.h>

@interface PageCell()
@property (weak, nonatomic) IBOutlet UIView *pageWrapper;
@property (weak, nonatomic) IBOutlet UIView *colorBorder;
@property (weak, nonatomic) IBOutlet UILabel *pageTitle;
@property (weak, nonatomic) IBOutlet UILabel *pageExcerpt;

@end

@implementation PageCell

- (void)awakeFromNib {
    // Initialization code
    [self setSeparatorInset:UIEdgeInsetsMake(0, 12, 0, 0)];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)configCellWithPost:(RemotePost *)post inBlog:(Blog *)blog
{
    self.backgroundColor = kBackgroundColorLightGray;
    //左border
    //self.colorBorder.backgroundColor
    self.colorBorder.backgroundColor = [self getBorderColor];
    //页面标题
    self.pageTitle.text = post.title;
    self.pageTitle.font = [UIFont boldSystemFontOfSize:16.0f];
    //页面摘要
    NSString *content = [post.excerpt isEmpty] ? post.content : post.excerpt;
    content = [content stringByReplacingOccurrencesOfString:@"\r" withString:@""];
    content = [content stringByReplacingOccurrencesOfString:@"\n" withString:@""];
    NSUInteger length = content.length > 36 ? 36 : content.length;
    NSString *tail = content.length > 36 ? @" ···" : @"";
    content = [content substringWithRange:NSMakeRange(0, length)];
    content = [content stringByAppendingString:tail];
    self.pageExcerpt.text = content;
    self.pageExcerpt.font = [UIFont systemFontOfSize:15.0f];
    self.pageExcerpt.textColor = kFontColorGray;
    
    if ([self.pageExcerpt.text isEmpty]) {
        //文章日期
        NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
        [dateFormat setDateFormat:@"YYYY-MM-dd HH:MM"];
        NSString *dateStr = [dateFormat stringFromDate:post.date];
        self.pageExcerpt.text = dateStr;
    };
    
    [self setNeedsUpdateConstraints];
}

- (UIColor *)getBorderColor
{
    NSArray *colors = @[kColorBorderRed,kColorBorderGray,kColorBorderGreen,kColorBorderOrange,kColorBorderYellow,kColorBorderLightBlue,kColorBorderBluePurple];
    int index = arc4random_uniform(6);
    return colors[index];
}

/**
 *  重建自适应内容高度方法
 *
 *  @param size 内容的约束尺寸
 *
 *  @return 返回内容的合适尺寸
 */
- (CGSize)sizeThatFits:(CGSize)size
{
    CGFloat height = CGRectGetMinY(self.pageWrapper.frame);
    height += 44;
    CGFloat width = size.width - 24;
    CGSize innerSize = CGSizeMake(width, CGFLOAT_MAX);
    height += [self.pageExcerpt sizeThatFits:innerSize].height;
    return CGSizeMake(size.width, height);
}

@end
