//
//  PAPIIllustList.m
//  PixixWalker
//
//  Created by Zhou Hao on 14/10/19.
//  Copyright (c) 2014年 Kastark. All rights reserved.
//

#import "PAPIIllustList.h"

@implementation PAPIIllustList

+ (PAPIIllustList *)parseJsonDictionaryToModelList:(NSDictionary *)jsonData
{
    if (![jsonData objectForKey:@"count"] || ![jsonData objectForKey:@"response"]) {
        NSLog(@"jsonData.count for jsonData.response not found");
        return nil;
    }
    if ([[jsonData objectForKey:@"count"] integerValue] != 1) {
        NSLog(@"response count %ld > 1", (long)[[jsonData objectForKey:@"count"] integerValue]);
        return nil;
    }
    
    PAPIIllustList *list = [[PAPIIllustList alloc] init];
    list.raw = jsonData;
    list.pagination = nil;
    if ([[jsonData objectForKey:@"pagination"] isKindOfClass:[NSDictionary class]]) {
        list.pagination = jsonData[@"pagination"];
    }
    
    // from response[] gen NSArray of PAPIIllust
    NSMutableArray *tmpIllusts = [[NSMutableArray alloc] init];
    for (NSDictionary *jsonIllust in jsonData[@"response"]) {
        PAPIIllust *illust = [PAPIIllust parseRawDictionaryToModel:jsonIllust];
        if (!illust) {
            NSLog(@"parseRaw() error:\n%@", jsonIllust);
            continue;
        }
        [tmpIllusts addObject:illust];
    }
    list.illusts = tmpIllusts;
    
    return list;
}

- (NSInteger)count
{
    return [self.illusts count];
}

#pragma mark - pagination properties

- (NSInteger)per_page
{
    return [self.pagination[@"per_page"] integerValue];
}

- (NSInteger)total
{
    return [self.pagination[@"total"] integerValue];
}

- (NSInteger)pages
{
    return [self.pagination[@"pages"] integerValue];
}

- (NSInteger)current
{
    return [self.pagination[@"current"] integerValue];
}

- (NSInteger)next
{
    return [self.pagination[@"next"] integerValue];
}

- (NSInteger)previous
{
    NSLog(@"%@", self.pagination[@"previous"]);
    return [self.pagination[@"previous"] integerValue];
}

@end
