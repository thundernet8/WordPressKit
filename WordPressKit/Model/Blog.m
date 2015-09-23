//
//  Blog.m
//  WordPressKit
//
//  Created by wuxueqian on 15/9/16.
//  Copyright (c) 2015年 wuxueqian. All rights reserved.
//

#import "Blog.h"
#import "DataModel.h"

@implementation Blog

- (NSArray *)getXMLRPCArgsWithExtra:(id)extra withDBRecordId:(NSInteger)rid{
    NSMutableArray *result = [NSMutableArray array];
    DataModel *dataModel = [[DataModel alloc] init];
    NSString *password = [dataModel readKeyChainWithId:rid];
    [result addObject:[NSNumber numberWithInteger:self.blogId]];
    [result addObject:self.userName];
    [result addObject:password];
    
    if ([extra isKindOfClass:[NSArray class]]) {
        [result addObjectsFromArray:extra];
    } else if (extra != nil) {
        [result addObject:extra];
    }
    
    return [NSArray arrayWithArray:result];
}

@end
