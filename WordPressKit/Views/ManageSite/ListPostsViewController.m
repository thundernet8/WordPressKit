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
#import "WebBrowserController.h"
#import "MBProgressHUD.h"

BOOL fetched = NO;
NSInteger const syncTimeInterval = 300;
NSString *const postType = @"post";
NSString *const postStatus = @"publish";


@interface ListPostsViewController () <PostCellDelegate>


- (void)configureTableView;
- (PostCell *)configCellNib:(NSIndexPath *)indexPath;
- (void)configCellStyle:(PostCell *)cell;
- (void)configVariable;
- (void)configCellContent:(PostCell *)cell atIndexPath:(NSIndexPath *)indexPath;
- (void)editPost:(RemotePost *)post;
- (void)viewPost:(RemotePost *)post;
- (void)publishPost:(RemotePost *)post;
- (void)deletePost:(RemotePost *)post;
- (void)restorePost:(RemotePost *)post;
- (void)addHud;
- (void)removeHud;
- (void)addNotificationObserver;

@end

@implementation ListPostsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self configVariable];
    [self configureTableView];
    [self addHud];
    
    [self.pc getDBPostsofType:postType postStatus:postStatus ForBlog:self.blog number:10];

    //[self.pc needsSyncPostsForBlog:self.blog forTimeInterval:syncTimeInterval postType:postType];

    NSLog(@"viewDidLoad");
    
    
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    NSLog(@"view appear");
    [self addNotificationObserver];
    [self.pc needsSyncPostsForBlog:self.blog forTimeInterval:syncTimeInterval postType:postType];
//    if (self.pc.chagedPostsNum != 0) {
//        [self.tableView reloadData];
//    }
    [self removeHud];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source and delegate

//行数
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSLog(@"numberOfRowsInSection:");
    return self.pc.posts ? [self.pc.posts count] : 0;
}

//cell实例化
- (PostCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSLog(@"cellforrowatindexpath");
    PostCell *cell = [self configCellNib:indexPath];
    [self configCellStyle:cell];
    [self configCellContent:cell atIndexPath:indexPath];
    
    return cell;
}

//即将显示cell
- (void)tableView:(UITableView *)tableView willDisplayCell:(PostCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath{
    //去掉cell背景
    //cell.backgroundColor = [UIColor clearColor];
    //cell边框阴影效果
//    UIView *view = cell.postCellWrapper;
//    UIBezierPath *shadowPath = [UIBezierPath bezierPathWithRect:CGRectMake(view.bounds.origin.x, view.bounds.origin.y, cell.bounds.size.width-8, cell.bounds.size.height-21)];
//    view.layer.masksToBounds = NO;
//    view.layer.shadowColor = [UIColor colorWithRed:89/255.0 green:120/255.0 blue:144/255.0 alpha:1.0].CGColor;
//    view.layer.shadowOffset = CGSizeMake(0.0f, 0.0f);
//    view.layer.shadowOpacity = 0.2f;
//    view.layer.shadowPath = shadowPath.CGPath;

}

/**
 *  预估cell高度，减少不必要的heightForRowAtIndexPath的调用
 *
 *  @param tableView tableView
 *  @param indexPath indexPath
 *
 *  @return 预估的cell高度值
 */
- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    RemotePost *post = self.pc.posts[indexPath.row];
    if ([post.postThumbnailPath isEmpty]) {
        return 324.0;
    }
    return 536.0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    NSLog(@"heightForRowAtIndexPath:");
    //return CGRectGetHeight(cell.frame);
    RemotePost *post = self.pc.posts[indexPath.row];
    PostCell *cell;
    if ([post.postThumbnailPath isEmpty]) {
        cell = (PostCell *)[[[NSBundle mainBundle] loadNibNamed:@"PostTextCell" owner:nil options:nil] firstObject];
    }else{
        cell = (PostCell *)[[[NSBundle mainBundle] loadNibNamed:@"PostImageCell" owner:nil options:nil] firstObject];
    }
    [self configCellContent:cell atIndexPath:indexPath];
    CGSize size = [cell sizeThatFits:CGSizeMake([UIScreen mainScreen].bounds.size.width - 12, CGFLOAT_MAX)];
    CGFloat height = ceil(size.height);
    return height;
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
    
    //cell delegate
    cell.delegate = self;
    
}




//- (void)configureCellsForLayout
//{
//    PostCell *textCellForLayout = (PostCell *)[[[NSBundle mainBundle] loadNibNamed:@"PostTextCell" owner:nil options:nil] firstObject];
//    [self forceUpdateCellLayout:textCellForLayout];
//    
//    PostCell *imageCellForLayout = (PostCell *)[[[NSBundle mainBundle] loadNibNamed:@"PostImageCell" owner:nil options:nil] firstObject];
//    [self forceUpdateCellLayout:imageCellForLayout];
//}
//
//- (void)forceUpdateCellLayout:(PostCell *)cell
//{
//    // Force a layout pass to ensure that constrants are configured for the
//    // proper size class.
//    [self.view addSubview:cell];
//    [cell updateConstraintsIfNeeded];
//    [cell layoutIfNeeded];
//    [cell removeFromSuperview];
//}

#pragma mark - cell delegate methods

- (void)cell:(PostCell *)cell receivedEditActionForProvider:(RemotePost *)post
{
    [self editPost:post];
}

- (void)cell:(PostCell *)cell receivedViewActionForProvider:(RemotePost *)post
{
    [self viewPost:post];
}

- (void)cell:(PostCell *)cell receivedPublishActionForProvider:(RemotePost *)post
{
    [self publishPost:post];
}

- (void)cell:(PostCell *)cell receivedTrashActionForProvider:(RemotePost *)post
{
    [self deletePost:post];
}

- (void)cell:(PostCell *)cell receivedRestoreActionForProvider:(RemotePost *)post
{
    [self restorePost:post];
}

#pragma mark - Post Actions

/*
- (void)createPost
{
    UINavigationController *navController;
    
    if ([WPPostViewController isNewEditorEnabled]) {
        WPPostViewController *postViewController = [[WPPostViewController alloc] initWithDraftForBlog:self.blog];
        navController = [[UINavigationController alloc] initWithRootViewController:postViewController];
        navController.restorationIdentifier = WPEditorNavigationRestorationID;
        navController.restorationClass = [WPPostViewController class];
    } else {
        WPLegacyEditPostViewController *editPostViewController = [[WPLegacyEditPostViewController alloc] initWithDraftForLastUsedBlog];
        navController = [[UINavigationController alloc] initWithRootViewController:editPostViewController];
        navController.restorationIdentifier = WPLegacyEditorNavigationRestorationID;
        navController.restorationClass = [WPLegacyEditPostViewController class];
    }
    
    [navController setToolbarHidden:NO]; // Fixes incorrect toolbar animation.
    navController.modalPresentationStyle = UIModalPresentationFullScreen;
    
    [self presentViewController:navController animated:YES completion:nil];
    
    [WPAnalytics track:WPAnalyticsStatEditorCreatedPost withProperties:@{ @"tap_source": @"posts_view" }];
}
*/

- (void)previewEditPost:(RemotePost *)post
{
    [self editPost:post withEditMode:@"preview"];
}

- (void)editPost:(RemotePost *)post
{
    [self editPost:post withEditMode:@"edit"];
}

- (void)viewPost:(RemotePost *)post
{
    NSString *url = [post.URL absoluteString];
    [self performSegueWithIdentifier:@"PreviewPost" sender:url];
}


- (void)editPost:(RemotePost *)post withEditMode:(NSString *)mode
{
//    if ([WPPostViewController isNewEditorEnabled]) {
//        WPPostViewController *postViewController = [[WPPostViewController alloc] initWithPost:apost mode:mode];
//        postViewController.hidesBottomBarWhenPushed = YES;
//        [self.navigationController pushViewController:postViewController animated:YES];
//    } else {
//        // In legacy mode, view means edit
//        WPLegacyEditPostViewController *editPostViewController = [[WPLegacyEditPostViewController alloc] initWithPost:apost];
//        UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:editPostViewController];
//        [navController setToolbarHidden:NO]; // Fixes incorrect toolbar animation.
//        navController.modalPresentationStyle = UIModalPresentationFullScreen;
//        navController.restorationIdentifier = WPLegacyEditorNavigationRestorationID;
//        navController.restorationClass = [WPLegacyEditPostViewController class];
//        
//        [self presentViewController:navController animated:YES completion:nil];
//    }
}

//- (void)promptThatPostRestoredToFilter:(PostListFilter *)filter
//{
//    NSString *message = NSLocalizedString(@"Post Restored to Drafts", @"Prompts the user that a restored post was moved to the drafts list.");
//    switch (filter.filterType) {
//        case PostListStatusFilterPublished:
//            message = NSLocalizedString(@"Post Restored to Published", @"Prompts the user that a restored post was moved to the published list.");
//            break;
//        case PostListStatusFilterScheduled:
//            message = NSLocalizedString(@"Post Restored to Scheduled", @"Prompts the user that a restored post was moved to the scheduled list.");
//            break;
//        default:
//            break;
//    }
//    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil
//                                                        message:message
//                                                       delegate:nil
//                                              cancelButtonTitle:NSLocalizedString(@"OK", @"Title of an OK button. Pressing the button acknowledges and dismisses a prompt.")
//                                              otherButtonTitles:nil, nil];
//    [alertView show];
//}

- (void)publishPost:(RemotePost *)post
{
    
}

- (void)deletePost:(RemotePost *)post
{
    
}

- (void)restorePost:(RemotePost *)post
{
    
}

#pragma mark - segue
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"PreviewPost"]) {
        WebBrowserController *controller = segue.destinationViewController;
        controller.url = sender;
    }
}


#pragma mark - hud
- (void)addHud
{
    if (!self.pc.posts || self.pc.posts.count == 0) {
        //添加指示器
        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        hud.mode = MBProgressHUDAnimationFade;
        hud.labelText = @"加载中···";
    }
}

- (void)removeHud
{
    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
}

#pragma mark - notification

- (void)addNotificationObserver
{
    //监听来自PostControll广播通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(writePostsToDBNotificationCallback:) name:@"writePostsToDBNotification" object:nil];
}

- (void)writePostsToDBNotificationCallback:(NSNotification *)notification
{
    NSDictionary *info = [notification userInfo];
    NSNumber *chagedPostsNum = [info valueForKey:@"chagedPostsNum"];
    if (chagedPostsNum > 0) {
        [self.pc getDBPostsofType:postType postStatus:postStatus ForBlog:self.blog number:10];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.tableView reloadData];
        });
    }
}

@end
