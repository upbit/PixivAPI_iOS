//
//  PAPIAuthor.m
//  PixixWalker
//
//  Created by Zhou Hao on 14/10/19.
//  Copyright (c) 2014年 Kastark. All rights reserved.
//

#import "PAPIAuthor.h"

@implementation PAPIAuthor

- (NSString *)description
{
    return [NSString stringWithFormat:@"Author: %@(account=%@, id=%ld)", self.name, self.account, (long)self.author_id];
}

+ (PAPIAuthor *)parseJsonDictionaryToModel:(NSDictionary *)jsonData
{
    if (![jsonData objectForKey:@"count"] || ![jsonData objectForKey:@"response"]) {
        NSLog(@"jsonData.count for jsonData.response not found");
        return nil;
    }
    if ([[jsonData objectForKey:@"count"] integerValue] != 1) {
        NSLog(@"response count %ld > 1", (long)[[jsonData objectForKey:@"count"] integerValue]);
        return nil;
    }
    
    PAPIAuthor *author = [[PAPIAuthor alloc] init];
    author.raw = jsonData;
    author.response = [jsonData[@"response"] firstObject];
    return author;
}

#pragma mark - Author properties

- (NSDictionary *)profile
{
    return self.response[@"profile"];
}
- (NSArray *)tags
{
    return self.profile[@"tags"];
}
- (NSString *)introduction
{
    return self.profile[@"introduction"];
}
- (NSString *)gender
{
    return self.profile[@"gender"];
}
- (NSString *)contacts
{
    return self.profile[@"contacts"];
}
- (NSString *)job
{
    return self.profile[@"job"];
}
- (NSString *)location
{
    return self.profile[@"location"];
}
- (NSString *)workspace
{
    return self.profile[@"workspace"];
}
- (NSString *)birth_date
{
    return self.profile[@"birth_date"];
}
- (NSString *)homepage
{
    return self.profile[@"homepage"];
}
- (NSString *)blood_type
{
    return self.profile[@"blood_type"];
}

- (NSString *)account
{
    return self.response[@"account"];
}

- (NSString *)name
{
    return self.response[@"name"];
}

- (NSString *)email
{
    return self.response[@"email"];
}

- (NSString *)is_premium
{
    return self.response[@"is_premium"];
}

- (NSDictionary *)profile_image_urls
{
    if ([self.response[@"profile_image_urls"] isKindOfClass:[NSDictionary class]]) {
        return self.response[@"profile_image_urls"];
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
    return [self.response[@"id"] integerValue];
}

@end
