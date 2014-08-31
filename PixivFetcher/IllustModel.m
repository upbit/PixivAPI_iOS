//
//  IllustModel.m
//  PixivDaily
//
//  Created by Zhou Hao on 14-8-29.
//  Copyright (c) 2014年 Kastark. All rights reserved.
//

#import "IllustModel.h"

// URL for page Referer
#define PIXIV_PAGE_URL          @"http://www.pixiv.net/"
#define PIXIV_ILLUST_PAGE_URL   @"http://www.pixiv.net/member_illust.php?mode=medium&illust_id="
#define PIXIV_MEMBER_PAGE_URL   @"http://www.pixiv.net/member.php?id="

@implementation IllustModel

- (NSString *)description
{
    return [NSString stringWithFormat:@"author_id=%u illust_id=%u, %@", self.authorId, self.illustId, self.mobileURL];
}

- (NSArray *)toDataArray
{
    NSMutableArray *array = [[NSMutableArray alloc] initWithCapacity:MIN_PIXIV_RECORD_FIELDS_NUM];
    
    [array setObject:[NSString stringWithFormat:@"%u", self.illustId] atIndexedSubscript:0];
    [array setObject:[NSString stringWithFormat:@"%u", self.authorId] atIndexedSubscript:1];
    [array setObject:self.ext atIndexedSubscript:2];
    [array setObject:self.title atIndexedSubscript:3];
    [array setObject:self.server atIndexedSubscript:4];
    [array setObject:self.authorName atIndexedSubscript:5];
    [array setObject:self.thumbURL atIndexedSubscript:6];
    [array setObject:@"" atIndexedSubscript:7];
    [array setObject:@"" atIndexedSubscript:8];
    [array setObject:self.mobileURL atIndexedSubscript:9];
    [array setObject:@"" atIndexedSubscript:10];
    [array setObject:@"" atIndexedSubscript:11];
    [array setObject:self.date atIndexedSubscript:12];
    [array setObject:[self.tags componentsJoinedByString:@" "] atIndexedSubscript:13];
    [array setObject:self.tool atIndexedSubscript:14];
    [array setObject:[NSString stringWithFormat:@"%u", self.feedbacks] atIndexedSubscript:15];
    [array setObject:[NSString stringWithFormat:@"%u", self.points] atIndexedSubscript:16];
    [array setObject:[NSString stringWithFormat:@"%u", self.views] atIndexedSubscript:17];
    [array setObject:self.comment atIndexedSubscript:18];
    [array setObject:[NSString stringWithFormat:@"%u", self.pages] atIndexedSubscript:19];
    [array setObject:@"" atIndexedSubscript:20];
    [array setObject:@"" atIndexedSubscript:21];
    [array setObject:[NSString stringWithFormat:@"%u", self.bookmarks] atIndexedSubscript:22];
    [array setObject:@"" atIndexedSubscript:23];
    [array setObject:self.username atIndexedSubscript:24];
    for (int i = 25; i < MIN_PIXIV_RECORD_FIELDS_NUM; i++)
        [array setObject:@"" atIndexedSubscript:i];
    
    return array;
}

- (NSString *)refererURL
{
    if (self.illustId != PIXIV_ID_INVALID)
        return [NSString stringWithFormat:@"%@%u", PIXIV_ILLUST_PAGE_URL, self.illustId];
    else if (self.authorId != PIXIV_ID_INVALID)
        return [NSString stringWithFormat:@"%@%u", PIXIV_MEMBER_PAGE_URL, self.authorId];
    else
        return PIXIV_PAGE_URL;
}

- (NSString *)baseURL
{
    NSRange range = [self.mobileURL rangeOfString:@"/mobile/" options:NSBackwardsSearch];
    return [self.mobileURL substringWithRange:NSMakeRange(0, range.location+1)];
}

- (NSString *)imageURL
{
    return [NSString stringWithFormat:@"%@%u.%@", [self baseURL], self.illustId, self.ext];
}

- (NSArray *)pageURLs
{
    if (self.pages == 0) {
        return @[self.imageURL];
    } else {
        NSMutableArray *result = [[NSMutableArray alloc] init];
        NSString *baseURL = [self baseURL];
        for (NSUInteger i = 0; i < self.pages; i++) {
            [result addObject:[NSString stringWithFormat:@"%@%u_big_p%u.%@", baseURL, self.illustId, i, self.ext]];
        }
        return result;
    }
}

@end
