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
#import "FileItemViewController.h"

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
    
    
    [self configureNavi];
    [self configureTableView];
    [self configureTabbar];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - configure
- (void)configureNavi
{
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];//导航条文字颜色
    self.navigationController.navigationBar.barTintColor = kNaviBackgroundColorGreenBlue; //导航条背景色
    
    self.navigationController.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName: [UIColor whiteColor]};//导航条标题颜色
}

- (void)configureTabbar
{
    self.tabBarController.tabBar.tintColor = kFontColorGreenBlue; //tab bar tint color
}

- (void)configureTableView
{
    self.tableView.separatorColor = kSeparatorColor;//tableview分割线颜色
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];//去除tableview底部空白cell
    self.tableView.backgroundColor = kBackgroundColorLightGray;
    self.view.backgroundColor = kBackgroundColorLightGray;
}


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
        NSString *img = sourceFile.type;
        NSArray *imgAvailable = @[@"php",@"css",@"js",@"txt",@"folder",@"html",@"xml"];
        if (![imgAvailable containsObject:img]) {
            img = @"unkown";
        }
        img = [NSString stringWithFormat:@"type_icon_%@",img];
        [cell.imageView setImage:[UIImage imageNamed:img]];
        //控制img大小
//        UIGraphicsBeginImageContext(CGSizeMake(20, 20));
//        [cell.imageView.image drawInRect:CGRectMake(0, 0, 20, 20)];
//        cell.imageView.image = UIGraphicsGetImageFromCurrentImageContext();
//        UIGraphicsEndImageContext();
        //配置acc
        if ([sourceFile.type isEqualToString:@"folder"]) {
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        }
    }else{
        cell.textLabel.text = @"Oops, 这里什么都没有 ···";
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
        [self configureNavBackButton];//自定义导航返回的左按钮
        [self.dataModel querySourceFilesByParentId:sourceFile.id];//查询数据
        [self.tableView reloadData];//页面重载
    }else if (sourceFile.type){
        [self performSegueWithIdentifier:@"ShowSourceFileContent" sender:sourceFile];
    }
}

//导航左按钮
- (void)configureNavBackButton
{
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.translatesAutoresizingMaskIntoConstraints = NO;
    button.exclusiveTouch = YES;
    button.titleLabel.font = [UIFont systemFontOfSize:16.0];
    [button setTitleColor:kWhiteColor forState:UIControlStateNormal];
    [button setTitleColor:[UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:0.2] forState:UIControlStateHighlighted];
    [button setTitle:@"返回" forState:UIControlStateNormal];
    [button setImage:[UIImage imageNamed:@"barbutton_backward"] forState:UIControlStateNormal];
    [button setImage:[UIImage imageNamed:@"barbutton_backward_hl"] forState:UIControlStateHighlighted];
    [button setImageEdgeInsets:UIEdgeInsetsMake(0.0, 0.0, 0.0, 0.0)];
    [button setTitleEdgeInsets:UIEdgeInsetsMake(0.0, -12.0, 0.0, 0.0)];
    CGSize fontSize = [button.titleLabel sizeThatFits:CGSizeMake(100.0, 22.0)];
    button.frame = CGRectMake(0.0, 0.0, button.imageView.image.size.width+fontSize.width+1, 40.0);
    [button addTarget:self action:@selector(backUpFolder) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *barbtn = [[UIBarButtonItem alloc] initWithCustomView:button];
    //修正iOS7以上左边距
    UIBarButtonItem *negativeSpacer = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
    negativeSpacer.width = -16;
    self.navigationItem.leftBarButtonItems = [NSArray arrayWithObjects:negativeSpacer,barbtn, nil];
}

// selector - 返回上一文件夹
- (void)backUpFolder
{
    SourceFile *sourceFile = (SourceFile *)self.dataModel.sourceFile;
    NSInteger pparentId = (NSInteger)[self.dataModel querySourceFileParentIdByParentId:sourceFile.parentId];
    [self.dataModel querySourceFilesByParentId:pparentId];
    SourceFile *parentSourceFile = (SourceFile *)self.dataModel.parentSourceFolderInfo;
    self.navigationItem.title = parentSourceFile.name ? parentSourceFile.name : @"源码";
    if (pparentId == 0) {
        self.navigationItem.leftBarButtonItems = nil;
        self.navigationItem.title = @"源码";
    }
    [self.tableView reloadData];
}

//segue传递参数
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"ShowSourceFileContent"]) {
        FileItemViewController *controller = segue.destinationViewController;
        controller.file = sender;
    }
}

//设置状态栏前景色
- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}



@end
