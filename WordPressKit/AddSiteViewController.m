//
//  AddSiteViewController.m
//  WordPressKit
//
//  Created by wuxueqian on 15/9/14.
//  Copyright (c) 2015年 wuxueqian. All rights reserved.
//

#import "AddSiteViewController.h"
#import "WordPressApi.h"


@interface AddSiteViewController () <UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate>

- (IBAction)cancelAddSite:(id)sender;
- (IBAction)addSite:(id)sender;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIView *wrapView;

@end

@implementation AddSiteViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // 指定tableview delegate
    //UITableView *loginTableView = (UITableView *)[self.view viewWithTag:1702];
    //loginTableView.delegate = self;
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    //tableview禁止拖动
    self.tableView.scrollEnabled = NO;
    //按钮-添加站点
    UIButton *addSiteButton = (UIButton *)[self.view viewWithTag:1705];
    addSiteButton.backgroundColor = [UIColor blackColor];
    addSiteButton.alpha = 0.2f;
    addSiteButton.layer.cornerRadius = 3.0f;
    //点击收起键盘
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(toggleDownKeyboard:)];
    [self.view addGestureRecognizer:tap];

    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//tap selector
- (void)toggleDownKeyboard:(UITapGestureRecognizer *)tap
{
    //动画方式恢复self view正常位置
    NSTimeInterval animationDuration = 0.30f;
    [UIView beginAnimations:@"ResizeForKeyboard" context:nil];
    [UIView setAnimationDuration:animationDuration];
    CGRect rect = CGRectMake(0.0f, 0.0f, self.view.frame.size.width, self.view.frame.size.height);
    self.view.frame = rect;
    [UIView commitAnimations];
    //取消编辑关闭键盘
    [self.view endEditing:YES];
}

//tableview datasource
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *identifier = @"LoginFieldCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    //配置cell内容
    UIImageView *imageField = (UIImageView *)[cell viewWithTag:1703];
    UITextField *textField = (UITextField *)[cell viewWithTag:1704];
    imageField.alpha = 0.5f;
    textField.delegate = self;
    if (indexPath.row == 0) {
        imageField.image = [UIImage imageNamed:@"icon_user"];
        textField.placeholder = @"用户名";
    }else if(indexPath.row == 1){
        imageField.image = [UIImage imageNamed:@"icon_lock"];
        textField.placeholder = @"密码";
        textField.secureTextEntry = YES;
    }else{
        imageField.image = [UIImage imageNamed:@"icon_global"];
        textField.placeholder = @"站点地址(URL)";
        //textField.keyboardType = UIKeyboardTypeURL;
    }
    //cell不可选中
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 3;
}

//cell行高
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 50.0;
}

//键盘点击return key退出
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    //动画方式恢复self view正常位置
    NSTimeInterval animationDuration = 0.30f;
    [UIView beginAnimations:@"ResizeForKeyboard" context:nil];
    [UIView setAnimationDuration:animationDuration];
    CGRect rect = CGRectMake(0.0f, 0.0f, self.view.frame.size.width, self.view.frame.size.height);
    self.view.frame = rect;
    [UIView commitAnimations];
    //取消编辑关闭键盘
    [self.view endEditing:YES];
    return YES;
}

//键盘弹出
- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    CGFloat offset = self.wrapView.frame.origin.y + 258 - (self.view.frame.size.height - 216);
    NSTimeInterval animationDuration = 0.30f;
    [UIView beginAnimations:@"ResizeForKeyBoard" context:nil];
    [UIView setAnimationDuration:animationDuration];
    if (offset > 0) {
        CGFloat width = self.view.frame.size.width;
        CGFloat height = self.view.frame.size.height;
        CGRect rect = CGRectMake(0.0f, -offset, width, height);
        self.view.frame = rect;
    }
    [UIView commitAnimations];
}

//取消添加站点并回到站点列表页
- (IBAction)cancelAddSite:(id)sender
{
    [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}

//尝试登录若成功则回到站点列表并广播数据
- (IBAction)addSite:(id)sender;
{
    UITableViewCell *userCell = (UITableViewCell *)[self.tableView.visibleCells objectAtIndex:0];
    UITableViewCell *passwordCell = (UITableViewCell *)[self.tableView.visibleCells objectAtIndex:1];
    UITableViewCell *urlCell = (UITableViewCell *)[self.tableView.visibleCells objectAtIndex:2];
    UITextField *userField = (UITextField *)[userCell viewWithTag:1704];
    UITextField *passwordField = (UITextField *)[passwordCell viewWithTag:1704];
    UITextField *urlField = (UITextField *)[urlCell viewWithTag:1704];
    NSString *message;
    BOOL isAllOk = NO;
    if (userField.text.length == 0 ) {
        message = @"用户名不能为空";
    }else if(passwordField.text.length == 0){
        message = @"密码不能为空";
    }else if(passwordField.text.length < 6){
        message = @"密码过短";
    }else if(urlField.text.length == 0){
        message = @"站点URL不能为空";
    }else{
        isAllOk = YES;
    }
    if (!isAllOk) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"警告" message:message delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alert show];
    }else{
        //通过xml-rpc请求验证
        // Sign in
        [WordPressApi signInWithURL:urlField.text
                           username:userField.text
                           password:passwordField.text
                            success:^(NSURL *xmlrpcURL) {
//                                NSUserDefaults *def = [NSUserDefaults standardUserDefaults];
//                                [def setObject:[xmlrpcURL absoluteString] forKey:@"wp_xmlrpc"];
//                                [def setObject:userField.text forKey:@"wp_username"];
//                                [def setObject:passwordField.text forKey:@"wp_password"];
//                                [def synchronize];
                                
                                
                                
                                [self dismissViewControllerAnimated:YES completion:nil];
                            } failure:^(NSError *error) {
                                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"登录错误" message:[error localizedDescription] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                                [alert show];
                            }];
    }
}


@end
