//
//  PostCell.m
//  WordPressKit
//
//  Created by wuxueqian on 15/9/21.
//  Copyright (c) 2015年 wuxueqian. All rights reserved.
//

#import "PostCell.h"
#import "NSString+Util.h"
#import "UIImageView+WebCache.h"
#import "PostActionBar.h"
#import "PostActionBarItem.h"
#import "PostCategory.h"

extern NSString * const PostStatusDraft;
extern NSString * const PostStatusPending;
extern NSString * const PostStatusPrivate;
extern NSString * const PostStatusPublish;
extern NSString * const PostStatusScheduled;
extern NSString * const PostStatusTrash;
static const UIEdgeInsets ViewButtonImageInsets = {2.0, 0.0, 0.0, 0.0};

@interface PostCell()
@property (weak, nonatomic) IBOutlet UIView *PostWrapper;
@property (weak, nonatomic) IBOutlet UIView *PostHead;
@property (weak, nonatomic) IBOutlet UIImageView *BlogAvatar;
@property (weak, nonatomic) IBOutlet UILabel *BlogName;
@property (weak, nonatomic) IBOutlet UILabel *PostAuthor;

@property (weak, nonatomic) IBOutlet UIImageView *PostThumb;
@property (weak, nonatomic) IBOutlet UILabel *PostTitle;
@property (weak, nonatomic) IBOutlet UILabel *PostContent;
@property (weak, nonatomic) IBOutlet UILabel *PostDate;
@property (weak, nonatomic) IBOutlet UILabel *PostCat;
@property (weak, nonatomic) IBOutlet PostActionBar *ActionBar;


@property (weak, nonatomic) Post *post;

@end

@implementation PostCell

- (void)awakeFromNib {
    
    //[self setNeedsUpdateConstraints];
    
}

- (void)didMoveToSuperview{
   
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

/**
 *  配置cell的内容
 *
 *  @param cell UITableViewCell对象
 *  @param post 文章对象
 */
- (void)configCellWithPost:(Post *)post inBlog:(Blog *)blog
{
    self.backgroundColor = kBackgroundColorLightGray;
    self.post = post;
    //博客名
    self.BlogName.text = blog.name;
    //作者
    self.PostAuthor.text = post.authorDisplayName;
    //文章标题
    self.PostTitle.text = post.title;
    //特色图
    [self confiImageWithPost:post];
    //文章内容
    NSString *content = [post.excerpt isEmpty] ? [post.content trim] : [post.excerpt trim];
//    content = [content stringByReplacingOccurrencesOfString:@"\r" withString:@""];
//    content = [content stringByReplacingOccurrencesOfString:@"\n" withString:@""];
    NSUInteger length = content.length > 120 ? 120 : content.length;
    NSString *tail = content.length > 120 ? @" ···" : @"";
    content = [content substringWithRange:NSMakeRange(0, length)];
    content = [content stringByAppendingString:tail];
    self.PostContent.text = content;
    self.PostContent.font = [UIFont systemFontOfSize:14.0f];
    //文章日期
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"YYYY-MM-dd HH:MM"];
    NSString *dateStr = [dateFormat stringFromDate:post.date];
    self.PostDate.text = dateStr;
    //文章分类
    NSMutableArray *catNames = [NSMutableArray new];
    for (PostCategory *cat in post.categories) {
        [catNames addObject:cat.name];
    }
    NSString *catStr = [catNames componentsJoinedByString:@" · "];
    self.PostCat.text = catStr;
    //Action bar
    [self configureActionBar];

    [self setNeedsUpdateConstraints];
}

/**
 *  重建自适应内容高度方法
 *
 *  @param size 内容的约束尺寸
 *
 *  @return 返回内容的合适尺寸
 */
- (CGSize)sizeThatFits:(CGSize)size
{
    CGFloat height = CGRectGetMinY(self.PostWrapper.frame);
    
    height += CGRectGetMinY(self.PostHead.frame);
    height += 34;//head height
    height += 16;//head low margin
    
    if (self.PostThumb) {
        height += CGRectGetHeight(self.PostThumb.frame);
        height += 16;
    }
    CGFloat width = size.width - 32;
    CGSize innerSize = CGSizeMake(width, CGFLOAT_MAX);
    height += [self.PostTitle sizeThatFits:innerSize].height;
    height += 16;//title low margin
    
    height += [self.PostContent sizeThatFits:innerSize].height;
    height += 16;//post content low margin
    
    height += CGRectGetHeight(self.PostDate.frame);
    height += 16;
    
    height += CGRectGetHeight(self.ActionBar.frame);
    return CGSizeMake(size.width, height);
}

/**
 *  配置cell的缩略图
 *
 *  @param post 文章对象
 */
- (void)confiImageWithPost:(Post *)post
{
    if (!self.PostThumb) {
        return;
    }
    SDWebImageManager *manager = [SDWebImageManager sharedManager];
    [manager downloadImageWithURL:[NSURL URLWithString:post.postThumbnailPath] options:SDWebImageContinueInBackground progress:^(NSInteger receivedSize, NSInteger expectedSize) {
        
    } completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, BOOL finished, NSURL *imageURL) {
        if (finished) {
            self.PostThumb.image = image;
        }
    }];
    self.PostThumb.contentMode = UIViewContentModeScaleToFill;
}

#pragma mark - Configure Actionbar

- (void)configureActionBar
{
    NSString *status = self.post.status;
    if ([status isEqualToString:PostStatusPublish] || [status isEqualToString:PostStatusPrivate]) {
        [self configurePublishedActionBar];
    } else if ([status isEqualToString:PostStatusTrash]) {
        // trashed
        [self configureTrashedActionBar];
    } else {
        // anything else (draft, pending, scheduled, something custom) treat as draft
        [self configureDraftActionBar];
    }
}

- (void)configurePublishedActionBar
{
    __weak __typeof(self) weakSelf = self;
    NSMutableArray *items = [NSMutableArray array];
    PostActionBarItem *item = [PostActionBarItem itemWithTitle:NSLocalizedString(@"编辑", @"Label for the edit post button. Tapping displays the editor.")
                                                                 image:[UIImage imageNamed:@"post_actionbar_icon_edit"]
                                                      highlightedImage:nil];
    item.callback = ^{
        [weakSelf editPostAction];
    };
    [items addObject:item];
    
    item = [PostActionBarItem itemWithTitle:NSLocalizedString(@"预览", @"Label for the view post button. Tapping displays the post as it appears on the web.")
                                          image:[UIImage imageNamed:@"post_actionbar_icon_preview"]
                               highlightedImage:nil];
    item.callback = ^{
        [weakSelf viewPostAction];
    };
    item.imageInsets = ViewButtonImageInsets;
    [items addObject:item];
    
    
    item = [PostActionBarItem itemWithTitle:NSLocalizedString(@"垃圾箱", @"Label for the trash post button. Tapping moves a post to the trash bin.")
                                          image:[UIImage imageNamed:@"post_actionbar_icon_trash"]
                               highlightedImage:nil];
    item.callback = ^{
        [weakSelf trashPostAction];
    };
    [items addObject:item];
    
    [self.ActionBar setItems:items];
}

- (void)configureDraftActionBar
{
    __weak __typeof(self) weakSelf = self;
    NSMutableArray *items = [NSMutableArray array];
    PostActionBarItem *item = [PostActionBarItem itemWithTitle:NSLocalizedString(@"编辑", @"Label for the edit post button. Tapping displays the editor.")
                                                                 image:[UIImage imageNamed:@"post_actionbar_icon_edit"]
                                                      highlightedImage:nil];
    item.callback = ^{
        [weakSelf editPostAction];
    };
    [items addObject:item];
    
    item = [PostActionBarItem itemWithTitle:NSLocalizedString(@"预览", @"Label for the preview post button. Tapping shows a preview of the post.")
                                          image:[UIImage imageNamed:@"post_actionbar_icon_preview"]
                               highlightedImage:nil];
    item.callback = ^{
        [weakSelf viewPostAction];
    };
    [items addObject:item];
    
    item = [PostActionBarItem itemWithTitle:NSLocalizedString(@"发布", @"Label for the publish button. Tapping publishes a draft post.")
                                          image:[UIImage imageNamed:@"post_actionbar_icon_publish"]
                               highlightedImage:nil];
    item.callback = ^{
        [weakSelf publishPostAction];
    };
    [items addObject:item];
    
    item = [PostActionBarItem itemWithTitle:NSLocalizedString(@"垃圾箱", @"Label for the trash post button. Tapping moves a post to the trash bin.")
                                          image:[UIImage imageNamed:@"post_actionbar_icon_trash"]
                               highlightedImage:nil];
    item.callback = ^{
        [weakSelf trashPostAction];
    };
    [items addObject:item];
    
    [self.ActionBar setItems:items];
}

- (void)configureTrashedActionBar
{
    __weak __typeof(self) weakSelf = self;
    NSMutableArray *items = [NSMutableArray array];
    PostActionBarItem *item = [PostActionBarItem itemWithTitle:NSLocalizedString(@"还原", @"Label for restoring a trashed post.")
                                                                 image:[UIImage imageNamed:@"post_actionbar_icon_restore"]
                                                      highlightedImage:nil];
    item.callback = ^{
        [weakSelf restorePostAction];
    };
    [items addObject:item];
    
    item = [PostActionBarItem itemWithTitle:NSLocalizedString(@"删除", @"Label for the delete post buton. Tapping permanently deletes a post.")
                                          image:[UIImage imageNamed:@"post_actionbar_icon_trash"]
                               highlightedImage:nil];
    item.callback = ^{
        [weakSelf trashPostAction];
    };
    [items addObject:item];
    
    [self.ActionBar setItems:items];
}

#pragma mark - Actions

- (void)editPostAction
{
    if ([self.delegate respondsToSelector:@selector(cell:receivedEditActionForProvider:)]) {
        [self.delegate cell:self receivedEditActionForProvider:self.post];
    }
}

- (void)viewPostAction
{
    if ([self.delegate respondsToSelector:@selector(cell:receivedViewActionForProvider:)]) {
        [self.delegate cell:self receivedViewActionForProvider:self.post];
    }
}

- (void)publishPostAction
{
    if ([self.delegate respondsToSelector:@selector(cell:receivedPublishActionForProvider:)]) {
        [self.delegate cell:self receivedPublishActionForProvider:self.post];
    }
}

- (void)trashPostAction
{
    if ([self.delegate respondsToSelector:@selector(cell:receivedTrashActionForProvider:)]) {
        [self.delegate cell:self receivedTrashActionForProvider:self.post];
    }
}

- (void)restorePostAction
{
    if ([self.delegate respondsToSelector:@selector(cell:receivedRestoreActionForProvider:)]) {
        [self.delegate cell:self receivedRestoreActionForProvider:self.post];
    }
}


@end
