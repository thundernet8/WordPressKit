//
//  DataModel.m
//  WordPressKit
//
//  Created by wuxueqian on 15/8/27.
//  Copyright (c) 2015年 wuxueqian. All rights reserved.
//

#import "DataModel.h"
#import "FuncItem.h"
#import "SourceFile.h"
#import "CatItem.h"
#import "KeychainItemWrapper.h"

@interface DataModel()



@end

@implementation DataModel


- (NSString *)dataFilePath
{
    return [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/FuncItems.sqlite3"];
}

- (NSString *)userDataFilePath
{
    return [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/UserData.db"];
}

//- (void)openDataFile:(NSString *)dataFilePath
//{
//    if (sqlite3_open([dataFilePath UTF8String], &db) != SQLITE_OK) {
//        sqlite3_close(db);
//        NSAssert(0, @"打开数据库失败");
//    }else{
//        //创建数据表
//        NSString *createSQL = @"CREATE TABLE IF NOT EXISTS FUNCITEMS (ID INTEGER PRIMARY KEY AUTOINCREMENT, NAME TEXT, CATEGORY TEXT, DESCRIPTION TEXT, USAGE TEXT, PARAMETERS TEXT, RETURNVALUE TEXT, NOTES TEXT, CHANGELOG TEXT, SOURCEFILEID INTEGER);";
//        NSString *createSQL2 = @"CREATE INDEX IDINDEX ON FUNCITEMS (ID);";
//        NSString *createSQL3 = @"CREATE INDEX NAMEINDEX ON FUNCITEMS (NAME);";
//        NSString *createSQL4 = @"CREATE TABLE IF NOT EXISTS SOURCEFILES (ID INTEGER PRIMARY KEY AUTOINCREMENT, NAME TEXT, FILECONTENT TEXT);";
//        NSString *createSQL5 = @"CREATE INDEX IDINDEX ON SOURCEFILES(ID);";
//        NSString *createSQL6 = @"CREATE INDEX NAMEINDEX ON FUNCITEMS (NAME);";
//        char *errorMsg;
//        if (sqlite3_exec(db, [createSQL UTF8String], NULL, NULL, &errorMsg) != SQLITE_OK && sqlite3_exec(db, [createSQL2 UTF8String], NULL, NULL, &errorMsg) != SQLITE_OK && sqlite3_exec(db, [createSQL3 UTF8String], NULL, NULL, &errorMsg) != SQLITE_OK && sqlite3_exec(db, [createSQL4 UTF8String], NULL, NULL, &errorMsg) != SQLITE_OK && sqlite3_exec(db, [createSQL5 UTF8String], NULL, NULL, &errorMsg) != SQLITE_OK && sqlite3_exec(db, [createSQL6 UTF8String], NULL, NULL, &errorMsg) != SQLITE_OK) {
//            sqlite3_close(db);
//            NSAssert(0, @"创建数据表错误%s",errorMsg);
//        }
//        sqlite3_close(db);
//    }
//}

- (void)restoreData
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *funcItemsNewPath = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/FuncItems.sqlite3"];
    NSString *funcItemsOriPath = [[NSBundle mainBundle] pathForResource:@"FuncItems" ofType:@"sqlite3"];
    NSString *userDataNewPath = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/UserData.db"];
    NSString *userDataOriPath = [[NSBundle mainBundle] pathForResource:@"UserData" ofType:@"db"];
    if ([fileManager fileExistsAtPath:funcItemsOriPath] && ![fileManager fileExistsAtPath:funcItemsNewPath]) {
        [fileManager copyItemAtPath:funcItemsOriPath toPath:funcItemsNewPath error:nil];
    }
    if ([fileManager fileExistsAtPath:userDataOriPath] && ![fileManager fileExistsAtPath:userDataNewPath]) {
        [fileManager copyItemAtPath:userDataOriPath toPath:userDataNewPath error:nil];
    }
}

- (void)registerDefaults
{
    //注册默认值，上次搜索词/是否首次启动/上次查看函数ID/上次查看的Tab/撰写地理位置标记
    NSDictionary *dictionary = @{@"SearchWords" : @"",@"FirstTime" : @YES,@"FuncItemId" : @0,@"LastTab" : @1,@"WordWrap" : @NO,@"LocationMark" : @NO};
    [[NSUserDefaults standardUserDefaults] registerDefaults:dictionary];
}

- (void)handleFirstTime
{
    BOOL firstTime = [[NSUserDefaults standardUserDefaults] boolForKey:@"FirstTime"];
    if (firstTime) {
        [self restoreData];//首次启用将数据文件导入数据库
        [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"FirstTime"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
}

- (id)init
{
    if (self = [super init]) {
        [self registerDefaults];
        [self handleFirstTime];
        //[self queryAllFuncItems]; //查询数据并保存到模型数组(移动到FunctionsView)

    }
    return self;
}

// 数据查询部分

//--查询全部funcItem
- (int)queryAllFuncItems
{
    NSString *path = self.dataFilePath;
    const char* npath = [path UTF8String];
    // 打开数据库
    if (sqlite3_open(npath, &db) != SQLITE_OK) {
        NSAssert(NO, @"打开数据库文件失败");
    }else{
        NSString *sql = @"SELECT * FROM FUNCITEMS";
        const char* nsql = [sql UTF8String];
        //char *error;
        sqlite3_stmt *stmt;
        if (sqlite3_prepare_v2(db, nsql, -1, &stmt, NULL) == SQLITE_OK) {
            self.funcItems = [[NSMutableArray alloc] init];
            while (sqlite3_step(stmt) == SQLITE_ROW) {
                FuncItem *funcItem = [[FuncItem alloc] init];
                int id = (int)sqlite3_column_int(stmt, 0);
                NSInteger nsId = (NSInteger)id;
                funcItem.itemId = nsId;
                
                char *name = (char *)sqlite3_column_text(stmt, 1);
                if (name != NULL) {
                    NSString *nsName = [[NSString alloc] initWithUTF8String:name];
                    funcItem.name = nsName;
                }
                
                int category = (int)sqlite3_column_int(stmt, 2);
                NSInteger nsCategory = (int)category;
                funcItem.category = nsCategory;
                
                char *des = (char *)sqlite3_column_text(stmt, 3);
                if (des != NULL) {
                    NSString *nsDescription = [[NSString alloc] initWithUTF8String:des];
                    funcItem.des = nsDescription;
                }
                
                char *usage = (char *)sqlite3_column_text(stmt, 4);
                if (usage != NULL) {
                    NSString *nsUsage = [[NSString alloc] initWithUTF8String:usage];
                    funcItem.usage = nsUsage;
                }
                
                char *parameters = (char *)sqlite3_column_text(stmt, 5);
                if (parameters != NULL) {
                    NSString *nsParameters = [[NSString alloc] initWithUTF8String:parameters];
                    funcItem.parameters = nsParameters;
                }
                
                char *returnvalue = (char *)sqlite3_column_text(stmt, 6);
                if (returnvalue != NULL) {
                    NSString *nsReturnvalue = [[NSString alloc] initWithUTF8String:returnvalue];
                    funcItem.returnValue = nsReturnvalue;
                }
                
                char *notes = (char *)sqlite3_column_text(stmt, 7);
                if (notes != NULL) {
                    NSString *nsNotes = [[NSString alloc] initWithUTF8String:notes];
                    funcItem.notes = nsNotes;
                }
                
                char *changeLog = (char *)sqlite3_column_text(stmt, 8);
                if (changeLog != NULL) {
                    NSString *nsChangeLog = [[NSString alloc] initWithUTF8String:changeLog];
                    funcItem.changeLog = nsChangeLog;
                }
                
                int sourceFileId = (int)sqlite3_column_int(stmt, 9);
                NSInteger nsSourceFileId = (NSInteger)sourceFileId;
                funcItem.sourceFileID = nsSourceFileId;
                
                char *sourcefile = (char *)sqlite3_column_text(stmt, 10);
                if (sourcefile != NULL) {
                    NSString *nsSourcefile = [[NSString alloc] initWithUTF8String:sourcefile];
                    funcItem.sourceFile = nsSourcefile;
                }
                
                char *img = (char *)sqlite3_column_text(stmt, 11);
                if (img != NULL) {
                    NSString *nsImg = [[NSString alloc] initWithUTF8String:img];
                    funcItem.img = nsImg;
                }
                
                [self.funcItems addObject:funcItem];
                
            }
        }
        sqlite3_finalize(stmt);
        sqlite3_close(db);
    }
    return 0;
}

// --根据主键查询funcItem
- (int)queryFuncItemById:(NSInteger)id
{
    NSString *path = self.dataFilePath;
    const char *npath = [path UTF8String];
    //打开数据库
    if (sqlite3_open(npath, &db) != SQLITE_OK){
        NSAssert(NO, @"打开数据库失败");
    }else{
        NSString *sql = @"SELECT * FROM FUNCITEMS WHERE ID = ?";
        const char *nsql = [sql UTF8String];
        //char *error;
        sqlite3_stmt *stmt;
        if (sqlite3_prepare_v2(db, nsql, -1, &stmt, NULL) == SQLITE_OK){
            sqlite3_bind_int(stmt, 1, (int)id);
            if (sqlite3_step(stmt) == SQLITE_ROW){
                FuncItem *funcItem = [[FuncItem alloc] init];
                int id = (int)sqlite3_column_int(stmt, 0);
                NSInteger nsId = (NSInteger)id;
                funcItem.itemId = nsId;
                
                char *name = (char *)sqlite3_column_text(stmt, 1);
                NSString *nsName = [[NSString alloc] initWithUTF8String:name];
                funcItem.name = nsName;
                
                int category = (int)sqlite3_column_int(stmt, 2);
                NSInteger nsCategory = (int)category;
                funcItem.category = nsCategory;
                
                char *des = (char *)sqlite3_column_text(stmt, 3);
                NSString *nsDescription = [[NSString alloc] initWithUTF8String:des];
                funcItem.des = nsDescription;
                
                char *usage = (char *)sqlite3_column_text(stmt, 4);
                NSString *nsUsage = [[NSString alloc] initWithUTF8String:usage];
                funcItem.usage = nsUsage;
                
                char *parameters = (char *)sqlite3_column_text(stmt, 5);
                NSString *nsParameters = [[NSString alloc] initWithUTF8String:parameters];
                funcItem.parameters = nsParameters;
                
                char *returnvalue = (char *)sqlite3_column_text(stmt, 6);
                NSString *nsReturnvalue = [[NSString alloc] initWithUTF8String:returnvalue];
                funcItem.returnValue = nsReturnvalue;
                
                char *notes = (char *)sqlite3_column_text(stmt, 7);
                NSString *nsNotes = [[NSString alloc] initWithUTF8String:notes];
                funcItem.notes = nsNotes;
                
                char *changeLog = (char *)sqlite3_column_text(stmt, 8);
                NSString *nsChangeLog = [[NSString alloc] initWithUTF8String:changeLog];
                funcItem.changeLog = nsChangeLog;
                
                int sourceFileId = (int)sqlite3_column_int(stmt, 9);
                NSInteger nsSourceFileId = (NSInteger)sourceFileId;
                funcItem.sourceFileID = nsSourceFileId;
            
                char *sourcefile = (char *)sqlite3_column_text(stmt, 10);
                NSString *nsSourcefile = [[NSString alloc] initWithUTF8String:sourcefile];
                funcItem.sourceFile = nsSourcefile;
                
                char *img = (char *)sqlite3_column_text(stmt, 11);
                NSString *nsImg = [[NSString alloc] initWithUTF8String:img];
                funcItem.img = nsImg;
                
                self.funcItem = funcItem;
            }
        }
        sqlite3_finalize(stmt);
        sqlite3_close(db);
    }
        
    return 0;
}

// --根据name近似查询funcItem
- (int)queryFuncItemBySimilarName:(NSString *)name inCatId:(NSInteger)id
{
    NSString *path = self.dataFilePath;
    const char *npath = [path UTF8String];
    //打开数据库
    if (sqlite3_open(npath, &db) != SQLITE_OK){
        NSAssert(NO, @"打开数据库失败");
    }else{
        NSString *sql;
        if (id > 0){
            sql = @"SELECT * FROM FUNCITEMS WHERE CATEGORY = ? AND NAME LIKE ? ORDER BY ID ASC";
        }else{
            sql = @"SELECT * FROM FUNCITEMS WHERE NAME LIKE ? ORDER BY ID ASC";
        }
        const char *nsql = [sql UTF8String];
        //char *error;
        sqlite3_stmt *stmt;
        if (sqlite3_prepare_v2(db, nsql, -1, &stmt, NULL) == SQLITE_OK){
            if (id > 0){
                sqlite3_bind_int(stmt, 1, (int)id);
                sqlite3_bind_text(stmt, 2, [[NSString stringWithFormat:@"%%%@%%", name] UTF8String], -1, NULL);
            }else{
                sqlite3_bind_text(stmt, 1, [[NSString stringWithFormat:@"%%%@%%", name] UTF8String], -1, NULL);
            }
            self.funcItems = [[NSMutableArray alloc] init];
            
                while (sqlite3_step(stmt) == SQLITE_ROW) {
                FuncItem *funcItem = [[FuncItem alloc] init];
                int id = (int)sqlite3_column_int(stmt, 0);
                NSInteger nsId = (NSInteger)id;
                funcItem.itemId = nsId;
                
                char *name = (char *)sqlite3_column_text(stmt, 1);
                NSString *nsName = [[NSString alloc] initWithUTF8String:name];
                funcItem.name = nsName;
                    NSLog(@"%@", nsName);
                    
                int category = (int)sqlite3_column_int(stmt, 2);
                NSInteger nsCategory = (int)category;
                funcItem.category = nsCategory;
                
                char *des = (char *)sqlite3_column_text(stmt, 3);
                NSString *nsDescription = [[NSString alloc] initWithUTF8String:des];
                funcItem.des = nsDescription;
                
                char *usage = (char *)sqlite3_column_text(stmt, 4);
                NSString *nsUsage = [[NSString alloc] initWithUTF8String:usage];
                funcItem.usage = nsUsage;
                
                char *parameters = (char *)sqlite3_column_text(stmt, 5);
                NSString *nsParameters = [[NSString alloc] initWithUTF8String:parameters];
                funcItem.parameters = nsParameters;
                
                char *returnvalue = (char *)sqlite3_column_text(stmt, 6);
                NSString *nsReturnvalue = [[NSString alloc] initWithUTF8String:returnvalue];
                funcItem.returnValue = nsReturnvalue;
                
                char *notes = (char *)sqlite3_column_text(stmt, 7);
                NSString *nsNotes = [[NSString alloc] initWithUTF8String:notes];
                funcItem.notes = nsNotes;
                
                char *changeLog = (char *)sqlite3_column_text(stmt, 8);
                NSString *nsChangeLog = [[NSString alloc] initWithUTF8String:changeLog];
                funcItem.changeLog = nsChangeLog;
                
                int sourceFileId = (int)sqlite3_column_int(stmt, 9);
                NSInteger nsSourceFileId = (NSInteger)sourceFileId;
                funcItem.sourceFileID = nsSourceFileId;
                    
                char *sourcefile = (char *)sqlite3_column_text(stmt, 10);
                NSString *nsSourcefile = [[NSString alloc] initWithUTF8String:sourcefile];
                funcItem.sourceFile = nsSourcefile;
                
                char *img = (char *)sqlite3_column_text(stmt, 11);
                NSString *nsImg = [[NSString alloc] initWithUTF8String:img];
                funcItem.img = nsImg;
                
                [self.funcItems addObject:funcItem];
                }
        }
        sqlite3_finalize(stmt);
        sqlite3_close(db);
    }
    
    return 0;
}


//--查询文件夹下的全部sourceFiles
- (int)querySourceFilesByParentId : (NSInteger)parentId
{
    NSString *path = self.dataFilePath;
    const char* npath = [path UTF8String];
    // 打开数据库
    if (sqlite3_open(npath, &db) != SQLITE_OK) {
        NSAssert(NO, @"打开数据库文件失败");
    }else{
        NSString *sql = @"SELECT * FROM SOURCEFILES WHERE PARENTID = ?";
        const char* nsql = [sql UTF8String];
        //char *error;
        sqlite3_stmt *stmt;
        if (sqlite3_prepare_v2(db, nsql, -1, &stmt, NULL) == SQLITE_OK) {
            sqlite3_bind_int(stmt, 1, (int)parentId);
            self.sourceFiles = [[NSMutableArray alloc] init];
            while (sqlite3_step(stmt) == SQLITE_ROW) {
                SourceFile *sourceFile = [[SourceFile alloc] init];
                int id = (int)sqlite3_column_int(stmt, 0);
                NSInteger nsId = (NSInteger)id;
                sourceFile.id = nsId;
                
                char *name = (char *)sqlite3_column_text(stmt, 1);
                NSString *nsName = [[NSString alloc] initWithUTF8String:name];
                sourceFile.name = nsName;
                
                char *type = (char *)sqlite3_column_text(stmt, 2);
                NSString *nsType = [[NSString alloc] initWithUTF8String:type];
                sourceFile.type = nsType;
                
                int parentId = (int)sqlite3_column_int(stmt, 3);
                NSInteger nsParentId = (NSInteger)parentId;
                sourceFile.parentId = nsParentId;
                
                char *path = (char *)sqlite3_column_text(stmt, 4);
                NSString *nsPath = [[NSString alloc] initWithUTF8String:path];
                sourceFile.path = nsPath;
                
                [self.sourceFiles addObject:sourceFile];
                
            }
        }
        sqlite3_finalize(stmt);
        sqlite3_close(db);
        SourceFile *oldSourceFile = [[SourceFile alloc] init];
        oldSourceFile.parentId = parentId;
        self.sourceFile = oldSourceFile;
    }
    return 0;
}

// --根据主键查询sourceFile
- (int)querySourceFileById:(NSInteger)id
{
    NSString *path = self.dataFilePath;
    const char *npath = [path UTF8String];
    //打开数据库
    if (sqlite3_open(npath, &db) != SQLITE_OK){
        NSAssert(NO, @"打开数据库失败");
    }else{
        NSString *sql = @"SELECT * FROM SOURCEFILES WHERE ID = ?";
        const char *nsql = [sql UTF8String];
        //char *error;
        sqlite3_stmt *stmt;
        if (sqlite3_prepare_v2(db, nsql, -1, &stmt, NULL) == SQLITE_OK){
            sqlite3_bind_int(stmt, 1, (int)id);
            if (sqlite3_step(stmt) == SQLITE_ROW){
                SourceFile *sourceFile = [[SourceFile alloc] init];
                int id = (int)sqlite3_column_int(stmt, 0);
                NSInteger nsId = (NSInteger)id;
                sourceFile.id = nsId;
                
                char *name = (char *)sqlite3_column_text(stmt, 1);
                NSString *nsName = [[NSString alloc] initWithUTF8String:name];
                sourceFile.name = nsName;
                
                char *type = (char *)sqlite3_column_text(stmt, 2);
                NSString *nsType = [[NSString alloc] initWithUTF8String:type];
                sourceFile.type = nsType;
                
                int parentId = (int)sqlite3_column_int(stmt, 3);
                NSInteger nsParentId = (NSInteger)parentId;
                sourceFile.parentId = nsParentId;
                
                char *path = (char *)sqlite3_column_text(stmt, 4);
                NSString *nsPath = [[NSString alloc] initWithUTF8String:path];
                sourceFile.path = nsPath;
                
                self.sourceFile = sourceFile;
            }
        }
        sqlite3_finalize(stmt);
        sqlite3_close(db);
    }
    
    return 0;
}

//根据父级id查询父级的父级id
- (int)querySourceFileParentIdByParentId:(NSInteger)parentId
{
    NSString *path = self.dataFilePath;
    const char *npath = [path UTF8String];
    //打开数据库
    if (sqlite3_open(npath, &db) != SQLITE_OK){
        NSAssert(NO, @"打开数据库失败");
    }else{
        NSString *sql = @"SELECT * FROM SOURCEFILES WHERE ID = (SELECT PARENTID FROM SOURCEFILES WHERE ID = ?)";
        const char *nsql = [sql UTF8String];
        //char *error;
        sqlite3_stmt *stmt;
        if (sqlite3_prepare_v2(db, nsql, -1, &stmt, NULL) == SQLITE_OK){
            sqlite3_bind_int(stmt, 1, (int)parentId);
            if (sqlite3_step(stmt) == SQLITE_ROW){
                SourceFile *sourceFile = [[SourceFile alloc] init];
                int id = (int)sqlite3_column_int(stmt, 0);
                NSInteger nsId = (NSInteger)id;
                sourceFile.id = nsId;
                
                char *name = (char *)sqlite3_column_text(stmt, 1);
                NSString *nsName = [[NSString alloc] initWithUTF8String:name];
                sourceFile.name = nsName;
                
                char *type = (char *)sqlite3_column_text(stmt, 2);
                NSString *nsType = [[NSString alloc] initWithUTF8String:type];
                sourceFile.type = nsType;
                
                int parentId = (int)sqlite3_column_int(stmt, 3);
                NSInteger nsParentId = (NSInteger)parentId;
                sourceFile.parentId = nsParentId;
                
                char *path = (char *)sqlite3_column_text(stmt, 4);
                NSString *nsPath = [[NSString alloc] initWithUTF8String:path];
                sourceFile.path = nsPath;
                
                self.parentSourceFolderInfo = sourceFile;
                
                return id;
            }
        }
        sqlite3_finalize(stmt);
        sqlite3_close(db);
    }
    
    return 0;
}

//--查询全部catItem
- (int)queryAllCatItems
{
    NSString *path = self.dataFilePath;
    const char* npath = [path UTF8String];
    // 打开数据库
    if (sqlite3_open(npath, &db) != SQLITE_OK) {
        NSAssert(NO, @"打开数据库文件失败");
    }else{
        NSString *sql = @"SELECT * FROM CATEGORIES";
        const char* nsql = [sql UTF8String];
        //char *error;
        sqlite3_stmt *stmt;
        if (sqlite3_prepare_v2(db, nsql, -1, &stmt, NULL) == SQLITE_OK) {
            
            self.catItems = [[NSMutableArray alloc] init];
            while (sqlite3_step(stmt) == SQLITE_ROW) {
                
                CatItem *catItem = [[CatItem alloc] init];
                int id = (int)sqlite3_column_int(stmt, 0);
                NSInteger nsId = (NSInteger)id;
                catItem.id = nsId;
                
                char *name = (char *)sqlite3_column_text(stmt, 1);
                NSString *nsName = [[NSString alloc] initWithUTF8String:name];
                catItem.name = nsName;
                
                char *des = (char *)sqlite3_column_text(stmt, 2);
                if (des != nil) {
                    NSString *nsDes = [[NSString alloc] initWithUTF8String:des];
                    catItem.des = nsDes;
                }else{
                    catItem.des = nil;
                }
                
                
                //查询该分类下的funcItem个数
                int count = [self queryFuncItemsCountInCatItemId:id];
                NSInteger nsCount = (NSInteger)count;
                catItem.count = nsCount;
                
                [self.catItems addObject:catItem];
                
            }
        }
        sqlite3_finalize(stmt);
        sqlite3_close(db);
    }
    return 0;
}

//根据分类id查询funcItem个数
- (int)queryFuncItemsCountInCatItemId:(NSInteger)id
{
    NSString *path = self.dataFilePath;
    const char* npath = [path UTF8String];
    // 打开数据库
    if (sqlite3_open(npath, &db) != SQLITE_OK) {
        NSAssert(NO, @"打开数据库文件失败");
    }else{
        NSString *sql = @"SELECT COUNT(*) FROM FUNCITEMS WHERE CATEGORY = ?";
        const char *nsql = [sql UTF8String];
        sqlite3_stmt *stmt;
        if (sqlite3_prepare_v2(db, nsql, -1, &stmt, NULL) == SQLITE_OK ){
            sqlite3_bind_int(stmt, 1, (int)id);
            if (sqlite3_step(stmt) == SQLITE_ROW){
                int count = sqlite3_column_int(stmt, 0);
                return count;
            }
        }
        sqlite3_finalize(stmt);
        sqlite3_close(db);
    }
    return 0;
}

//根据分类id查询funcItems
- (int)queryFuncItemsInCatItemId:(NSInteger)id
{
    NSString *path = self.dataFilePath;
    const char* npath = [path UTF8String];
    // 打开数据库
    if (sqlite3_open(npath, &db) != SQLITE_OK) {
        NSAssert(NO, @"打开数据库文件失败");
    }else{
        NSString *sql = @"SELECT * FROM FUNCITEMS WHERE CATEGORY = ?";
        const char *nsql = [sql UTF8String];
        sqlite3_stmt *stmt;
        if (sqlite3_prepare_v2(db, nsql, -1, &stmt, NULL) == SQLITE_OK ){
            sqlite3_bind_int(stmt, 1, (int)id);
            self.funcItems = [[NSMutableArray alloc] init];
            while (sqlite3_step(stmt) == SQLITE_ROW){
                FuncItem *funcItem = [[FuncItem alloc] init];
                int id = (int)sqlite3_column_int(stmt, 0);
                NSInteger nsId = (NSInteger)id;
                funcItem.itemId = nsId;
                
                char *name = (char *)sqlite3_column_text(stmt, 1);
                NSString *nsName = [[NSString alloc] initWithUTF8String:name];
                funcItem.name = nsName;
                NSLog(@"%@", nsName);
                
                int category = (int)sqlite3_column_int(stmt, 2);
                NSInteger nsCategory = (int)category;
                funcItem.category = nsCategory;
                
                char *des = (char *)sqlite3_column_text(stmt, 3);
                NSString *nsDescription = [[NSString alloc] initWithUTF8String:des];
                funcItem.des = nsDescription;
                
                char *usage = (char *)sqlite3_column_text(stmt, 4);
                NSString *nsUsage = [[NSString alloc] initWithUTF8String:usage];
                funcItem.usage = nsUsage;
                
                char *parameters = (char *)sqlite3_column_text(stmt, 5);
                NSString *nsParameters = [[NSString alloc] initWithUTF8String:parameters];
                funcItem.parameters = nsParameters;
                
                char *returnvalue = (char *)sqlite3_column_text(stmt, 6);
                NSString *nsReturnvalue = [[NSString alloc] initWithUTF8String:returnvalue];
                funcItem.returnValue = nsReturnvalue;
                
                char *notes = (char *)sqlite3_column_text(stmt, 7);
                NSString *nsNotes = [[NSString alloc] initWithUTF8String:notes];
                funcItem.notes = nsNotes;
                
                char *changeLog = (char *)sqlite3_column_text(stmt, 8);
                NSString *nsChangeLog = [[NSString alloc] initWithUTF8String:changeLog];
                funcItem.changeLog = nsChangeLog;
                
                int sourceFileId = (int)sqlite3_column_int(stmt, 9);
                NSInteger nsSourceFileId = (NSInteger)sourceFileId;
                funcItem.sourceFileID = nsSourceFileId;
                
                char *sourcefile = (char *)sqlite3_column_text(stmt, 10);
                NSString *nsSourcefile = [[NSString alloc] initWithUTF8String:sourcefile];
                funcItem.sourceFile = nsSourcefile;
                
                char *img = (char *)sqlite3_column_text(stmt, 11);
                NSString *nsImg = [[NSString alloc] initWithUTF8String:img];
                funcItem.img = nsImg;
                
                [self.funcItems addObject:funcItem];
            }
        }
        sqlite3_finalize(stmt);
        sqlite3_close(db);
    }
    return 0;
}

//查询博客列表
- (int)queryAllBlogs
{
    NSString *path = self.userDataFilePath;
    const char *npath = [path UTF8String];
    //打开数据库
    if (sqlite3_open(npath, &db) != SQLITE_OK) {
        NSAssert(NO, @"打开数据库文件失败");
    }else{
        NSString *sql = @"SELECT * FROM BLOGS";
        const char *nsql = [sql UTF8String];
        sqlite3_stmt *stmt;
        if (sqlite3_prepare_v2(db, nsql, -1, &stmt, NULL) == SQLITE_OK ){
            self.blogs = [[NSMutableArray alloc] init];
            while (sqlite3_step(stmt) == SQLITE_ROW){
                Blog *blog = [[Blog alloc] init];
                NSInteger id = (NSInteger)sqlite3_column_int(stmt, 0);
                blog.id = id;
                
                char *name = (char *)sqlite3_column_text(stmt, 1);
                NSString *nsName = [[NSString alloc] initWithUTF8String:name];
                blog.name = nsName;
                
                char *url = (char *)sqlite3_column_text(stmt, 2);
                NSString *nsUrl = [[NSString alloc] initWithUTF8String:url];
                blog.url = nsUrl;
                
                char *userName = (char *)sqlite3_column_text(stmt, 3);
                NSString *nsUserName = [[NSString alloc] initWithUTF8String:userName];
                blog.userName = nsUserName;
                
                NSInteger blogId = (NSInteger)sqlite3_column_int(stmt, 4);
                blog.blogId = blogId;
                
                char *xmlrpc = (char *)sqlite3_column_text(stmt, 5);
                NSString *nsXmlrpc = [[NSString alloc] initWithUTF8String:xmlrpc];
                blog.xmlrpc = nsXmlrpc;
                
                NSInteger isAdmin = (NSInteger)sqlite3_column_int(stmt, 6);
                blog.isAdmin = isAdmin;
                
                NSInteger lastSync = (NSInteger)sqlite3_column_int(stmt, 7);
                blog.lastSync = lastSync;
                
                char *subTitle = (char *)sqlite3_column_text(stmt, 8);
                NSString *nsSubTitle = subTitle ? [[NSString alloc] initWithUTF8String:subTitle] : nil;
                blog.subTitle = nsSubTitle;
                
                NSInteger defaultCatId = (NSInteger)sqlite3_column_int(stmt, 9);
                blog.defaultCatId = defaultCatId;
                
                char *defaultCat = (char *)sqlite3_column_text(stmt, 10);
                NSString *nsDefaultCat = defaultCat ? [[NSString alloc] initWithUTF8String:defaultCat] : nil;
                blog.defaultCat = nsDefaultCat;
                
                char *defaultFormat = (char *)sqlite3_column_text(stmt, 11);
                NSString *nsDefaultFormat = defaultFormat ? [[NSString alloc] initWithUTF8String:defaultFormat] : nil;
                blog.defaultCat = nsDefaultFormat;
                
                NSInteger locationMark = (NSInteger)sqlite3_column_int(stmt, 12);
                blog.locationMark = locationMark;
                
                char *template = (char *)sqlite3_column_text(stmt, 13);
                NSString *nsTemplate = template ? [[NSString alloc] initWithUTF8String:template] : nil;
                blog.template = nsTemplate;
                
                [self.blogs addObject:blog];
            }
        }
        sqlite3_finalize(stmt);
        sqlite3_close(db);
    }
    
    return 0;
}

//查询单个博客
- (Blog *)queryBlogWithId:(NSInteger)Id{
    NSString *path = self.userDataFilePath;
    const char *npath = [path UTF8String];
    //打开数据库
    if (sqlite3_open(npath, &db) != SQLITE_OK) {
        NSAssert(NO, @"打开数据库文件失败");
    }else{
        NSString *sql = @"SELECT * FROM BLOGS WHERE ID = ?";
        const char *nsql = [sql UTF8String];
        sqlite3_stmt *stmt;
        if (sqlite3_prepare_v2(db, nsql, -1, &stmt, NULL) == SQLITE_OK ){
            sqlite3_bind_int(stmt, 1, (int)Id);
                if (sqlite3_step(stmt) == SQLITE_ROW) {
                    Blog *blog = [[Blog alloc] init];
                    NSInteger id = (NSInteger)sqlite3_column_int(stmt, 0);
                    blog.id = id;
                    
                    char *name = (char *)sqlite3_column_text(stmt, 1);
                    NSString *nsName = [[NSString alloc] initWithUTF8String:name];
                    blog.name = nsName;
                    
                    char *url = (char *)sqlite3_column_text(stmt, 2);
                    NSString *nsUrl = [[NSString alloc] initWithUTF8String:url];
                    blog.url = nsUrl;
                    
                    char *userName = (char *)sqlite3_column_text(stmt, 3);
                    NSString *nsUserName = [[NSString alloc] initWithUTF8String:userName];
                    blog.userName = nsUserName;
                    
                    NSInteger blogId = (NSInteger)sqlite3_column_int(stmt, 4);
                    blog.blogId = blogId;
                    
                    char *xmlrpc = (char *)sqlite3_column_text(stmt, 5);
                    NSString *nsXmlrpc = [[NSString alloc] initWithUTF8String:xmlrpc];
                    blog.xmlrpc = nsXmlrpc;
                    
                    NSInteger isAdmin = (NSInteger)sqlite3_column_int(stmt, 6);
                    blog.isAdmin = isAdmin;
                    
                    NSInteger lastSync = (NSInteger)sqlite3_column_int(stmt, 7);
                    blog.lastSync = lastSync;
                    
                    char *subTitle = (char *)sqlite3_column_text(stmt, 8);
                    NSString *nsSubTitle = subTitle ? [[NSString alloc] initWithUTF8String:subTitle] : nil;
                    blog.subTitle = nsSubTitle;
                    
                    NSInteger defaultCatId = (NSInteger)sqlite3_column_int(stmt, 9);
                    blog.defaultCatId = defaultCatId;
                    
                    char *defaultCat = (char *)sqlite3_column_text(stmt, 10);
                    NSString *nsDefaultCat = defaultCat ? [[NSString alloc] initWithUTF8String:defaultCat] : nil;
                    blog.defaultCat = nsDefaultCat;
                    
                    char *defaultFormat = (char *)sqlite3_column_text(stmt, 11);
                    NSString *nsDefaultFormat = defaultFormat ? [[NSString alloc] initWithUTF8String:defaultFormat] : nil;
                    blog.defaultCat = nsDefaultFormat;
                    
                    NSInteger locationMark = (NSInteger)sqlite3_column_int(stmt, 12);
                    blog.locationMark = locationMark;
                    
                    char *template = (char *)sqlite3_column_text(stmt, 13);
                    NSString *nsTemplate = template ? [[NSString alloc] initWithUTF8String:template] : nil;
                    blog.template = nsTemplate;
                    
                    return blog;
                }
            }
            sqlite3_finalize(stmt);
            sqlite3_close(db);
        }
    return nil;
}


//判断博客是否存在
- (BOOL)isExistBlogWithUrl : (NSString *)url{
    NSString *path = self.userDataFilePath;
    const char *npath = [path UTF8String];
    //打开数据库
    if (sqlite3_open(npath, &db) != SQLITE_OK) {
        NSAssert(NO, @"打开数据库文件失败");
    }else{
        NSString *sql = @"SELECT * FROM BLOGS WHERE URL = ?";
        const char *nsql = [sql UTF8String];
        sqlite3_stmt *stmt;
        if (sqlite3_prepare_v2(db, nsql, -1, &stmt, NULL) == SQLITE_OK ){
            sqlite3_bind_text(stmt, 1, [url UTF8String], -1, NULL);
            if (sqlite3_step(stmt) == SQLITE_ROW) {
                return YES;
            }
        }
        sqlite3_finalize(stmt);
        sqlite3_close(db);
    }
    return NO;
}

//插入博客记录
- (int)insertBlogRecordWithName : (NSString *)name blogWithUrl : (NSString *)url blogWithUserName : (NSString *)username blogWithId : (NSInteger)blogId blogWithXmlrpc : (NSString *)xmlrpc isAdmin : (NSInteger)isAdmin;
{
    NSString *path = self.userDataFilePath;
    const char *npath = [path UTF8String];
    //打开数据库
    if (sqlite3_open(npath, &db) != SQLITE_OK) {
        NSAssert(NO, @"打开数据库文件失败");
    }else{
        NSString *sql = @"INSERT INTO BLOGS (NAME, URL, USERNAME, BLOGID, XMLRPC, ISADMIN) VALUES(?, ?, ?, ?, ?, ?)";
        const char *nsql = [sql UTF8String];
        sqlite3_stmt *stmt;
        if (sqlite3_prepare_v2(db, nsql, -1, &stmt, NULL) == SQLITE_OK ){
            sqlite3_bind_text(stmt, 1, [name UTF8String], -1, NULL);
            sqlite3_bind_text(stmt, 2, [url UTF8String], -1, NULL);
            sqlite3_bind_text(stmt, 3, [username UTF8String], -1, NULL);
            sqlite3_bind_int(stmt, 4, (int)blogId);
            sqlite3_bind_text(stmt, 5, [xmlrpc UTF8String], -1, NULL);
            sqlite3_bind_int(stmt, 6, (int)isAdmin);
            if (sqlite3_step(stmt) == SQLITE_DONE) {
                return (int)sqlite3_last_insert_rowid(db);
            }
        }
        sqlite3_finalize(stmt);
        sqlite3_close(db);
    }
    return 0;
}

//删除博客记录
- (int)deleteBlogRecordWithId:(NSInteger)id
{
    NSString *path = self.userDataFilePath;
    const char *npath = [path UTF8String];
    //打开数据库
    if (sqlite3_open(npath, &db) != SQLITE_OK) {
        NSAssert(NO, @"打开数据库文件失败");
    }else{
        NSString *sql = @"DELETE FROM BLOGS WHERE ID = ?";
        const char *nsql = [sql UTF8String];
        sqlite3_stmt *stmt;
        if (sqlite3_prepare_v2(db, nsql, -1, &stmt, NULL) == SQLITE_OK ){
            sqlite3_bind_int(stmt, 1, (int)id);
            if (sqlite3_step(stmt) == SQLITE_DONE) {
                return 1;
            }
        }
        sqlite3_finalize(stmt);
        sqlite3_close(db);
    }
    return 0;
}

//更新博客记录
- (int)updateBlogRecordWithId:(NSInteger)id withName:(NSString *)name withUrl:(NSString *)url withUsername:(NSString *)username blogWithId:(NSInteger)blogId blogWithXmlrpc : (NSString *)xmlrpc isAdmin:(NSInteger)isAdmin
{
    NSString *path = self.userDataFilePath;
    const char *npath = [path UTF8String];
    //打开数据库
    if (sqlite3_open(npath, &db) != SQLITE_OK) {
        NSAssert(NO, @"打开数据库文件失败");
    }else{
        NSString *sql = @"UPDATE BLOGS SET NAME = ?, URL = ?, USERNAME = ?, BLOGID = ?, XMLRPC = ? ISADMIN = ? WHERE ID = ?";
        const char *nsql = [sql UTF8String];
        sqlite3_stmt *stmt;
        if (sqlite3_prepare_v2(db, nsql, -1, &stmt, NULL) == SQLITE_OK ){
            sqlite3_bind_text(stmt, 1, [name UTF8String], -1, NULL);
            sqlite3_bind_text(stmt, 2, [url UTF8String], -1, NULL);
            sqlite3_bind_text(stmt, 3, [username UTF8String], -1, NULL);
            sqlite3_bind_int(stmt, 4, (int)blogId);
            sqlite3_bind_text(stmt, 5, [xmlrpc UTF8String], -1, NULL);
            sqlite3_bind_int(stmt, 6, (int)isAdmin);
            sqlite3_bind_int(stmt, 6, (int)id);
            if (sqlite3_step(stmt) == SQLITE_DONE) {
                return 1;
            }
        }
        sqlite3_finalize(stmt);
        sqlite3_close(db);
    }
    return 0;
}

//更新博客其他设置并返回最新blog对象
- (Blog *)updateBlog:(NSInteger)id WithKeyValuePairs:(NSDictionary *)keyValuePairs
{
    NSString *path = self.userDataFilePath;
    const char *npath = [path UTF8String];
    //打开数据库
    if (sqlite3_open(npath, &db) != SQLITE_OK) {
        NSAssert(NO, @"打开数据库文件失败");
    }else{
        NSString *sql = @"UPDATE BLOGS SET ";
        NSLog(@"keyvalue %@", keyValuePairs);
        if (!keyValuePairs.count == 0) {
            NSInteger i = 0;
            for (NSString *key in keyValuePairs) {
                i++;
                if (i != 1) sql = [sql stringByAppendingString:@", "];
                if ([[keyValuePairs objectForKey:key] isKindOfClass:[NSString class]]){
                   sql = [sql stringByAppendingString:[NSString stringWithFormat:@"%@ = '%@'",key,[keyValuePairs valueForKey:key]]];
                }else if ([[keyValuePairs objectForKey:key] isKindOfClass:[NSNumber class]]){
                    NSNumber *markNum = (NSNumber *)[keyValuePairs valueForKey:key];
                    sql = [sql stringByAppendingString:[NSString stringWithFormat:@"%@ = %i",key,[markNum intValue]]];
                }else{
                   sql = [sql stringByAppendingString:[NSString stringWithFormat:@"%@ = %i",key,(int)[keyValuePairs valueForKey:key]]];
                }
                
            }
            sql = [sql stringByAppendingString:[NSString stringWithFormat:@" WHERE ID = %i",(int)id]];
            const char *nsql = [sql UTF8String];
            sqlite3_stmt *stmt;
            if (sqlite3_prepare_v2(db, nsql, -1, &stmt, NULL) == SQLITE_OK ){
                if (sqlite3_step(stmt) == SQLITE_DONE) {
                    return [self queryBlogWithId:(NSInteger)id];
                }
            }
            sqlite3_finalize(stmt);
        }else{
           return [self queryBlogWithId:(NSInteger)id];
        }
        sqlite3_close(db);
    }
    return [self queryBlogWithId:(NSInteger)id];
}

#pragma - methods
//判断空字符串
- (BOOL) isBlankString:(NSString *)string {
    if (string == nil || string == NULL) {
        return YES;
    }
    if ([string isKindOfClass:[NSNull class]]) {
        return YES;
    }
    if ([[string stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] length]==0) {
        return YES;
    }
    return NO;
}

#pragma - method for keyChain
//写入keyChain以保存用户名密码
- (void)writeKeyChainWithId : (NSInteger)bid UserName : (NSString *)userName passWord : (NSString *)passWord{
    NSDictionary *infoDict = [[NSBundle mainBundle] infoDictionary];
    NSString *device = [infoDict objectForKey:@"DTPlatformName"];
    //针对模拟器
    if ([device isEqualToString:@"iphonesimulator"]) {
        [[NSUserDefaults standardUserDefaults] setObject:passWord forKey:[NSString stringWithFormat:@"Blog%i",(int)bid]];
        return;
    }
    
    //针对真机
    KeychainItemWrapper *keyChain = [[KeychainItemWrapper alloc] initWithIdentifier:@"com.wuxueqian.WordPressKit" accessGroup:nil];
    NSDictionary *Pwds = [keyChain objectForKey:(__bridge id)kSecValueData];
    Pwds = (Pwds && Pwds.count > 0) ? Pwds : [[NSDictionary alloc] init];
    NSMutableDictionary *newPwds = [Pwds mutableCopy];
    
    //添加或更新密码
    [newPwds setObject:passWord forKey:[NSString stringWithFormat:@"Blog%i",(int)bid]];
    [keyChain setObject:newPwds forKey:(__bridge id)kSecValueData];
}

//读取keyChain用户名密码
- (NSString *)readKeyChainWithId : (NSInteger)bid{
    NSDictionary *infoDict = [[NSBundle mainBundle] infoDictionary];
    NSString *device = [infoDict objectForKey:@"DTPlatformName"];
    //针对模拟器
    if ([device isEqualToString:@"iphonesimulator"]) {
        if ([[NSUserDefaults standardUserDefaults] objectForKey:[NSString stringWithFormat:@"Blog%i",(int)bid]]){
            return [[NSUserDefaults standardUserDefaults] objectForKey:[NSString stringWithFormat:@"Blog%i",(int)bid]];
        }
        return nil;
    }

    //针对真机
    KeychainItemWrapper *keyChain = [[KeychainItemWrapper alloc] initWithIdentifier:@"com.wuxueqian.WordPressKit" accessGroup:nil];
    NSDictionary *Pwds = [keyChain objectForKey:(__bridge id)kSecValueData];
    if (Pwds && Pwds.count > 0) {
        return [Pwds valueForKey:[NSString stringWithFormat:@"Blog%i",(int)bid]];
    }
    return nil;
}


@end
