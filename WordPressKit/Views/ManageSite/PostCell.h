//
//  PostCell.h
//  WordPressKit
//
//  Created by wuxueqian on 15/9/21.
//  Copyright (c) 2015年 wuxueqian. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Post.h"
#import "Blog.h"

@protocol PostCellDelegate <NSObject>

@optional
- (void)cell:(UITableViewCell *)cell receivedEditActionForProvider:(Post *)post;
- (void)cell:(UITableViewCell *)cell receivedViewActionForProvider:(Post *)post;
- (void)cell:(UITableViewCell *)cell receivedTrashActionForProvider:(Post *)post;
- (void)cell:(UITableViewCell *)cell receivedPublishActionForProvider:(Post *)post;
- (void)cell:(UITableViewCell *)cell receivedRestoreActionForProvider:(Post *)post;

@end

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

@property (weak, nonatomic) id<PostCellDelegate> delegate;

- (void)configCellWithPost:(Post *)post inBlog:(Blog *)blog;
- (void)confiImageWithPost:(Post *)post;

@end
