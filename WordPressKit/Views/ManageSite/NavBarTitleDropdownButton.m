//
//  NavBarTitleDropdownButton.m
//  WordPressKit
//
//  Created by wuxueqian on 15/10/9.
//  Copyright (c) 2015年 wuxueqian. All rights reserved.
//

#import "NavBarTitleDropdownButton.h"

@implementation NavBarTitleDropdownButton

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    self.titleLabel.textColor = [UIColor whiteColor];
    self.titleLabel.adjustsFontSizeToFitWidth = NO;
    self.titleLabel.lineBreakMode = NSLineBreakByTruncatingTail;
    [self setImage:[UIImage imageNamed:@"navbutton_chevron"] forState:UIControlStateNormal];
    [self setImage:[UIImage imageNamed:@"navbutton_chevron_hl"] forState:UIControlStateHighlighted];
}

- (CGRect)imageRectForContentRect:(CGRect)contentRect
{
    CGRect frame = [super imageRectForContentRect:contentRect];
    frame.origin.x = CGRectGetMaxX(contentRect) - CGRectGetWidth(frame) -  self.imageEdgeInsets.right + self.imageEdgeInsets.left;
    return frame;
}

- (CGRect)titleRectForContentRect:(CGRect)contentRect
{
    CGRect frame = [super titleRectForContentRect:contentRect];
    frame.origin.x = CGRectGetMinX(frame) - CGRectGetWidth([self imageRectForContentRect:contentRect]);
    return frame;
}

- (void)setAttributedTitleForTitle:(NSString *)title
{
    title = [title stringByAppendingString:@" "];
    NSDictionary *attributes = @{NSForegroundColorAttributeName : [UIColor whiteColor],
                                 NSFontAttributeName : [UIFont systemFontOfSize:16.0] };
    NSMutableAttributedString *titleText = [[NSMutableAttributedString alloc] initWithString:title attributes:attributes];
    
    [self setAttributedTitle:titleText forState:UIControlStateNormal];
    [self setAttributedTitle:titleText forState:UIControlStateHighlighted];
    [self sizeToFit];
}


@end
