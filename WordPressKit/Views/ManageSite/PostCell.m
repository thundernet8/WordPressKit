//
//  PostCell.m
//  WordPressKit
//
//  Created by wuxueqian on 15/9/21.
//  Copyright (c) 2015年 wuxueqian. All rights reserved.
//

#import "PostCell.h"

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
    UIButton *editButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [editButton setImage:[UIImage imageNamed:@"post_actionbar_icon_edit"] forState:UIControlStateNormal];
    [editButton setTitle:@"编辑" forState:UIControlStateNormal];
    [editButton.titleLabel setFont:[UIFont systemFontOfSize:12]];
    [editButton setTitleColor:[UIColor colorWithRed:15/255.0 green:115/255.0 blue:176/255.0 alpha:1.0] forState:UIControlStateNormal];
    [editButton sizeToFit];
    UIBarButtonItem *editBar = [[UIBarButtonItem alloc] initWithCustomView:editButton];
    //预览按钮
    UIButton *previewButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [previewButton setImage:[UIImage imageNamed:@"post_actionbar_icon_preview"] forState:UIControlStateNormal];
    [previewButton setTitle:@"预览" forState:UIControlStateNormal];
    [previewButton.titleLabel setFont:[UIFont systemFontOfSize:12]];
    [previewButton setTitleColor:[UIColor colorWithRed:15/255.0 green:115/255.0 blue:176/255.0 alpha:1.0] forState:UIControlStateNormal];
    [previewButton sizeToFit];
    UIBarButtonItem *previewBar = [[UIBarButtonItem alloc] initWithCustomView:previewButton];
    //删除文章按钮
    UIButton *trashButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [trashButton setImage:[UIImage imageNamed:@"post_actionbar_icon_trash"] forState:UIControlStateNormal];
    [trashButton setTitle:@"回收站" forState:UIControlStateNormal];
    [trashButton.titleLabel setFont:[UIFont systemFontOfSize:12]];
    [trashButton setTitleColor:[UIColor colorWithRed:15/255.0 green:115/255.0 blue:176/255.0 alpha:1.0] forState:UIControlStateNormal];
    [trashButton sizeToFit];
    UIBarButtonItem *trashBar = [[UIBarButtonItem alloc] initWithCustomView:trashButton];
    //Flexible space
    UIBarButtonItem *flexibleSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    
    //添加按钮
    [self.postCellToolBar setItems:@[editBar,flexibleSpace,previewBar,flexibleSpace,trashBar]];
    
    //去除顶部border
    self.postCellToolBar.clipsToBounds = YES;
    
    
    
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
