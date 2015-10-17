//
//  FileItemViewController.m
//  WordPressKit
//
//  Created by wuxueqian on 15/8/26.
//  Copyright (c) 2015年 wuxueqian. All rights reserved.
//

#import "FileItemViewController.h"
#import "SourceFile.h"
#import "MBProgressHUD.h"
#import "NSString+Util.h"

@interface FileItemViewController ()

@property (nonatomic, strong) IBOutlet UIWebView *webViewer;

@end

@implementation FileItemViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.tabBarController.tabBar.tintColor = [[UIColor alloc] initWithRed:0.0 green:168/255.0 blue:219/255.0 alpha:1.0]; //tab bar tint color
    self.webViewer.delegate = self;//设置webview委托
    UIBarButtonItem *rightBar = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"barbutton_wrap"] style:UIBarButtonItemStylePlain target:self action:@selector(wrapHtmlContent)];//自定义导航右换行切换按钮
    self.navigationItem.rightBarButtonItem = rightBar;//自定义导航右换行切换按钮
    [self configureNavBackButton];
    //开始加载
    [self loadHud];
    //[self loadHtml];
}

//网页内容切换是否自动换行
- (void)wrapHtmlContent{
    //获取当前wrap状态
    BOOL isWrapped = [[NSUserDefaults standardUserDefaults] boolForKey:@"WordWrap"];
    if (isWrapped) {
        [self.webViewer stringByEvaluatingJavaScriptFromString:@"wrapContent(0)"];
        [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"WordWrap"];
    }else{
        [self.webViewer stringByEvaluatingJavaScriptFromString:@"wrapContent(1)"];
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"WordWrap"];
    }
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
    SourceFile *file = (SourceFile *)self.file;
    
    //导航标题
    self.navigationItem.title = file.name;
    
    //远程文本or本地缓存
    NSError *error;
    NSString *sourceHtml;
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *cachePath = [NSHomeDirectory() stringByAppendingPathComponent:@"Library/Caches/SourceFiles"];
    //需要判断是否存在缓存文件夹
    if (![fileManager fileExistsAtPath:cachePath]) {
        [fileManager createDirectoryAtPath:cachePath withIntermediateDirectories:YES attributes:nil error:nil];
    }
    NSString *cacheFilePath = [cachePath stringByAppendingPathComponent:[NSString stringWithFormat:@"%i.scache", (int)file.id]];
    if ([fileManager fileExistsAtPath:cacheFilePath] && [[NSString stringWithContentsOfFile:cacheFilePath encoding:NSUTF8StringEncoding error:&error] lengthOfBytesUsingEncoding:NSUTF8StringEncoding] > 0) {
        sourceHtml = [NSString stringWithContentsOfFile:cacheFilePath encoding:NSUTF8StringEncoding error:&error];
    }else{
        //APP内嵌bundle
        NSString *resourcePath = [[NSBundle mainBundle] pathForResource:@"WordPress" ofType:@"bundle"];
        if (resourcePath.length > 0) {
            NSBundle *wpBundle = [[NSBundle alloc] initWithPath:resourcePath];
            NSString *localFile = [wpBundle pathForResource:file.path ofType:nil];
            sourceHtml = [NSString stringWithContentsOfFile:localFile encoding:NSUTF8StringEncoding error:&error];
        }else{
            //采用Github源的代码文件
            NSString *gitSourceBaseUrl = @"https://raw.githubusercontent.com/WordPress/WordPress/master/";
            NSString *completeUrl = [NSString stringWithFormat:@"%@%@", gitSourceBaseUrl, file.path];
            NSURL *url = [[NSURL alloc] initWithString:completeUrl];
            sourceHtml = [NSString stringWithContentsOfURL:url encoding:NSUTF8StringEncoding error:&error];
        }
        
        //写入缓存
        [fileManager createFileAtPath:cacheFilePath contents:[sourceHtml dataUsingEncoding:NSUTF8StringEncoding] attributes:nil];
        
    }
    sourceHtml = [sourceHtml htmlEntityEncode];
    NSString *preRomoteHtml = [NSString stringWithFormat:@"<pre class=\"precode prettyprint linenums\">%@</pre>",sourceHtml];
    //本地模板文本
    NSString *path = [[NSBundle mainBundle] pathForResource:@"sourcefile" ofType:@"html"];
    NSString *localHtml = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:&error];
    
    //合并
    NSString *html = [localHtml stringByReplacingOccurrencesOfString:@"{{code}}" withString:preRomoteHtml];

    //加载
    NSURL *baseUrl = [NSURL fileURLWithPath:[[NSBundle mainBundle] bundlePath]];
    [self.webViewer loadHTMLString:html baseURL:baseUrl];
    
}

#pragma mark - webview delegate methods
- (void)webViewDidStartLoad:(UIWebView *)webView
{

}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    BOOL isWrapped = [[NSUserDefaults standardUserDefaults] boolForKey:@"WordWrap"];
    NSString *js = [NSString stringWithFormat:@"loadCodeStyle(%i)",(int)isWrapped];
    [self.webViewer stringByEvaluatingJavaScriptFromString:js];
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    NSLog(@"error occurs--%@",error.localizedDescription);
}

//接收js通知
- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    NSURL *url = [request URL];
    if ([[url scheme] isEqualToString:@"sourcefile"] && [[url host] isEqualToString:@"completed"]) {
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        return NO;
    }
    
    return YES;
}

#pragma mark - configure
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

@end
