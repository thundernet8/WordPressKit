//
//  NSString+Util2.h
//  WordPressKit
//
//  Created by wuxueqian on 15/9/23.
//  Copyright (c) 2015年 wuxueqian. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface NSString (Util)

- (bool)isEmpty;
- (NSString *)trim;
- (NSNumber *)numericValue;
- (CGSize)suggestedSizeWithFont:(UIFont *)font width:(CGFloat)width;
- (NSString *)htmlEntityDecode;
- (NSString *)htmlEntityEncode;

@end

@interface NSObject (NumericValueHack)
- (NSNumber *)numericValue;
@end
