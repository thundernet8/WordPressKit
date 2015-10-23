//
//  PostCommentsViewController.m
//  WordPressKit
//
//  Created by wuxueqian on 15/10/20.
//  Copyright (c) 2015年 wuxueqian. All rights reserved.
//

#import "PostCommentsViewController.h"
#import "Comment.h"
#import "NSString+Util.h"
#import "UIImageView+WebCache.h"
#import "GravatarHelper.h"
#import "CommentData.h"

const NSInteger numOfCommentsPerPage = 20;
static NSString *commentStatus = @"approve";
static NSString *commentType = @"";

@interface PostCommentsViewController () <CommentDateDelegate>

@property (nonatomic,strong) NSMutableArray *comments;
@property (nonatomic) NSInteger page;
@property (nonatomic) BOOL isLoadingMore;

@end

@implementation PostCommentsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initVars];
    [self configureCommentTableView];
    UIRefreshControl *rc = [[UIRefreshControl alloc] init];
    rc.attributedTitle = [[NSAttributedString alloc] initWithString:@"下拉刷新"];
    [rc addTarget:self action:@selector(refreshComments:) forControlEvents:UIControlEventValueChanged];
    self.refreshControl = rc;
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.refreshControl beginRefreshing];
        [self.refreshControl endRefreshing];
    });
    //加载评论
    [self queryComments];
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    [self maybeFetchComments];
}

- (void)initVars{
    _page = 1;
    _isLoadingMore = NO;
}

- (void)refreshComments:(UIRefreshControl *)sender{
    [self removeNoCommentsView];
    sender.attributedTitle = [[NSAttributedString alloc] initWithString:@"加载中···"];
    CommentData *cd = [self instanceManager];
    [cd fetchPostCommentsOfStatus:commentStatus commentType:commentType inCommentPage:_page];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
}

#pragma mark - configure
- (void)configureCommentTableView
{
    self.tableView.backgroundColor = kBackgroundColorLightGray;
    self.tableView.separatorColor = kSeparatorColor;
    self.tableView.tableFooterView = [UIView new];
}

#pragma mark - comments tableview datasource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _comments.count;
}

- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 100.0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    Comment *comment = self.comments[indexPath.row];
    UILabel *contentLabel = [UILabel new];
    contentLabel.lineBreakMode = NSLineBreakByWordWrapping;
    contentLabel.numberOfLines = 0;
    contentLabel.font = [UIFont systemFontOfSize:14.0];
    contentLabel.text = comment.content;
    CGSize contentLabelSize = [contentLabel sizeThatFits:CGSizeMake([UIScreen mainScreen].bounds.size.width - 32, CGFLOAT_MAX)];
    return 60.0 + contentLabelSize.height;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *identifier = @"CommentCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    [self configureCommentCell:cell atIndexPath:indexPath];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    //瀑布流加载
    if (!_isLoadingMore && _comments.count % numOfCommentsPerPage == 0 && _comments.count - indexPath.row < 4) {
        [self loadingMoreComments];
    }
    return cell;
}

- (void)configureCommentCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    Comment *comment = _comments[indexPath.row];
    //avatar
    UIImageView *avatar = (UIImageView *)[cell.contentView viewWithTag:1];
    avatar.layer.masksToBounds = YES;
    avatar.layer.cornerRadius = 20.0;
    if (comment.authorEmail && ![comment.authorEmail isEmpty]) {
        NSURL *gravatarURL = [GravatarHelper getGravatarURL:comment.authorEmail imageSize:40];
        SDWebImageManager *manager = [SDWebImageManager sharedManager];
        [manager downloadImageWithURL:gravatarURL options:SDWebImageContinueInBackground progress:^(NSInteger receivedSize, NSInteger expectedSize) {
            
        } completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, BOOL finished, NSURL *imageURL) {
            avatar.image = image;
        }];
    }
    avatar.contentMode = UIViewContentModeScaleToFill;
    //author
    UILabel *authorLabel = (UILabel *)[cell.contentView viewWithTag:2];
    authorLabel.text = comment.author;
    //comment time
    UILabel *dateLabel = (UILabel *)[cell.contentView viewWithTag:3];
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"YYYY-MM-dd HH:MM:SS"];
    NSString *dateStr = [dateFormat stringFromDate:comment.date];
    dateLabel.text = dateStr;
    //comment content
    UILabel *commentLabel = (UILabel *)[cell.contentView viewWithTag:4];
    commentLabel.numberOfLines = 0;
    commentLabel.lineBreakMode = NSLineBreakByWordWrapping;
    commentLabel.text = comment.content;
}

#pragma mark - comments tableview delegate


- (void)dealNoCommentsView
{
    //********************//:-(
    [self removeNoCommentsView];
    UIView *noCommentsView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 160.0)];
    noCommentsView.tag = 8;
    UILabel *emotion = [[UILabel alloc] initWithFrame:CGRectMake(0, 30.0, noCommentsView.frame.size.width, 100.0)];
    emotion.font = [UIFont systemFontOfSize:36.0];
    emotion.textColor = [UIColor colorWithRed:225/255.0 green:225/255.0 blue:225/255.0 alpha:1.0];
    emotion.text = @":-(\r\nNo Comments";
    emotion.numberOfLines = 0;
    emotion.textAlignment = NSTextAlignmentCenter;
    [noCommentsView addSubview:emotion];
    [self.tableView addSubview:noCommentsView];
    
}

- (void)removeNoCommentsView
{
    if ([self.view viewWithTag:8]) {
        [[self.view viewWithTag:8] removeFromSuperview];
    }
}

- (void)loadingMoreComments
{
    NSLog(@"loadingMoreComments");
    _isLoadingMore = YES;
    _page ++;
    [self queryComments];
    
}

- (void)appendMoreComments:(NSMutableArray *)moreComments
{
    int64_t delayInSeconds = 0.5;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void) {
        NSInteger currentCount = _comments.count;
        NSInteger addNum = moreComments.count;
        [_comments addObjectsFromArray:moreComments];
        NSMutableArray *indexPaths = [NSMutableArray array];
        for (int i = 0; i < addNum; i++) {
            [indexPaths addObject:[NSIndexPath indexPathForRow:currentCount+i inSection:0]];
        }
        [self.tableView beginUpdates];
        [self.tableView insertRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationFade];
        [self.tableView endUpdates];
        [self.tableView scrollToRowAtIndexPath:[indexPaths firstObject] atScrollPosition:UITableViewScrollPositionBottom animated:YES];
        _isLoadingMore = NO;
    });
}

#pragma mark - query comments data
- (void)queryComments
{
    NSLog(@"queryComments");
    CommentData *cd = [self instanceManager];
    [cd getPostCommentsOfStatus:commentStatus commentType:commentType inCommentPage:_page];
    
}

- (void)maybeFetchComments
{
    if (!_comments || _comments.count == 0) {
        CommentData *cd = [self instanceManager];
        [cd maybeFetchPostCommentsOfStatus:commentStatus commentType:commentType inCommentPage:_page];
    }
}

- (void)fetchMoreComments
{
    NSLog(@"fetchMoreComments");
    if (_isLoadingMore) {
        CommentData *cd = [self instanceManager];
        [cd fetchPostCommentsOfStatus:commentStatus commentType:commentType inCommentPage:_page];
    }
}

#pragma mark - CommentData delegate
- (CommentData *)instanceManager
{
    CommentData *cd = [CommentData sharedManager];
    [cd configureManagerPost:_post forBlog:_blog];
    cd.delegate = self;
    return cd;
}

//数据库查询评论成功回调
- (void)queryDBCommentsSuccess:(NSMutableArray *)Comments
{
    NSLog(@"queryDBCommentsSuccess %i",Comments.count);
    if ([self.refreshControl isRefreshing]) {
        [self.refreshControl endRefreshing];
        self.refreshControl.attributedTitle = [[NSAttributedString alloc] initWithString:@"下拉刷新"];
    }
    if (Comments && Comments.count > 0 && !_isLoadingMore) {
        _comments = Comments;
        [self.tableView reloadData];
    }else if (Comments && Comments.count > 0 && _isLoadingMore){
        //append
        [self appendMoreComments:Comments];
    }else{
        if (!_isLoadingMore) {
            _comments = Comments;
            [self dealNoCommentsView];
        }else{
            [self fetchMoreComments];
        }
    }
    
}

//数据库查询评论失败回调
- (void)queryDBCommentsFailure:(NSError *)err
{
    NSLog(@"queryDBCommentsFailure %@",err.description);
}

//服务器获取评论失败回调
- (void)fetchServerCommentsFailure:(NSError *)err
{
    NSLog(@"fetchServerCommentsFailure");
}

//评论数据写入数据库成功回调
- (void)writeDBCommentsSuccess:(NSArray *)Comments
{
    if ([self.refreshControl isRefreshing]) {
        [self.refreshControl endRefreshing];
        self.refreshControl.attributedTitle = [[NSAttributedString alloc] initWithString:@"下拉刷新"];
    }
    if (Comments && Comments.count > 0 && !_isLoadingMore) {
        _comments = [Comments mutableCopy];
        [self removeNoCommentsView];
        [self.tableView reloadData];
    }else if (Comments && Comments.count > 0 && _isLoadingMore) {
        //append
        [self appendMoreComments:[Comments mutableCopy]];
    }else{
        if (!_isLoadingMore) {
            [self dealNoCommentsView];
        }else{
            _isLoadingMore = NO;
        }
    }
    NSLog(@"writeDBCommentsSuccess");
}





@end
