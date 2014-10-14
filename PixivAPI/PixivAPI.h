//
//  PixivAPI.h
//
//  Created by Zhou Hao on 14-10-8.
//  Copyright (c) 2014年 Kastark. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "IllustBaseInfo.h"

typedef void (^SuccessLoginBlock)(NSString *raw_cookie);
typedef void (^SuccessIllustBlock)(IllustBaseInfo *illust, BOOL isIllust);
typedef void (^SuccessIllustListBlock)(NSArray *illusts, BOOL isIllust);
typedef void (^SuccessDictionaryBlock)(NSDictionary *result);
typedef void (^AsyncCompletionBlock)(NSURLResponse *response, NSData *data, NSError *connectionError);
typedef void (^FailureFetchBlock)(NSURLResponse *response, NSInteger responseCode, NSData *data, NSError *connectionError);

@interface PixivAPI : NSObject

@property (strong, nonatomic) NSString *access_token;
@property (strong, nonatomic) NSString *session;

#pragma mark - common

// Init API with default URLs
- (instancetype)init;

/**
 *  Async Fetch URL
 *
 *  @param method  HTTP/HTTPS method (GET or POST)
 *  @param url     base url
 *  @param handler (^AsyncCompletionBlock) for completion
 *  @param headers header for request
 *  @param params  url encode params for GET/POST
 *  @param data    payload for POST
 *
 *  @return response NSURLResponse for response
 *  @return data     response data
 *  @return connectionError
 */
- (void)asyncURLFetch:(NSString *)method url:(NSString *)url
    completionHandler:(AsyncCompletionBlock)handler
              headers:(NSDictionary *)headers params:(NSDictionary *)params data:(NSDictionary *)data;

#pragma mark - login

/**
 *  oauth.secure.pixiv.net/auth/token
 */
- (void)login:(NSString *)username password:(NSString *)password
    onSuccess:(SuccessLoginBlock)onSuccessHandler onFailure:(FailureFetchBlock)onFailureHandler;

/**
 *  Set session string for PHPSESSID (get PHPSESSID from api.session)
 *
 *  @param access_token [last AccessToken from api.access_token]
 *  @param session      [last PHPSESSID from api.session]
 *
 */
- (void)set_auth:(NSString *)access_token session:(NSString *)session;


#pragma mark - SAPI exports

/**
 *  ranking.php
 *
 *  @param page    [1-n]
 *  @param mode    [day, week, month]
 *  @param content [all, male, female, original]
 *
 *  @return NSArray of IllustBaseInfo
 */
- (void)SAPI_ranking:(NSUInteger)page mode:(NSString *)mode content:(NSString *)content
           onSuccess:(SuccessIllustListBlock)onSuccessHandler onFailure:(FailureFetchBlock)onFailureHandler;

/**
 *  过去排行
 *  ranking_log.php
 *
 *  @param Date_Year        2014
 *  @param Date_Month       4
 *  @param Date_Day         15
 *  @param mode             [daily, weekly, monthly, male, female, rookie], require_auth[daily_r18, weekly_r18, male_r18, female_r18, r18g]
 *  @param page             [1-n]
 *  @param requireAuth      YES - for r18 result
 *
 *  @return NSArray of IllustBaseInfo
 */
- (void)SAPI_ranking_log:(NSUInteger)Date_Year month:(NSUInteger)Date_Month day:(NSUInteger)Date_Day
                    mode:(NSString *)mode page:(NSUInteger)page requireAuth:(BOOL)requireAuth
               onSuccess:(SuccessIllustListBlock)onSuccessHandler onFailure:(FailureFetchBlock)onFailureHandler;

/**
 *  作品信息 (新版本已使用 PAPI_works: 代替)
 *  illust.php
 *
 *  @param illust_id        [id for illust]
 *  @param requireAuth      YES - for r18 result
 *
 *  @return IllustBaseInfo
 */
- (void)SAPI_illust:(NSUInteger)illust_id requireAuth:(BOOL)requireAuth
          onSuccess:(SuccessIllustBlock)onSuccessHandler onFailure:(FailureFetchBlock)onFailureHandler;

/**
 *  用户作品列表
 *  member_illust.php
 *
 *  @param author_id        [id for author]
 *  @param page             [1-n]
 *  @param requireAuth      YES - for r18 result
 *
 *  @return NSArray of IllustBaseInfo
 */
- (void)SAPI_member_illust:(NSUInteger)author_id page:(NSUInteger)page requireAuth:(BOOL)requireAuth
                 onSuccess:(SuccessIllustListBlock)onSuccessHandler onFailure:(FailureFetchBlock)onFailureHandler;

/**
 *  用户资料 (新版本已使用 PAPI_users: 代替)
 *  user.php
 *
 *  @param user_id  [id for author]
 *
 *  @return IllustBaseInfo (isIllust = NO)
 */
- (void)SAPI_user:(NSUInteger)author_id
        onSuccess:(SuccessIllustBlock)onSuccessHandler onFailure:(FailureFetchBlock)onFailureHandler;

/**
 *  用户收藏 (新版本已使用 PAPI_users_favorite_works: 代替)
 *  bookmark.php (Authentication required)
 *
 *  @param author_id [id for author]
 *  @param page      [1-n]
 *
 *  @return NSArray of IllustBaseInfo
 */
- (void)SAPI_bookmark:(NSUInteger)author_id page:(NSUInteger)page
            onSuccess:(SuccessIllustListBlock)onSuccessHandler onFailure:(FailureFetchBlock)onFailureHandler;

/**
 *  bookmark_user_all.php (Authentication required)
 *
 *  @param author_id [id for author]
 *  @param page      [1-n]
 *
 *  @return NSArray of IllustBaseInfo (isIllust = NO)
 */
- (void)SAPI_bookmark_user_all:(NSUInteger)author_id page:(NSUInteger)page
                     onSuccess:(SuccessIllustListBlock)onSuccessHandler onFailure:(FailureFetchBlock)onFailureHandler;

/**
 *  mypixiv_all.php
 *
 *  @param author_id [id for author]
 *  @param page      [1-n]
 *
 *  @return NSArray of IllustBaseInfo (isIllust = NO)
 */
- (void)SAPI_mypixiv_all:(NSUInteger)author_id page:(NSUInteger)page
               onSuccess:(SuccessIllustListBlock)onSuccessHandler onFailure:(FailureFetchBlock)onFailureHandler;

#pragma mark - Public-API exports

/**
 *  作品详细
 *  works/<illust_id>.json
 *
 *  @return NSDictionary of works(count=1)
 */
- (void)PAPI_works:(NSUInteger)illust_id
         onSuccess:(SuccessDictionaryBlock)onSuccessHandler onFailure:(FailureFetchBlock)onFailureHandler;
/**
 *  用户资料
 *  users/<author_id>.json
 *
 *  @return NSDictionary of users(count=1)
 */
- (void)PAPI_users:(NSUInteger)author_id
         onSuccess:(SuccessDictionaryBlock)onSuccessHandler onFailure:(FailureFetchBlock)onFailureHandler;

/**
 *  我的订阅
 *  me/feeds.json
 *
 *  @param show_r18         NO - hide r18 illusts
 *
 *  @return NSDictionary of works
 */
- (void)PAPI_me_feeds:(BOOL)show_r18
            onSuccess:(SuccessDictionaryBlock)onSuccessHandler onFailure:(FailureFetchBlock)onFailureHandler;

/**
 *  users/<author_id>/favorite_works.json
 *
 *  @param page             [1-n]
 *  @param publicity        YES - public; NO - private (only auth user)
 *
 *  @return NSDictionary of works
 */
- (void)PAPI_users_favorite_works:(NSUInteger)author_id page:(NSUInteger)page publicity:(BOOL)publicity
                        onSuccess:(SuccessDictionaryBlock)onSuccessHandler onFailure:(FailureFetchBlock)onFailureHandler;

@end
