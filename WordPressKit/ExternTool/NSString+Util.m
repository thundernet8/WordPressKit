//
//  NSString+Util2.m
//  WordPressKit
//
//  Created by wuxueqian on 15/9/23.
//  Copyright (c) 2015年 wuxueqian. All rights reserved.
//

#import "NSString+Util.h"


@implementation NSString (Util)

- (bool)isEmpty {
    return self.length == 0;
}

- (NSString *)trim {
    NSCharacterSet *set = [NSCharacterSet whitespaceAndNewlineCharacterSet];
    return [self stringByTrimmingCharactersInSet:set];
}

- (NSNumber *)numericValue {
    return [NSNumber numberWithUnsignedLongLong:[self longLongValue]];
}

- (CGSize)suggestedSizeWithFont:(UIFont *)font width:(CGFloat)width {
    CGRect bounds = [self boundingRectWithSize:CGSizeMake(width, CGFLOAT_MAX) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName: font} context:nil];
    return bounds.size;
}

-(NSString *)htmlEntityDecode{
    NSString *string = [self stringByReplacingOccurrencesOfString:@"&quot;" withString:@"\""];
    string = [self stringByReplacingOccurrencesOfString:@"&apos;" withString:@"'"];
    string = [self stringByReplacingOccurrencesOfString:@"&amp;" withString:@"&"];
    string = [self stringByReplacingOccurrencesOfString:@"&lt;" withString:@"<"];
    string = [self stringByReplacingOccurrencesOfString:@"&gt;" withString:@">"];
    
    return string;
}

-(NSString *)htmlEntityEncode{
    //string = [self stringByReplacingOccurrencesOfString:@"\"" withString:@"&quot;"];
    //string = [self stringByReplacingOccurrencesOfString:@"'" withString:@"&apos;"];
    //string = [self stringByReplacingOccurrencesOfString:@"&" withString:@"&amp;"];
    NSString *string = [self stringByReplacingOccurrencesOfString:@"<" withString:@"&lt;"];
    string = [self stringByReplacingOccurrencesOfString:@">" withString:@"&gt;"];
    string = [self stringByReplacingOccurrencesOfString:@"\t" withString:@"&nbsp;&nbsp;&nbsp;&nbsp;"];
    return string;
}

@end

@implementation NSObject (NumericValueHack)
- (NSNumber *)numericValue {
    if ([self isKindOfClass:[NSNumber class]]) {
        return (NSNumber *)self;
    }
    return nil;
}
@end
