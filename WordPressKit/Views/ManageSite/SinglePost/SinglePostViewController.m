//
//  SinglePostViewController.m
//  WordPressKit
//
//  Created by wuxueqian on 15/10/15.
//  Copyright (c) 2015年 wuxueqian. All rights reserved.
//

#import "SinglePostViewController.h"
#import "RemotePost.h"
#import "NSString+Util.h"
#import "MBProgressHUD.h"

static NSArray *fontSizes;
static NSInteger currentFontSizeIndex;

@interface SinglePostViewController () <UIWebViewDelegate>

@property (weak, nonatomic) IBOutlet UISegmentedControl *contentCommentSwitch;
@property (weak, nonatomic) IBOutlet UIView *postHeader;
@property (weak, nonatomic) IBOutlet UILabel *postTitle;
@property (weak, nonatomic) IBOutlet UILabel *postMeta;
@property (weak, nonatomic) IBOutlet UIWebView *postContent;
- (IBAction)chageFontSize:(id)sender;

@end

@implementation SinglePostViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self addHud];
    [self configureVariables];
    [self configureContent];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
}

- (void)viewDidLayoutSubviews{
    [super viewDidLayoutSubviews];
    [self configureView];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)addHud
{
    //添加指示器
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.mode = MBProgressHUDAnimationFade;
    //hud.labelText = @"加载中···";
}

- (void)removeHud
{
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
    });
}

- (void)configureVariables
{
    fontSizes = @[@"small",@"normal",@"big"];
}

- (void)configureView
{
    //[self.postContent setContentOffset:CGPointZero];
}

- (void)configureContent
{
    //title
    self.postTitle.text = self.post.title;
    self.postTitle.numberOfLines = 0;
    [self.postTitle setLineBreakMode:NSLineBreakByWordWrapping];
    [self.postTitle sizeToFit];
    //date
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    //[dateFormat setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"]];
    [dateFormat setTimeZone:[NSTimeZone timeZoneWithName:@"Asia/Shanghai"]];
    [dateFormat setDateFormat:@"yyyy-MM-dd hh:MM a"];
    NSString *metaStr = [dateFormat stringFromDate:self.post.date];
    //authorname
    if (![self.post.authorDisplayName isEmpty]) {
        metaStr = [NSString stringWithFormat:@"%@ · %@", metaStr, self.post.authorDisplayName];
    }
    self.postMeta.text = metaStr;
//    NSAttributedString *content = [[NSAttributedString alloc] initWithData:[self.post.content dataUsingEncoding:NSUnicodeStringEncoding] options:@{ NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType } documentAttributes:nil error:nil];
    //webview content
    //本地模板文本
    NSString *path = [[NSBundle mainBundle] pathForResource:@"post" ofType:@"html"];
    NSString *localHtml = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil];
    //合并
    NSString *html = [localHtml stringByReplacingOccurrencesOfString:@"{{postcontent}}" withString:self.post.content];
    
    //加载
    NSURL *baseUrl = [NSURL fileURLWithPath:[[NSBundle mainBundle] bundlePath]];
    [self.postContent loadHTMLString:html baseURL:baseUrl];
    
    self.postContent.delegate = self;
    
}

#pragma mark - webview delegate
- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    NSURL *url = [request URL];
    if (navigationType == UIWebViewNavigationTypeLinkClicked) {
        [[UIApplication sharedApplication] openURL:url];
        return YES;
    }
    if ([url.scheme isEqualToString:@"wpkwebview"] && [url.host isEqualToString:@"postloaded"]) {
        [self removeHud];
    }
    return YES;
}

- (void)webViewDidStartLoad:(UIWebView *)webView
{
    
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    
}

#pragma mark - IBAction change fontSize
- (IBAction)chageFontSize:(id)sender
{
    currentFontSizeIndex ++;
    NSString *fontSize = fontSizes[currentFontSizeIndex%3];
    [self.postContent stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:@"changeFontSize('%@')",fontSize]];
}

@end
