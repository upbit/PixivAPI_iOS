//
//  PixivAPI.m
//
//  Created by Zhou Hao on 14-10-8.
//  Copyright (c) 2014年 Kastark. All rights reserved.
//

#import "PixivAPI.h"

@interface PixivAPI()
@property (strong, nonatomic) NSString *login_root;
@property (strong, nonatomic) NSString *sapi_root;
@property (strong, nonatomic) NSString *papi_root;
@property (strong, nonatomic) NSDictionary *default_headers;
@end

@implementation PixivAPI

- (instancetype)init
{
    self = [super init];
    
    if (self) {
        self.login_root = @"https://oauth.secure.pixiv.net/auth/token";
        self.sapi_root = @"http://spapi.pixiv.net/iphone/";
        self.papi_root = @"https://public-api.secure.pixiv.net/v1/";
        
        self.default_headers = @{
            @"Referer": @"http://spapi.pixiv.net/",
            @"User-Agent": @"PixivIOSApp/5.1.1",
            @"Content-Type": @"application/x-www-form-urlencoded",
        };
        
        self.session = nil;
    }
    return self;
}

+ (NSString*)_encodeDictionary:(NSDictionary*)dictionary
{
    NSMutableArray *parts = [[NSMutableArray alloc] init];
    for (NSString *key in dictionary) {
        id value = [dictionary objectForKey:key];
        if (![value isKindOfClass:[NSString class]]) {
            value = [NSString stringWithFormat:@"%@", value];
        }
        NSString *encodedValue = [value stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        NSString *encodedKey = [key stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        [parts addObject:[NSString stringWithFormat: @"%@=%@", encodedKey, encodedValue]];
    }
    if ([parts count] > 0) {
        return [parts componentsJoinedByString:@"&"];
    } else {
        return nil;
    }
}

/**
 *  Async fetch URL
 */
- (void)asyncURLFetch:(NSString *)method url:(NSString *)url
    completionHandler:(AsyncCompletionBlock)handler
              headers:(NSDictionary *)headers params:(NSDictionary *)params data:(NSDictionary *)data
{
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setHTTPMethod:method];
    
    /* headers */
    for (NSString* key in self.default_headers)
        [request setValue:[self.default_headers objectForKey:key] forHTTPHeaderField:key];
    // user headers
    for (NSString* key in headers)
        [request setValue:[headers objectForKey:key] forHTTPHeaderField:key];
    
    /* url */
    NSString *request_url = [NSString stringWithString:url];
    NSString *url_params = [PixivAPI _encodeDictionary:params];
    if (url_params)
        request_url = [NSString stringWithFormat:@"%@?%@", request_url, url_params];
    [request setURL:[NSURL URLWithString:request_url]];
    
    /* body */
    NSString *payload = [PixivAPI _encodeDictionary:data];
    if (payload)
        [request setHTTPBody:[payload dataUsingEncoding:NSUTF8StringEncoding]];
    
    /* request */
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:handler];
}

#pragma mark - OAuth Login

- (BOOL)_has_auth
{
    if (self.session) {
        return YES;
    }
    return NO;
}

- (void)login:(NSString *)username password:(NSString *)password
    onSuccess:(SuccessLoginBlock)onSuccessHandler onFailure:(FailureFetchBlock)onFailureHandler
{
    NSString *url = self.login_root;
    NSDictionary *login_headers = @{ @"Referer": @"http://www.pixiv.net/", };
    
    NSDictionary* data = @{
        @"username": username,
        @"password": password,
        // OAuth login from PixivIOSApp/5.1.1
        @"grant_type": @"password",
        @"client_id": @"bYGKuGVw91e0NMfPGp44euvGt59s",
        @"client_secret": @"HP3RmkgAmEGro0gn1x9ioawQE8WMfvLXDz3ZqxpK",
    };
    
    [self asyncURLFetch:@"POST" url:url completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
        NSInteger responseCode = [(NSHTTPURLResponse *)response statusCode];
        if (!connectionError && responseCode == 200 && [response isKindOfClass:[NSHTTPURLResponse class]]) {
            //NSString *payload = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            //NSLog(@"%@", payload);
            
            // from header["Set-Cookie"] get PHPSESSID
            NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse*)response;
            NSString *raw_cookie = [httpResponse allHeaderFields][@"Set-Cookie"];
            for (NSString *cookie in [raw_cookie componentsSeparatedByString:@"; "]) {
                NSRange range = [cookie rangeOfString:@"PHPSESSID="];
                if (range.length > 0) {
                    NSLog(@"%@", cookie);
                    self.session = [cookie substringFromIndex:range.length];
                }
            }
            
            onSuccessHandler(raw_cookie);
        } else {
            onFailureHandler(response, responseCode, data, connectionError);
        };
    } headers:login_headers params:nil data:data];
}

- (void)set_session:(NSString *)session
{
    self.session = session;
}

#pragma mark - SAPI common

// match state for parsePayload()
typedef NS_ENUM(NSUInteger, PARSER_STATE) {
    PARSER_STATE_NONE = 0,              // not match
    PARSER_STATE_DQUOTES = 1,           // first "
    PARSER_STATE_DQUOTES_CLOSE = 2      // check "...(["],)|(["]")
};

/**
 *  Pixiv SAPI result State Machine
 *
 *  @param payload SPAI line record
 *
 *  @return Array of NSString
 */
+ (IllustModel *)parsePayload:(NSString *)payload
{
    PARSER_STATE matchState = PARSER_STATE_NONE;
    NSString *token = @"";
    NSMutableArray *result = [[NSMutableArray alloc] init];
    
    for (int i = 0; i < [payload length]; i++) {
        NSString *c = [payload substringWithRange:NSMakeRange(i, 1)];
        
        switch (matchState) {
            case PARSER_STATE_NONE:
                if ([c isEqualToString:@"\""]) {
                    matchState = PARSER_STATE_DQUOTES;
                    token = @"";
                } else if ([c isEqualToString:@","]) {
                    [result addObject:token];
                    token = @"";
                } else {
                    token = [token stringByAppendingString:c];
                }
                break;
                
            case PARSER_STATE_DQUOTES:
                if ([c isEqualToString:@"\""]) {
                    matchState = PARSER_STATE_DQUOTES_CLOSE;    // check
                } else {
                    token = [token stringByAppendingString:c];
                }
                break;
                
            case PARSER_STATE_DQUOTES_CLOSE:
                if ([c isEqualToString:@"\""]) {
                    matchState = PARSER_STATE_DQUOTES;          // found "", it's a " in string
                    [token stringByAppendingString:@"\""];
                } else {
                    [result addObject:token];
                    token = @"";
                    matchState = PARSER_STATE_NONE;
                }
                break;
        }
    }
    
    return [IllustModel parseDataArrayToModel:result];
}

+ (NSArray *)parsePayloadList:(NSString *)payload
{
    NSMutableArray *listResult = [[NSMutableArray alloc] init];
    NSArray *inputLines = [payload componentsSeparatedByString:@"\n"];
    
    for (NSString *line in inputLines) {
        IllustModel *illust = [PixivAPI parsePayload:line];
        if (illust) {
            [listResult addObject:illust];
        }
    }
    
    return listResult;
}

- (void)_SAPI_asyncURLFetch:(NSString *)api_url params:(NSDictionary *)params
               requireAuth:(BOOL)requireAuth isIllust:(BOOL)isIllust
                  onSuccess:(SuccessIllustBlock)onSuccessHandler onFailure:(FailureFetchBlock)onFailureHandler
{
    NSString *url = [NSString stringWithFormat:@"%@%@", self.sapi_root, api_url];
    NSMutableDictionary *req_params = [NSMutableDictionary dictionaryWithDictionary:params];
    
    if (requireAuth) {
        if (![self _has_auth]) {
            NSLog(@"Authentication required! Call login: or set_session: first!");
            onFailureHandler(nil, -1, nil, nil);
            return;
        }
        
        req_params[@"PHPSESSID"] = self.session;
    }
    
    [self asyncURLFetch:@"GET" url:url completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
        NSInteger responseCode = [(NSHTTPURLResponse *)response statusCode];
        if (!connectionError && responseCode == 200) {
            NSString *payload = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            //NSLog(@"pixiv return: %@", payload);
            IllustModel *illust = [PixivAPI parsePayload:payload];
            if (illust) {
                onSuccessHandler(illust, isIllust);
            } else {
                onFailureHandler(response, responseCode, data, connectionError);
            }
        } else {
            onFailureHandler(response, responseCode, data, connectionError);
        };
    } headers:nil params:req_params data:nil];
}

- (void)_SAPI_asyncURLFetch_List:(NSString *)api_url params:(NSDictionary *)params
                requireAuth:(BOOL)requireAuth isIllust:(BOOL)isIllust
                  onSuccess:(SuccessIllustListBlock)onSuccessHandler onFailure:(FailureFetchBlock)onFailureHandler
{
    NSString *url = [NSString stringWithFormat:@"%@%@", self.sapi_root, api_url];
    NSMutableDictionary *req_params = [NSMutableDictionary dictionaryWithDictionary:params];
    
    if (requireAuth) {
        if (![self _has_auth]) {
            NSLog(@"Authentication required! Call login: or set_session: first!");
            onFailureHandler(nil, -1, nil, nil);
            return;
        }
        
        req_params[@"PHPSESSID"] = self.session;
    }
    
    [self asyncURLFetch:@"GET" url:url completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
        NSInteger responseCode = [(NSHTTPURLResponse *)response statusCode];
        if (!connectionError && responseCode == 200) {
            NSString *payload = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            //NSLog(@"pixiv return: %@", payload);
            onSuccessHandler([PixivAPI parsePayloadList:payload], isIllust);
        } else {
            onFailureHandler(response, responseCode, data, connectionError);
        };
    } headers:nil params:req_params data:nil];
}

#pragma mark - SAPI define

- (void)SAPI_ranking:(NSUInteger)page mode:(NSString *)mode content:(NSString *)content
           onSuccess:(SuccessIllustListBlock)onSuccessHandler onFailure:(FailureFetchBlock)onFailureHandler
{
    NSString *api_url = @"ranking.php";
    NSDictionary *params = @{
        @"content": content,
        @"mode": mode,
        @"p": @((page>0) ? page : 1),
    };
    [self _SAPI_asyncURLFetch_List:api_url params:params requireAuth:NO isIllust:YES onSuccess:onSuccessHandler onFailure:onFailureHandler];
}

- (void)SAPI_ranking_log:(NSString *)mode year:(NSUInteger)Date_Year month:(NSUInteger)Date_Month day:(NSUInteger)Date_Day page:(NSUInteger)page
               onSuccess:(SuccessIllustListBlock)onSuccessHandler onFailure:(FailureFetchBlock)onFailureHandler
{
    NSString *api_url = @"ranking_log.php";
    NSDictionary *params = @{
        @"mode": mode,
        @"Date_Year": @(Date_Year),
        @"Date_Month": @(Date_Month),
        @"Date_Day": @(Date_Day),
        @"p": @((page>0) ? page : 1),
    };
    [self _SAPI_asyncURLFetch_List:api_url params:params requireAuth:NO isIllust:YES onSuccess:onSuccessHandler onFailure:onFailureHandler];
}

- (void)SAPI_illust:(NSUInteger)illust_id
          onSuccess:(SuccessIllustBlock)onSuccessHandler onFailure:(FailureFetchBlock)onFailureHandler
{
    NSString *api_url = @"illust.php";
    NSDictionary *params = @{
        @"illust_id": @(illust_id),
    };
    [self _SAPI_asyncURLFetch:api_url params:params requireAuth:NO isIllust:YES onSuccess:onSuccessHandler onFailure:onFailureHandler];
}

- (void)SAPI_member_illust:(NSUInteger)author_id page:(NSUInteger)page
                 onSuccess:(SuccessIllustListBlock)onSuccessHandler onFailure:(FailureFetchBlock)onFailureHandler
{
    NSString *api_url = @"member_illust.php";
    NSDictionary *params = @{
        @"id": @(author_id),
        @"p": @((page>0) ? page : 1),
    };
    [self _SAPI_asyncURLFetch_List:api_url params:params requireAuth:NO isIllust:YES onSuccess:onSuccessHandler onFailure:onFailureHandler];
}

- (void)SAPI_user:(NSUInteger)author_id
        onSuccess:(SuccessIllustBlock)onSuccessHandler onFailure:(FailureFetchBlock)onFailureHandler
{
    NSString *api_url = @"user.php";
    NSDictionary *params = @{
        @"user_id": @(author_id),
        @"level": @3,
    };
    [self _SAPI_asyncURLFetch:api_url params:params requireAuth:NO isIllust:NO onSuccess:onSuccessHandler onFailure:onFailureHandler];
}

- (void)SAPI_bookmark:(NSUInteger)author_id page:(NSUInteger)page
            onSuccess:(SuccessIllustListBlock)onSuccessHandler onFailure:(FailureFetchBlock)onFailureHandler
{
    NSString *api_url = @"bookmark.php";
    NSDictionary *params = @{
        @"id": @(author_id),
        @"p": @((page>0) ? page : 1),
    };
    [self _SAPI_asyncURLFetch_List:api_url params:params requireAuth:YES isIllust:YES onSuccess:onSuccessHandler onFailure:onFailureHandler];
}

- (void)SAPI_bookmark_user_all:(NSUInteger)author_id page:(NSUInteger)page
                     onSuccess:(SuccessIllustListBlock)onSuccessHandler onFailure:(FailureFetchBlock)onFailureHandler
{
    NSString *api_url = @"bookmark_user_all.php";
    NSDictionary *params = @{
        @"id": @(author_id),
        @"p": @((page>0) ? page : 1),
        @"rest": @"show",
    };
    [self _SAPI_asyncURLFetch_List:api_url params:params requireAuth:YES isIllust:NO onSuccess:onSuccessHandler onFailure:onFailureHandler];
}

- (void)SAPI_mypixiv_all:(NSUInteger)author_id page:(NSUInteger)page
               onSuccess:(SuccessIllustListBlock)onSuccessHandler onFailure:(FailureFetchBlock)onFailureHandler
{
    NSString *api_url = @"mypixiv_all.php";
    NSDictionary *params = @{
        @"id": @(author_id),
        @"p": @((page>0) ? page : 1),
    };
    [self _SAPI_asyncURLFetch_List:api_url params:params requireAuth:NO isIllust:NO onSuccess:onSuccessHandler onFailure:onFailureHandler];
}

#pragma mark - Public-API common

+ (NSString *)_bearer_token
{
    return [NSString stringWithFormat:@"Bearer %@", @"8mMXXWT9iuwdJvsVIvQsFYDwuZpRCMePeyagSh30ZdU"];
}

- (void)_PAPI_asyncURLFetch:(NSString *)api_url params:(NSDictionary *)params
    onSuccess:(SuccessDictionaryBlock)onSuccessHandler onFailure:(FailureFetchBlock)onFailureHandler
{
    NSString *url = [NSString stringWithFormat:@"%@%@", self.papi_root, api_url];
    
    if (![self _has_auth]) {
        NSLog(@"Authentication required! Call login: or set_session: first!");
        onFailureHandler(nil, -1, nil, nil);
        return;
    }
    NSDictionary *papi_headers = @{
        @"Authorization": [PixivAPI _bearer_token],
        @"Cookie": [NSString stringWithFormat:@"PHPSESSID=%@", self.session],
    };
    
    [self asyncURLFetch:@"GET" url:url completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
        NSInteger responseCode = [(NSHTTPURLResponse *)response statusCode];
        if (!connectionError && responseCode == 200) {
            NSError* error;
            NSDictionary* json_result = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
            //NSLog(@"%@", json_result);
            onSuccessHandler(json_result);
        } else {
            onFailureHandler(response, responseCode, data, connectionError);
        };
    } headers:papi_headers params:params data:nil];
}

#pragma mark - Public-API define

- (void)PAPI_works:(NSUInteger)illust_id
        onSuccess:(SuccessDictionaryBlock)onSuccessHandler onFailure:(FailureFetchBlock)onFailureHandler
{
    NSString *api_url = [NSString stringWithFormat:@"works/%lu.json", illust_id];
    NSDictionary *params = @{
        @"profile_image_sizes": @"px_170x170,px_50x50",
        @"image_sizes": @"px_128x128,small,medium,large,px_480mw",
        @"include_stats": @"true",
    };
    [self _PAPI_asyncURLFetch:api_url params:params onSuccess:onSuccessHandler onFailure:onFailureHandler];
}

- (void)PAPI_users:(NSUInteger)author_id
         onSuccess:(SuccessDictionaryBlock)onSuccessHandler onFailure:(FailureFetchBlock)onFailureHandler
{
    NSString *api_url = [NSString stringWithFormat:@"users/%lu.json", author_id];
    NSDictionary *params = @{
        @"profile_image_sizes": @"px_170x170,px_50x50",
        @"image_sizes": @"px_128x128,small,medium,large,px_480mw",
        @"include_stats": @1,
        @"include_profile": @1,
        @"include_workspace": @1,
        @"include_contacts": @1,
    };
    [self _PAPI_asyncURLFetch:api_url params:params onSuccess:onSuccessHandler onFailure:onFailureHandler];
}

@end
