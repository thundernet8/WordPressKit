//
//  FiltersTableViewController.m
//  WordPressKit
//
//  Created by wuxueqian on 15/10/10.
//  Copyright (c) 2015年 wuxueqian. All rights reserved.
//

#import "FiltersTableViewController.h"
#import "PostStatusType.h"

@interface FiltersTableViewController ()

@property (nonatomic, strong) NSArray *filters;
@property (nonatomic, assign) NSInteger currentIndex;

@end

@implementation FiltersTableViewController

- (instancetype)initWithFilters:(NSArray *)filters andCurrentIndex:(NSInteger)index
{
    return [self initWithStyle:UITableViewStyleGrouped andFilters:filters andCurrentIndex:index];
}

- (instancetype)initWithStyle:(UITableViewStyle)style andFilters:(NSArray *)filters andCurrentIndex:(NSInteger)index
{
    self = [self initWithStyle:style];
    if (self) {
        self.title = @"过滤器";
        self.filters = filters;
        
        self.currentIndex = index;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    if (self.tableView.style == UITableViewStylePlain) {
        // 隐藏表格底部空白行
        self.tableView.tableFooterView = [UIView new];
    }
    
    [self configureCancelButton];
    
    [self configureTableView];
    
    [self configureNavibar];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)configureTableView
{
    self.tableView.backgroundColor = kBackgroundColorLightBlue;
    self.tableView.separatorColor = kSeparatorColor;
}

- (void)configureNavibar
{
    self.navigationController.navigationBar.barTintColor = kNaviBackgroundColorBlue;
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
    static NSString *CellIdentifier = @"FilterCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier];
    }
    cell.accessoryType = UITableViewCellAccessoryNone;
    
    PostStatusType *filter = [self.filters objectAtIndex:indexPath.row];
    
    cell.textLabel.text = filter.postStatusText;
    
    if (self.currentIndex == indexPath.row) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    self.currentIndex = indexPath.row;
    [self.tableView reloadData];
    
    if (self.onItemSelected != nil) {
        self.onItemSelected([NSNumber numberWithInteger:indexPath.row]);
    }
}

- (void)dismiss
{
    [self.navigationController popViewControllerAnimated:YES];
}

@end
