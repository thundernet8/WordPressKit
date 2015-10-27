//
//  IntroViewController.m
//  WordPressKit
//
//  Created by wuxueqian on 15/10/27.
//  Copyright (c) 2015年 wuxueqian. All rights reserved.
//

#import "IntroViewController.h"

@interface IntroViewController () <UIWebViewDelegate>

@property (weak, nonatomic) IBOutlet UIWebView *webView;

@end

@implementation IntroViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self configureNav];
    [self configureWebView];
    [self loadHtml];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden = NO;
}

#pragma mark - configure
- (void)configureNav
{
    self.navigationController.navigationBar.barTintColor = kNaviBackgroundColorGreenBlue;
    self.navigationItem.leftBarButtonItem.tintColor = kWhiteColor;
    self.navigationItem.title = @"介绍";
    self.navigationController.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName: kWhiteColor};
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

- (void)configureWebView
{
    self.webView.delegate = self;
    self.webView.backgroundColor = kBackgroundColorLightGray;
}

- (void)loadHtml
{
    NSURL *baseUrl = [[NSBundle mainBundle] bundleURL];
    NSURL *resourceUrl = [[NSBundle mainBundle] resourceURL];
    NSLog(@"bundle is %@\n%@",baseUrl,resourceUrl);
    NSString *path = [[NSBundle mainBundle] pathForResource:@"intro" ofType:@"html"];
    NSURL *fileUrl = [NSURL URLWithString:path];
    [self.webView loadRequest:[NSURLRequest requestWithURL:fileUrl]];
}

@end
