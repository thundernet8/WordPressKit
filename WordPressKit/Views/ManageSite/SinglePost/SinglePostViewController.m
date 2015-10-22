//
//  SinglePostViewController.m
//  WordPressKit
//
//  Created by wuxueqian on 15/10/15.
//  Copyright (c) 2015年 wuxueqian. All rights reserved.
//

#import "SinglePostViewController.h"
#import "PostCommentsViewController.h"
#import "Post.h"
#import "NSString+Util.h"
#import "MBProgressHUD.h"
#import "CommentData.h"
#import "Comment.h"

static NSArray *fontSizes;
static NSInteger currentFontSizeIndex;

@interface SinglePostViewController () <UIWebViewDelegate>

@property (weak, nonatomic) IBOutlet UISegmentedControl *contentCommentSwitch;
@property (weak, nonatomic) IBOutlet UIView *postViewWrapper;
@property (weak, nonatomic) IBOutlet UIView *commentViewWrapper;
@property (weak, nonatomic) IBOutlet UIView *postHeader;
@property (weak, nonatomic) IBOutlet UILabel *postTitle;
@property (weak, nonatomic) IBOutlet UILabel *postMeta;
@property (weak, nonatomic) IBOutlet UIWebView *postContent;
@property (nonatomic,strong) NSArray *comments;
@property (nonatomic, strong) CommentData *cmt;

- (IBAction)chageFontSize:(id)sender;

@end

@implementation SinglePostViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self addHud];
    [self configureVariables];
    [self configureNavBackButton];
    [self configureSegmentControll];
    [self configureContent];
    [self.view bringSubviewToFront:self.postViewWrapper];
    
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    //NSLog(@"subviews %@", self.view.subviews.description);
}

- (void)viewDidLayoutSubviews{
    [super viewDidLayoutSubviews];
    
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
    fontSizes = @[@"normal",@"big",@"small"];
}

- (void)configureSegmentControll
{
    [self.contentCommentSwitch addTarget:self action:@selector(segControllClicked:) forControlEvents:UIControlEventValueChanged];
}

- (void)segControllClicked:(UISegmentedControl *)sender
{
    if (sender.selectedSegmentIndex == 1) {
        [self.view bringSubviewToFront:self.commentViewWrapper];
        self.navigationItem.rightBarButtonItem.enabled = NO;
        self.navigationItem.rightBarButtonItem.image = nil;
        [self maybeLoadComments];
    }else{
        [self.view bringSubviewToFront:self.postViewWrapper];
        self.navigationItem.rightBarButtonItem.enabled = YES;
        self.navigationItem.rightBarButtonItem.image = [UIImage imageNamed:@"barbutton_fontsize"];
    }
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
    [dateFormat setDateFormat:@"yyyy-MM-dd hhMM a"];
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

#pragma mark - comments
- (void)maybeLoadComments
{
    //切换到comments view时加载评论
    
}



#pragma mark - IBAction change fontSize
- (IBAction)chageFontSize:(id)sender
{
    currentFontSizeIndex ++;
    NSString *fontSize = fontSizes[currentFontSizeIndex%3];
    [self.postContent stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:@"changeFontSize('%@')",fontSize]];
}

#pragma mark - segue
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"ShowCommentsTable"]) {
        PostCommentsViewController *controller = segue.destinationViewController;
        controller.blog = self.blog;
        controller.post = self.post;
    }
}



@end
