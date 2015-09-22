//
//  SiteToolsViewController.m
//  WordPressKit
//
//  Created by wuxueqian on 15/9/20.
//  Copyright (c) 2015年 wuxueqian. All rights reserved.
//

#import "SiteToolsViewController.h"
#import "ToolKit/WebBrowserController.h"
#import "ManageSite/ListPostsViewController.h"

@interface SiteToolsViewController ()

@end

@implementation SiteToolsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    //去除tableview底部空白cell
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    
    //标题
    self.navigationItem.title = self.blog.name;
    
    //table上方描述
    UIImageView *blogLogo = (UIImageView *)[self.view viewWithTag:1802];
    blogLogo.image = [UIImage imageNamed:@"icon_blogavatar"];
    UILabel *blogName = (UILabel *)[self.view viewWithTag:1803];
    blogName.text = self.blog.name;
    UILabel *blogUrl = (UILabel *)[self.view viewWithTag:1804];
    blogUrl.text = [[self.blog.url stringByReplacingOccurrencesOfString:@"http://" withString:@""] stringByReplacingOccurrencesOfString:@"/" withString:@""];
    
    //tableview分割线颜色
    self.tableView.separatorColor = [[UIColor alloc] initWithRed:229/255.0 green:236/255.0 blue:240/255.0 alpha:1.0f];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) {
        return 2;
    }else if (section == 1){
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
    label.text = section == 0 ? @"" : section == 1 ? @"发布" : @"配置";
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
        [self performSegueWithIdentifier:@"ShowPosts" sender:self.blog];
    }
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return NO;
}

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark - Segue
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if ([segue.identifier isEqualToString:@"ShowWebBrowser"]) {
        WebBrowserController *controller = segue.destinationViewController;
        controller.url = (NSString *)sender;
    } else if ([segue.identifier isEqualToString:@"ShowPosts"]){
        ListPostsViewController *controller = segue.destinationViewController;
        controller.blog = sender;
    }
}

@end
