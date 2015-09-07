//
//  FuncItemViewController.m
//  WordPressKit
//
//  Created by wuxueqian on 15/8/26.
//  Copyright (c) 2015年 wuxueqian. All rights reserved.
//

#import "FuncItemViewController.h"
#import "FuncItem.h"

@interface FuncItemViewController ()
@property (strong, nonatomic) IBOutlet UIScrollView *scrollView;

@end

@implementation FuncItemViewController

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden = NO;
    
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    //[self.scrollView setContentSize:CGSizeMake(320.0, 1800.0)];
    [self.scrollView setContentSize:CGSizeMake(self.view.frame.size.width, [self.view viewWithTag:1102].frame.size.height + [self.view viewWithTag:1103].frame.size.height + [self.view viewWithTag:1104].frame.size.height + [self.view viewWithTag:1105].frame.size.height + [self.view viewWithTag:1106].frame.size.height + [self.view viewWithTag:1107].frame.size.height + [self.view viewWithTag:1108].frame.size.height + 390)];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    //配置文字
    [self configText];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

// 配置各模块的文字
- (void)configText
{
    FuncItem *funcItem = [[FuncItem alloc] init];
    funcItem = self.funcItem;
    //标题与函数名
    self.title = funcItem.name;
    UILabel *nameLabel = (UILabel *)[self.view viewWithTag:1101];
    nameLabel.text = funcItem.name;
    //描述
    UITextView *desText = (UITextView *)[self.view viewWithTag:1102];
    desText.text = funcItem.des;
    //使用
    UITextView *usageText = (UITextView *)[self.view viewWithTag:1103];
    usageText.text = funcItem.usage;
    //参数
    UITextView *parameterText = (UITextView *)[self.view viewWithTag:1104];
    parameterText.text = funcItem.parameters;
    //返回值
    UITextView *returnValueText = (UITextView *)[self.view viewWithTag:1105];
    returnValueText.text = funcItem.returnValue;
    //注意
    UITextView *noteText = (UITextView *)[self.view viewWithTag:1106];
    noteText.text = funcItem.notes;
    //变更日志
    UITextView *changeLogText = (UITextView *)[self.view viewWithTag:1107];
    changeLogText.text = funcItem.changeLog;

    //源文件
    UITextView *sourceFileText = (UITextView *)[self.view viewWithTag:1108];
    //html格式化
    NSString *str = [NSString stringWithFormat:@"%@ is located in <a id=\"sourfile_trigger\" href=\"javascript:\">%@</a>", funcItem.name, funcItem.sourceFile];
    NSAttributedString *astr = [[NSAttributedString alloc] initWithData:[str dataUsingEncoding:NSUTF8StringEncoding] options:@{NSDocumentTypeDocumentAttribute:NSHTMLTextDocumentType} documentAttributes:nil error:nil];
    sourceFileText.attributedText = astr;
    
    
}

@end
