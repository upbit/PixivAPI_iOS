//
//  IllustBaseInfo.m
//  PixivDaily
//
//  Created by Zhou Hao on 14-8-29.
//  Copyright (c) 2014年 Kastark. All rights reserved.
//

#import "IllustBaseInfo.h"

// URL for page Referer
#define PIXIV_PAGE_URL          @"http://www.pixiv.net/"
#define PIXIV_ILLUST_PAGE_URL   @"http://www.pixiv.net/member_illust.php?mode=medium&illust_id="
#define PIXIV_MEMBER_PAGE_URL   @"http://www.pixiv.net/member.php?id="

@implementation IllustBaseInfo

- (NSString *)description
{
    return [NSString stringWithFormat:@"author_id=%lu illust_id=%lu, %@", (unsigned long)self.authorId, (unsigned long)self.illustId, self.mobileURL];
}

- (NSArray *)toDataArray
{
    NSMutableArray *array = [[NSMutableArray alloc] initWithCapacity:MIN_PIXIV_RECORD_FIELDS_NUM];
    
    [array setObject:[NSString stringWithFormat:@"%lu", (unsigned long)self.illustId] atIndexedSubscript:0];
    [array setObject:[NSString stringWithFormat:@"%lu", (unsigned long)self.authorId] atIndexedSubscript:1];
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
    [array setObject:[NSString stringWithFormat:@"%ld", (long)self.feedbacks] atIndexedSubscript:15];
    [array setObject:[NSString stringWithFormat:@"%ld", (long)self.points] atIndexedSubscript:16];
    [array setObject:[NSString stringWithFormat:@"%ld", (long)self.views] atIndexedSubscript:17];
    [array setObject:self.comment atIndexedSubscript:18];
    [array setObject:[NSString stringWithFormat:@"%ld", (long)self.pages] atIndexedSubscript:19];
    [array setObject:@"" atIndexedSubscript:20];
    [array setObject:@"" atIndexedSubscript:21];
    [array setObject:[NSString stringWithFormat:@"%ld", (long)self.bookmarks] atIndexedSubscript:22];
    [array setObject:@"" atIndexedSubscript:23];
    [array setObject:self.username atIndexedSubscript:24];
    [array setObject:@"" atIndexedSubscript:25];
    [array setObject:[NSString stringWithFormat:@"%ld", (long)self.r18] atIndexedSubscript:26];
    
    //for (int i = ; i < MIN_PIXIV_RECORD_FIELDS_NUM; i++)
    //    [array setObject:@"" atIndexedSubscript:i];
    
    return array;
}

/**
 *  Parse payload NSArray to IllustBaseInfo
 *
 *  @param array payload property array from pixiv
 *
 *  @return illust class
 */
+ (IllustBaseInfo *)parseDataArrayToModel:(NSArray *)data
{
    if ([data count] < MIN_PIXIV_RECORD_FIELDS_NUM)
        return nil;
    
    IllustBaseInfo *illust = [[IllustBaseInfo alloc] init];
    
    illust.illustId = [(NSString *)data[0] intValue];
    illust.authorId = [(NSString *)data[1] intValue];
    illust.ext = data[2];
    illust.title = data[3];
    illust.server = data[4];
    illust.authorName = data[5];
    illust.thumbURL = data[6];
    illust.mobileURL = data[9];
    illust.date = data[12];
    illust.tags = [data[13] componentsSeparatedByString:@" "];
    illust.tool = data[14];
    illust.feedbacks = [(NSString *)data[15] intValue];
    illust.points = [(NSString *)data[16] intValue];
    illust.views = [(NSString *)data[17] intValue];
    illust.comment = data[18];
    illust.pages = [(NSString *)data[19] intValue];
    illust.bookmarks = [(NSString *)data[22] intValue];
    illust.username = data[24];
    illust.r18 = [(NSString *)data[26] intValue];
    
    return illust;
}

- (NSString *)refererURL
{
    if (self.illustId != PIXIV_ID_INVALID)
        return [NSString stringWithFormat:@"%@%lu", PIXIV_ILLUST_PAGE_URL, (unsigned long)self.illustId];
    else if (self.authorId != PIXIV_ID_INVALID)
        return [NSString stringWithFormat:@"%@%lu", PIXIV_MEMBER_PAGE_URL, (unsigned long)self.authorId];
    else
        return PIXIV_PAGE_URL;
}

@end
