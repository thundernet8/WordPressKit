//
//  CatFuncItemsViewController.m
//  WordPressKit
//
//  Created by wuxueqian on 15/9/12.
//  Copyright (c) 2015年 wuxueqian. All rights reserved.
//

#import "CatFuncItemsViewController.h"
#import "FuncItem.h"
#import "SourceFile.h"
#import "DataModel.h"
#import "FuncItemViewController.h"
#import "CatItem.h"

@interface CatFuncItemsViewController () <UISearchBarDelegate>

@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;

@end

@implementation CatFuncItemsViewController

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    self.navigationController.navigationBarHidden = NO;
    
    [[UITextField appearanceWhenContainedIn:[UISearchBar class], nil] setTextColor:[UIColor grayColor]];//searchtext颜色
    [[UILabel appearanceWhenContainedIn:[UISearchBar class], nil] setTextColor:[UIColor grayColor]];//placeholder颜色
    self.searchBar.backgroundColor = [UIColor whiteColor];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.searchBar.delegate = self;
    self.dataModel = [[DataModel alloc] init]; //初始化DataModel
    
    [self.dataModel queryFuncItemsInCatItemId:self.catItem.id];//查询数据
    self.searchBar.placeholder = [NSString stringWithFormat:@"Search in %@",self.catItem.name];
    
    self.tabBarController.tabBar.tintColor = [[UIColor alloc] initWithRed:0.0 green:168/255.0 blue:219/255.0 alpha:1.0]; //tab bar tint color
    
    // 点击空白搜索框消失
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(viewTapped:)];
    tap.cancelsTouchesInView = NO;
    [self.view addGestureRecognizer:tap];
    
    //分割线全宽-tableview
//    UITableView *tableView = self.tableView;
//    if ([tableView respondsToSelector:@selector(setSeparatorInset:)]) {
//        [tableView setSeparatorInset:UIEdgeInsetsZero];
//    }
//    if ([tableView respondsToSelector:@selector(setLayoutMargins:)]) {
//        [tableView setLayoutMargins:UIEdgeInsetsZero];
//    }
    
    [self configureTableView];

    self.navigationController.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName: [UIColor whiteColor]};//导航条标题颜色
    
    
    
}

// 点击空白搜索框消失
- (void)viewTapped: (UITapGestureRecognizer *)tap
{
    [self.view endEditing:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)configureTableView
{
    self.tableView.separatorColor = kSeparatorColor;
    self.tableView.backgroundColor = kBackgroundColorLightBlue;
    self.tableView.tableFooterView = [UIView new];
}

#pragma mark - 配置cell的img和label
- (void)configImgForCell: (UITableViewCell *)cell cellWithFuncItem: (FuncItem *)item
{
    NSString *img = [self.dataModel isBlankString:item.img] ? @"type_icon_function" : [NSString stringWithFormat:@"type_icon_%@",item.img];
//    UIGraphicsBeginImageContext(CGSizeMake(20, 20));
//    [[UIImage imageNamed:img] drawInRect:CGRectMake(0, 0, 20, 20)];
//    cell.imageView.image = UIGraphicsGetImageFromCurrentImageContext();
//    UIGraphicsEndImageContext();
    cell.imageView.image = [UIImage imageNamed:img];
    
}

- (void)configTextForCell: (UITableViewCell *)cell cellWithFuncItem: (FuncItem *)item
{
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

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.searchBar resignFirstResponder];
    FuncItem *funcItem = [[FuncItem alloc] init];
    funcItem = self.dataModel.funcItems[indexPath.row];
    [self performSegueWithIdentifier:@"ShowFuncItem" sender:funcItem];
}

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
    NSInteger catId;
    if (self.catItem) {
        catId = self.catItem.id;
    }else{
        catId = 0;
    }
    [self.dataModel queryFuncItemBySimilarName:searchText inCatId:catId];
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

@end
