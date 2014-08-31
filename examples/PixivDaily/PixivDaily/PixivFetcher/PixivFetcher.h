//
//  PixivFetcher.h
//  PixivDaily
//
//  Created by Zhou Hao on 14-8-29.
//  Copyright (c) 2014年 Kastark. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "IllustModel.h"

typedef void (^SuccessIllustBlock)(IllustModel *illust, BOOL isIllust);
typedef void (^SuccessIllustListBlock)(NSArray *illusts, BOOL isIllust);
typedef void (^AsyncCompletionBlock)(NSURLResponse *response, NSData *data, NSError *connectionError);
typedef void (^FailureFetchBlock)(NSURLResponse *response, NSInteger responseCode, NSData *data, NSError *connectionError);

/**
 *  API param define
 */
#define PIXIV_RANKING_CONTENT_ALL       @"all"
#define PIXIV_RANKING_CONTENT_MALE      @"male"
#define PIXIV_RANKING_CONTENT_FEMALE    @"female"
#define PIXIV_RANKING_CONTENT_ORIGINAL  @"original"

#define PIXIV_RANKING_MODE_DAY          @"day"
#define PIXIV_RANKING_MODE_WEEK         @"week"
#define PIXIV_RANKING_MODE_MONTH        @"month"

@interface PixivFetcher : NSObject

/**
 *  Parse NSArray of pixiv data to IllustModel
 *
 *  @param data NSArray of pixiv return
 *
 *  @return IllustModel for data
 */
+ (IllustModel *)parseDataArrayToModel:(NSArray *)data;

/**
 *  ranking.php
 *
 *  @param content [all, male, female, original]
 *  @param mode    [day, week, month]
 *  @param p       [1-n]
 *
 *  @return NSArray of IllustModel
 */
+ (void)API_getRanking:(NSUInteger)page mode:(NSString *)mode content:(NSString *)content
                onSuccess:(SuccessIllustListBlock)onSuccessHandler onFailure:(FailureFetchBlock)onFailureHandler;

/**
 *  illust.php
 *
 *  @param illust_id [id for illust]
 *
 *  @return IllustModel
 */
+ (void)API_getIllust:(NSUInteger)illustId
            onSuccess:(SuccessIllustBlock)onSuccessHandler onFailure:(FailureFetchBlock)onFailureHandler;

/**
 *  member_illust.php
 *
 *  @param id       [id for author]
 *  @param p        [1-n]
 *
 *  @return NSArray of IllustModel
 */
+ (void)API_getMemberIllust:(NSUInteger)authorId page:(NSUInteger)page
                  onSuccess:(SuccessIllustListBlock)onSuccessHandler onFailure:(FailureFetchBlock)onFailureHandler;

/**
 *  user.php
 *
 *  @param user_id  [id for author]
 *
 *  @return IllustModel (isIllust = NO)
 */
+ (void)API_getUser:(NSUInteger)authorId
          onSuccess:(SuccessIllustListBlock)onSuccessHandler onFailure:(FailureFetchBlock)onFailureHandler;

@end
