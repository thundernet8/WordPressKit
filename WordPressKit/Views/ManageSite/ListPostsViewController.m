//
//  ListPostsViewController.m
//  WordPressKit
//
//  Created by wuxueqian on 15/9/21.
//  Copyright (c) 2015年 wuxueqian. All rights reserved.
//

#import "ListPostsViewController.h"
#import "PostCell.h"
#import "WordPressApi.h"
#import "Blog.h"
#import "DataModel.h"
#import "WPXMLRPCClient.h"
#import "PostControll.h"
#import "NSString+Util.h"

BOOL fetched = NO;
NSInteger const syncTimeInterval = 300;
NSString *const postType = @"post";
NSString *const postStatus = @"publish";


@interface ListPostsViewController ()


- (void)configureTableView;
- (PostCell *)configCellNib:(NSIndexPath *)indexPath;
- (void)configCellStyle:(PostCell *)cell;
- (void)configVariable;
- (void)configCellContent:(PostCell *)cell atIndexPath:(NSIndexPath *)indexPath;
@property (nonatomic) int *cnt;

@end

@implementation ListPostsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self configVariable];
    [self configureTableView];
    
    
    [self.pc getDBPostsofType:postType postStatus:postStatus ForBlog:self.blog number:10];

    //[self.pc needsSyncPostsForBlog:self.blog forTimeInterval:syncTimeInterval postType:postType];

    NSLog(@"viewDidLoad");
    
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source and delegate

//节数
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

//行数
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSLog(@"numberOfRowsInSection:");
    return [self.pc.posts count];
}

//cell实例化
- (PostCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    PostCell *cell = [self configCellNib:indexPath];
    [self configCellStyle:cell];
    [self configCellContent:cell atIndexPath:indexPath];
    NSLog(@"cellforrowatindexpath");
//    //
//    [PostControll getPostsOfType:@"post" forBlog:self.blog options:@{@"post_status":@"publish",@"number":@5} success:^(NSArray *posts) {
//        
//        //配置post cell内容
////        RemotePost *post = [posts objectAtIndex:indexPath.row];
////        cell.postCellPostTitle.text = post.title;
////        cell.postCellPostContent.attributedText = [[NSAttributedString alloc] initWithData:[post.content dataUsingEncoding:NSUnicodeStringEncoding] options:@{ NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType } documentAttributes:nil error:nil];
////        cell.postCellThumb.image = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:post.postThumbnailPath]]];
////        cell.postCellPostDate.text = [NSString stringWithFormat:@"%@",post.date];
//        
//        
//        
//        
//    } failure:^(NSError *error) {
//        NSLog(@"oh no");
//    }];
    
    // Post Cell头部配置
    cell.postCellBlogName.text = self.blog.name;
    
    
    return cell;
}

//即将显示cell
- (void)tableView:(UITableView *)tableView willDisplayCell:(PostCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath{
    //去掉cell背景
    cell.backgroundColor = [UIColor clearColor];
    //cell边框阴影效果
    UIView *view = cell.postCellWrapper;
    UIBezierPath *shadowPath = [UIBezierPath bezierPathWithRect:CGRectMake(view.bounds.origin.x, view.bounds.origin.y, cell.bounds.size.width-8, cell.bounds.size.height-21)];
    view.layer.masksToBounds = NO;
    view.layer.shadowColor = [UIColor colorWithRed:89/255.0 green:120/255.0 blue:144/255.0 alpha:1.0].CGColor;
    view.layer.shadowOffset = CGSizeMake(0.0f, 0.0f);
    view.layer.shadowOpacity = 0.2f;
    view.layer.shadowPath = shadowPath.CGPath;

}

//cell 高度
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    //PostCell *cell = (PostCell *)[self tableView:tableView cellForRowAtIndexPath:indexPath];
    //PostCell *cell = [self configCellNib:indexPath];
//    //cell 高度
//    CGRect titleRect = [cell.postCellPostTitle.text boundingRectWithSize:CGSizeMake([UIScreen mainScreen].bounds.size.width - 24.0, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName : [UIFont fontWithName:@"Georgia" size:16.0]} context:nil];
//    CGRect contentRect = [cell.postCellPostContent.text boundingRectWithSize:CGSizeMake([UIScreen mainScreen].bounds.size.width - 24.0, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName : [UIFont fontWithName:@"Georgia" size:14.0]} context:nil];
//    CGFloat thumbHeight = 0.75 * ([UIScreen mainScreen].bounds.size.width - 8);
//    CGFloat height = 188.0 + titleRect.size.height + contentRect.size.height + thumbHeight;
    //return height;
    NSLog(@"heightForRowAtIndexPath:");
    //return CGRectGetHeight(cell.frame);
    RemotePost *post = self.pc.posts[indexPath.row];
    PostCell *cell;
    if ([post.postThumbnailPath isEmpty]) {
        cell = (PostCell *)[[[NSBundle mainBundle] loadNibNamed:@"PostTextCell" owner:nil options:nil] firstObject];
        return 350;
    }else{
        cell = (PostCell *)[[[NSBundle mainBundle] loadNibNamed:@"PostImageCell" owner:nil options:nil] firstObject];
    }
    //[self forceUpdateCellLayout:textCellForLayout];
    CGSize size = [cell sizeThatFits:CGSizeMake([UIScreen mainScreen].bounds.size.width - 12, CGFLOAT_MAX)];
    CGFloat height = ceil(size.height);
    return 520;
}


/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark - configuration
- (void)configureTableView
{
    self.tableView.accessibilityIdentifier = @"PostsTable";
    self.tableView.isAccessibilityElement = YES;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    // Register the cells
    UINib *postTextCellNib = [UINib nibWithNibName:@"PostTextCell" bundle:[NSBundle mainBundle]];
    [self.tableView registerNib:postTextCellNib forCellReuseIdentifier:@"PostTextCell"];
    
    UINib *postImageCellNib = [UINib nibWithNibName:@"PostImageCell" bundle:[NSBundle mainBundle]];
    [self.tableView registerNib:postImageCellNib forCellReuseIdentifier:@"PostImageCell"];
    
}

/**
 *  根据预加载的post特色图是否存在选择不同类型Nib模板
 *
 *  @param indexPath cell的indexPath
 */
- (PostCell *)configCellNib:(NSIndexPath *)indexPath
{
    RemotePost *post = self.pc.posts[indexPath.row];
    NSNumber *thumb = post.postThumbnailID;
    NSString *thumbPath = post.postThumbnailPath;
    NSLog(@"call times is %i",(int)self.cnt);
    self.cnt++;
    NSString *cellIdentifier = (thumb > 0 && ![thumbPath isEqualToString:@""]) ? @"PostImageCell" : @"PostTextCell";
    PostCell *cell = [self.tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    return cell;

}

/**
 *  配置cell的样式
 *
 *  @param cell PostCell对象
 */
- (void)configCellStyle:(PostCell *)cell
{
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
}

/**
 *  配置view的基本变量获取
 */
- (void)configVariable
{
    self.pc = [[PostControll alloc] initWithBlog:self.blog];
}

/**
 *  配置cell的内容显示
 *
 *  @param cell      PostCell对象
 *  @param indexPath cell的indexPath
 */
- (void)configCellContent:(PostCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    RemotePost *post = self.pc.posts[indexPath.row];

    [cell configCellWithPost:post inBlog:self.blog];
    CGSize size = [cell sizeThatFits:CGSizeMake([UIScreen mainScreen].bounds.size.width - 12, CGFLOAT_MAX)];
    CGFloat height = ceil(size.height);
}




- (void)configureCellsForLayout
{
    PostCell *textCellForLayout = (PostCell *)[[[NSBundle mainBundle] loadNibNamed:@"PostTextCell" owner:nil options:nil] firstObject];
    [self forceUpdateCellLayout:textCellForLayout];
    
    PostCell *imageCellForLayout = (PostCell *)[[[NSBundle mainBundle] loadNibNamed:@"PostImageCell" owner:nil options:nil] firstObject];
    [self forceUpdateCellLayout:imageCellForLayout];
}

- (void)forceUpdateCellLayout:(PostCell *)cell
{
    // Force a layout pass to ensure that constrants are configured for the
    // proper size class.
    [self.view addSubview:cell];
    [cell updateConstraintsIfNeeded];
    [cell layoutIfNeeded];
    [cell removeFromSuperview];
}








@end
