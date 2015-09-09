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
    if (self.catItem) {
        self.navigationController.navigationBarHidden = NO;
    }else{
        self.navigationController.navigationBarHidden = YES; //隐藏导航条
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    if (!self.catItem) {
        [NSThread sleepForTimeInterval:2.0]; //延长Launch image加载时间
    }
    self.searchBar.delegate = self;
    self.dataModel = [[DataModel alloc] init]; //初始化DataModel
    if (self.catItem) {
        [self.dataModel queryFuncItemsInCatItemId:self.catItem.id];
        self.searchBar.placeholder = [NSString stringWithFormat:@"Search in %@",self.catItem.name];
    }else{
        [self.dataModel queryAllFuncItems];
    }
    
    //[self.dataModel queryFuncItemById:1];
    //[self.dataModel queryFuncItemBySimilarName:@"get"];
    
    // 点击空白搜索框消失
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(viewTapped:)];
    tap.cancelsTouchesInView = NO;
    [self.view addGestureRecognizer:tap];
    
    //[[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    //设置status bar背景色(对隐藏导航栏无效)
    //[self.navigationController.navigationBar setBarTintColor:[UIColor blackColor]];
    
    //分割线全宽-tableview
    UITableView *tableView = self.tableView;
    if ([tableView respondsToSelector:@selector(setSeparatorInset:)]) {
        [tableView setSeparatorInset:UIEdgeInsetsZero];
    }
    if ([tableView respondsToSelector:@selector(setLayoutMargins:)]) {
        [tableView setLayoutMargins:UIEdgeInsetsZero];
    }
    
    NSLog(@"the path is %@", [self.dataModel dataFilePath]);
    [self setStatusBarBackgroundColor];

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
    cell.imageView.image = [UIImage imageNamed:item.img];
    UIGraphicsBeginImageContext(CGSizeMake(16, 16));
    [cell.imageView.image drawInRect:CGRectMake(0, 0, 16, 16)];
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
//    if (cell == nil) {
//        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
//    }
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

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.searchBar resignFirstResponder];
    FuncItem *funcItem = [[FuncItem alloc] init];
    funcItem = self.dataModel.funcItems[indexPath.row];
    [self.dataModel querySourceFileById:funcItem.itemId];
    SourceFile *sourceFile = (SourceFile *)self.dataModel.sourceFile;
    funcItem.sourceFile = sourceFile.name;
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

//搜索框内容变化(粘贴)

//搜索框消失
- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    [self.searchBar resignFirstResponder];
}

//设置状态栏前景色
//- (UIStatusBarStyle)preferredStatusBarStyle
//{
//    return UIStatusBarStyleDefault;
//}

//设置状态栏背景色
- (void)setStatusBarBackgroundColor
{
    self.view.window.clipsToBounds = YES;
    [[UIApplication sharedApplication] setStatusBarStyle: UIStatusBarStyleLightContent];
    
    UIInterfaceOrientation orientation = [UIApplication sharedApplication].statusBarOrientation;
    if(orientation == UIInterfaceOrientationLandscapeLeft || orientation == UIInterfaceOrientationLandscapeRight)
    {
        self.view.window.frame =  CGRectMake(20, 0,self.view.window.frame.size.width-20,self.view.window.frame.size.height);
        self.view.window.bounds = CGRectMake(20, 0, self.view.window.frame.size.width, self.view.window.frame.size.height);
    } else
    {
        self.view.window.frame =  CGRectMake(0,20,self.view.window.frame.size.width,self.view.window.frame.size.height-20);
        self.view.window.bounds = CGRectMake(0, 20, self.view.window.frame.size.width, self.view.window.frame.size.height);
    }
}

@end
