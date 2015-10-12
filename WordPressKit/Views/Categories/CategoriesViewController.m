//
//  CategoriesViewController.m
//  WordPressKit
//
//  Created by wuxueqian on 15/8/25.
//  Copyright (c) 2015年 wuxueqian. All rights reserved.
//

#import "CategoriesViewController.h"
#import "CatItem.h"
#import "DataModel.h"
#import "CatFuncItemsViewController.h"
#import "UIImageView+WebCache.h"

@interface CategoriesViewController ()

@end

@implementation CategoriesViewController

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden = NO;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    //通过dataModel获取catItems
    self.dataModel = [[DataModel alloc] init];//
    [self.dataModel queryAllCatItems]; //查询
    
    self.tableView.separatorColor = kSeparatorColor;
    
    self.navigationController.navigationBar.tintColor = kWhiteColor;//导航条文字颜色
    self.navigationController.navigationBar.barTintColor = kNaviBackgroundColorBlue; //导航条背景色
    
    self.navigationController.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName: kWhiteColor};//导航条标题颜色
    

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
    [[SDImageCache sharedImageCache] setValue:nil forKey:@"memCache"];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

//配置cell label text
- (void)configLabelTextForCell:(UITableViewCell *)cell cellWithCatItem:(CatItem *)catItem
{
    UILabel *titleLabel = (UILabel *)[cell.contentView viewWithTag:1201];
    UILabel *desLabel = (UILabel *)[cell.contentView viewWithTag:1202];
    UILabel *countLabel = (UILabel *)[cell.contentView viewWithTag:1203];
    titleLabel.text = catItem.name;
    desLabel.text = catItem.des;
    countLabel.text = [NSString stringWithFormat:@"%d", (int)catItem.count];
    
}

//datasource
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *identifier = @"CatCell";
    //UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier forIndexPath:indexPath];
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    }
    
    //配置cell文字
    [self configLabelTextForCell:cell cellWithCatItem:self.dataModel.catItems[indexPath.row]];
    
    //设置计数标签背景和圆角
    UILabel *countLabel = (UILabel *)[cell.contentView viewWithTag:1203];
    countLabel.layer.backgroundColor = [[UIColor alloc] initWithRed:0 green:0 blue:0 alpha:0.1].CGColor;
    countLabel.layer.cornerRadius = 6;
    
    //配置desLabel尺寸以及cell自动尺寸
    UILabel *desLabel = (UILabel *)[cell.contentView viewWithTag:1202];
    //desLabel换行
    desLabel.numberOfLines = 0;
    CGSize desSize = [desLabel sizeThatFits:CGSizeMake([UIScreen mainScreen].bounds.size.width - 20, MAXFLOAT)];
    CGRect rect = cell.frame;
    rect.size.height = 32 + desSize.height;
    cell.frame = rect;
    
    //配置countLabel尺寸
    [countLabel sizeToFit];
    //CGSize countSize = [countLabel.text sizeWithFont:[UIFont systemFontOfSize:12.0] constrainedToSize:CGSizeMake(50.0, 12.0)];
    //CGFloat width = countSize.width + 15;
    //CGFloat width = countLabel.frame.size.width + 15;
    CGFloat width = 20;
    NSLayoutConstraint *widthConstraint = [NSLayoutConstraint constraintWithItem:countLabel attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeWidth multiplier:0.0f constant:width];
    widthConstraint.active = YES;
    
    //设置选中样式
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    //分割线全宽-cell
    if ([cell respondsToSelector:@selector(setSeparatorInset:)]) {
        [cell setSeparatorInset:UIEdgeInsetsZero];
    }
    if ([cell respondsToSelector:@selector(setLayoutMargins:)]) {
        [cell setLayoutMargins:UIEdgeInsetsZero];
    }
    

    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.dataModel.catItems count];
}

//行高
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [self tableView:tableView cellForRowAtIndexPath:indexPath];
    return cell.frame.size.height;
}

//选中cell
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    //取消选中
    //[tableView deselectRowAtIndexPath:indexPath animated:NO];
    CatItem *catItem = self.dataModel.catItems[indexPath.row];
    [self performSegueWithIdentifier:@"shouCatFuncItems" sender:catItem];
}

//执行segue跳转至分类函数列表
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"shouCatFuncItems"]) {
        CatFuncItemsViewController *controller = segue.destinationViewController;
        controller.catItem = sender;
    }
}

//设置状态栏前景色
- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}
 
@end
