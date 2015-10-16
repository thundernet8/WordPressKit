//
//  PagesListViewController.m
//  WordPressKit
//
//  Created by wuxueqian on 15/10/13.
//  Copyright (c) 2015年 wuxueqian. All rights reserved.
//

#import "PagesListViewController.h"
#import "PostControll.h"
#import "NavBarTitleDropdownButton.h"
#import "PostStatusType.h"
#import "FiltersTableViewController.h"
#import "MBProgressHUD.h"
#import "WebBrowserController.h"
#import "PageCell.h"
#import "SinglePostViewController.h"

static NSInteger const syncTimeInterval = 600;
NSInteger const numOfPostsPerPageB = 20;
NSUInteger pageB = 1;//当前页码
static NSString * postType = @"page";
NSString * postStatusB = @"publish";
static NSString * postStatusText = @"已发布";
extern const CGFloat tableViewInsertTop;
extern const CGFloat tableViewInsertBottom;

@interface PagesListViewController () <UITableViewDelegate, UITableViewDataSource, UIPopoverControllerDelegate>

@property (nonatomic, strong) NSArray *pageStatusFilters;
@property (nonatomic) NSInteger postStatusIndex;//文章状态过滤器列表当前选中项
@property (strong, nonatomic) IBOutlet NavBarTitleDropdownButton *filterButton;
@property (nonatomic, strong) UIPopoverController *pageFilterPopoverController;
@property (nonatomic, strong) NSArray *walkedPagesResults;

- (IBAction)didTapFilterButton:(id)sender;

@end

@implementation PagesListViewController
- (void)loadView {
    [super loadView];
    //顶部导航预留空间
    self.tableViewInsertTop = tableViewInsertTop;
    //底部选项卡预留空间
    self.tableViewInsertBottom = tableViewInsertBottom;
    [self configureTableView];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self addNotificationObserver];
    [self configVariable];
    [self updateFilter];
    [self configureNavbar];
    [self addSCPullRefreshBlocks];
    [self fetchPostsFromDBWithReloadTableView:NO];
    
    NSLog(@"viewDidLoad");
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    NSLog(@"view appear");
    if (self.pc.posts.count <= numOfPostsPerPageB) {
        [self.pc needsSyncPostsForBlog:self.blog forTimeInterval:syncTimeInterval postType:postType];
    }
    pageB = ceil((double)(self.pc.posts.count*1.0/numOfPostsPerPageB));
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - tableView data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    self.walkedPagesResults = [self.pc walkPages:self.pc.posts];
    if (self.walkedPagesResults) {
        return self.walkedPagesResults.count;
    }
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    //return self.pc.posts ? [self.pc.posts count] : 0;;
    if (self.walkedPagesResults && self.walkedPagesResults.count > section) {
        NSDictionary *walkSectionResult = self.walkedPagesResults[section];
        NSInteger rows = [[walkSectionResult objectForKey:@"rows"] integerValue];
        return rows;
    }
    return 0;
}

- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 60.0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    PageCell *cell = (PageCell *)[[[NSBundle mainBundle] loadNibNamed:@"PageCell" owner:nil options:nil] firstObject];
    [self configureCell:cell atIndexPath:indexPath];
    CGSize size = [cell sizeThatFits:CGSizeMake([UIScreen mainScreen].bounds.size.width - 24, CGFLOAT_MAX)];
    CGFloat height = ceil(size.height);
    return height;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    if (!self.pc.posts || self.pc.posts.count == 0) {
        return [UIView new];
    }
    UIView *header = [[UIView alloc] init];
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(16.0f, 8.0f, tableView.frame.size.width, 20.0f)];
    
    if (self.walkedPagesResults && self.walkedPagesResults.count > section) {
        NSDictionary *walkSectionResult = self.walkedPagesResults[section];
        NSString *headerTitle = [walkSectionResult objectForKey:@"headerTitle"];
        label.text = headerTitle;
    }
    //label.textColor = kFontColorGrayBlue;
    label.font = [UIFont boldSystemFontOfSize:18.0];
    [header addSubview:label];
    header.backgroundColor = kBackgroundColorGray;
    return header;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 36.0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"PageCell";
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    [self configureCell:cell atIndexPath:indexPath];
    return cell;
}

#pragma mark - tableView delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.walkedPagesResults && self.walkedPagesResults.count > indexPath.section) {
        NSDictionary *walkSectionResult = self.walkedPagesResults[indexPath.section];
        NSInteger indexOfSectionBegin = [[walkSectionResult objectForKey:@"index"] integerValue];
        NSInteger index = indexOfSectionBegin + indexPath.row;
        RemotePost *post = self.pc.posts[index];
        [self performSegueWithIdentifier:@"ViewPage" sender:post];
    }
}

#pragma mark - configure
- (void)configVariable
{
    self.pc = [[PostControll alloc] initWithBlog:self.blog];
    self.pageStatusFilters = [PostStatusType newPostStatusFilterWithPostType:postType];
}

- (void)configureNavbar
{
    self.navigationItem.titleView = self.filterButton;
    //配置即将push的VC的导航返回按钮的文字(只能在父级中配置)
    UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithTitle:@"返回" style:UIBarButtonItemStylePlain target:nil action:nil];
    self.navigationItem.backBarButtonItem = backButton;
    [self updateFilterTitle];
}

- (void)configureTableView
{
    //init
    self.tableView = [[UITableView alloc] initWithFrame:self.view.frame];
    self.tableView.tableFooterView = [UIView new];
    
    self.tableView.backgroundColor = kBackgroundColorLightBlue;
    self.tableView.separatorColor = kSeparatorColor;
    
    self.tableView.separatorInset = UIEdgeInsetsMake(0, 12, 0, 0);
    
    //delegate
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self.view addSubview:self.tableView];
    // Register the cells
    UINib *postTextCellNib = [UINib nibWithNibName:@"PageCell" bundle:[NSBundle mainBundle]];
    [self.tableView registerNib:postTextCellNib forCellReuseIdentifier:@"PageCell"];
}

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    typeof (PageCell) *pageCell = (PageCell *)cell;
    if (self.walkedPagesResults && self.walkedPagesResults.count > indexPath.section) {
        NSDictionary *walkSectionResult = self.walkedPagesResults[indexPath.section];
        NSInteger indexOfSectionBegin = [[walkSectionResult objectForKey:@"index"] integerValue];
        NSInteger index = indexOfSectionBegin + indexPath.row;
        
        [pageCell configCellWithPost:self.pc.posts[index] inBlog:self.blog];
    }
}

#pragma mark - Nav filter and related action
- (IBAction)didTapFilterButton:(id)sender
{
    if (self.pageFilterPopoverController) {
        return;
    }
    [self displayFiltersView];
}

- (NSInteger)currentPostStatusFilterIndex
{
    NSNumber *index = [[NSUserDefaults standardUserDefaults] objectForKey:@"PageStatusFilterIndex"];
    if (!index || [index integerValue] >= [self.pageStatusFilters count]) {
        return 0;
    }
    return [index integerValue];
}

- (PostStatusType *)currentPostStatusFilter
{
    return self.pageStatusFilters[[self currentPostStatusFilterIndex]];
}

- (void)setCurrentFilterIndex:(NSInteger)newIndex
{
    NSInteger index = [self currentPostStatusFilterIndex];
    if (newIndex == index) {
        return;
    }
    [[NSUserDefaults standardUserDefaults] setObject:@(newIndex) forKey:@"PageStatusFilterIndex"];
    [NSUserDefaults resetStandardUserDefaults];
    [self updateFilter];
    [self updateFilterTitle];
    
    [self fetchPostsFromDBWithReloadTableView:YES];
}

- (void)updateFilter
{
    PostStatusType *filter = [self currentPostStatusFilter];
    self.postStatusIndex = [self currentPostStatusFilterIndex];
    postStatusB = filter.postStatus;
    postStatusText = filter.postStatusText;
}

- (void)updateFilterTitle
{
    [self.filterButton setAttributedTitleForTitle:postStatusText];
}

- (void)displayFiltersView
{
    FiltersTableViewController *controller = [[FiltersTableViewController alloc] initWithStyle:UITableViewStylePlain andFilters:self.pageStatusFilters andCurrentIndex:[self currentPostStatusFilterIndex]];
    controller.onItemSelected = ^(NSNumber *selectedIndex) {
        if (self.pageFilterPopoverController) {
            [self.pageFilterPopoverController dismissPopoverAnimated:YES];
            self.pageFilterPopoverController = nil;
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
    controller.preferredContentSize = CGSizeMake(320.0, 220.0);
    
    CGRect titleRect = self.navigationItem.titleView.frame;
    titleRect = [self.navigationController.view convertRect:titleRect fromView:self.navigationItem.titleView.superview];
    
    self.pageFilterPopoverController = [[UIPopoverController alloc] initWithContentViewController:controller];
    self.pageFilterPopoverController.delegate = self;
    [self.pageFilterPopoverController presentPopoverFromRect:titleRect
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
    if (self.pageFilterPopoverController) {
        [self popoverControllerDidDismissPopover:self.pageFilterPopoverController];
    }
}

#pragma mark - UIPopover Delegate Methods

- (void)popoverControllerDidDismissPopover:(UIPopoverController *)popoverController
{
    self.pageFilterPopoverController.delegate = nil;
    self.pageFilterPopoverController = nil;
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

#pragma mark - segue
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"PreviewPage"]) {
        WebBrowserController *controller = segue.destinationViewController;
        controller.url = sender;
    }else if ([segue.identifier isEqualToString:@"ViewPage"]){
        SinglePostViewController *controller = segue.destinationViewController;
        controller.post = sender;
    }
}

#pragma mark - fetch posts related
- (void)fetchPostsFromDBWithReloadTableView:(BOOL)reloadTableView
{
    [self addHud];
    [self.pc getDBPostsofType:postType postStatus:postStatusB ForBlog:self.blog number:numOfPostsPerPageB];
    if (reloadTableView) {
        [self.tableView reloadData];
    }
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
    NSArray *morePosts = [self.pc loadMoreDBPostsofType:postType postStatus:postStatusB ForBlog:self.blog page:pageB+1];
    if (morePosts && morePosts.count > 0) {
        [self appendMorePosts:morePosts];
        [self endLoadMore];
        pageB++;
    }else{
        [MBProgressHUD hideHUDForView:self.view animated:NO];
        MBProgressHUD *textHud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        textHud.mode = MBProgressHUDModeText;
        textHud.labelText = @"没有更多了";
        [textHud hide:YES afterDelay:1.5];
        [self endLoadMore];
    }
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
        [self.pc getDBPostsofType:postType postStatus:postStatusB ForBlog:self.blog number:numOfPostsPerPageB];
        dispatch_async(dispatch_get_main_queue(), ^{
            //[self endRefresh];
            [self.tableView reloadData];
        });
    }else if ([self isLoadingMore]){
        [self hasSyncMorePosts];
    }
    [self endRefresh];
}

- (void)queryedDBPostsNotificationCallback:(NSNotification *)notification
{
    [self removeHud];
}

#pragma mark - SCPullRefresh Blocks

- (void)addSCPullRefreshBlocks
{
    __weak typeof(PagesListViewController) *weakSelf = self;
    
    self.refreshBlock = ^{
        
        __strong typeof(PagesListViewController) *strongSelf = weakSelf;
        
        //[strongSelf performSelector:@selector(endRefresh) withObject:strongSelf afterDelay:2.0];
        [PostControll syncPostsWithBlog:strongSelf.blog postType:postType page:pageB];
        
    };
    
    self.loadMoreBlock = ^{
        
        __strong typeof(PagesListViewController) *strongSelf = weakSelf;
        
        NSArray *morePosts = [strongSelf.pc loadMoreDBPostsofType:postType postStatus:postStatusB ForBlog:strongSelf.blog page:pageB+1];
        if (morePosts && morePosts.count >= numOfPostsPerPageB) {
            [strongSelf appendMorePosts:morePosts];
            [strongSelf endLoadMore];
            pageB++;
        }else{
            [PostControll syncPostsWithBlog:strongSelf.blog postType:postType page:pageB+1];
        }
        //[strongSelf performSelector:@selector(endLoadMore) withObject:strongSelf afterDelay:2.0];
    };
}

#pragma mark - dealloc
- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
























@end
