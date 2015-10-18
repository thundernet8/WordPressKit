//
//  SiteSettingViewController.m
//  WordPressKit
//
//  Created by wuxueqian on 15/10/5.
//  Copyright (c) 2015年 wuxueqian. All rights reserved.
//

#import "SiteSettingViewController.h"
#import "WordPressXMLRPCApi.h"
#import "DataModel.h"

@interface SiteSettingViewController ()

@property (nonatomic, strong) NSDictionary *blogOptions;
@property (weak, nonatomic) IBOutlet UISwitch *locationMark;
@property (nonatomic, assign) BOOL currentLocationMark;
@property (nonatomic, strong) DataModel *dataModel;

- (void)configTableView;
- (void)configTableViewCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath;
- (void)configNavTitle;
- (void)retrieveSiteOptions:(Blog *)blog;
- (NSString *)getOptions:(NSDictionary *)options ValueForKey:(NSString *)key;

- (IBAction)locationMarkValueChanged:(id)sender;

@end

@implementation SiteSettingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    //data model
    self.dataModel = [[DataModel alloc] init];
    [self configNavTitle];
    [self configureNavBackButton];
    [self configTableView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 3;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [super tableView:tableView cellForRowAtIndexPath:indexPath];
    [self configTableViewCell:cell atIndexPath:indexPath];
    return cell;
}

#pragma - tableview的header
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    UIView *header = [[UIView alloc] init];
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(16.0f, 12.0f, tableView.frame.size.width, 16.0f)];
    label.text = section == 0 ? @"常规" : section == 1 ? @"账户" : @"撰写";
    label.textColor = [[UIColor alloc] initWithRed:89/255.0 green:120/255.0 blue:144/255.0 alpha:1.0f];
    label.font = [UIFont systemFontOfSize:14.0];
    [header addSubview:label];
    return header;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 40.0f;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 0;
}

#pragma mark - configure

- (void)configureNavBackButton
{
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.translatesAutoresizingMaskIntoConstraints = NO;
    button.exclusiveTouch = YES;
    button.titleLabel.font = [UIFont systemFontOfSize:16.0];
    [button setTitleColor:kWhiteColor forState:UIControlStateNormal];
    [button setTitleColor:[UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:0.2] forState:UIControlStateHighlighted];
    [button setTitle:@"站点" forState:UIControlStateNormal];
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

- (void)configTableView
{
    self.tableView.separatorColor = kSeparatorColor;
    self.tableView.backgroundColor = kBackgroundColorLightGray;
    self.view.backgroundColor = kBackgroundColorLightGray;
}

- (void)configTableViewCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    if (indexPath.section == 0 && indexPath.row == 0) {
        //标题
        UILabel *siteTitleLabel = (UILabel *)[cell.contentView.subviews lastObject];
        siteTitleLabel.text = self.blog.name;
    }else if (indexPath.section == 0 && indexPath.row == 1){
        //副标题
        UILabel *subTitleLabel = (UILabel *)[cell.contentView.subviews lastObject];
        if (self.blog.subTitle) {
            subTitleLabel.text = self.blog.subTitle;
        }else{
            [self retrieveSiteOptions:self.blog];
            //subTitleLabel.text = [self getOptions:self.blogOptions ValueForKey:@"blog_tagline"];
        }
    }else if (indexPath.section == 0 && indexPath.row == 2){
        //地址
        UILabel *urlLabel = (UILabel *)[cell.contentView.subviews lastObject];
        urlLabel.text = self.blog.url;
        
    }else if (indexPath.section == 1 && indexPath.row == 0){
        //用户名
        UILabel *usernameLabel = (UILabel *)[cell.contentView.subviews lastObject];
        usernameLabel.text = self.blog.userName;
    }else if (indexPath.section == 1 && indexPath.row == 1){
        //密码
        DataModel *dataModel = [[DataModel alloc] init];
        NSString *password = [dataModel readKeyChainWithId:self.blog.id];
        UITextField *passwordField = (UITextField *)[cell.contentView.subviews lastObject];
        passwordField.text = password;
    }else if (indexPath.section == 1 && indexPath.row ==2){
        //角色
        UILabel *roleLabel = (UILabel *)[cell.contentView.subviews lastObject];
        if (self.blog.isAdmin == 1) {
            roleLabel.text = @"管理员";
        }else{
            roleLabel.text = @"非管理员";
        }
    }else if (indexPath.section == 2 && indexPath.row == 0){
        //地理位置
        UISwitch *locationMark = (UISwitch *)[cell.contentView.subviews lastObject];
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        BOOL mark = [defaults boolForKey:@"LocationMark"];
        locationMark.on = mark;
        self.currentLocationMark = mark;

    }else if (indexPath.section == 2 && indexPath.row == 1){
        //默认分类
    }else if (indexPath.section == 2 && indexPath.row == 2){
        //默认文章形式
    }
    
}

- (void)configNavTitle
{
    self.navigationItem.title = @"设置";
}

#pragma mark - WordPress XMLRPC request

- (void)retrieveSiteOptions:(Blog *)blog
{
    NSString *password = [self.dataModel readKeyChainWithId:blog.id];
    WordPressXMLRPCApi *xmlrpcApi = [[WordPressXMLRPCApi alloc] initWithXMLRPCEndpoint:[NSURL URLWithString:blog.xmlrpc] username:blog.userName password:password];
    [xmlrpcApi getBlogOptionsWithSuccess:^(id options) {
        self.blogOptions = options;
        //插入数据库
        NSString *subTitle = [self getOptions:options ValueForKey:@"blog_tagline"];
        NSString *template = [self getOptions:self.blogOptions ValueForKey:@"template"];
        NSDictionary *dict = @{@"SUBTITLE":subTitle, @"TEMPLATE":template};
        self.blog = [self.dataModel updateBlog:self.blog.id WithKeyValuePairs:dict];
        //[self.tableView reloadData];
        UITableViewCell *subTitleCell = [self tableView:self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:0]];
        UILabel *subTitleLabel = [subTitleCell.contentView.subviews lastObject];
        subTitleLabel.text = self.blog.subTitle;
        
    } failure:^(NSError *error) {
        NSLog(@"error are %@", error.description);
    }];
}

- (NSString *)getOptions:(NSDictionary *)options ValueForKey:(NSString *)key
{
    return [[options valueForKey:key] valueForKey:@"value"];
}

#pragma mark - IBAction

- (IBAction)locationMarkValueChanged:(id)sender
{
    if (self.locationMark.on == self.currentLocationMark) {
        NSLog(@"return");
        return;
    }else{
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        [defaults setBool:self.locationMark.on forKey:@"LocationMark"];
        [defaults synchronize];
        if (self.locationMark.on) {
            NSLog(@"yes");
        }else{
            NSLog(@"no");
        }
    }
    self.currentLocationMark = self.locationMark.on;
}

@end
