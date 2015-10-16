//
//  RemotePost.h
//  WordPressKit
//
//  Created by wuxueqian on 15/9/23.
//  Copyright (c) 2015年 wuxueqian. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RemotePost : NSObject
@property (nonatomic, strong) NSNumber *postID;
@property (nonatomic, strong) NSNumber *siteID;
@property (nonatomic, strong) NSString *authorAvatarURL;
@property (nonatomic, strong) NSString *authorDisplayName;
@property (nonatomic, strong) NSString *authorEmail;
@property (nonatomic, strong) NSString *authorURL;
@property (nonatomic, strong) NSNumber *authorID;
@property (nonatomic, strong) NSDate *date;
@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSURL *URL;
@property (nonatomic, strong) NSURL *shortURL;
@property (nonatomic, strong) NSString *content;
@property (nonatomic, strong) NSString *excerpt;
@property (nonatomic, strong) NSString *slug;
@property (nonatomic, strong) NSString *status;
@property (nonatomic, strong) NSString *password;
@property (nonatomic, strong) NSNumber *parentID;
@property (nonatomic, strong) NSNumber *postThumbnailID;
@property (nonatomic, strong) NSString *postThumbnailPath;
@property (nonatomic, strong) NSString *type;
@property (nonatomic, strong) NSString *format;

@property (nonatomic, strong) NSNumber *commentCount;
@property (nonatomic, strong) NSNumber *likeCount;

@property (nonatomic, strong) NSArray *categories;
@property (nonatomic, strong) NSArray *tags;
@property (nonatomic, strong) NSString *pathForDisplayImage;
@property (nonatomic, assign) BOOL isFeaturedImageChanged;


/**
 自定义字段数组. 每个值均为一个dictionary, 结构{ID, key, value}
 */
@property (nonatomic, strong) NSArray *metadata;

// Featured images?
// Geolocation?
// Attachments?
// Metadata?
@end
