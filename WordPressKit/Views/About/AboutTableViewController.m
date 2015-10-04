//
//  AboutTableViewController.m
//  WordPressKit
//
//  Created by wuxueqian on 15/10/4.
//  Copyright (c) 2015年 wuxueqian. All rights reserved.
//

#import "AboutTableViewController.h"
#import "UIImageView+WebCache.h"

@interface AboutTableViewController ()

- (void)statisticCache;
- (void)clearCache;
- (float)fileSizeAtPath:(NSString *)filePath;
- (float)folderSizeAtPath:(NSString *)folderPath;

@end

@implementation AboutTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    //[self statisticCache];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self statisticCache];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) {
        return 3;
    }
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [super tableView:tableView cellForRowAtIndexPath:indexPath];
    if (indexPath.section == 1 && indexPath.row == 0) {
        
    }
    return cell;
}

/**
 *  配置static tableview header的高度
 *
 *  @param tableView tableView实例对象
 *  @param section   section
 *
 *  @return 对应section的header高度
 */
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    if (section == 0) {
        return 0.0;
    }
    if ([UIScreen mainScreen].bounds.size.height < 500){
        return 2.0;
    }
    return 10.0;
}

#pragma mark - tableview delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section == 1 && indexPath.row ==0) {
        [self clearCache];
        [self statisticCache];
    }
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark - accessories

/**
 *  统计缓存文件大小并配置相关标签数据
 */
- (void)statisticCache
{
    //sourcefiles代码缓存
    NSString *codeSourceCachePath = [NSHomeDirectory() stringByAppendingPathComponent:@"Library/Caches/SourceFiles"];
    float codeCacheSize = [self folderSizeAtPath:codeSourceCachePath];
    //SDWebImage缓存
    __block float sdCacheSize = 0;
    [[SDImageCache sharedImageCache] calculateSizeWithCompletionBlock:^(NSUInteger fileCount, NSUInteger totalSize) {
        sdCacheSize += totalSize;
        //该block方法为异步,为获取执行结束后的数值,view变更方法也定义在block内
        float totalCacheSize = codeCacheSize + sdCacheSize;
        //转换MB
        float mbSize = totalCacheSize/(1024*1024);
        self.cacheLabel.text = [NSString stringWithFormat:@"%0.2f MB", mbSize];
    }];
}

/**
 *  清理硬盘缓存
 */
- (void)clearCache
{
    //SDWebImageCache
    [[SDImageCache sharedImageCache] clearDisk];
    //sourcefile代码缓存
    NSString *codeSourceCachePath = [NSHomeDirectory() stringByAppendingPathComponent:@"Library/Caches/SourceFiles"];
    NSFileManager *manager = [NSFileManager defaultManager];
    [manager removeItemAtPath:codeSourceCachePath error:nil];
}

/**
 *  获取文件大小
 *
 *  @param filePath 文件路径
 *
 *  @return 文件大小,单位字节
 */
- (float)fileSizeAtPath:(NSString *)filePath
{
    NSFileManager *manager = [NSFileManager defaultManager];
    if ([manager fileExistsAtPath:filePath]) {
        return [[manager attributesOfItemAtPath:filePath error:nil] fileSize];
    }
    return 0;
}

/**
 *  获取文件夹大小
 *
 *  @param folderPath 文件夹路径
 *
 *  @return 文件夹大小,单位字节
 */
- (float)folderSizeAtPath:(NSString *)folderPath
{
    NSFileManager *manager = [NSFileManager defaultManager];
    if (![manager fileExistsAtPath:folderPath]) {
        return 0;
    }
    NSEnumerator *childFilesEnumerator = [[manager subpathsAtPath:folderPath] objectEnumerator];
    NSString *fileName;
    float folderSize = 0;
    while ((fileName = [childFilesEnumerator nextObject]) != nil) {
        NSString *fileAbsolutePath = [folderPath stringByAppendingPathComponent:fileName];
        folderSize += [self fileSizeAtPath:fileAbsolutePath];
    }
    return folderSize;
}

@end
