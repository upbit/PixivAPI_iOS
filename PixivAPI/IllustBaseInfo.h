//
//  IllustBaseInfo.h
//  PixivDaily
//
//  Created by Zhou Hao on 14-8-29.
//  Copyright (c) 2014年 Kastark. All rights reserved.
//

#import <Foundation/Foundation.h>

#define PIXIV_ID_INVALID   (0)
#define MIN_PIXIV_RECORD_FIELDS_NUM (26)                        // AuthorModel(26) / IllustBaseInfo(30)

@interface IllustBaseInfo : NSObject

// Model to NSArray
- (NSArray *)toDataArray;

/**
 *  Parse NSArray of pixiv data to IllustBaseInfo
 *
 *  @param data NSArray of pixiv return
 *
 *  @return IllustBaseInfo for data
 */
+ (IllustBaseInfo *)parseDataArrayToModel:(NSArray *)data;

#pragma mark - Author / Illust common

@property (strong, nonatomic)   NSString        *raw;           // raw data

@property (nonatomic)           NSUInteger      authorId;       // data[1]
@property (strong, nonatomic)   NSString        *authorName;    // data[5]
@property (strong, nonatomic)   NSString        *thumbURL;      // data[6]
@property (strong, nonatomic)   NSString        *username;      // data[24]

// return Referer for Image donwload
- (NSString *)refererURL;

#pragma mark - Illust propertys

@property (nonatomic)           NSUInteger      illustId;       // data[0]
@property (strong, nonatomic)   NSString        *ext;           // data[2]
@property (strong, nonatomic)   NSString        *title;         // data[3]
@property (strong, nonatomic)   NSString        *server;        // data[4]
@property (strong, nonatomic)   NSString        *mobileURL;     // data[9]
@property (strong, nonatomic)   NSString        *date;          // data[12]
@property (strong, nonatomic)   NSArray         *tags;          // data[13] of NSString
@property (strong, nonatomic)   NSString        *tool;          // data[14]
@property (nonatomic)           NSInteger       feedbacks;      // data[15]
@property (nonatomic)           NSInteger       points;         // data[16]
@property (nonatomic)           NSInteger       views;          // data[17]
@property (strong, nonatomic)   NSString        *comment;       // data[18]
@property (nonatomic)           NSInteger       pages;          // data[19]
@property (nonatomic)           NSInteger       bookmarks;      // data[22]
@property (nonatomic)           NSInteger       r18;            // data[26]

@end
