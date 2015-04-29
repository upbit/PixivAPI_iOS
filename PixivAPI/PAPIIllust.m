//
//  PAPIIllust.m
//
//  Created by Zhou Hao on 14/10/19.
//  Copyright (c) 2014 Zhou Hao. All rights reserved.
//

#import "PAPIIllust.h"
#import "PixivDefines.h"

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

+ (PAPIIllust *)parseRawDictionaryToModel:(NSDictionary *)jsonData isWork:(BOOL)isWork
{
    NSDictionary *data = nil;
    if (isWork) {
        data = jsonData;
    } else {
        if ([jsonData objectForKey:@"work"]) {
            data = jsonData[@"work"];
        }
    }
    
    if (!data) {
        NSLog(@"unknow data: %@", jsonData);
        return nil;
    }
    if (![data objectForKey:@"id"] || ![data objectForKey:@"title"]) {
        NSLog(@"data.id or data.title not found");
        return nil;
    }
    
    PAPIIllust *illust = [[PAPIIllust alloc] init];
    illust.raw = @{
        @"response": @[data],
    };
    illust.response = data;
    return illust;
}

- (NSDictionary *)toObject
{
    return self.response;
}

#pragma mark - Illust properties

- (NSInteger)safeIntegerValue:(id)data
{
    if (data == [NSNull null]) {
        return PIXIV_INT_INVALID;
    }
    return [data integerValue];
}

- (NSInteger)publicity
{
    return [self safeIntegerValue:self.response[@"publicity"]];
}

- (BOOL)is_manga
{
    return [self.response[@"is_manga"] integerValue] ? YES : NO;
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
    return [self safeIntegerValue:self.favorited_count[@"private"]];
}
- (NSInteger)favorited_public
{
    return [self safeIntegerValue:self.favorited_count[@"public"]];
}
- (NSInteger)score
{
    return [self safeIntegerValue:self.stats[@"score"]];
}
- (NSInteger)views_count
{
    return [self safeIntegerValue:self.stats[@"views_count"]];
}
- (NSInteger)scored_count
{
    return [self safeIntegerValue:self.stats[@"scored_count"]];
}
- (NSInteger)commented_count
{
    return [self safeIntegerValue:self.stats[@"commented_count"]];
}

- (NSInteger)favorite_id
{
    return [self safeIntegerValue:self.response[@"favorite_id"]];
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
    return [self.response[@"is_liked"] integerValue] ? YES : NO;
}

- (NSInteger)page_count
{
    return [self safeIntegerValue:self.response[@"page_count"]];
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
    return [self safeIntegerValue:self.response[@"height"]];
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
    return [self.user[@"is_friend"] integerValue] ? YES : NO;
}
- (BOOL)is_following
{
    return [self.user[@"is_following"] integerValue] ? YES : NO;
}
- (BOOL)is_follower
{
    return [self.user[@"is_follower"] integerValue] ? YES : NO;
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
    return [self safeIntegerValue:self.user[@"id"]];
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
    return [self safeIntegerValue:self.response[@"id"]];
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
    return [self safeIntegerValue:self.response[@"width"]];
}

- (NSDictionary *)metadata
{
    if ([self.response[@"metadata"] isKindOfClass:[NSDictionary class]]) {
        return self.response[@"metadata"];
    }
    return nil;
}
- (NSArray *)pages
{
    if ([self.metadata[@"pages"] isKindOfClass:[NSArray class]]) {
        return self.metadata[@"pages"];
    }
    return nil;
}

- (NSString *)true_url_large
{
    if (!self.pages) {
        if (self.page_count > 1) {
            NSString *url = self.url_large;
            NSRange range = [url rangeOfString:@"_p0" options:NSBackwardsSearch];
            if (range.length > 0) {
                // New illust with _p0 ext, just return url_large
                return url;
            } else {
                // Old illust storage, add _p0 in url_large.ext
                // FIX BUG: some illust has "?timestamp" at end, so seach backward
                NSRange ext_dot = [url rangeOfString:@"." options:NSBackwardsSearch];
                NSString *url_base = [url substringWithRange:NSMakeRange(0, ext_dot.location)];
                NSString *url_ext = [url substringFromIndex:ext_dot.location];
                return [NSString stringWithFormat:@"%@_p0%@", url_base, url_ext];
            }
        } else {
            return self.url_large;
        }
    } else {
        return [self.pages firstObject][@"image_urls"][@"large"];
    }
}

#pragma mark - NSCoding

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];
    if (!self) {
        return nil;
    }
    
    self.raw = [aDecoder decodeObjectForKey:@"raw"];
    self.response = [aDecoder decodeObjectForKey:@"response"];
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:self.raw forKey:@"raw"];
    [aCoder encodeObject:self.response forKey:@"response"];
}

@end
