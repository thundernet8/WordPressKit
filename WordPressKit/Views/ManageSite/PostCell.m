//
//  PostCell.m
//  WordPressKit
//
//  Created by wuxueqian on 15/9/21.
//  Copyright (c) 2015年 wuxueqian. All rights reserved.
//

#import "PostCell.h"
#import "NSString+Util.h"

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
    //博客名
    self.BlogName.text = blog.name;
    //作者
    self.PostAuthor.text = post.authorDisplayName;
    //文章标题
    self.PostTitle.text = post.title;
    //特色图
    if (self.PostThumb) {
        self.PostThumb.image = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:post.postThumbnailPath]]];
    }
    self.PostThumb.contentMode = UIViewContentModeScaleToFill;
    //文章内容
    NSString *content = [post.excerpt isEmpty] ? post.content : post.excerpt;
    NSUInteger length = content.length > 200 ? 200 : content.length;
    content = [content substringWithRange:NSMakeRange(0, length)];
    self.PostContent.attributedText = [[NSAttributedString alloc] initWithData:[content dataUsingEncoding:NSUnicodeStringEncoding] options:@{ NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType } documentAttributes:nil error:nil];
    self.PostContent.font = [UIFont systemFontOfSize:14.0f];
    //文章日期
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"YYYY-MM-DD HH:MM:SS"];
    NSString *dateStr = [dateFormat stringFromDate:post.date];
    self.PostDate.text = dateStr;
    

    
}



@end
