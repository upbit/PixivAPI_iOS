//
//  PAPIAuthor.h
//
//  Created by Zhou Hao on 14/10/19.
//  Copyright (c) 2014 Zhou Hao. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PAPIAuthor : NSObject <NSCoding>

/**
 *  Parse NSDictionary of PAPI json result to PAPIAuthor
 *
 *  @param NSDictionary of PAPI json result
 *
 *  @return PAPIAuthor object
 */
+ (PAPIAuthor *)parseJsonDictionaryToModel:(NSDictionary *)jsonData;

- (NSDictionary *)toObject;

@property (strong, nonatomic) NSDictionary *raw;            // origin json data from PAPI
@property (strong, nonatomic) NSDictionary *response;       // response[0] for illust

#pragma mark - Author properties

@property (nonatomic, readonly)         NSInteger       author_id;
@property (strong, nonatomic, readonly) NSString        *account;
@property (strong, nonatomic, readonly) NSString        *name;

@property (strong, nonatomic, readonly) NSDictionary    *profile;
@property (strong, nonatomic, readonly) NSArray         *tags;
@property (strong, nonatomic, readonly) NSString        *introduction;
@property (strong, nonatomic, readonly) NSString        *gender;
@property (strong, nonatomic, readonly) NSString        *contacts;
@property (strong, nonatomic, readonly) NSString        *job;
@property (strong, nonatomic, readonly) NSString        *location;
@property (strong, nonatomic, readonly) NSString        *workspace;
@property (strong, nonatomic, readonly) NSString        *birth_date;
@property (strong, nonatomic, readonly) NSString        *homepage;
@property (strong, nonatomic, readonly) NSString        *blood_type;

@property (strong, nonatomic, readonly) NSString        *email;
@property (strong, nonatomic, readonly) NSString        *is_premium;

@property (strong, nonatomic, readonly) NSDictionary    *profile_image_urls;
@property (strong, nonatomic, readonly) NSString        *profile_url_px_50x50;
@property (strong, nonatomic, readonly) NSString        *profile_url_px_170x170;

@end
