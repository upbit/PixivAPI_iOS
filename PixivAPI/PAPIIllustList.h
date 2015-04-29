//
//  PAPIIllustList.h
//
//  Created by Zhou Hao on 14/10/19.
//  Copyright (c) 2014 Zhou Hao. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "PAPIIllust.h"

@interface PAPIIllustList : NSObject <NSCoding>

/**
 *  Parse NSDictionary of PAPI json result to PAPIIllustList
 *
 *  @param NSDictionary of PAPI json result
 *
 *  @return PAPIIllustList object
 */
+ (PAPIIllustList *)parseJsonDictionaryToModelList:(NSDictionary *)jsonData isWork:(BOOL)isWork;

- (NSArray *)toObjectList;

@property (strong, nonatomic) NSDictionary *raw;            // origin json data from PAPI
@property (strong, nonatomic) NSDictionary *pagination;     // pagination info

@property (strong, nonatomic) NSArray *illusts;             // of PAPIIllust
@property (nonatomic, readonly) NSInteger count;

#pragma mark - pagination properties

@property (nonatomic, readonly)         NSInteger       per_page;
@property (nonatomic, readonly)         NSInteger       total;
@property (nonatomic, readonly)         NSInteger       pages;

@property (nonatomic, readonly)         NSInteger       current;
@property (nonatomic, readonly)         NSInteger       next;
@property (nonatomic, readonly)         NSInteger       previous;

@end
