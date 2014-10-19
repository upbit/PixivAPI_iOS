//
//  PAPIIllust.m
//  PixixWalker
//
//  Created by Zhou Hao on 14/10/19.
//  Copyright (c) 2014年 Kastark. All rights reserved.
//

#import "PAPIIllust.h"

@implementation PAPIIllust

- (NSString *)description
{
    return [NSString stringWithFormat:@"Illust: [%@(id=%ld)] %@(id=%ld), size=%ldx%ld",
             self.name, (long)self.author_id, self.title, (long)self.illust_id, (long)self.width, (long)self.height];
}

+ (PAPIIllust *)parseJsonDictionaryToModel:(NSDictionary *)jsonData
{
    if (![jsonData objectForKey:@"count"] || ![jsonData objectForKey:@"response"]) {
        NSLog(@"jsonData.count or jsonData.response not found");
        return nil;
    }
    if ([[jsonData objectForKey:@"count"] integerValue] != 1) {
        NSLog(@"response count %ld > 1", (long)[[jsonData objectForKey:@"count"] integerValue]);
        return nil;
    }
    
    PAPIIllust *illust = [[PAPIIllust alloc] init];
    illust.raw = jsonData;
    illust.response = [jsonData[@"response"] firstObject];
    return illust;
}

+ (PAPIIllust *)parseRawDictionaryToModel:(NSDictionary *)jsonData
{
    if (![jsonData objectForKey:@"id"] || ![jsonData objectForKey:@"title"]) {
        NSLog(@"jsonData.id or jsonData.title not found");
        return nil;
    }
    
    PAPIIllust *illust = [[PAPIIllust alloc] init];
    illust.raw = @{
        @"response": @[jsonData],
    };
    illust.response = jsonData;
    return illust;
}

#pragma mark - Illust properties

- (NSInteger)publicity
{
    return [self.response[@"publicity"] integerValue];
}

- (BOOL)is_manga
{
    return self.response[@"is_manga"] ? YES : NO;
}

- (NSDictionary *)stats
{
    if ([self.response[@"stats"] isKindOfClass:[NSDictionary class]]) {
        return self.response[@"stats"];
    }
    return nil;
}
- (NSDictionary *)favorited_count
{
    if ([self.stats[@"favorited_count"] isKindOfClass:[NSDictionary class]]) {
        return self.stats[@"favorited_count"];
    }
    return nil;
}
- (NSInteger)favorited_private
{
    return [self.favorited_count[@"private"] integerValue];
}
- (NSInteger)favorited_public
{
    return [self.favorited_count[@"public"] integerValue];
}
- (NSInteger)score
{
    return [self.stats[@"score"] integerValue];
}
- (NSInteger)views_count
{
    return [self.stats[@"views_count"] integerValue];
}
- (NSInteger)scored_count
{
    return [self.stats[@"scored_count"] integerValue];
}
- (NSInteger)commented_count
{
    return [self.stats[@"commented_count"] integerValue];
}

- (NSInteger)favorite_id
{
    return [self.response[@"favorite_id"] integerValue];
}

- (NSArray *)tags
{
    return self.response[@"tags"];
}

- (NSString *)type
{
    return self.response[@"type"];
}

- (BOOL)is_liked
{
    return self.response[@"is_liked"] ? YES : NO;
}

- (NSInteger)page_count
{
    return [self.response[@"page_count"] integerValue];
}

- (NSDictionary *)image_urls
{
    if ([self.response[@"image_urls"] isKindOfClass:[NSDictionary class]]) {
        return self.response[@"image_urls"];
    }
    return nil;
}
- (NSString *)url_small
{
    return self.image_urls[@"small"];
}
- (NSString *)url_large
{
    return self.image_urls[@"large"];
}
- (NSString *)url_px_128x128
{
    return self.image_urls[@"px_128x128"];
}
- (NSString *)url_medium
{
    return self.image_urls[@"medium"];
}
- (NSString *)url_px_480mw
{
    return self.image_urls[@"px_480mw"];
}

- (NSInteger)height
{
    return [self.response[@"height"] integerValue];
}

- (NSString *)caption
{
    return self.response[@"caption"];
}

- (NSString *)tools
{
    NSArray *toolList = self.response[@"tools"];
    return [toolList componentsJoinedByString:@" "];
}

- (NSDictionary *)user
{
    if ([self.response[@"user"] isKindOfClass:[NSDictionary class]]) {
        return self.response[@"user"];
    }
    return nil;
}
- (NSString *)account
{
    return self.user[@"account"];
}
- (NSString *)name
{
    return self.user[@"name"];
}
- (BOOL)is_friend
{
    return self.user[@"is_friend"] ? YES : NO;
}
- (BOOL)is_following
{
    return self.user[@"is_following"] ? YES : NO;
}
- (BOOL)is_follower
{
    return self.user[@"is_follower"] ? YES : NO;
}
- (NSDictionary *)profile_image_urls
{
    if ([self.user[@"profile_image_urls"] isKindOfClass:[NSDictionary class]]) {
        return self.user[@"profile_image_urls"];
    }
    return nil;
}
- (NSString *)profile_url_px_50x50
{
    return self.profile_image_urls[@"px_50x50"];
}
- (NSString *)profile_url_px_170x170
{
    return self.profile_image_urls[@"px_170x170"];
}
- (NSInteger)author_id
{
    return [self.user[@"id"] integerValue];
}

- (NSString *)reuploaded_time
{
    return self.response[@"reuploaded_time"];
}

- (NSString *)created_time
{
    return self.response[@"created_time"];
}

- (NSString *)title
{
    return self.response[@"title"];
}

- (NSInteger)illust_id
{
    return [self.response[@"id"] integerValue];
}

- (NSString *)book_style
{
    return self.response[@"book_style"];
}

- (NSString *)age_limit
{
    return self.response[@"age_limit"];
}

- (NSInteger)width
{
    return [self.response[@"width"] integerValue];
}

- (NSDictionary *)metadata
{
    if ([self.response[@"metadata"] isKindOfClass:[NSDictionary class]]) {
        return self.response[@"metadata"];
    }
    return nil;
}
// for mutilpages

@end
