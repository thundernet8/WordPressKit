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

@interface PostCommentsViewController ()

@property (nonatomic,strong) NSArray *comments;

@end

@implementation PostCommentsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self configureCommentTableView];
    UIRefreshControl *rc = [[UIRefreshControl alloc] init];
    rc.attributedTitle = [[NSAttributedString alloc] initWithString:@"刷新中···"];
    [rc addTarget:self action:nil forControlEvents:UIControlEventValueChanged];
    self.refreshControl = rc;
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.refreshControl beginRefreshing];
        [self.refreshControl endRefreshing];
    });
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
    //return self.comments.count;
    return 1;
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
    return cell;
}

- (void)configureCommentCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    Comment *comment = _comments[indexPath.row];
    //avatar
    UIImageView *avatar = (UIImageView *)[cell.contentView viewWithTag:1];
    avatar.layer.masksToBounds = YES;
    avatar.layer.cornerRadius = 20.0;
    if (![comment.authorEmail isEmpty]) {
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
    commentLabel.text = _comments[indexPath.row];
}

#pragma mark - comments tableview delegate



@end
