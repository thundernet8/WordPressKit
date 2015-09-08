//
//  DataModel.h
//  WordPressKit
//
//  Created by wuxueqian on 15/8/27.
//  Copyright (c) 2015年 wuxueqian. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <sqlite3.h>

//#define DBFILENAME @"FuncItems.sqlite3"

@interface DataModel : NSObject
{
    sqlite3 *db;
}

@property (nonatomic, strong) NSMutableArray *funcItems;
@property (nonatomic, strong) NSObject *funcItem;
@property (nonatomic, strong) NSMutableArray *sourceFiles;
@property (nonatomic, strong) NSObject *sourceFile;
@property (nonatomic, strong) NSMutableArray *catItems;
@property (nonatomic, strong) NSObject *catItem;


- (void)registerDefaults;
- (void)handleFirstTime;
- (void)restoreData;

// SQL
- (NSString *)dataFilePath;

- (int)queryFuncItemById : (NSInteger)id;
- (int)queryAllFuncItems;
- (int)queryFuncItemBySimilarName:(NSString *)name inCatId:(NSInteger)id;

- (int)querySourceFileById : (NSInteger)id;
- (int)querySourceFiles;

- (int)queryAllCatItems;
- (int)queryFuncItemsCountInCatItemId:(NSInteger)id;
- (int)queryFuncItemsInCatItemId:(NSInteger)id;



@end
