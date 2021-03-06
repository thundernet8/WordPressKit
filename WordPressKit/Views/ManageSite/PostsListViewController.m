//
//  PostsListViewController.m
//  WordPressKit
//
//  Created by wuxueqian on 15/10/8.
//  Copyright (c) 2015年 wuxueqian. All rights reserved.
//

#import "PostsListViewController.h"
#import "PostCell.h"
#import "WordPressApi.h"
#import "Blog.h"
#import "DataModel.h"
#import "WPXMLRPCClient.h"
#import "PostControll.h"
#import "NSString+Util.h"
#import "WebBrowserController.h"
#import "MBProgressHUD.h"
#import "NavBarTitleDropdownButton.h"
#import "PostStatusType.h"
#import "FiltersTableViewController.h"
#import "UIImageView+WebCache.h"
#import "SinglePostViewController.h"

static NSInteger const syncTimeInterval = 300;
NSInteger const numOfPostsPerPageA = 10;
NSUInteger pageA = 1;//当前页码
static NSString * postType = @"post";
NSString * postStatusA = @"publish";
static NSString * postStatusText = @"已发布";
const CGFloat tableViewInsertTop = 64.0;
const CGFloat tableViewInsertBottom = 49.0;

@interface PostsListViewController () <UITableViewDelegate, UITableViewDataSource, PostCellDelegate, UIPopoverControllerDelegate>

@property (nonatomic, strong) NSArray *postStatusFilters;
@property (nonatomic) NSInteger postStatusIndex;

@property (weak, nonatomic) IBOutlet NavBarTitleDropdownButton *filterButton;
@property (nonatomic, strong) UIPopoverController *postFilterPopoverController;

- (IBAction)didTapFilterButton:(id)sender;

@end

@implementation PostsListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self addNotificationObserver];
    [self configVariable];
    [self updateFilter];
    [self configureNavbar];
    [self configureNavBackButton];
    [self addSCPullRefreshBlocks];
    [self fetchPostsFromDB];
    //隐藏添加文章按钮，待用
    self.navigationItem.rightBarButtonItem = nil;
}

- (void)loadView {
    [super loadView];
    //顶部导航预留空间
    self.tableViewInsertTop = tableViewInsertTop;
    //底部选项卡预留空间
    self.tableViewInsertBottom = tableViewInsertBottom;
    [self configureTableView];
}


- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    if (self.pc.posts.count == 0) {
        [PostControll syncPostsWithBlog:self.blog postType:postType page:pageA];
    }else if (self.pc.posts.count <= numOfPostsPerPageA) {
        [self.pc needsSyncPostsForBlog:self.blog forTimeInterval:syncTimeInterval postType:postType];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    [[SDImageCache sharedImageCache] setValue:nil forKey:@"memCache"];
}

#pragma mark - Table view data source and delegate

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.pc.posts ? [self.pc.posts count] : 0;
}

- (PostCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSLog(@"cellforrowatindexpath");
    PostCell *cell = [self configCellNib:indexPath];
    [self configCellStyle:cell];
    [self configCellContent:cell atIndexPath:indexPath];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 62.0;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    Post *post = self.pc.posts[indexPath.row];
    Blog *blog = self.blog;
    NSDictionary *sender = @{@"blog":blog,@"post":post};
    [self performSegueWithIdentifier:@"ViewPost" sender:sender];
}


#pragma mark - configuration
- (void)configureNavbar
{
    self.navigationItem.titleView = self.filterButton;
    //配置即将push的VC的导航返回按钮的文字(只能在父级中配置)
    UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithTitle:@"返回" style:UIBarButtonItemStylePlain target:nil action:nil];
    self.navigationItem.backBarButtonItem = backButton;
    [self updateFilterTitle];
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

- (void)configureTableView
{
    //init
    self.tableView = [[UITableView alloc] initWithFrame:self.view.frame];
    self.tableView.backgroundColor = kBackgroundColorLightGray;
    
    //delegate
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    
    self.tableView.accessibilityIdentifier = @"PostsTable";
    self.tableView.isAccessibilityElement = YES;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.view addSubview:self.tableView];
    
    // Register the cells
    UINib *postTextCellNib = [UINib nibWithNibName:@"TextCell" bundle:[NSBundle mainBundle]];
    [self.tableView registerNib:postTextCellNib forCellReuseIdentifier:@"TextCell"];
    
    UINib *postImageCellNib = [UINib nibWithNibName:@"ImageCell" bundle:[NSBundle mainBundle]];
    [self.tableView registerNib:postImageCellNib forCellReuseIdentifier:@"ImageCell"];
}

/**
 *  根据预加载的post特色图是否存在选择不同类型Nib模板
 *
 *  @param indexPath cell的indexPath
 */
- (PostCell *)configCellNib:(NSIndexPath *)indexPath
{
    Post *post = self.pc.posts[indexPath.row];
    NSNumber *thumb = post.postThumbnailID;
    NSString *thumbPath = post.postThumbnailPath;
    NSString *cellIdentifier = (thumb > 0 && ![thumbPath isEqualToString:@""]) ? @"ImageCell" : @"TextCell";
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
    self.postStatusIndex = 0;
    self.pc = [[PostControll alloc] initWithBlog:self.blog];
    self.postStatusFilters = [PostStatusType newPostStatusFilterWithPostType:postType];
}

/**
 *  配置cell的内容显示
 *
 *  @param cell      PostCell对象
 *  @param indexPath cell的indexPath
 */
- (void)configCellContent:(PostCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    Post *post = self.pc.posts[indexPath.row];
    [cell configCellWithPost:post inBlog:self.blog];
    cell.delegate = self;
}


#pragma mark - cell delegate methods

- (void)cell:(PostCell *)cell receivedEditActionForProvider:(Post *)post
{
    [self editPost:post];
}

- (void)cell:(PostCell *)cell receivedViewActionForProvider:(Post *)post
{
    [self viewPost:post];
}

- (void)cell:(PostCell *)cell receivedPublishActionForProvider:(Post *)post
{
    [self publishPost:post];
}

- (void)cell:(PostCell *)cell receivedTrashActionForProvider:(Post *)post
{
    [self deletePost:post];
}

- (void)cell:(PostCell *)cell receivedRestoreActionForProvider:(Post *)post
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

- (void)previewEditPost:(Post *)post
{
    [self editPost:post withEditMode:@"preview"];
}

- (void)editPost:(Post *)post
{
    [self editPost:post withEditMode:@"edit"];
}

- (void)viewPost:(Post *)post
{
    NSString *url = [post.URL absoluteString];
    [self performSegueWithIdentifier:@"PreviewPost" sender:url];
}


- (void)editPost:(Post *)post withEditMode:(NSString *)mode
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

- (void)publishPost:(Post *)post
{
    
}

- (void)deletePost:(Post *)post
{
    
}

- (void)restorePost:(Post *)post
{
    
}

#pragma mark - segue
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"PreviewPost"]) {
        WebBrowserController *controller = segue.destinationViewController;
        controller.url = sender;
    }else if ([segue.identifier isEqualToString:@"ViewPost"]){
        SinglePostViewController *controller = segue.destinationViewController;
        controller.blog = [sender objectForKey:@"blog"];
        controller.post = [sender objectForKey:@"post"];
    }
}


#pragma mark - hud
- (void)addHud
{
    //if (!self.pc.posts || self.pc.posts.count == 0) {
        //添加指示器
        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        hud.mode = MBProgressHUDAnimationFade;
        hud.labelText = @"加载中···";
    //}
}

- (void)removeHud
{
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
    });
}

#pragma mark - notification

- (void)addNotificationObserver
{
    //监听来自PostControll广播通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(writePostsToDBNotificationCallback:) name:@"writePostsToDBNotification" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(queryedDBPostsNotificationCallback:) name:@"queryedDBPostsNotification" object:nil];
}

- (void)writePostsToDBNotificationCallback:(NSNotification *)notification
{
    NSDictionary *info = [notification userInfo];
    NSNumber *insertedPostsNum = [info objectForKey:@"insertedPostsNum"];
    BOOL netWorkOk = [[info objectForKey:@"netWorkOk"] boolValue];
    if (!netWorkOk) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"\r\n网络连接或博客服务器存在问题,更新失败\r\n" delegate:nil cancelButtonTitle:@"确认" otherButtonTitles:nil, nil];
        [self removeHud];
        [alert show];
    }
    if ([insertedPostsNum intValue] > 0 && ![self isLoadingMore]) {
        [self.pc getDBPostsofType:postType postStatus:postStatusA ForBlog:self.blog number:numOfPostsPerPageA];
        [self fetchPostsFromDB];
    }else if ([self isLoadingMore]){
        [self hasSyncMorePosts];
    }else if ([self isRefreshing]){
        if ([insertedPostsNum intValue] == 0) {
            [MBProgressHUD hideHUDForView:self.view animated:NO];
            MBProgressHUD *textHud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
            textHud.mode = MBProgressHUDModeText;
            textHud.labelText = @"已经是最新了";
            [textHud hide:YES afterDelay:1.5];
        }
        [self endRefresh];
    }
    
    //[self endLoadMore];
    [self removeHud];
}

- (void)queryedDBPostsNotificationCallback:(NSNotification *)notification
{
    //NSDictionary *info = [notification userInfo];
    //NSNumber *postsCount = [info valueForKey:@"queryedDBPostsCount"];
    if (self.pc.posts.count > 0) {
        [self removeHud];
    }
    //if (self.pc.posts.count > 0 && ![self isLoadingMore]) {
    if (![self isLoadingMore]) {
        [self.tableView reloadData];
    }
    if ([self isRefreshing]) {
        [self endRefresh];
    }
}

#pragma mark - SCPullRefresh Blocks

- (void)addSCPullRefreshBlocks
{
    __weak typeof(PostsListViewController) *weakSelf = self;
    
    self.refreshBlock = ^{
        
        __strong typeof(PostsListViewController) *strongSelf = weakSelf;
        
        //[strongSelf performSelector:@selector(endRefresh) withObject:strongSelf afterDelay:2.0];
        [PostControll syncPostsWithBlog:strongSelf.blog postType:postType page:pageA];
        
    };
    
    self.loadMoreBlock = ^{

        __strong typeof(PostsListViewController) *strongSelf = weakSelf;
        
        NSArray *morePosts = [strongSelf.pc loadMoreDBPostsofType:postType postStatus:postStatusA ForBlog:strongSelf.blog page:pageA+1];
        if (morePosts && morePosts.count >= numOfPostsPerPageA) {
            [strongSelf appendMorePosts:morePosts];
            [strongSelf endLoadMore];
            pageA++;
        }else{
            [PostControll syncPostsWithBlog:strongSelf.blog postType:postType page:pageA+1];
        }
        //[strongSelf performSelector:@selector(endLoadMore) withObject:strongSelf afterDelay:2.0];
    };
}

- (void)appendMorePosts:(NSArray *)morePosts
{
    int64_t delayInSeconds = 0.5;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void) {
        NSInteger addNum = morePosts?morePosts.count:0;
        NSMutableArray *indexPaths = [NSMutableArray array];
        NSInteger currentCount = self.pc.posts.count-addNum;
        for (int i = 0; i < addNum; i++) {
            [indexPaths addObject:[NSIndexPath indexPathForRow:currentCount+i inSection:0]];
        }
        [self.tableView beginUpdates];
        [self.tableView insertRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationFade];
        [self.tableView endUpdates];
        [self.tableView scrollToRowAtIndexPath:[indexPaths firstObject] atScrollPosition:UITableViewScrollPositionTop animated:YES];
        //[self.tableView layoutIfNeeded];
    });
}

- (void)hasSyncMorePosts
{
    NSArray *morePosts = [self.pc loadMoreDBPostsofType:postType postStatus:postStatusA ForBlog:self.blog page:pageA+1];
    if (morePosts && morePosts.count > 0) {
        [self appendMorePosts:morePosts];
        [self endLoadMore];
        pageA++;
    }else{
        [MBProgressHUD hideHUDForView:self.view animated:NO];
        MBProgressHUD *textHud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        textHud.mode = MBProgressHUDModeText;
        textHud.labelText = @"没有更多了";
        [textHud hide:YES afterDelay:1.5];
        [self endLoadMore];
    }
}



#pragma mark - dealloc
- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - Nav Filter Button
- (IBAction)didTapFilterButton:(id)sender
{
    if (self.postFilterPopoverController) {
        return;
    }
    [self displayFiltersView];
}

#pragma mark - noresults view
- (void)dealNoPostsView
{
    //********************//:-(
    [self removeNoPostsView];
    UIView *noCommentsView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 160.0)];
    noCommentsView.tag = 8;
    UILabel *emotion = [[UILabel alloc] initWithFrame:CGRectMake(0, 30.0, noCommentsView.frame.size.width, 100.0)];
    emotion.font = [UIFont systemFontOfSize:36.0];
    emotion.textColor = [UIColor colorWithRed:225/255.0 green:225/255.0 blue:225/255.0 alpha:1.0];
    emotion.text = @":-(\r\nNo Posts";
    emotion.numberOfLines = 0;
    emotion.textAlignment = NSTextAlignmentCenter;
    [noCommentsView addSubview:emotion];
    [self.tableView addSubview:noCommentsView];
    
}

- (void)removeNoPostsView
{
    if ([self.view viewWithTag:8]) {
        [[self.view viewWithTag:8] removeFromSuperview];
    }
}

#pragma mark - post status filter
- (void)updateFilter
{
    PostStatusType *filter = [self currentPostStatusFilter];
    self.postStatusIndex = [self currentPostStatusFilterIndex];
    postStatusA = filter.postStatus;
    postStatusText = filter.postStatusText;
}

- (PostStatusType *)currentPostStatusFilter
{
    return self.postStatusFilters[[self currentPostStatusFilterIndex]];
}

- (NSInteger)currentPostStatusFilterIndex
{
    NSNumber *index = [[NSUserDefaults standardUserDefaults] objectForKey:@"PostStatusFilterIndex"];
    if (!index || [index integerValue] >= [self.postStatusFilters count]) {
        return 0;
    }
    return [index integerValue];
}

- (void)updateFilterTitle
{
    [self.filterButton setAttributedTitleForTitle:postStatusText];
}

- (void)setCurrentFilterIndex:(NSInteger)newIndex
{
    NSInteger index = [self currentPostStatusFilterIndex];
    if (newIndex == index) {
        return;
    }
    [[NSUserDefaults standardUserDefaults] setObject:@(newIndex) forKey:@"PostStatusFilterIndex"];
    [NSUserDefaults resetStandardUserDefaults];
    [self updateFilter];
    [self updateFilterTitle];

    [self fetchPostsFromDB];
}


#pragma mark - filter view controll
- (void)displayFiltersView
{
    FiltersTableViewController *controller = [[FiltersTableViewController alloc] initWithStyle:UITableViewStylePlain andFilters:self.postStatusFilters andCurrentIndex:[self currentPostStatusFilterIndex]];
    controller.onItemSelected = ^(NSNumber *selectedIndex) {
        if (self.postFilterPopoverController) {
            [self.postFilterPopoverController dismissPopoverAnimated:YES];
            self.postFilterPopoverController = nil;
        } else {
            [self dismissViewControllerAnimated:YES completion:nil];
        }
        [self setCurrentFilterIndex:[selectedIndex integerValue]];
    };
    controller.onCancel = ^() {
        [self handleFilterSelectionCanceled];
    };
    
    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:controller];
    if (IS_IPAD) {
        [self displayFilterPopover:navController];
    } else {
        [self displayFilterModal:navController];
    }
}

- (void)displayFilterPopover:(UIViewController *)controller
{
    controller.preferredContentSize = CGSizeMake(320.0, 264.0);
    
    CGRect titleRect = self.navigationItem.titleView.frame;
    titleRect = [self.navigationController.view convertRect:titleRect fromView:self.navigationItem.titleView.superview];
    
    self.postFilterPopoverController = [[UIPopoverController alloc] initWithContentViewController:controller];
    self.postFilterPopoverController.delegate = self;
    [self.postFilterPopoverController presentPopoverFromRect:titleRect
                                                      inView:self.navigationController.view
                                    permittedArrowDirections:UIPopoverArrowDirectionAny
                                                    animated:YES];
}

- (void)displayFilterModal:(UIViewController *)controller
{
    controller.modalPresentationStyle = UIModalPresentationPageSheet;
    controller.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
    [self presentViewController:controller animated:YES completion:nil];
}
         
- (void)handleFilterSelectionCanceled
{
    if (self.postFilterPopoverController) {
        [self popoverControllerDidDismissPopover:self.postFilterPopoverController];
    }
}

#pragma mark - UIPopover Delegate Methods

- (void)popoverControllerDidDismissPopover:(UIPopoverController *)popoverController
{
    self.postFilterPopoverController.delegate = nil;
    self.postFilterPopoverController = nil;
}

#pragma mark - fetch posts

- (void)fetchPostsFromDB
{
    [self addHud];
    [self.pc getDBPostsofType:postType postStatus:postStatusA ForBlog:self.blog number:numOfPostsPerPageA];
}
         

         
         
         
         
         
         
         
         
         
         
         
         
         
         
         
         
         
         
         
         
         
@end
