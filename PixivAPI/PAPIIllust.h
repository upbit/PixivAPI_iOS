//
//  PAPIIllust.h
//
//  Created by Zhou Hao on 14/10/19.
//  Copyright (c) 2014 Zhou Hao. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PAPIIllust : NSObject <NSCoding>

/**
 *  Parse NSDictionary of PAPI json result to PAPIIllust
 *
 *  @param NSDictionary of PAPI json result
 *
 *  @return PAPIIllust object
 */
+ (PAPIIllust *)parseJsonDictionaryToModel:(NSDictionary *)jsonData;
+ (PAPIIllust *)parseRawDictionaryToModel:(NSDictionary *)jsonData isWork:(BOOL)isWork;

- (NSDictionary *)toObject;

@property (strong, nonatomic) NSDictionary *raw;            // origin json data from PAPI
@property (strong, nonatomic) NSDictionary *response;       // response[0] for illust

#pragma mark - Illust properties

@property (nonatomic, readonly)         NSInteger       illust_id;
@property (strong, nonatomic, readonly) NSString        *title;
@property (strong, nonatomic, readonly) NSString        *type;
@property (nonatomic, readonly)         NSInteger       page_count;

@property (strong, nonatomic, readonly) NSArray         *tags;
@property (strong, nonatomic, readonly) NSString        *caption;
@property (strong, nonatomic, readonly) NSString        *tools;

@property (strong, nonatomic, readonly) NSString        *age_limit;
@property (nonatomic, readonly)         NSInteger       publicity;
@property (nonatomic, readonly)         BOOL            is_manga;

@property (strong, nonatomic, readonly) NSDictionary    *stats;
@property (strong, nonatomic, readonly) NSDictionary    *favorited_count;
@property (nonatomic, readonly)         NSInteger       favorited_private;
@property (nonatomic, readonly)         NSInteger       favorited_public;
@property (nonatomic, readonly)         NSInteger       views_count;
@property (nonatomic, readonly)         NSInteger       score;
@property (nonatomic, readonly)         NSInteger       scored_count;
@property (nonatomic, readonly)         NSInteger       commented_count;

@property (nonatomic, readonly)         NSInteger       favorite_id;
@property (nonatomic, readonly)         BOOL            is_liked;

@property (strong, nonatomic, readonly) NSDictionary    *image_urls;
@property (strong, nonatomic, readonly) NSString        *url_px_128x128;
@property (strong, nonatomic, readonly) NSString        *url_px_480mw;
@property (strong, nonatomic, readonly) NSString        *url_large;
@property (strong, nonatomic, readonly) NSString        *url_small;
@property (strong, nonatomic, readonly) NSString        *url_medium;

@property (nonatomic, readonly)         NSInteger       width;
@property (nonatomic, readonly)         NSInteger       height;

@property (strong, nonatomic, readonly) NSDictionary    *user;
@property (nonatomic, readonly)         NSInteger       author_id;
@property (strong, nonatomic, readonly) NSString        *account;
@property (strong, nonatomic, readonly) NSString        *name;
@property (nonatomic, readonly)         BOOL            is_friend;
@property (nonatomic, readonly)         BOOL            is_following;
@property (nonatomic, readonly)         BOOL            is_follower;
@property (strong, nonatomic, readonly) NSDictionary    *profile_image_urls;
@property (strong, nonatomic, readonly) NSString        *profile_url_px_50x50;
@property (strong, nonatomic, readonly) NSString        *profile_url_px_170x170;

@property (strong, nonatomic, readonly) NSString        *created_time;
@property (strong, nonatomic, readonly) NSString        *reuploaded_time;
@property (strong, nonatomic, readonly) NSString        *book_style;

@property (strong, nonatomic, readonly) NSDictionary    *metadata;
@property (strong, nonatomic, readonly) NSArray         *pages;

@property (strong, nonatomic, readonly) NSString        *true_url_large;

@end
