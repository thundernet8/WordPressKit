//
//  PostCell.h
//  WordPressKit
//
//  Created by wuxueqian on 15/9/21.
//  Copyright (c) 2015年 wuxueqian. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RemotePost.h"
#import "Blog.h"

@interface PostCell : UITableViewCell


@property (weak, nonatomic) IBOutlet UIView *postCellWrapper;
@property (weak, nonatomic) IBOutlet UIView *postCellHeaderView;
@property (weak, nonatomic) IBOutlet UIImageView *postCellBlogAvatar;
@property (weak, nonatomic) IBOutlet UILabel *postCellBlogName;
@property (weak, nonatomic) IBOutlet UIView *postCellContentView;
@property (weak, nonatomic) IBOutlet UILabel *postCellPostTitle;
@property (weak, nonatomic) IBOutlet UITextView *postCellPostContent;
@property (weak, nonatomic) IBOutlet UIView *postCellPostFooterView;
@property (weak, nonatomic) IBOutlet UILabel *postCellPostDate;
@property (weak, nonatomic) IBOutlet UIImageView *postCellThumb;

@property (weak, nonatomic) IBOutlet UIToolbar *postCellToolBar;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *postCellPostEditButton;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *postCellPostPreviewButton;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *postCellPostTrashButton;

- (void)configCellWithPost:(RemotePost *)post inBlog:(Blog *)blog;
- (void)confiImageWithPost:(RemotePost *)post;

@end
