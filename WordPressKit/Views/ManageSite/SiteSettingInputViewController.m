//
//  SiteSettingInputViewController.m
//  WordPressKit
//
//  Created by wuxueqian on 15/10/25.
//  Copyright (c) 2015年 wuxueqian. All rights reserved.
//

#import "SiteSettingInputViewController.h"
#import "OptionData.h"
#import "NSString+Util.h"

@interface SiteSettingInputViewController ()<UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UITextField *input;
@property (weak, nonatomic) IBOutlet UILabel *tipLabel;
@property (nonatomic, strong)Blog *blog;
@property (nonatomic, strong)NSString *key;
@property (nonatomic, strong)NSString *value;
@property (nonatomic) BOOL isCancel;//用于判断是否从导航栏返回以取消更改

@end

@implementation SiteSettingInputViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self configureVars];
    [self configureView];
    [self configureNav];
    [self configureTextInput];
    [self configureTips];
}

- (void)viewDidDisappear:(BOOL)animated
{
    if (self.onValueChanged) {
        self.onValueChanged(_input.text,_key,_isCancel);
    }
    [super viewDidDisappear:animated];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - configure
- (void)configureVars
{
    _key = [_settingObject objectForKey:@"key"];
    _value = [_settingObject objectForKey:@"value"];
    _blog = [_settingObject objectForKey:@"blog"];
    _isCancel = YES;
}

- (void)configureView
{
    self.view.backgroundColor = kBackgroundColorLightGray;
}

- (void)configureTextInput
{
    _input.delegate = self;
    _input.layer.sublayerTransform = CATransform3DMakeTranslation(-12.0, 0, 0);
    UIView *spacerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 25, 40)];
    [_input setLeftViewMode:UITextFieldViewModeAlways];
    [_input setLeftView:spacerView];
    _input.layer.borderColor = [UIColor colorWithRed:225/255.0 green:225/255.0 blue:225/255.0 alpha:1.0].CGColor;
    _input.layer.borderWidth = 1.0f;
    if ([_key isEqualToString:@"password"]) {
        [_input setSecureTextEntry:YES];
    }
    _input.text = _value;
    [_input becomeFirstResponder];
}

- (void)configureTips
{
    _tipLabel.numberOfLines = 0;
    if ([_key isEqualToString:@"password"]) {
        _tipLabel.text = @"Tips:如果你从其他地方更改了博客密码，请及时从此处更新，以免无法正常使用其他服务";
    }else{
        _tipLabel.text = @"";
    }
    
}

- (void)configureNav
{
    if ([_key isEqualToString:@"blog_title"]) {
        self.navigationItem.title = @"站点标题";
    }else if ([_key isEqualToString:@"blog_tagline"]){
        self.navigationItem.title = @"标语";
    }else if ([_key isEqualToString:@"password"]){
        self.navigationItem.title = @"密码";
    }
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.translatesAutoresizingMaskIntoConstraints = NO;
    button.exclusiveTouch = YES;
    button.titleLabel.font = [UIFont systemFontOfSize:16.0];
    [button setTitleColor:kWhiteColor forState:UIControlStateNormal];
    [button setTitleColor:[UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:0.2] forState:UIControlStateHighlighted];
    [button setTitle:@"设置" forState:UIControlStateNormal];
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

#pragma mark - textinput delegate
- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if ([textField.text isEmpty]) {
        return NO;
    }else{
        _isCancel = NO;
        [self.navigationController popViewControllerAnimated:YES];
        return YES;
    }
    return NO;
}



@end
