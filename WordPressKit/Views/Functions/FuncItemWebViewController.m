//
//  FuncItemWebViewController.m
//  WordPressKit
//
//  Created by wuxueqian on 15/10/24.
//  Copyright (c) 2015年 wuxueqian. All rights reserved.
//

#import "FuncItemWebViewController.h"
#import "NSString+Util.h"
#import "MBProgressHUD.h"
#import "DataModel.h"
#import "SourceFile.h"
#import "FileItemViewController.h"

@interface FuncItemWebViewController () <UIWebViewDelegate>

@property (weak, nonatomic) IBOutlet UIWebView *webView;

@end

@implementation FuncItemWebViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.webView.delegate = self;
    self.webView.backgroundColor = kBackgroundColorLightGray;
    [self configureNavi];
    [self configureNavBackButton];
    [self configureTabbar];
    [self loadHud];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)loadHud
{
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.mode = MBProgressHUDAnimationFade;
    hud.labelText = @"加载中···";
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
        //加载内容
        [self loadHtml];
        dispatch_async(dispatch_get_main_queue(), ^{
            //[MBProgressHUD hideHUDForView:self.view animated:YES];
        });
    });
}

- (void)loadHtml
{
    NSError *error;
    NSString *sourceHtml;
    //APP内嵌bundle
    NSString *resourcePath = [[NSBundle mainBundle] pathForResource:@"FuncItems" ofType:@"bundle"];
    if (resourcePath.length > 0) {
        NSBundle *wpBundle = [[NSBundle alloc] initWithPath:resourcePath];
        NSString *localFile = [wpBundle pathForResource:[NSString stringWithFormat:@"%li",(long)_funcItem.itemId] ofType:@"ftm"];
        sourceHtml = [NSString stringWithContentsOfFile:localFile encoding:NSUTF8StringEncoding error:&error];
    }
    //替换链接
    sourceHtml = [sourceHtml stringByReplacingOccurrencesOfString:@"https://developer.wordpress.org/reference/files" withString:@"sourcefile://wproot"];
    //sourceHtml = [sourceHtml htmlEntityEncode];
    //HTML模板文本
    NSString *path = [[NSBundle mainBundle] pathForResource:@"funcitem" ofType:@"html"];
    NSString *localHtml = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:&error];
    
    //合并
    NSString *html = [localHtml stringByReplacingOccurrencesOfString:@"{{code}}" withString:sourceHtml];
    //加载
    NSURL *baseUrl = [NSURL fileURLWithPath:[[NSBundle mainBundle] bundlePath]];
    [self.webView loadHTMLString:html baseURL:baseUrl];
    
}

#pragma mark - webview delegate methods
- (void)webViewDidStartLoad:(UIWebView *)webView
{
    
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    BOOL isWrapped = [[NSUserDefaults standardUserDefaults] boolForKey:@"WordWrap"];
    NSString *js = [NSString stringWithFormat:@"wrapContent(%i)",(int)isWrapped];
    [self.webView stringByEvaluatingJavaScriptFromString:js];
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    NSLog(@"error occurs--%@",error.localizedDescription);
}

//接收js通知
- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    NSURL *url = [request URL];
    NSLog(@"%@",url.absoluteString);
    if ([[url scheme] isEqualToString:@"funcitem"] && [[url host] isEqualToString:@"completed"]) {
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        return NO;
    }else if ([[url scheme] isEqualToString:@"sourcefile"]){
        NSInteger sourfileId = _funcItem.sourceFileID;
        if (sourfileId != 0) {
            DataModel *dataModel = [[DataModel alloc] init];
            [dataModel querySourceFileById:sourfileId];
            SourceFile *sourcefile = [[SourceFile alloc] init];
            sourcefile = (SourceFile *)dataModel.sourceFile;
            [self performSegueWithIdentifier:@"ShowSourfileFromFuncItemInWebView" sender:sourcefile];
            return NO;
        }
    }else if ([[url scheme] isEqualToString:@"http"] || [[url scheme] isEqualToString:@"https"]){
        return NO;
    }
    return YES;
}

#pragma mark - configure
//导航标题
- (void)configureNavi
{
    self.navigationController.navigationBarHidden = NO;
    self.navigationItem.title = _funcItem.name;
    self.navigationController.navigationBar.barTintColor = kNaviBackgroundColorGreenBlue;
    UIBarButtonItem *rightBar = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"barbutton_wrap"] style:UIBarButtonItemStylePlain target:self action:@selector(wrapHtmlContent)];//自定义导航右换行切换按钮
    self.navigationItem.rightBarButtonItem = rightBar;//自定义导航右换行切换按钮
}

//网页内容切换是否自动换行
- (void)wrapHtmlContent{
    //获取当前wrap状态
    BOOL isWrapped = [[NSUserDefaults standardUserDefaults] boolForKey:@"WordWrap"];
    if (isWrapped) {
        [self.webView stringByEvaluatingJavaScriptFromString:@"wrapContent(0)"];
        [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"WordWrap"];
    }else{
        [self.webView stringByEvaluatingJavaScriptFromString:@"wrapContent(1)"];
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"WordWrap"];
    }
}

//导航左按钮
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

- (void)configureTabbar
{
    self.tabBarController.tabBar.tintColor = kFontColorGreenBlue; //tab bar tint color
}

#pragma mark - segue
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"ShowSourfileFromFuncItemInWebView"]) {
        FileItemViewController *controller = segue.destinationViewController;
        controller.file = sender;
    }
}


@end
