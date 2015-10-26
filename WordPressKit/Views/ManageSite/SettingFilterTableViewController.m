//
//  SettingFilterTableViewController.m
//  WordPressKit
//
//  Created by wuxueqian on 15/10/25.
//  Copyright (c) 2015年 wuxueqian. All rights reserved.
//

#import "SettingFilterTableViewController.h"
#import "MBProgressHUD.h"
#import "OptionData.h"
#import "PostCategory.h"
#import "PostFormat.h"

@interface SettingFilterTableViewController () <OptionDataDelegate>

@property (nonatomic, strong) NSArray *filters;
@property (nonatomic, assign) id currentFilter;
@property (nonatomic, copy) NSString *filterType;

@end

@implementation SettingFilterTableViewController

- (instancetype)initWithCurrentFilter:(id)filter forFilterType:(NSString *)type
{
    return [self initWithStyle:UITableViewStylePlain andCurrentFilter:filter forFilterType:type];
}

- (instancetype)initWithStyle:(UITableViewStyle)style andCurrentFilter:(id)currentFilter forFilterType:(NSString *)type{
    self = [self initWithStyle:style];
    if (self) {
        self.title = [type isEqualToString:@"category"] ? @"分类" : @"文章形式";
        self.filters = [NSArray new];
        self.currentFilter = currentFilter;
        self.filterType = type;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self configurePullToRefresh];
    
    [self configureCancelButton];
    
    [self configureTableView];
    
    [self configureNavibar];
    
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self fetchFiltersOfBlog:_blog withType:_filterType];
}

- (void)configurePullToRefresh
{
    if ([_filterType isEqualToString:@"category"]) {
        UIRefreshControl *rc = [[UIRefreshControl alloc] init];
        rc.attributedTitle = [[NSAttributedString alloc] initWithString:@"下拉刷新分类列表"];
        [rc addTarget:self action:@selector(refreshCategories:) forControlEvents:UIControlEventValueChanged];
        self.refreshControl = rc;
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.refreshControl beginRefreshing];
            [self.refreshControl endRefreshing];
        });
    }
}

- (void)configureTableView
{
    self.tableView.backgroundColor = kBackgroundColorLightGray;
    self.tableView.separatorColor = kSeparatorColor;
    self.tableView.scrollEnabled = YES;
    if (self.tableView.style == UITableViewStylePlain) {
        // 隐藏表格底部空白行
        self.tableView.tableFooterView = [UIView new];
    }
}

- (void)configureNavibar
{
    self.navigationController.navigationBar.barTintColor = kNaviBackgroundColorGreenBlue;
    self.navigationController.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName: kWhiteColor};
    self.navigationController.navigationBar.tintColor = kWhiteColor;
}

- (void)configureCancelButton
{
    if ([self.navigationController.viewControllers count] > 1) {
        return;
    }
    
    UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(didTapCancelButton:)];
    self.navigationItem.rightBarButtonItem = cancelButton;
}

- (void)didTapCancelButton:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
    if (self.onCancel) {
        self.onCancel();
    }
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.filters count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"SettingFilterCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier];
    }
    cell.accessoryType = UITableViewCellAccessoryNone;
    
    if ([_filterType isEqualToString:@"category"]) {
        PostCategory *filter = [self.filters objectAtIndex:indexPath.row];
        PostCategory *currentFilter = (PostCategory *)_currentFilter;
        cell.textLabel.text = filter.name;
        cell.accessoryType = (currentFilter && [filter.categoryID isEqual:currentFilter.categoryID])?UITableViewCellAccessoryCheckmark:UITableViewCellAccessoryNone;
    }else if ([_filterType isEqualToString:@"format"]){
        PostFormat *filter = [self.filters objectAtIndex:indexPath.row];
        PostFormat *currentFilter = (PostFormat *)_currentFilter;
        cell.textLabel.text = filter.name;
        cell.accessoryType = (currentFilter && [filter.slug isEqualToString:currentFilter.slug])?UITableViewCellAccessoryCheckmark:UITableViewCellAccessoryNone;
    }
    
    if (!_currentFilter && indexPath.section == 0 && indexPath.row == 0) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    self.currentFilter = self.filters[indexPath.row];
    [self.tableView reloadData];
    
    if (self.onItemSelected != nil) {
        self.onItemSelected(self.filters[indexPath.row]);
    }
}

#pragma mark - fetch filters
- (void)fetchFiltersOfBlog:(Blog *)blog withType:(NSString *)type
{
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.yOffset = -40.0;
    hud.mode = MBProgressHUDModeIndeterminate;
    hud.detailsLabelText = @"检索中";
    OptionData *op = [OptionData sharedManager];
    op.delegate = self;
    if ([type isEqualToString:@"category"]) {
        [op fetchCategoriesOfBlog:blog];
    }else if ([type isEqualToString:@"format"]){
        [op fetchFormatsOfBlog:blog];
    }
}

- (void)refreshCategories:(UIRefreshControl *)controll
{
    controll.attributedTitle = [[NSAttributedString alloc] initWithString:@"更新中···"];
    OptionData *op = [OptionData sharedManager];
    op.delegate = self;
    [op fetchRemoteCategoriesOfBlog:_blog];
}

#pragma mark - optiondata delegate
- (void)fetchCategoriesFinished:(NSArray *)categories
{
    [MBProgressHUD hideAllHUDsForView:self.tableView animated:YES];
    if ([self.refreshControl isRefreshing]) {
        self.refreshControl.attributedTitle = [[NSAttributedString alloc] initWithString:@"下拉刷新分类列表"];
        [self.refreshControl endRefreshing];
    }
    self.filters = categories;
    [self.tableView reloadData];
}

- (void)fetchCategoriesFailure:(NSError *)error
{
    [MBProgressHUD hideAllHUDsForView:self.tableView animated:YES];
    if ([self.refreshControl isRefreshing]) {
        self.refreshControl.attributedTitle = [[NSAttributedString alloc] initWithString:@"下拉刷新分类列表"];
        [self.refreshControl endRefreshing];
    }
    NSString *message = error.localizedDescription;
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"出错了" message:message delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil];
    [alert show];
}

- (void)fetchFormatsFinished:(NSArray *)formats
{
    [MBProgressHUD hideAllHUDsForView:self.tableView animated:YES];
    self.filters = formats;
    [self.tableView reloadData];
}

- (void)fetchFormatsFailure:(NSError *)error
{
    [MBProgressHUD hideAllHUDsForView:self.tableView animated:YES];
    NSString *message = error.localizedDescription;
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"出错了" message:message delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil];
    [alert show];
}

- (void)dismiss
{
    [self.navigationController popViewControllerAnimated:YES];
}

@end