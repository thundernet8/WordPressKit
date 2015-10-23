//
//  AboutTableViewController.m
//  WordPressKit
//
//  Created by wuxueqian on 15/10/4.
//  Copyright (c) 2015年 wuxueqian. All rights reserved.
//

#import "AboutTableViewController.h"
#import "UIImageView+WebCache.h"
#import "WebBrowserController.h"
#import "UIImageView+WebCache.h"
#import <MessageUI/MFMailComposeViewController.h>

@interface AboutTableViewController () <MFMailComposeViewControllerDelegate>

- (void)configTableView;
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
    [self configTableView];
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
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) {
        return 3;
    }else if (section == 1){
        return 2;
    }
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [super tableView:tableView cellForRowAtIndexPath:indexPath];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
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
//    if (section == 0) {
//        return 0.0;
//    }
    return 6.0;
}

#pragma mark - tableview delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section == 0 && indexPath.row == 0) {
        //功能介绍
        
    }else if(indexPath.section == 0 && indexPath.row == 1) {
        //帮助
        
    }else if(indexPath.section == 0 && indexPath.row == 2) {
        //反馈
        [self sendEmail];
    }else if(indexPath.section == 1 && indexPath.row == 0) {
        //打开App Store评分
        NSURL *url = [NSURL URLWithString:@"https://itunes.apple.com/cn/app/WordPressKit"];
        [[UIApplication sharedApplication] openURL:url];
        
    }else if(indexPath.section == 1 && indexPath.row == 1) {
        //打开源代码网页
        NSString *url = @"https://www.github.com/WuXueqian/WordPressKit";
        [self performSegueWithIdentifier:@"AboutToBrowser" sender:url];
        
    }else if(indexPath.section == 2 && indexPath.row == 0) {
        [self clearCache];
        [self statisticCache];
    }
}


#pragma mark - accessories

- (void)configTableView
{
    self.tableView.backgroundColor = kBackgroundColorLightGray;
    CGFloat deviceHeight = [UIScreen mainScreen].bounds.size.height;
    if (deviceHeight < 560.0) {
        self.tableView.scrollEnabled = YES;
    }else{
        self.tableView.scrollEnabled = NO;
    }
}

- (void)sendEmail
{
    MFMailComposeViewController *mc = [[MFMailComposeViewController alloc] init];
    mc.mailComposeDelegate = self;
    [mc setSubject:@"WordPressKit 意见反馈"];
    [mc setToRecipients:[NSArray arrayWithObjects:@"wuxueqian2010@icloud.com", nil]];
    NSDictionary *infoDict = [[NSBundle mainBundle] infoDictionary];
    NSString *version = [infoDict objectForKey:@"CFBundleShortVersionString"];
    NSString *build = [infoDict objectForKey:@"CFBundleVersion"];
    NSString *osVersion = [[UIDevice currentDevice] systemVersion];
    NSString *content = [NSString stringWithFormat:@"<感谢您的反馈意见,我们会认真听取并改进!>\n\n系统版本:%@\n程序版本:%@ build %@",osVersion,version,build];
    [mc setMessageBody:content isHTML:NO];
    [self presentViewController:mc animated:YES completion:nil];
}

//发送邮件委托方法
- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error
{
    NSString *notice;
    switch (result)
    {
        case MFMailComposeResultCancelled:
            notice = @"您取消了发送";
            break;
        case MFMailComposeResultSaved:
            notice = @"反馈已保存, 请记得发送";
            break;
        case MFMailComposeResultSent:
            notice = @":-)邮件已发送, 感谢您的反馈";
            break;
        case MFMailComposeResultFailed:
            notice = [NSString stringWithFormat:@":-(发生了错误%@",[error localizedDescription]];
            break;
        default:
            break;
    }
    [self dismissViewControllerAnimated:YES completion:^(void){
        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view.superview.superview animated:YES];
        hud.mode = MBProgressHUDModeText;
        hud.labelText = notice;
        [hud hide:YES afterDelay:1.5];
    }];
}

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
    [[SDImageCache sharedImageCache] setValue:nil forKey:@"memCache"];//内存缓存清理 防止内存泄露
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

#pragma mark - segue

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"AboutToBrowser"]) {
        WebBrowserController *controller = segue.destinationViewController;
        controller.url = sender;
    }
}

@end
