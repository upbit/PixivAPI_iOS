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
 *  @param session last api.session
 */
- (void)set_session:(NSString *)session;


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
 *  ranking_log.php
 *
 *  @param mode             [daily, weekly, monthly, male, female]
 *  @param Date_Year        2014
 *  @param Date_Month       4
 *  @param Date_Day         15
 *  @param page             [1-n]
 *
 *  @return NSArray of IllustBaseInfo
 */
- (void)SAPI_ranking_log:(NSString *)mode year:(NSUInteger)Date_Year month:(NSUInteger)Date_Month day:(NSUInteger)Date_Day page:(NSUInteger)page
               onSuccess:(SuccessIllustListBlock)onSuccessHandler onFailure:(FailureFetchBlock)onFailureHandler;

/**
 *  illust.php
 *
 *  @param illust_id [id for illust]
 *
 *  @return IllustBaseInfo
 */
- (void)SAPI_illust:(NSUInteger)illust_id
          onSuccess:(SuccessIllustBlock)onSuccessHandler onFailure:(FailureFetchBlock)onFailureHandler;

/**
 *  member_illust.php
 *
 *  @param author_id [id for author]
 *  @param page      [1-n]
 *
 *  @return NSArray of IllustBaseInfo
 */
- (void)SAPI_member_illust:(NSUInteger)author_id page:(NSUInteger)page
                 onSuccess:(SuccessIllustListBlock)onSuccessHandler onFailure:(FailureFetchBlock)onFailureHandler;

/**
 *  user.php
 *
 *  @param user_id  [id for author]
 *
 *  @return IllustBaseInfo (isIllust = NO)
 */
- (void)SAPI_user:(NSUInteger)author_id
        onSuccess:(SuccessIllustBlock)onSuccessHandler onFailure:(FailureFetchBlock)onFailureHandler;

/**
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
 *  works/<illust_id>.json
 *
 *  @return NSDictionary of works(count=1)
 */
- (void)PAPI_works:(NSUInteger)illust_id
         onSuccess:(SuccessDictionaryBlock)onSuccessHandler onFailure:(FailureFetchBlock)onFailureHandler;
/**
 *  users/<author_id>.json
 *
 *  @return NSDictionary of users(count=1)
 */
- (void)PAPI_users:(NSUInteger)author_id
         onSuccess:(SuccessDictionaryBlock)onSuccessHandler onFailure:(FailureFetchBlock)onFailureHandler;

@end
