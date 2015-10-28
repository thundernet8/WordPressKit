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
#import "UIImageView+WebCache.h"
#import "FuncItemWebViewController.h"

@interface FunctionsViewController () <UITableViewDelegate,UITableViewDataSource,UISearchBarDelegate,UIScrollViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic,weak) IBOutlet UISearchBar *searchBar;

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
    [NSThread sleepForTimeInterval:1.0]; //延长Launch image加载时间
    [self configureTableView];
    self.dataModel = [[DataModel alloc] init]; //初始化DataModel
    [self.dataModel queryAllFuncItems]; //查询数据
    [self configureSearchBar];
    [self configureNavi];
    [self configureTabbar];
    [self setStatusBarBackgroundColor]; //设置状态栏背景色
    [self addTapGesture];
}

// 点击空白搜索框消失
- (void)viewTapped: (UITapGestureRecognizer *)tap
{
    [self.view endEditing:YES];
}

- (void)addTapGesture
{
    // 点击空白搜索框消失
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(viewTapped:)];
    tap.cancelsTouchesInView = NO;
    [self.tableView addGestureRecognizer:tap];
}

- (void)configureSearchBar
{
    self.searchBar.delegate = self;
    self.searchBar.backgroundColor = kNaviBackgroundColorGreenBlue;
}

- (void)configureTableView
{
    self.view.backgroundColor = kBackgroundColorLightGray;
    self.tableView.separatorColor = kSeparatorColor;
    self.tableView.backgroundColor = kBackgroundColorLightGray;
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.contentInset = UIEdgeInsetsMake(-1.0f, 0.0f, 0.0f, 0.0);
    if ([self.tableView respondsToSelector:@selector(setSectionIndexColor:)]) {
        self.tableView.sectionIndexColor = kNaviBackgroundColorGreenBlue;
        self.tableView.sectionIndexTrackingBackgroundColor = [UIColor clearColor];
        self.tableView.sectionIndexBackgroundColor = [UIColor clearColor];
    }
}

- (void)configureNavi
{
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];//导航条文字颜色
    self.navigationController.navigationBar.barTintColor = [[UIColor alloc] initWithRed:0.0 green:168/255.0 blue:219/255.0 alpha:1.0]; //导航条背景色
    
    self.navigationController.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName: [UIColor whiteColor]};//导航条标题颜色
}

- (void)configureTabbar
{
    self.tabBarController.tabBar.tintColor = kFontColorGreenBlue; //tab bar tint color
    self.tabBarController.tabBar.barTintColor = kWhiteColor;
}

#pragma mark - 配置cell的img和label
- (void)configImgForCell: (UITableViewCell *)cell cellWithFuncItem: (FuncItem *)item
{
    NSString *img = [self.dataModel isBlankString:item.img] ? @"type_icon_function" : [NSString stringWithFormat:@"type_icon_%@",item.img];
    cell.imageView.image = [UIImage imageNamed:img];
    
}

- (void)configTextForCell: (UITableViewCell *)cell cellWithFuncItem: (FuncItem *)item
{
    cell.textLabel.text = [NSString stringWithFormat:@"%@", item.name];
}

#pragma mark - tableview datasource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if (!self.searchBar.text || [self.searchBar.text isEqualToString:@""]) {
        return 26;
    }
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (!self.searchBar.text || [self.searchBar.text isEqualToString:@""]) {
        NSArray *rowNums = @[@90,@11,@98,@82,@31,@28,@475,@28,@138,@3,@3,@33,@66,@22,@7,@85,@2,@69,@105,@222,@111,@14,@773,@6,@1,@177];
        return [rowNums[section] integerValue];
    }
    return [self.dataModel.funcItems count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"FuncItem";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    NSInteger num = [self getFuncItemRowNumofIndexPath:indexPath];
    FuncItem *item = self.dataModel.funcItems[num];
    [self configImgForCell:cell cellWithFuncItem:item];
    [self configTextForCell:cell cellWithFuncItem:item];
    
    //分割线全宽-cell
    if ([cell respondsToSelector:@selector(setSeparatorInset:)]) {
        [cell setSeparatorInset:UIEdgeInsetsZero];
    }
    if ([cell respondsToSelector:@selector(setLayoutMargins:)]) {
        [cell setLayoutMargins:UIEdgeInsetsZero];
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}

//cell行高
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 36;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (section == 0) {
        return 1.0;
    }
    return 0;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    return [UIView new];
}

//索引标题
- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView
{
    if (!self.searchBar.text || [self.searchBar.text isEqualToString:@""]) {
        return @[@"A",@"B",@"C",@"D",@"E",@"F",@"G",@"H",@"I",@"J",@"K",@"L",@"M",@"N",@"O",@"P",@"Q",@"R",@"S",@"T",@"U",@"V",@"W",@"X",@"Z",@"#"];
    }
    return nil;
}

#pragma mark - tableview delegate
//cell选中执行segue跳转详情页
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger num = [self getFuncItemRowNumofIndexPath:indexPath];
    FuncItem *funcItem = self.dataModel.funcItems[num];
    if ([funcItem.img isEqualToString:@"api"]) {
        [self performSegueWithIdentifier:@"ShowFuncItem" sender:funcItem];
    }else{
        [self performSegueWithIdentifier:@"ShowFuncItemInWebView" sender:funcItem];
    }
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    [self.view endEditing:YES];
}

//跳转函数详情页前segue准备
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"ShowFuncItem"]) {
        FuncItemViewController *controller = segue.destinationViewController;
        controller.funcItem = sender;
    }else if ([segue.identifier isEqualToString:@"ShowFuncItemInWebView"]) {
        FuncItemWebViewController *controller = segue.destinationViewController;
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
    UIView *statusBarView =  [[UIView alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 22)];
    statusBarView.backgroundColor  =  kNaviBackgroundColorGreenBlue;
    [self.view addSubview:statusBarView];
}

- (void)setStatusBarWithNavBackgroundColor
{
    UIView *statusBarView =  [[UIView alloc] initWithFrame:CGRectMake(0, -20, [UIScreen mainScreen].bounds.size.width, 22)];
    statusBarView.backgroundColor  =  [[UIColor alloc] initWithRed:0.0 green:168/255.0 blue:219/255.0 alpha:1];
    [self.navigationController.navigationBar addSubview:statusBarView];
}

//获取对应indexPath下的函数row
- (NSInteger)getFuncItemRowNumofIndexPath:(NSIndexPath *)indexPath
{
    NSArray *rowNums = @[@90,@11,@98,@82,@31,@28,@475,@28,@138,@3,@3,@33,@66,@22,@7,@85,@2,@69,@105,@222,@111,@14,@773,@6,@1,@177];
    NSInteger num = 0;
    for (NSInteger i=0; i<indexPath.section; i++) {
        num += [rowNums[i] integerValue];
    }
    num += indexPath.row;
    return num;
}

@end
