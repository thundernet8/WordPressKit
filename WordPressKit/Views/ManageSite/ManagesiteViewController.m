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
#import "AddSiteViewController.h"
#import "WordPressApi.h"
#import "KeychainItemWrapper.h"
#import "SiteToolsViewController.h"
#import "MBProgressHUD.h"
#import "UIImageView+WebCache.h"

@interface ManagesiteViewController () <UITableViewDelegate, UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end

@implementation ManagesiteViewController

- (void)viewDidLayoutSubviews{
    //tableView 高度 - (待autolayout完成后更改，才能生效)
    [self.tableView setFrame:CGRectMake(0.0f, 0.0f, self.tableView.frame.size.width, 64.0f + [self.dataModel.blogs count]*56.0f)];
//    CALayer *bottomBorder = [CALayer layer];
//    bottomBorder.frame = CGRectMake(0.0f, [self.dataModel.blogs count]*56.0f-1, self.tableView.frame.size.width, 1.0f);
//    bottomBorder.backgroundColor = [[UIColor alloc] initWithRed:210/255.0 green:210/255.0 blue:210/255.0 alpha:1].CGColor;
//    [self.tableView.layer addSublayer:bottomBorder];
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    [self configureNavi];
    [self configureTableView];
    [self configureTabbar];
    
    //初始化dataModel
    self.dataModel = [[DataModel alloc] init];
    
    //获取博客列表
    [self.dataModel queryAllBlogs];
    
    //监听广播通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(addBlogComplete:) name:@"AddBlogCompleteNotification" object:nil];
    
    //导航左按钮绑定编辑事件
    if (self.dataModel.blogs.count >0) {
        self.navigationItem.leftBarButtonItem = self.editButtonItem;
    }

}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
    [[SDImageCache sharedImageCache] setValue:nil forKey:@"memCache"];
}

#pragma mark - configure
- (void)configureNavi
{
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];//导航条文字颜色
    self.navigationController.navigationBar.barTintColor = kFontColorGreenBlue; //导航条背景色
    
    self.navigationController.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName: [UIColor whiteColor]};//导航条标题颜色
}

- (void)configureTableView
{
    self.tableView.separatorColor = kSeparatorColor;//tableview分割线颜色
    self.tableView.backgroundColor = kBackgroundColorLightGray;
    self.view.backgroundColor = kBackgroundColorLightGray;
    //tableView 委托与数据源
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    
    //tableView 禁止拖动
    self.tableView.scrollEnabled = NO;
}

- (void)configureTabbar
{
    self.tabBarController.tabBar.tintColor = kFontColorGreenBlue; //tab bar tint color
}

//监听广播通知执行页面重载
- (void)addBlogComplete : (NSNotification *)notification{
//   NSDictionary *blogInfo = [notification userInfo];
//    NSString *url = [blogInfo valueForKey:@"Url"];
//    NSString *userName = [blogInfo valueForKey:@"UserName"];
//    NSString *password = [blogInfo valueForKey:@"Password"];
    
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.mode = MBProgressHUDModeCustomView;
    //hud.labelText = @"Completed";
    hud.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"icon_check_white"]];
    [hud hide:YES afterDelay:1];
    
    [self.dataModel queryAllBlogs];
    //由于子线程无法更新UI，需要切换主线程执行重载任务
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.tableView reloadData];
        [self.view setNeedsDisplay];
        [self.view setNeedsLayout];
        self.navigationItem.leftBarButtonItem = self.editButtonItem;
    });
}

#pragma - tableview datasource & delegate
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *identifier = @"BlogCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    //配置内容
    UIImageView *blogLogo = (UIImageView *)[cell viewWithTag:1601];
    UILabel *blogName = (UILabel *)[cell viewWithTag:1602];
    UILabel *blogUrl = (UILabel *)[cell viewWithTag:1603];
    
    Blog *blog = (Blog *)self.dataModel.blogs[indexPath.row];
    blogLogo.image = [UIImage imageNamed:@"icon_blogavatar"];
    blogLogo.alpha = 0.5;
    blogName.text = blog.name;
    blogUrl.text = [[blog.url stringByReplacingOccurrencesOfString:@"http://" withString:@""] stringByReplacingOccurrencesOfString:@"/" withString:@""];
    blogUrl.textColor = [[UIColor alloc] initWithRed:128/255.0 green:128/255.0 blue:128/255.0 alpha:1.0f];
    
    //给config按钮设置基于index.row的tag便于后面读取
    UIButton *configBtn = [cell.contentView.subviews objectAtIndex:3];
    [configBtn addTarget:self action:@selector(clickConfigBtn:) forControlEvents:UIControlEventTouchDown];
    configBtn.tag = indexPath.row + 100;
    
    return cell;
}

//selector config按钮点击事件
- (void)clickConfigBtn : (UIButton *)sender{
    NSInteger index = sender.tag - 100;
    Blog *blog = self.dataModel.blogs[index];
    [self performSegueWithIdentifier:@"PopConfigSiteView" sender:blog];
}

//执行segue
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if ([segue.identifier isEqualToString:@"PopConfigSiteView"]) {
        AddSiteViewController *controller = segue.destinationViewController;
        controller.blog = sender;
    }else if ([segue.identifier isEqualToString:@"ShowSiteToolsView"]){
        SiteToolsViewController *controller = segue.destinationViewController;
        controller.blog = sender;
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.dataModel.blogs count];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

//cell行高
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 56.0f;
}

#pragma mark - cell点击
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    Blog *blog = self.dataModel.blogs[indexPath.row];
    //检查站点用户名密码是否正确
    
    //keyChain读取密码
    //NSString *password = [self.dataModel readKeyChainWithId:blog.id];
    
    
    /*[WordPressApi signInWithURL:blog.url username:blog.userName password:password success:^(NSURL *xmlrpcURL) {
        NSLog(@"success");
        
    } failure:^(NSError *error) {
        //请求重新配置站点
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"站点配置信息有误, 需要重新配置" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        //[alert show];
        //[self performSegueWithIdentifier:@"PopConfigSiteView" sender:blog];
        NSLog(@"identifier is %@, and password is %@", keyChainIdentifier, password);
    }];*/
    
    //提高响应速度，不检查用户名密码，抓取文章时进行检查
    [self performSegueWithIdentifier:@"ShowSiteToolsView" sender:blog];
}


#pragma mark - edit tableview

//设置表编辑按钮样式
- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.row == self.dataModel.blogs.count) {
        return UITableViewCellEditingStyleInsert;
    }else{
        return UITableViewCellEditingStyleDelete;
    }
    
}

- (void)setEditing:(BOOL)editing animated:(BOOL)animated{
    [super setEditing:editing animated:animated];
    [self.tableView setEditing:editing animated:animated];
    NSArray *cells = self.tableView.visibleCells;
    for (UITableViewCell *cell in cells) {
//        for (UIView *configBtn in cell.contentView.subviews) {
//            if ([configBtn isKindOfClass:[UIButton class]]) {
//                configBtn.hidden = !editing;
//            }
//        }
        UIButton *configBtn = [cell.contentView.subviews objectAtIndex:3];
        configBtn.hidden = !editing;
    }
    if (editing) {
        
    }else{
        
    }
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath{
    NSArray *indexPaths = [NSArray arrayWithObject:indexPath];
    Blog *blog = self.dataModel.blogs[indexPath.row];
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        [self.dataModel deleteBlogRecordWithId:blog.id];
        [self.dataModel queryAllBlogs];
        [self.tableView deleteRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationFade];
    }
    if (self.dataModel.blogs.count == 0) {
        self.navigationItem.leftBarButtonItem = nil;
    }
    [self.tableView reloadData];
    [self.tableView setFrame:CGRectMake(0.0f, 0.0f, self.tableView.frame.size.width, 64.0f + [self.dataModel.blogs count]*56.0f)];
//    [self.view setNeedsDisplay];
//    [self.view setNeedsLayout];
}

@end
