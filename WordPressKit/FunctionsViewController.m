//
//  FunctionsViewController.m
//  WordPressKit
//
//  Created by wuxueqian on 15/8/25.
//  Copyright (c) 2015年 wuxueqian. All rights reserved.
//

#import "FunctionsViewController.h"
#import "FuncItem.h"
#import "SourceFile.h"
#import "DataModel.h"
#import "FuncItemViewController.h"
#import "CatItem.h"

@interface FunctionsViewController () <UISearchBarDelegate>
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;

@end

@implementation FunctionsViewController

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden = YES; //隐藏导航条
    [[UITextField appearanceWhenContainedIn:[UISearchBar class], nil] setTextColor:[UIColor whiteColor]];//searchtext颜色
    [[UILabel appearanceWhenContainedIn:[UISearchBar class], nil] setTextColor:[UIColor whiteColor]];//placeholder颜色
    [self.searchBar setImage:[UIImage imageNamed:@"SearchWhite"] forSearchBarIcon:UISearchBarIconSearch state:UIControlStateNormal];//搜索放大镜替换
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [NSThread sleepForTimeInterval:2.0]; //延长Launch image加载时间
    
    self.searchBar.delegate = self;
    
    self.dataModel = [[DataModel alloc] init]; //初始化DataModel
    
    [self.dataModel queryAllFuncItems]; //查询数据
    
    self.tabBarController.tabBar.tintColor = [[UIColor alloc] initWithRed:0.0 green:168/255.0 blue:219/255.0 alpha:1.0]; //tab bar tint color
    
    // 点击空白搜索框消失
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(viewTapped:)];
    tap.cancelsTouchesInView = NO;
    [self.view addGestureRecognizer:tap];
    
    //分割线全宽-tableview
    UITableView *tableView = self.tableView;
    if ([tableView respondsToSelector:@selector(setSeparatorInset:)]) {
        [tableView setSeparatorInset:UIEdgeInsetsZero];
    }
    if ([tableView respondsToSelector:@selector(setLayoutMargins:)]) {
        [tableView setLayoutMargins:UIEdgeInsetsZero];
    }
    [self setStatusBarBackgroundColor]; //设置状态栏背景色
        
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];//导航条文字颜色
    self.navigationController.navigationBar.barTintColor = [[UIColor alloc] initWithRed:0.0 green:168/255.0 blue:219/255.0 alpha:1.0]; //导航条背景色
    
    self.navigationController.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName: [UIColor whiteColor]};//导航条标题颜色
    
    NSLog(@"the path is %@", [self.dataModel dataFilePath]);
    
    
}

// 点击空白搜索框消失
- (void)viewTapped: (UITapGestureRecognizer *)tap
{
    //[self.searchBar resignFirstResponder];
    [self.view endEditing:YES];
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

#pragma mark - 配置cell的img和label
- (void)configImgForCell: (UITableViewCell *)cell cellWithFuncItem: (FuncItem *)item
{
    NSString *img = [self.dataModel isBlankString:item.img] ? @"function" : item.img;
    UIGraphicsBeginImageContext(CGSizeMake(20, 20));
    [[UIImage imageNamed:img] drawInRect:CGRectMake(0, 0, 20, 20)];
    cell.imageView.image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
}

- (void)configTextForCell: (UITableViewCell *)cell cellWithFuncItem: (FuncItem *)item
{
    //UILabel *label = (UILabel *)[cell viewWithTag:1002];
    cell.textLabel.text = [NSString stringWithFormat:@"%@", item.name];
}

#pragma mark - tableview datasource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.dataModel.funcItems count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"FuncItem";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    FuncItem *item = self.dataModel.funcItems[indexPath.row];
    [self configImgForCell:cell cellWithFuncItem:item];
    [self configTextForCell:cell cellWithFuncItem:item];
    
    //去掉分割线
    //[tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    
    //分割线全宽-cell
    if ([cell respondsToSelector:@selector(setSeparatorInset:)]) {
        [cell setSeparatorInset:UIEdgeInsetsZero];
    }
    if ([cell respondsToSelector:@selector(setLayoutMargins:)]) {
        [cell setLayoutMargins:UIEdgeInsetsZero];
    }
    return cell;
}

//cell行高
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 36;
}


//cell选中执行segue跳转详情页
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.searchBar resignFirstResponder];
    FuncItem *funcItem = [[FuncItem alloc] init];
    funcItem = self.dataModel.funcItems[indexPath.row];
    [self performSegueWithIdentifier:@"ShowFuncItem" sender:funcItem];
}


//跳转函数详情页前segue准备
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"ShowFuncItem"]) {
        FuncItemViewController *controller = segue.destinationViewController;
        controller.funcItem = sender;
        
    }
}

//搜索框内容变化
- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    [self.dataModel queryFuncItemBySimilarName:searchText inCatId:0];
    [self.tableView reloadData];
}

//搜索框消失
- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    [self.searchBar resignFirstResponder];
}

//设置状态栏前景色
- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

//设置状态栏背景色
- (void)setStatusBarBackgroundColor
{
    UIView *statusBarView =  [[UIView alloc] initWithFrame:CGRectMake(0, -20, [UIScreen mainScreen].bounds.size.width, 22)];
    statusBarView.backgroundColor  =  [[UIColor alloc] initWithRed:0.0 green:168/255.0 blue:219/255.0 alpha:1];
    [self.view addSubview:statusBarView];
}

- (void)setStatusBarWithNavBackgroundColor
{
    UIView *statusBarView =  [[UIView alloc] initWithFrame:CGRectMake(0, -20, [UIScreen mainScreen].bounds.size.width, 22)];
    statusBarView.backgroundColor  =  [[UIColor alloc] initWithRed:0.0 green:168/255.0 blue:219/255.0 alpha:1];
    [self.navigationController.navigationBar addSubview:statusBarView];
}

@end
