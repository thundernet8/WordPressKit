//
//  FuncItem.h
//  WordPressKit
//
//  Created by wuxueqian on 15/8/26.
//  Copyright (c) 2015年 wuxueqian. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FuncItem : NSObject

@property (nonatomic, copy) NSString *img;
@property (nonatomic, assign) NSInteger itemId;
@property (nonatomic, copy) NSString *name;
@property (nonatomic, assign) NSInteger category;
@property (nonatomic, copy) NSString *des;
@property (nonatomic, copy) NSString *usage;
@property (nonatomic, copy) NSString *parameters;
@property (nonatomic, copy) NSString *returnValue;
@property (nonatomic, copy) NSString *notes;
@property (nonatomic, copy) NSString *changeLog;
@property (nonatomic, copy) NSString *sourceFile;
@property (nonatomic, assign) NSInteger sourceFileID;


@end
