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
@property (weak, nonatomic) IBOutlet UIView *ActionBar;

@property (weak, nonatomic) RemotePost *post;




@end

@implementation PostCell

- (void)awakeFromNib {
    // Initialization code
    //[self.postCellPostEditButton setTitleTextAttributes:@{NSFontAttributeName : [UIFont systemFontOfSize:12.0]} forState:UIControlStateNormal];
    //编辑按钮
//    UIButton *editButton = [UIButton buttonWithType:UIButtonTypeCustom];
//    [editButton setImage:[UIImage imageNamed:@"post_actionbar_icon_edit"] forState:UIControlStateNormal];
//    [editButton setTitle:@"编辑" forState:UIControlStateNormal];
//    [editButton.titleLabel setFont:[UIFont systemFontOfSize:12]];
//    [editButton setTitleColor:[UIColor colorWithRed:15/255.0 green:115/255.0 blue:176/255.0 alpha:1.0] forState:UIControlStateNormal];
//    [editButton sizeToFit];
//    UIBarButtonItem *editBar = [[UIBarButtonItem alloc] initWithCustomView:editButton];
//    //预览按钮
//    UIButton *previewButton = [UIButton buttonWithType:UIButtonTypeCustom];
//    [previewButton setImage:[UIImage imageNamed:@"post_actionbar_icon_preview"] forState:UIControlStateNormal];
//    [previewButton setTitle:@"预览" forState:UIControlStateNormal];
//    [previewButton.titleLabel setFont:[UIFont systemFontOfSize:12]];
//    [previewButton setTitleColor:[UIColor colorWithRed:15/255.0 green:115/255.0 blue:176/255.0 alpha:1.0] forState:UIControlStateNormal];
//    [previewButton sizeToFit];
//    UIBarButtonItem *previewBar = [[UIBarButtonItem alloc] initWithCustomView:previewButton];
//    //删除文章按钮
//    UIButton *trashButton = [UIButton buttonWithType:UIButtonTypeCustom];
//    [trashButton setImage:[UIImage imageNamed:@"post_actionbar_icon_trash"] forState:UIControlStateNormal];
//    [trashButton setTitle:@"回收站" forState:UIControlStateNormal];
//    [trashButton.titleLabel setFont:[UIFont systemFontOfSize:12]];
//    [trashButton setTitleColor:[UIColor colorWithRed:15/255.0 green:115/255.0 blue:176/255.0 alpha:1.0] forState:UIControlStateNormal];
//    [trashButton sizeToFit];
//    UIBarButtonItem *trashBar = [[UIBarButtonItem alloc] initWithCustomView:trashButton];
//    //Flexible space
//    UIBarButtonItem *flexibleSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
//    
//    //添加按钮
//    [self.postCellToolBar setItems:@[editBar,flexibleSpace,previewBar,flexibleSpace,trashBar]];
//    
//    //去除顶部border
//    self.postCellToolBar.clipsToBounds = YES;
    
    //NSLog(@"awakeFromNib");
    
    //[self setNeedsUpdateConstraints];
    
}

- (void)didMoveToSuperview{
    //NSLog(@"didMoveToSuperview");
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
- (void)configCellWithPost:(RemotePost *)post inBlog:(Blog *)blog
{
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
    NSUInteger length = content.length > 120 ? 120 : content.length;
    content = [content substringWithRange:NSMakeRange(0, length)];
    self.PostContent.attributedText = [[NSAttributedString alloc] initWithData:[content dataUsingEncoding:NSUnicodeStringEncoding] options:@{ NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType } documentAttributes:nil error:nil];
    self.PostContent.font = [UIFont systemFontOfSize:14.0f];
    //文章日期
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"YYYY-MM-dd HH:MM:SS"];
    NSString *dateStr = [dateFormat stringFromDate:post.date];
    self.PostDate.text = dateStr;
    

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
    NSLog(@"sizing begin");
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
    NSLog(@"sizing end");
    return CGSizeMake(size.width, height);
}

/**
 *  配置cell的缩略图
 *
 *  @param post 文章对象
 */
- (void)confiImageWithPost:(RemotePost *)post
{
    if (!self.PostThumb) {
        return;
    }
    SDWebImageManager *manager = [SDWebImageManager sharedManager];
    [manager downloadImageWithURL:[NSURL URLWithString:post.postThumbnailPath] options:SDWebImageContinueInBackground progress:^(NSInteger receivedSize, NSInteger expectedSize) {
        NSLog(@"download progress is %f", receivedSize/expectedSize*1.0);
        
    } completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, BOOL finished, NSURL *imageURL) {
        if (finished) {
            NSLog(@"download finished");
            self.PostThumb.image = image;
        }
    }];
    self.PostThumb.contentMode = UIViewContentModeScaleToFill;
}


@end
