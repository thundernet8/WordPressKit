//
//  AddSiteViewController.m
//  WordPressKit
//
//  Created by wuxueqian on 15/9/14.
//  Copyright (c) 2015年 wuxueqian. All rights reserved.
//

#import "AddSiteViewController.h"
#import "WordPressApi.h"
#import "DataModel.h"
#import "WordPressXMLRPCApi.h"
#import "MBProgressHUD.h"


@interface AddSiteViewController () <UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate>

- (IBAction)cancelAddSite:(id)sender;
- (IBAction)addSite:(id)sender;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIView *wrapView;

//插入博客记录
- (void)tryAddBlogWithUrl:(NSString *)url withUserName:(NSString *)username withPassWord:(NSString *)password;

//发送广播通知便于博客列表控制器读取新添加的数据
- (void)sendAddBlogCompleteNotificationWithBlogUrl : (NSString *)url withUserName : (NSString *)userName withPassword : (NSString *)password;


@end

@implementation AddSiteViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // 指定tableview delegate
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    
    //tableview禁止拖动
    self.tableView.scrollEnabled = NO;
    
    //按钮-添加站点
    UIButton *addSiteButton = (UIButton *)[self.view viewWithTag:1705];
    addSiteButton.backgroundColor = [UIColor blackColor];
    addSiteButton.alpha = 0.3f;
    addSiteButton.layer.cornerRadius = 3.0f;
    //添加按钮的文字选择
    if (self.blog) {
        [addSiteButton setTitle:@"更新站点" forState:UIControlStateNormal];
    }
    
    //点击收起键盘
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(toggleDownKeyboard:)];
    [self.view addGestureRecognizer:tap];
    
    //实例化datamodel
    self.dataModel = [[DataModel alloc] init];
    
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
        textField.keyboardType = UIKeyboardTypeDefault;
        textField.text = self.blog.userName;
    }else if(indexPath.row == 1){
        imageField.image = [UIImage imageNamed:@"icon_lock"];
        textField.placeholder = @"密码";
        textField.secureTextEntry = YES;
        //textField.text = @"wxq881994";
    }else{
        imageField.image = [UIImage imageNamed:@"icon_global"];
        textField.placeholder = @"站点地址(URL)";
        textField.keyboardType = UIKeyboardTypeURL;
        textField.text = [[self.blog.url stringByReplacingOccurrencesOfString:@"http://" withString:@""] stringByReplacingOccurrencesOfString:@"/" withString:@""];;
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
        //通过xml-rpc请求验证并尝试添加站点
        [self tryAddBlogWithUrl:urlField.text withUserName:userField.text withPassWord:passwordField.text];
        
    }
}

#pragma - method - 尝试添加站点
//尝试添加站点
- (void)tryAddBlogWithUrl:(NSString *)url withUserName:(NSString *)username withPassWord:(NSString *)password{
    //添加指示器
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.mode = MBProgressHUDAnimationFade;
    
    //通过getuserblogs尝试获取网站对应用户的博客列表
    [WordPressXMLRPCApi guessXMLRPCURLForSite:url success:^(NSURL *xmlrpcURL) {
        WordPressXMLRPCApi *xmlrpcApi = [[WordPressXMLRPCApi alloc] initWithXMLRPCEndpoint:xmlrpcURL username:username password:password];
        [xmlrpcApi getBlogsWithSuccess:^(NSArray *blogs){
            //如果是更新博客数据
            if (self.blog) {
                NSDictionary *blog = [blogs firstObject];
                int updateId = [self.dataModel updateBlogRecordWithId:self.blog.id withName:[blog valueForKey:@"blogName"] withUrl:[blog valueForKey:@"url"] withUsername:username blogWithId:[[blog valueForKey:@"blogid"] integerValue] isAdmin:[[blog valueForKey:@"isAdmin"] integerValue]];
                if (updateId > 0) {
                    //keyChain存储用户名密码
                    [self.dataModel writeKeyChainWithId:self.blog.id UserName:username passWord:password];
                    //广播通知博客列表页面controller
                    [self sendAddBlogCompleteNotificationWithBlogUrl:url withUserName:username withPassword:password];
                    
                    [MBProgressHUD hideHUDForView:self.view animated:YES];
                    [self dismissViewControllerAnimated:YES completion:nil];
                    return;
                }else{
                    //更新失败
                    [MBProgressHUD hideHUDForView:self.view animated:YES];
                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"更新站点配置失败，请重新尝试" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                    [alert show];
                    return;
                }
            }
            
            //插入到数据库
            for (NSDictionary *blog in blogs) {
                if ([self.dataModel isExistBlogWithUrl:[blog valueForKey:@"url"]]) {
                    [MBProgressHUD hideHUDForView:self.view animated:YES];
                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"此站点已经存在，请勿重复添加" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                    [alert show];
                    continue;
                }else{
                    int insertId = [self.dataModel insertBlogRecordWithName:[blog valueForKey:@"blogName"] blogWithUrl:[blog valueForKey:@"url"] blogWithUserName:username blogWithId:[[blog valueForKey:@"blogid"] integerValue] isAdmin:[[blog valueForKey:@"isAdmin"] integerValue]];
                    if (insertId > 0) {
                        //keyChain存储用户名密码
                        [self.dataModel writeKeyChainWithId:insertId UserName:username passWord:password];
                        
                        //广播通知博客列表页面controller
                        [self sendAddBlogCompleteNotificationWithBlogUrl:url withUserName:username withPassword:password];
                        
                        [MBProgressHUD hideHUDForView:self.view animated:YES];
                        [self dismissViewControllerAnimated:YES completion:nil];
                    }else{
                        //插入失败
                        [MBProgressHUD hideHUDForView:self.view animated:YES];
                        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"添加记录失败，请重新尝试" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                        [alert show];
                        break;
                    }
                }
            }
            
            
        } failure:^(NSError *error) {
            [MBProgressHUD hideHUDForView:self.view animated:YES];
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:error.localizedDescription delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alert show];
        }];
    } failure:^(NSError *error) {
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:error.localizedDescription delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
    }];
}



//发送广播通知便于博客列表控制器读取新添加的数据
- (void)sendAddBlogCompleteNotificationWithBlogUrl:(NSString *)url withUserName:(NSString *)userName withPassword:(NSString *)password
{
    NSDictionary *blogInfo = @{@"Url" : url, @"UserName" : userName, @"Password" : password};
    [[NSNotificationCenter defaultCenter] postNotificationName:@"AddBlogCompleteNotification" object:nil userInfo:blogInfo];
}



@end
