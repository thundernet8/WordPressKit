//
//  ListPostsViewController.m
//  WordPressKit
//
//  Created by wuxueqian on 15/9/21.
//  Copyright (c) 2015年 wuxueqian. All rights reserved.
//

#import "ListPostsViewController.h"
#import "PostCell.h"
#import "WordPressApi.h"
#import "Blog.h"
#import "DataModel.h"
#import "WPXMLRPCClient.h"
#import "RemotePost.h"
#import "PostControll.h"

BOOL fetched = NO;
NSInteger const syncTimeInterval = 300;
NSString *const postType = @"post";


@interface ListPostsViewController ()

@property (nonatomic, strong) NSMutableArray *posts;

@end

@implementation ListPostsViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    //[PostControll syncPostsWithBlog:self.blog];
    self.pc = [[PostControll alloc] initWithBlog:self.blog];
    [self.pc getDBPostsofType:@"post" ForBlog:self.blog number:20];
    NSLog(@"posts count is %i", (int)self.pc.posts.count);
    //[PostControll syncPostsWithBlog:_blog postType:postType];
    [self.pc needsSyncPostsForBlog:self.blog forTimeInterval:syncTimeInterval postType:postType];
    NSLog(@"posts count is %i", (int)self.pc.posts.count);
    
    
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

//节数
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

//行数
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.pc.posts count];
}

//cell实例化
- (PostCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    PostCell *cell = [tableView dequeueReusableCellWithIdentifier:@"PostXibCell"];
    if (cell == nil) {
        [tableView registerNib:[UINib nibWithNibName:@"PostImageCell" bundle:nil] forCellReuseIdentifier:@"PostImageCell"];
        cell = [tableView dequeueReusableCellWithIdentifier:@"PostImageCell"];
    }
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
//    //
//    [PostControll getPostsOfType:@"post" forBlog:self.blog options:@{@"post_status":@"publish",@"number":@5} success:^(NSArray *posts) {
//        
//        //配置post cell内容
////        RemotePost *post = [posts objectAtIndex:indexPath.row];
////        cell.postCellPostTitle.text = post.title;
////        cell.postCellPostContent.attributedText = [[NSAttributedString alloc] initWithData:[post.content dataUsingEncoding:NSUnicodeStringEncoding] options:@{ NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType } documentAttributes:nil error:nil];
////        cell.postCellThumb.image = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:post.postThumbnailPath]]];
////        cell.postCellPostDate.text = [NSString stringWithFormat:@"%@",post.date];
//        
//        
//        
//        
//    } failure:^(NSError *error) {
//        NSLog(@"oh no");
//    }];
    
    // Post Cell头部配置
    cell.postCellBlogName.text = self.blog.name;
    
    
    return cell;
}

//即将显示cell
- (void)tableView:(UITableView *)tableView willDisplayCell:(PostCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath{
    //去掉cell背景
    cell.backgroundColor = [UIColor clearColor];
    //cell边框阴影效果
    UIView *view = cell.postCellWrapper;
    UIBezierPath *shadowPath = [UIBezierPath bezierPathWithRect:CGRectMake(view.bounds.origin.x, view.bounds.origin.y, cell.bounds.size.width-8, cell.bounds.size.height-21)];
    view.layer.masksToBounds = NO;
    view.layer.shadowColor = [UIColor colorWithRed:89/255.0 green:120/255.0 blue:144/255.0 alpha:1.0].CGColor;
    view.layer.shadowOffset = CGSizeMake(0.0f, 0.0f);
    view.layer.shadowOpacity = 0.2f;
    view.layer.shadowPath = shadowPath.CGPath;
}

//cell 高度
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    PostCell *cell = (PostCell *)[self tableView:tableView cellForRowAtIndexPath:indexPath];
    //cell 高度
    CGRect titleRect = [cell.postCellPostTitle.text boundingRectWithSize:CGSizeMake([UIScreen mainScreen].bounds.size.width - 24.0, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName : [UIFont fontWithName:@"Georgia" size:16.0]} context:nil];
    CGRect contentRect = [cell.postCellPostContent.text boundingRectWithSize:CGSizeMake([UIScreen mainScreen].bounds.size.width - 24.0, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName : [UIFont fontWithName:@"Georgia" size:14.0]} context:nil];
    CGFloat thumbHeight = 0.75 * ([UIScreen mainScreen].bounds.size.width - 8);
    CGFloat height = 188.0 + titleRect.size.height + contentRect.size.height + thumbHeight;
    return height;
}


/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark - Fetch posts
- (void)fetchPostsForBlog{
    Blog *blog = self.blog;
    if (fetched) {
        return;
    }
    [PostControll getPostsOfType:@"post" forBlog:blog options:@{@"post_status":@"publish",@"number":@5} success:^(NSArray *posts) {
        
        self.posts = [posts mutableCopy];
        
        
        fetched = YES;
        
        
    } failure:^(NSError *error) {
        NSLog(@"oh no");
    }];
}


@end
