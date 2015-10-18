//
//  AboutViewController.m
//  WordPressKit
//
//  Created by wuxueqian on 15/8/25.
//  Copyright (c) 2015年 wuxueqian. All rights reserved.
//

#import "AboutViewController.h"
#import "AboutTableViewController.h"

@interface AboutViewController ()
@property (weak, nonatomic) IBOutlet UIView *staticCellContainer;
@property (weak, nonatomic) UITableView *tableView;

- (void)configureStyle;
- (void)configureLabel;

@end

@implementation AboutViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self configureStyle];
    [self configureLabel];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)configureStyle
{
    //tab bar tint color
    self.tabBarController.tabBar.tintColor = kFontColorGreenBlue;
    //设置status bar背景色
    UIView *statusBarView =  [[UIView alloc] initWithFrame:CGRectMake(0, -1, [UIScreen mainScreen].bounds.size.width, 22)];
    statusBarView.backgroundColor  =  kNaviBackgroundColorGreenBlue;
    [self.view addSubview:statusBarView];
    self.view.backgroundColor = kBackgroundColorLightGray;
}

- (void)configureLabel
{
    UILabel *verLabel = (UILabel *)[self.view viewWithTag:1000];
    NSDictionary *infoDict = [[NSBundle mainBundle] infoDictionary];
    NSString *version = [infoDict objectForKey:@"CFBundleShortVersionString"];
    NSString *build = [infoDict objectForKey:@"CFBundleVersion"];
    NSString *verLabelText = [NSString stringWithFormat:@"版本: %@ build %@",version,build];
    verLabel.text = verLabelText;
}

#pragma mark - segue
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"AboutStaticTable"]) {
        UITableViewController *staticTableViewController = segue.destinationViewController;
        self.tableView = staticTableViewController.tableView;
    }
}

@end
