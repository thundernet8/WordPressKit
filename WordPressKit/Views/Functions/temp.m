//
//  temp.m
//  WordPressKit
//
//  Created by wuxueqian on 15/10/24.
//  Copyright (c) 2015年 wuxueqian. All rights reserved.
//

#import "temp.h"

@interface temp()
@property (weak, nonatomic) IBOutlet UITextView *text;

@end

@implementation temp

- (void)viewDidLoad
{
    self.navigationController.navigationBarHidden = NO;
    NSError *error;
    NSString *sourceHtml;
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *cachePath = [NSHomeDirectory() stringByAppendingPathComponent:@"Library/Caches/Funcs"];
    //需要判断是否存在缓存文件夹
    if (![fileManager fileExistsAtPath:cachePath]) {
        [fileManager createDirectoryAtPath:cachePath withIntermediateDirectories:YES attributes:nil error:nil];
    }
    NSString *cacheFilePath = [cachePath stringByAppendingPathComponent:[NSString stringWithFormat:@"%i.fcache", (int)_item.itemId]];
    if ([fileManager fileExistsAtPath:cacheFilePath] && [[NSString stringWithContentsOfFile:cacheFilePath encoding:NSUTF8StringEncoding error:&error] lengthOfBytesUsingEncoding:NSUTF8StringEncoding] > 0) {
        sourceHtml = [NSString stringWithContentsOfFile:cacheFilePath encoding:NSUTF8StringEncoding error:&error];
    }else{
            //采用Github源的代码文件
            NSString *gitSourceBaseUrl = @"https://developer.wordpress.org/reference/functions/";
            NSString *completeUrl = [NSString stringWithFormat:@"%@%@", gitSourceBaseUrl, _item.name];
            NSURL *url = [[NSURL alloc] initWithString:completeUrl];
            sourceHtml = [NSString stringWithContentsOfURL:url encoding:NSUTF8StringEncoding error:&error];
    }
    NSString *searchText = sourceHtml;
    NSRange range = [searchText rangeOfString:@"<article[^<>]+?>(.|[\r\n])*?</article>" options:NSRegularExpressionSearch];
    if (range.location != NSNotFound) {
        sourceHtml = [searchText substringWithRange:range];
        NSLog(@"%@", sourceHtml);
    }
    
        
        //写入缓存
        [fileManager createFileAtPath:cacheFilePath contents:[sourceHtml dataUsingEncoding:NSUTF8StringEncoding] attributes:nil];
    self.text.text = sourceHtml;
}







@end
