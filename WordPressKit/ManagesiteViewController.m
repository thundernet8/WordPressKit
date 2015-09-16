//
//  ManagesiteViewController.m
//  WordPressKit
//
//  Created by wuxueqian on 15/8/25.
//  Copyright (c) 2015年 wuxueqian. All rights reserved.
//

#import "ManagesiteViewController.h"
#import "DataModel.h"
#import "Blog.h"

@interface ManagesiteViewController () <UITableViewDelegate, UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end

@implementation ManagesiteViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.tabBarController.tabBar.tintColor = [[UIColor alloc] initWithRed:0.0 green:168/255.0 blue:219/255.0 alpha:1.0]; //tab bar tint color
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];//导航条文字颜色
    self.navigationController.navigationBar.barTintColor = [[UIColor alloc] initWithRed:0.0 green:168/255.0 blue:219/255.0 alpha:1.0]; //导航条背景色
    
    self.navigationController.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName: [UIColor whiteColor]};//导航条标题颜色
    
    //tableView 委托与数据源
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    
    //初始化dataModel
    self.dataModel = [[DataModel alloc] init];
    
    //获取博客列表
    [self.dataModel queryAllBlogs];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma - tableview datasource
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *identifier = @"BlogCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    //配置内容
    UIImageView *blogLogo = (UIImageView *)[cell viewWithTag:1601];
    UILabel *blogName = (UILabel *)[cell viewWithTag:1602];
    UILabel *blogUrl = (UILabel *)[cell viewWithTag:1603];
    
    Blog *blog = (Blog *)self.dataModel.blogs[indexPath.row];
    blogLogo.image = [UIImage imageNamed:@"icon_global"];
    blogName.text = blog.name;
    blogUrl.text = blog.url;
    
    
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.dataModel.blogs count];
}

//cell行高
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 40.0f;
}


@end
