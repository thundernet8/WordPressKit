//
//  SourcefileViewController.m
//  WordPressKit
//
//  Created by wuxueqian on 15/8/25.
//  Copyright (c) 2015年 wuxueqian. All rights reserved.
//

#import "SourcefileViewController.h"
#import "DataModel.h"
#import "SourceFile.h"

@interface SourcefileViewController ()

@end

@implementation SourcefileViewController

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden = NO;
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.dataModel = [[DataModel alloc] init]; //初始化dataModel
    [self.dataModel querySourceFilesByParentId:0]; //查询初始文件夹层级所有内容
    
    //分割线全宽-tableview
    UITableView *tableView = self.tableView;
    if ([tableView respondsToSelector:@selector(setSeparatorInset:)]) {
        [tableView setSeparatorInset:UIEdgeInsetsZero];
    }
    if ([tableView respondsToSelector:@selector(setLayoutMargins:)]) {
        [tableView setLayoutMargins:UIEdgeInsetsZero];
    }
    
    self.tabBarController.tabBar.tintColor = [[UIColor alloc] initWithRed:0.0 green:168/255.0 blue:219/255.0 alpha:1.0]; //tab bar tint color
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];//导航条文字颜色
    self.navigationController.navigationBar.barTintColor = [[UIColor alloc] initWithRed:0.0 green:168/255.0 blue:219/255.0 alpha:1.0]; //导航条背景色
    
    self.navigationController.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName: [UIColor whiteColor]};//导航条标题颜色
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark - datasource
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *identifier = @"SourceFileCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (cell != nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    }
    
    //分割线全宽-cell
    if ([cell respondsToSelector:@selector(setSeparatorInset:)]) {
        [cell setSeparatorInset:UIEdgeInsetsZero];
    }
    if ([cell respondsToSelector:@selector(setLayoutMargins:)]) {
        [cell setLayoutMargins:UIEdgeInsetsZero];
    }
    
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    
    if (self.dataModel.sourceFiles.count > 0) {
        //配置内容
        SourceFile *sourceFile = self.dataModel.sourceFiles[indexPath.row];
        cell.textLabel.text = sourceFile.name;
        [cell.imageView setImage:[UIImage imageNamed:@"parameter"]];
        //控制img大小
        UIGraphicsBeginImageContext(CGSizeMake(20, 20));
        [cell.imageView.image drawInRect:CGRectMake(0, 0, 20, 20)];
        cell.imageView.image = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
    }else{
        cell.textLabel.text = @"Oops, Nothing Founded...";
    }
    
    
    return cell;
    
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.dataModel.sourceFiles count]?[self.dataModel.sourceFiles count]:1;
}

//cell行高
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 36;
}

//cell选中
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    SourceFile *sourceFile = self.dataModel.sourceFiles.count > indexPath.row ? self.dataModel.sourceFiles[indexPath.row] : nil;
    NSString *title = sourceFile.name ? sourceFile.name : @"源码";
    if ([sourceFile.type  isEqual: @"folder"]) {
        [self.navigationItem setTitle:title];//设定导航标题
        UIBarButtonItem *leftBar = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"barbutton_back"] style:UIBarButtonItemStylePlain target:self action:@selector(backUpFolder)];//自定义导航返回的左按钮
        self.navigationItem.leftBarButtonItem = leftBar;//自定义导航返回的左按钮
        [self.dataModel querySourceFilesByParentId:sourceFile.id];//查询数据
        [self.tableView reloadData];//页面重载
    }
}

- (void)backUpFolder
{
    SourceFile *sourceFile = (SourceFile *)self.dataModel.sourceFile;
    NSInteger pparentId = (NSInteger)[self.dataModel querySourceFileParentIdByParentId:sourceFile.parentId];
    [self.dataModel querySourceFilesByParentId:pparentId];
    if (pparentId == 0) {
        self.navigationItem.leftBarButtonItem = nil;
    }
    [self.tableView reloadData];
}

//设置状态栏前景色
- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

@end
