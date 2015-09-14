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
    hud.labelText = @"Loading···";
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
    if ([fileManager fileExistsAtPath:cacheFilePath] && ![NSString stringWithContentsOfFile:cacheFilePath encoding:NSUTF8StringEncoding error:&error]) {
        sourceHtml = [NSString stringWithContentsOfFile:cacheFilePath encoding:NSUTF8StringEncoding error:&error];
    }else{
        NSString *gitSourceBaseUrl = @"https://raw.githubusercontent.com/WordPress/WordPress/master/";
        NSString *completeUrl = [NSString stringWithFormat:@"%@%@", gitSourceBaseUrl, file.path];
        NSURL *url = [[NSURL alloc] initWithString:completeUrl];
        sourceHtml = [NSString stringWithContentsOfURL:url encoding:NSUTF8StringEncoding error:&error];
        //写入缓存
        [fileManager createFileAtPath:cacheFilePath contents:[sourceHtml dataUsingEncoding:NSUTF8StringEncoding] attributes:nil];
        
    }
    sourceHtml = [self htmlEntityEncode:sourceHtml];
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

-(NSString *)htmlEntityDecode:(NSString *)string
{
    string = [string stringByReplacingOccurrencesOfString:@"&quot;" withString:@"\""];
    string = [string stringByReplacingOccurrencesOfString:@"&apos;" withString:@"'"];
    string = [string stringByReplacingOccurrencesOfString:@"&amp;" withString:@"&"];
    string = [string stringByReplacingOccurrencesOfString:@"&lt;" withString:@"<"];
    string = [string stringByReplacingOccurrencesOfString:@"&gt;" withString:@">"];
    
    return string;
}

-(NSString *)htmlEntityEncode:(NSString *)string
{
    //string = [string stringByReplacingOccurrencesOfString:@"\"" withString:@"&quot;"];
    //string = [string stringByReplacingOccurrencesOfString:@"'" withString:@"&apos;"];
    //string = [string stringByReplacingOccurrencesOfString:@"&" withString:@"&amp;"];
    string = [string stringByReplacingOccurrencesOfString:@"<" withString:@"&lt;"];
    string = [string stringByReplacingOccurrencesOfString:@">" withString:@"&gt;"];
    
    return string;
}

#pragma mark - webview delegate methods
- (void)webViewDidStartLoad:(UIWebView *)webView
{
    NSLog(@"start load\r");
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

@end
