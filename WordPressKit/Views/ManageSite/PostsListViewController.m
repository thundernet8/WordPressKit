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

NSInteger const syncTimeInterval = 300;
NSInteger const numOfPostsPerPage = 10;
NSUInteger page = 1;
NSString * postType = @"post";
NSInteger postStatusIndex = 0;
NSString * postStatus = @"publish";
NSString * postStatusText = @"已发布";
CGFloat tableViewInsertTop = 64.0;
CGFloat tableViewInsertBottom = 49.0;

@interface PostsListViewController () <UITableViewDelegate, UITableViewDataSource, PostCellDelegate, UIPopoverControllerDelegate>

@property (nonatomic, strong) NSArray *postStatusFilters;

@property (weak, nonatomic) IBOutlet NavBarTitleDropdownButton *filterButton;
@property (nonatomic, strong) UIPopoverController *postFilterPopoverController;

- (IBAction)didTapFilterButton:(id)sender;

- (void)configureNavbar;
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
- (void)addSCPullRefreshBlocks;
- (void)updateFilter;
- (PostStatusType *)currentPostStatusFilter;
- (NSInteger)currentPostStatusFilterIndex;
- (void)updateFilterTitle;
- (void)displayFiltersView;
- (void)setCurrentFilterIndex:(NSInteger)newIndex;
- (void)fetchPostsFromDBWithReloadTableView:(BOOL)reloadTableView;

- (void)appendMorePosts:(NSArray *)morePosts;

@end

@implementation PostsListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self addNotificationObserver];
    [self configVariable];
    [self updateFilter];
    [self configureNavbar];
    //[self configureTableView];
    //[self addHud];
    [self addSCPullRefreshBlocks];
    

    [self fetchPostsFromDBWithReloadTableView:NO];
    
    NSLog(@"viewDidLoad");
    
    
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
    NSLog(@"view appear");
    if (self.pc.posts.count <= numOfPostsPerPage) {
        [self.pc needsSyncPostsForBlog:self.blog forTimeInterval:syncTimeInterval postType:postType];
        page = ceil((double)(self.pc.posts.count*1.0/numOfPostsPerPage));
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
    [[SDImageCache sharedImageCache] setValue:nil forKey:@"memCache"];
}

#pragma mark - Table view data source and delegate

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    //NSLog(@"numberOfRowsInSection:");
    return self.pc.posts ? [self.pc.posts count] : 0;
}

- (PostCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    //NSLog(@"cellforrowatindexpath");
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


#pragma mark - configuration
- (void)configureNavbar
{
    self.navigationItem.titleView = self.filterButton;
    [self updateFilterTitle];
}

- (void)configureTableView
{
    //init
    self.tableView = [[UITableView alloc] initWithFrame:self.view.frame];
    self.tableView.backgroundColor = kBackgroundColorLightBlue;
    
    //delegate
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    
    self.tableView.accessibilityIdentifier = @"PostsTable";
    self.tableView.isAccessibilityElement = YES;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.view addSubview:self.tableView];
    
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
    RemotePost *post = self.pc.posts[indexPath.row];
    
    [cell configCellWithPost:post inBlog:self.blog];
    
    //cell delegate
    cell.delegate = self;
    
}


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
    NSNumber *chagedPostsNum = [info objectForKey:@"chagedPostsNum"];
    BOOL netWorkOk = [[info objectForKey:@"netWorkOk"] boolValue];
    if (!netWorkOk) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"\r\n网络连接或博客服务器存在问题,更新失败\r\n" delegate:nil cancelButtonTitle:@"确认" otherButtonTitles:nil, nil];
        [alert show];
    }
    if ([chagedPostsNum intValue] > 0 && ![self isLoadingMore]) {
        [self.pc getDBPostsofType:postType postStatus:postStatus ForBlog:self.blog number:numOfPostsPerPage];
        dispatch_async(dispatch_get_main_queue(), ^{
            //[self endRefresh];
            [self.tableView reloadData];
        });
    }else if ([self isLoadingMore]){
        [self hasSyncMorePosts];
    }
    [self endRefresh];
    //[self endLoadMore];
    //[self removeHud];
}

- (void)queryedDBPostsNotificationCallback:(NSNotification *)notification
{
    //NSDictionary *info = [notification userInfo];
    //NSNumber *postsCount = [info valueForKey:@"queryedDBPostsCount"];
    [self removeHud];
}

#pragma mark - SCPullRefresh Blocks

- (void)addSCPullRefreshBlocks
{
    __weak typeof(PostsListViewController) *weakSelf = self;
    
    self.refreshBlock = ^{
        
        __strong typeof(PostsListViewController) *strongSelf = weakSelf;
        
        //[strongSelf performSelector:@selector(endRefresh) withObject:strongSelf afterDelay:2.0];
        [PostControll syncPostsWithBlog:strongSelf.blog postType:postType page:page];
        
    };
    
    self.loadMoreBlock = ^{

        __strong typeof(PostsListViewController) *strongSelf = weakSelf;
        
        NSArray *morePosts = [strongSelf.pc loadMoreDBPostsofType:postType postStatus:postStatus ForBlog:strongSelf.blog page:page+1];
        if (morePosts && morePosts.count >= numOfPostsPerPage) {
            [strongSelf appendMorePosts:morePosts];
            [strongSelf endLoadMore];
            page++;
        }else{
            [PostControll syncPostsWithBlog:strongSelf.blog postType:postType page:page+1];
        }
        //[strongSelf performSelector:@selector(endLoadMore) withObject:strongSelf afterDelay:2.0];
    };
}

- (void)appendMorePosts:(NSArray *)morePosts
{
    int64_t delayInSeconds = 2.0;
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
    NSArray *morePosts = [self.pc loadMoreDBPostsofType:postType postStatus:postStatus ForBlog:self.blog page:page+1];
    if (morePosts && morePosts.count > 0) {
        [self appendMorePosts:morePosts];
        [self endLoadMore];
        page++;
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

#pragma mark - post status filter
- (void)updateFilter
{
    PostStatusType *filter = [self currentPostStatusFilter];
    postStatusIndex = [self currentPostStatusFilterIndex];
    postStatus = filter.postStatus;
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

    [self fetchPostsFromDBWithReloadTableView:YES];
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

- (void)fetchPostsFromDBWithReloadTableView:(BOOL)reloadTableView
{
    [self addHud];
    [self.pc getDBPostsofType:postType postStatus:postStatus ForBlog:self.blog number:numOfPostsPerPage];
    if (reloadTableView) {
        [self.tableView reloadData];
    }
}
         

         
         
         
         
         
         
         
         
         
         
         
         
         
         
         
         
         
         
         
         
         
@end
