//
//  PAPIIllustList.m
//
//  Created by Zhou Hao on 14/10/19.
//  Copyright (c) 2014 Zhou Hao. All rights reserved.
//

#import "PAPIIllustList.h"
#import "PixivDefines.h"

@implementation PAPIIllustList

+ (PAPIIllustList *)parseJsonDictionaryToModelList:(NSDictionary *)jsonData isWork:(BOOL)isWork
{
    if (![jsonData objectForKey:@"count"] || ![jsonData objectForKey:@"response"]) {
        NSLog(@"jsonData.count for jsonData.response not found");
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
    NSArray *responseList = nil;
    if ([[jsonData[@"response"] firstObject] objectForKey:@"works"]) {
        responseList = [[jsonData[@"response"] firstObject] objectForKey:@"works"];
    } else {
        responseList = jsonData[@"response"];
    }
    for (NSDictionary *jsonIllust in responseList) {
        PAPIIllust *illust = [PAPIIllust parseRawDictionaryToModel:jsonIllust isWork:isWork];
        if (!illust) {
            NSLog(@"parseRaw() error:\n%@", jsonIllust);
            continue;
        }
        [tmpIllusts addObject:illust];
    }
    list.illusts = tmpIllusts;
    
    return list;
}

- (NSArray *)toObjectList;
{
    NSMutableArray *tmpIllusts = [[NSMutableArray alloc] init];
    for (PAPIIllust *illust in self.illusts) {
        [tmpIllusts addObject:illust.toObject];
    }
    return tmpIllusts;
}

- (NSInteger)count
{
    return [self.illusts count];
}

#pragma mark - pagination properties

- (NSInteger)safeIntegerValue:(id)data
{
    if (data == [NSNull null]) {
        return PIXIV_INT_INVALID;
    }
    return [data integerValue];
}

- (NSInteger)per_page
{
    return [self safeIntegerValue:self.pagination[@"per_page"]];
}

- (NSInteger)total
{
    return [self safeIntegerValue:self.pagination[@"total"]];
}

- (NSInteger)pages
{
    return [self safeIntegerValue:self.pagination[@"pages"]];
}

- (NSInteger)current
{
    return [self safeIntegerValue:self.pagination[@"current"]];
}

- (NSInteger)next
{
    return [self safeIntegerValue:self.pagination[@"next"]];
}

- (NSInteger)previous
{
    return [self safeIntegerValue:self.pagination[@"previous"]];
}

#pragma mark - NSCoding

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];
    if (!self) {
        return nil;
    }
    
    self.raw = [aDecoder decodeObjectForKey:@"raw"];
    self.pagination = [aDecoder decodeObjectForKey:@"pagination"];
    self.illusts = [aDecoder decodeObjectForKey:@"illusts"];
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:self.raw forKey:@"raw"];
    [aCoder encodeObject:self.pagination forKey:@"pagination"];
    [aCoder encodeObject:self.illusts forKey:@"illusts"];
}

@end
