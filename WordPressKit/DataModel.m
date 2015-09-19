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
#import "Blog.h"

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
    //注册默认值，上次搜索词/是否首次启动/上次查看函数ID/上次查看的Tab
    NSDictionary *dictionary = @{@"SearchWords" : @"",@"FirstTime" : @YES,@"FuncItemId" : @0,@"LastTab" : @1,@"WordWrap" : @NO};
    [[NSUserDefaults standardUserDefaults] registerDefaults:dictionary];
}

- (void)handleFirstTime
{
    BOOL firstTime = [[NSUserDefaults standardUserDefaults] boolForKey:@"FirstTime"];
    if (firstTime) {
        [self restoreData];//首次启用将数据文件导入数据库
        [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"FirstTime"];
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
                
                NSInteger isAdmin = (NSInteger)sqlite3_column_int(stmt, 5);
                blog.isAdmin = isAdmin;
                
                [self.blogs addObject:blog];
            }
        }
        sqlite3_finalize(stmt);
        sqlite3_close(db);
    }
    
    return 0;
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
- (int)insertBlogRecordWithName : (NSString *)name blogWithUrl : (NSString *)url blogWithUserName : (NSString *)username blogWithId : (NSInteger)blogId isAdmin : (NSInteger)isAdmin;
{
    NSString *path = self.userDataFilePath;
    const char *npath = [path UTF8String];
    //打开数据库
    if (sqlite3_open(npath, &db) != SQLITE_OK) {
        NSAssert(NO, @"打开数据库文件失败");
    }else{
        NSString *sql = @"INSERT INTO BLOGS (NAME, URL, USERNAME, BLOGID, ISADMIN) VALUES(?, ?, ?, ?, ?)";
        const char *nsql = [sql UTF8String];
        sqlite3_stmt *stmt;
        if (sqlite3_prepare_v2(db, nsql, -1, &stmt, NULL) == SQLITE_OK ){
            sqlite3_bind_text(stmt, 1, [name UTF8String], -1, NULL);
            sqlite3_bind_text(stmt, 2, [url UTF8String], -1, NULL);
            sqlite3_bind_text(stmt, 3, [username UTF8String], -1, NULL);
            sqlite3_bind_int(stmt, 4, (int)blogId);
            sqlite3_bind_int(stmt, 5, (int)isAdmin);
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
- (int)updateBlogRecordWithId:(NSInteger)id withName:(NSString *)name withUrl:(NSString *)url withUsername:(NSString *)username withPassword:(NSString *)password
{
    NSString *path = self.userDataFilePath;
    const char *npath = [path UTF8String];
    //打开数据库
    if (sqlite3_open(npath, &db) != SQLITE_OK) {
        NSAssert(NO, @"打开数据库文件失败");
    }else{
        NSString *sql = [NSString stringWithFormat:@"UPDATE BLOGS SET NAME = \"%@\", URL = \"%@\", USERNAME = \"%@\", PASSWORD = \"%@\" WHERE ID = ?", name, url, username, password];
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




@end
