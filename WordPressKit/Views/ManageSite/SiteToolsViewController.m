//
//  SiteToolsViewController.m
//  WordPressKit
//
//  Created by wuxueqian on 15/9/20.
//  Copyright (c) 2015年 wuxueqian. All rights reserved.
//

#import "SiteToolsViewController.h"
#import "ToolKit/WebBrowserController.h"
#import "ManageSite/PostsListViewController.h"
#import "ManageSite/SiteSettingViewController.h"
#import "ManageSite/PagesListViewController.h"
#import "ManageSite/CustomPostsListViewController.h"
#import "NSString+Util.h"

@interface SiteToolsViewController () <UIAlertViewDelegate>

- (void)configureNavBackItemTitle;

@end

@implementation SiteToolsViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    [self configureBlogInfo];
    [self configureNavBackItemTitle];
    [self configureTableView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - configure
- (void)configureBlogInfo
{
    //标题
    self.navigationItem.title = self.blog.name;
    
    //table上方描述
    UIView *blogInfoWrapper = [self.view viewWithTag:1801];
    blogInfoWrapper.backgroundColor = kBackgroundColorLightGray;
    UIImageView *blogLogo = (UIImageView *)[self.view viewWithTag:1802];
    blogLogo.image = [UIImage imageNamed:@"icon_blogavatar"];
    UILabel *blogName = (UILabel *)[self.view viewWithTag:1803];
    blogName.text = self.blog.name;
    UILabel *blogUrl = (UILabel *)[self.view viewWithTag:1804];
    blogUrl.text = [[self.blog.url stringByReplacingOccurrencesOfString:@"http://" withString:@""] stringByReplacingOccurrencesOfString:@"/" withString:@""];
}

- (void)configureTableView
{
    //去除tableview底部空白cell
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    //tableview分割线颜色
    self.tableView.separatorColor = kSeparatorColor;
    self.tableView.backgroundColor = kBackgroundColorLightGray;
    self.view.backgroundColor = kBackgroundColorLightGray;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) {
        return 2;
    }else if (section == 1){
        //return 4;
        return 3;
    }else if (section == 2){
        return 1;
    }
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    NSString *identifier = [NSString stringWithFormat:@"SiteToolCell_s%i_r%i", (int)indexPath.section, (int)indexPath.row];
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    }
    //配置图标文字
    NSString *icon, *text;
    NSInteger row = (indexPath.section + 1)*10 + indexPath.row;
    switch (row) {
        case 10:
            icon = @"icon_viewsite";
            text = @"浏览站点";
            break;
        case 11:
            icon = @"icon_viewadmin";
            text = @"后台管理";
            break;
        case 20:
            icon = @"icon_posts";
            text = @"文章";
            break;
        case 21:
            icon = @"icon_pages";
            text = @"页面";
            break;
        case 22:
            icon = @"icon_filter";
            text = @"自定义";
            break;
        case 23:
            icon = @"icon_comments";
            text = @"评论";
            break;
        case 30:
            icon = @"icon_settings";
            text = @"设置";
        default:
            break;
    }
    cell.imageView.image = [UIImage imageNamed:icon];
    cell.textLabel.text = text;
    cell.textLabel.textColor = [[UIColor alloc] initWithRed:25/255.0 green:50/255.0 blue:68/255.0 alpha:1.0f];
    //cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}

#pragma - tableview的header
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    UIView *header = [[UIView alloc] init];
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(16.0f, 25.0f, tableView.frame.size.width, 20.0f)];
    label.text = section == 0 ? @"" : section == 1 ? @"内容" : @"配置";
    label.textColor = [[UIColor alloc] initWithRed:89/255.0 green:120/255.0 blue:144/255.0 alpha:1.0f];
    label.font = [UIFont systemFontOfSize:14.0];
    [header addSubview:label];
    return header;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    if (section != 0) {
        return 50.0f;
    }
    return 0.0f;
}

#pragma - tableview delegate

//cell点击
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section ==0 && indexPath.row == 1) {
        NSString *urlString = [self.blog.url stringByAppendingString:@"wp-admin"];
        NSURL *url = [NSURL URLWithString:urlString];
        [[UIApplication sharedApplication] openURL:url];
    }else if (indexPath.section == 0 && indexPath.row ==0){
        [self performSegueWithIdentifier:@"ShowWebBrowser" sender:self.blog.url];
    }else if (indexPath.section == 1 && indexPath.row == 0){
        [self performSegueWithIdentifier:@"ShowPostsList" sender:self.blog];
    }else if (indexPath.section == 1 && indexPath.row == 1){
        [self performSegueWithIdentifier:@"ShowPagesList" sender:self.blog];
    }else if (indexPath.section == 1 && indexPath.row == 2){
        [self.tableView cellForRowAtIndexPath:indexPath].selected = NO;
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"输入文章类型" message:@"请输入自定义的文章类型,例如'post'" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确认", nil];
        alert.alertViewStyle = UIAlertViewStylePlainTextInput;
        [alert show];
        
    }else if (indexPath.section == 2 && indexPath.row == 0){
        [self performSegueWithIdentifier:@"SiteSettings" sender:self.blog];
    }
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return NO;
}


#pragma mark - Segue

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if ([segue.identifier isEqualToString:@"ShowWebBrowser"]) {
        WebBrowserController *controller = segue.destinationViewController;
        controller.url = (NSString *)sender;
    } else if ([segue.identifier isEqualToString:@"ShowPostsList"]){
        PostsListViewController *controller = segue.destinationViewController;
        controller.blog = sender;
    } else if ([segue.identifier isEqualToString:@"ShowPagesList"]){
        PagesListViewController *controller = segue.destinationViewController;
        controller.blog = sender;
    } else if ([segue.identifier isEqualToString:@"SiteSettings"]){
        SiteSettingViewController *controller = segue.destinationViewController;
        controller.blogChanged = ^(Blog *blog){
            self.blog = blog;
        };
        controller.blog = sender;
    } else if ([segue.identifier isEqualToString:@"ShowCustomPosts"]){
        CustomPostsListViewController *controller = segue.destinationViewController;
        controller.blogInfo = sender;
    }
}

#pragma mark - configure

/**
 *  配置即将push的VC的导航返回按钮的文字(只能在父级中配置)
 */
- (void)configureNavBackItemTitle
{
    //UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithTitle:[NSString string] style:UIBarButtonItemStylePlain target:nil action:nil];
    UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithTitle:@"返回" style:UIBarButtonItemStylePlain target:nil action:nil];
    self.navigationItem.backBarButtonItem = backButton;
    [self configureNavBackButton];
}

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
    [button addTarget:self action:@selector(backForward:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *barbtn = [[UIBarButtonItem alloc] initWithCustomView:button];
    //修正iOS7以上左边距
    UIBarButtonItem *negativeSpacer = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
    negativeSpacer.width = -16;
    self.navigationItem.leftBarButtonItems = [NSArray arrayWithObjects:negativeSpacer,barbtn, nil];
}

- (void)backForward:(UINavigationItem *)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - alertview delegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 1) {
        UITextField *textField = [alertView textFieldAtIndex:0];
        [textField resignFirstResponder];
        NSString *postType = textField.text;
        if (![postType isEmpty]) {
            NSArray *blogInfo = @[self.blog,postType];
            [self performSegueWithIdentifier:@"ShowCustomPosts" sender:blogInfo];
        }
    }
}

@end
