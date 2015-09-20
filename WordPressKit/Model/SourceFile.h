//
//  SourceFile.h
//  WordPressKit
//
//  Created by wuxueqian on 15/8/31.
//  Copyright (c) 2015年 wuxueqian. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SourceFile : NSObject

@property (nonatomic, assign) NSInteger id;
@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *type;
@property (nonatomic, copy) NSString *path;
@property (nonatomic, assign) NSInteger parentId;


@end
