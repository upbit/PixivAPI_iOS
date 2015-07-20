//
//  PixivAPI.m
//
//  Created by Zhou Hao on 14-10-8.
//  Copyright (c) 2014 Zhou Hao. All rights reserved.
//

#import "PixivAPI.h"

@interface PixivAPI()
@property (strong, nonatomic) NSString *login_root;
@property (strong, nonatomic) NSString *sapi_root;
@property (strong, nonatomic) NSString *papi_root;
@property (strong, nonatomic) NSDictionary *default_headers;
@end

@implementation PixivAPI

+ (PixivAPI *)sharedInstance
{
    static dispatch_once_t onceToken;
    static PixivAPI *instance = nil;
    dispatch_once(&onceToken, ^{
        instance = [[PixivAPI alloc] init];
    });
    return instance;
}

- (instancetype)init
{
    self = [super init];
    
    if (self) {
        self.login_root = PIXIV_LOGIN_ROOT;
        self.sapi_root = PIXIV_SAPI_ROOT;
        self.papi_root = PIXIV_PAPI_ROOT;
        self.default_headers = PIXIV_DEFAULT_HEADERS;
        self.session = nil;
    }
    return self;
}

#pragma mark - Asynchronous BlockingQueue

- (NSOperationQueue *)operationQueue
{
    if (!_operationQueue) {
        _operationQueue = [[NSOperationQueue alloc] init];
        _operationQueue.maxConcurrentOperationCount = MAX_CONCURRENT_OPERATION_COUNT;
    }
    return _operationQueue;
}

- (void)asyncBlockingQueue:(NSOperationQueuePriority)queuePriority operations:(void (^)(void))mainOperations
{
    NSBlockOperation *operation = [NSBlockOperation blockOperationWithBlock:^{
        mainOperations();
    }];
    [operation setQueuePriority:queuePriority];
    [self.operationQueue addOperation:operation];
}

- (void)asyncBlockingQueue:(void (^)(void))mainOperations
{
    [self asyncBlockingQueue:NSOperationQueuePriorityNormal operations:mainOperations];
}

- (void)asyncWaitAllOperationsAreFinished:(void (^)(void))onCompletion
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.operationQueue waitUntilAllOperationsAreFinished];
        onCompletion();
    });
}

- (void)onMainQueue:(void (^)(void))operationBlock
{
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        operationBlock();
    }];
}

#pragma mark - URL Fetcher

- (NSDictionary *)URLFetch:(NSString *)method url:(NSString *)url
                   headers:(NSDictionary *)headers params:(NSDictionary *)params data:(NSDictionary *)data
{
    NSString *error = nil;
    return [self URLFetch:method url:url headers:headers params:params data:data error:&error];
}

- (NSDictionary *)URLFetch:(NSString *)method url:(NSString *)url
                   headers:(NSDictionary *)headers params:(NSDictionary *)params
                      data:(NSDictionary *)data error:(NSString **)errorResponseMessage
{
    *errorResponseMessage = nil;
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setHTTPMethod:method];
    [request setTimeoutInterval:MAX_PIXIVAPI_FETCH_TIMEOUT];
    
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
    NSURLResponse *response = nil;
    NSError *error = nil;
    NSData *responseData = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
    if (error) {
        NSLog(@"Error sending request: %@", [error localizedDescription]);
        *errorResponseMessage = [error localizedDescription];
        return nil;
    }

    NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
    if (httpResponse.statusCode != 200) {
        NSString *payload = [[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding];
        NSLog(@"Error HTTP %ld:\n%@", (long)httpResponse.statusCode, payload);
        
        NSError *error = nil;
        NSDictionary* errorJsonResult = [NSJSONSerialization JSONObjectWithData:responseData
                                                                        options:kNilOptions error:&error];
        if (error) {
            *errorResponseMessage = error.description;
            return nil;
        }
        *errorResponseMessage = [[[errorJsonResult valueForKey:@"errors"]
                                  valueForKey:@"system"] valueForKey:@"message"];
        return nil;
    }
    
    return [PixivAPI _buildResponse:httpResponse data:responseData];
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

+ (NSDictionary *)_buildResponse:(NSHTTPURLResponse *)response data:(NSData *)data
{
    return @{
        @"header": [response allHeaderFields],
        @"data": data,
        @"payload": [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding],
    };
}

#pragma mark - OAuth Login

- (NSDictionary *)login:(NSString *)username password:(NSString *)password
{
    NSString *error = nil;
    return [self login:username password:password error:&error];
}

- (NSDictionary *)login:(NSString *)username password:(NSString *)password error:(NSString **)errorMessage
{
    *errorMessage = nil;
    
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

    NSDictionary *response = [self URLFetch:@"POST" url:url headers:login_headers
                                     params:nil data:data error:errorMessage];
    
    if (*errorMessage) {
        return nil;
    }
    
    if (!response || (!response[@"data"])) {
        *errorMessage = @"response is nil.";
        return nil;
    }

    // from response.payload get AccessToken
    NSError* error;
    NSDictionary* json_result = [NSJSONSerialization JSONObjectWithData:response[@"data"] options:kNilOptions error:&error];
    if (error) {
        *errorMessage = error.description;
        return nil;
    }
    self.access_token = json_result[@"response"][@"access_token"];
    self.user_id = [json_result[@"response"][@"user"][@"id"] integerValue];
    NSLog(@"AccessToken:%@", self.access_token);
    
    // from response.header["Set-Cookie"] get PHPSESSID
    NSString *raw_cookie = response[@"header"][@"Set-Cookie"];
    for (NSString *cookie in [raw_cookie componentsSeparatedByString:@"; "]) {
        NSRange range = [cookie rangeOfString:@"PHPSESSID="];
        if (range.length > 0) {
            self.session = [cookie substringFromIndex:range.length];
            NSLog(@"Session:%@", self.session);
            break;
        }
    }
    
    [self saveAuthToUserDefaults:self.access_token session:self.session username:username user_id:self.user_id];
    return json_result;
}

- (BOOL)loginIfNeeded:(NSString *)username password:(NSString *)password
{
    if (![self loadAuthFromUserDefaults:username]) {
        // Auth expired, call login:
        NSDictionary *auth = [self login:username password:password];
        if (auth) {
            return YES;
        } else {
            return NO;
        }
    } else {
        // load auth success
        return YES;
    }
}

- (void)loginIfNeeded:(NSString *)username password:(NSString *)password error:(NSString **)errorMessage
{
    *errorMessage = nil;
    
    if (![self loadAuthFromUserDefaults:username]) {
        [self login:username password:password error:errorMessage];
    }
}

- (BOOL)_has_auth
{
    if (self.access_token && self.session) {
        return YES;
    }
    return NO;
}

- (void)set_auth:(NSString *)access_token session:(NSString *)session
{
    self.access_token = access_token;
    self.session = session;
}

- (void)saveAuthToUserDefaults:(NSString *)access_token session:(NSString *)session username:(NSString *)username user_id:(NSInteger)user_id
{
    NSDate *now = [NSDate date];
    NSDate *expire = [now dateByAddingTimeInterval: 3600.0-30.0];      // -30 network timeout sec
    
    NSDictionary *auth_storage = @{
        @"expired": expire,
        @"username": username,
        @"user_id": @(user_id),
        @"bearer_token": access_token,
        @"session": session,
    };
    
    [[NSUserDefaults standardUserDefaults] setObject:auth_storage forKey:PIXIV_AUTH_STORAGE_KEY];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

// return NO if Auth expired
- (BOOL)loadAuthFromUserDefaults:(NSString *)username
{
    NSDictionary *auth_storage = [[NSUserDefaults standardUserDefaults] objectForKey:PIXIV_AUTH_STORAGE_KEY];
    if (auth_storage) {
        NSDate *now = [NSDate date];
        NSDate *expire = auth_storage[@"expired"];
        if ([expire compare:now] == NSOrderedDescending) {
            if (username) {
                // if username is set, check username
                NSString *last_user = auth_storage[@"username"];
                if (![username isEqualToString:last_user]) {
                    NSLog(@"found last auth for '%@', but search for user '%@'", last_user, username);
                    return NO;
                }
            }
            
            self.access_token = auth_storage[@"bearer_token"];
            self.session = auth_storage[@"session"];
            if (auth_storage[@"user_id"]) {
                self.user_id = [auth_storage[@"user_id"] integerValue];
            } else {
                self.user_id = 0;
                return NO;          // old entry, retry login
            }
            NSLog(@"find vailed Auth:\nAccessToken=%@\nSession=%@", self.access_token, self.session);
            return YES;
        }
    }
    return NO;
}

- (void)dropAuthFromUserDefaults
{
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:PIXIV_AUTH_STORAGE_KEY];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

#pragma mark - SAPI common

// match state for parsePayload()
typedef NS_ENUM(NSInteger, PARSER_STATE) {
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
+ (SAPIIllust *)parsePayload:(NSString *)payload
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
    
    return [SAPIIllust parseDataArrayToModel:result];
}

+ (NSArray *)parsePayloadList:(NSString *)payload
{
    NSMutableArray *listResult = [[NSMutableArray alloc] init];
    NSArray *inputLines = [payload componentsSeparatedByString:@"\n"];
    
    for (NSString *line in inputLines) {
        SAPIIllust *illust = [PixivAPI parsePayload:line];
        if (illust) {
            [listResult addObject:illust];
        }
    }
    
    return listResult;
}

- (SAPIIllust *)_SAPI_URLFetch:(NSString *)api_url params:(NSDictionary *)params requireAuth:(BOOL)requireAuth
{
    NSString *url = [NSString stringWithFormat:@"%@%@", self.sapi_root, api_url];
    NSMutableDictionary *req_params = [NSMutableDictionary dictionaryWithDictionary:params];
    
    if (requireAuth) {
        if (![self _has_auth]) {
            NSLog(@"Authentication required! Call login: or set_session: first!");
            return nil;
        }
        req_params[@"PHPSESSID"] = self.session;
    }
    
    NSDictionary *response = [self URLFetch:@"GET" url:url headers:nil params:req_params data:nil];
    //NSLog(@"pixiv return: %@", response[@"payload"]);
    return [PixivAPI parsePayload:response[@"payload"]];
}

- (NSArray *)_SAPI_URLFetchList:(NSString *)api_url params:(NSDictionary *)params requireAuth:(BOOL)requireAuth
{
    NSString *url = [NSString stringWithFormat:@"%@%@", self.sapi_root, api_url];
    NSMutableDictionary *req_params = [NSMutableDictionary dictionaryWithDictionary:params];
    
    if (requireAuth) {
        if (![self _has_auth]) {
            NSLog(@"Authentication required! Call login: or set_session: first!");
            return nil;
        }
        req_params[@"PHPSESSID"] = self.session;
    }
    
    NSDictionary *response = [self URLFetch:@"GET" url:url headers:nil params:req_params data:nil];
    //NSLog(@"pixiv return: %@", response[@"payload"]);
    return [PixivAPI parsePayloadList:response[@"payload"]];
}

#pragma mark - SAPI define

- (NSArray *)SAPI_ranking:(NSInteger)page mode:(NSString *)mode content:(NSString *)content requireAuth:(BOOL)requireAuth
{
    NSString *api_url = @"ranking.php";
    NSDictionary *params = @{
        @"content": content,
        @"mode": mode,
        @"p": @((page>0) ? page : 1),
    };
    return [self _SAPI_URLFetchList:api_url params:params requireAuth:requireAuth];
}

- (NSArray *)SAPI_ranking_log:(NSInteger)Date_Year month:(NSInteger)Date_Month day:(NSInteger)Date_Day
                         mode:(NSString *)mode page:(NSInteger)page requireAuth:(BOOL)requireAuth
{
    NSString *api_url = @"ranking_log.php";
    NSDictionary *params = @{
        @"mode": mode,
        @"Date_Year": [NSString stringWithFormat:@"%ld", (long)Date_Year],
        @"Date_Month": [NSString stringWithFormat:@"%.2ld", (long)Date_Month],
        @"Date_Day": [NSString stringWithFormat:@"%.2ld", (long)Date_Day],
        @"p": @((page>0) ? page : 1),
    };
    return [self _SAPI_URLFetchList:api_url params:params requireAuth:requireAuth];
}

- (SAPIIllust *)SAPI_illust:(NSInteger)illust_id requireAuth:(BOOL)requireAuth
{
    NSString *api_url = @"illust.php";
    NSDictionary *params = @{
        @"illust_id": @(illust_id),
    };
    return [self _SAPI_URLFetch:api_url params:params requireAuth:requireAuth];
}

- (NSArray *)SAPI_member_illust:(NSInteger)author_id page:(NSInteger)page requireAuth:(BOOL)requireAuth
{
    NSString *api_url = @"member_illust.php";
    NSDictionary *params = @{
        @"id": @(author_id),
        @"p": @((page>0) ? page : 1),
    };
    return [self _SAPI_URLFetchList:api_url params:params requireAuth:requireAuth];
}

- (SAPIIllust *)SAPI_user:(NSInteger)author_id requireAuth:(BOOL)requireAuth
{
    NSString *api_url = @"user.php";
    NSDictionary *params = @{
        @"user_id": @(author_id),
        @"level": @3,
    };
    return [self _SAPI_URLFetch:api_url params:params requireAuth:requireAuth];
}

- (NSArray *)SAPI_bookmark:(NSInteger)author_id page:(NSInteger)page requireAuth:(BOOL)requireAuth
{
    NSString *api_url = @"bookmark.php";
    NSDictionary *params = @{
        @"id": @(author_id),
        @"p": @((page>0) ? page : 1),
    };
    return [self _SAPI_URLFetchList:api_url params:params requireAuth:requireAuth];
}

- (NSArray *)SAPI_illust_bookmarks:(NSInteger)illust_id page:(NSInteger)page requireAuth:(BOOL)requireAuth
{
    NSString *api_url = @"illust_bookmarks.php";
    NSDictionary *params = @{
        @"illust_id": @(illust_id),
        @"p": @((page>0) ? page : 1),
    };
    return [self _SAPI_URLFetchList:api_url params:params requireAuth:requireAuth];
}

- (NSArray *)SAPI_bookmark_user_all:(NSInteger)author_id page:(NSInteger)page requireAuth:(BOOL)requireAuth
{
    NSString *api_url = @"bookmark_user_all.php";
    NSDictionary *params = @{
        @"id": @(author_id),
        @"p": @((page>0) ? page : 1),
        @"rest": @"show",
    };
    return [self _SAPI_URLFetchList:api_url params:params requireAuth:requireAuth];
}

- (NSArray *)SAPI_mypixiv_all:(NSInteger)author_id page:(NSInteger)page requireAuth:(BOOL)requireAuth
{
    NSString *api_url = @"mypixiv_all.php";
    NSDictionary *params = @{
        @"id": @(author_id),
        @"p": @((page>0) ? page : 1),
    };
    return [self _SAPI_URLFetchList:api_url params:params requireAuth:requireAuth];
}

#pragma mark - Public-API common

- (id)_PAPI_URLFetch:(NSString *)api_url params:(NSDictionary *)params isIllust:(BOOL)isIllust
{
    NSString *url = [NSString stringWithFormat:@"%@%@", self.papi_root, api_url];
    
    if (![self _has_auth]) {
        NSLog(@"Authentication required! Call login: or set_session: first!");
        return nil;
    }
    NSDictionary *papi_headers = @{
        @"Authorization": [NSString stringWithFormat:@"Bearer %@", self.access_token],
        @"Cookie": [NSString stringWithFormat:@"PHPSESSID=%@", self.session],
    };
    
    NSDictionary *response = [self URLFetch:@"GET" url:url headers:papi_headers params:params data:nil];
    if (!response[@"data"]) {
        NSLog(@"GET %@ return data: nil: %@", url, response);
        return nil;
    }
    
    NSError* error;
    NSDictionary* json_result = [NSJSONSerialization JSONObjectWithData:response[@"data"] options:kNilOptions error:&error];
    //NSLog(@"pixiv json: %@", json_result);
    if (error) {
        return nil;
    }
    
    if (isIllust) {
        return [PAPIIllust parseJsonDictionaryToModel:json_result];
    } else {
        return [PAPIAuthor parseJsonDictionaryToModel:json_result];
    }
}

/**
 *    @param isWork  YES - response is work{}; NO - response wrap and has work key
 */
- (id)_PAPI_URLFetchList:(NSString *)api_url params:(NSDictionary *)params isWork:(BOOL)isWork
{
    NSString *url = [NSString stringWithFormat:@"%@%@", self.papi_root, api_url];
    
    if (![self _has_auth]) {
        NSLog(@"Authentication required! Call login: or set_session: first!");
        return nil;
    }
    NSDictionary *papi_headers = @{
        @"Authorization": [NSString stringWithFormat:@"Bearer %@", self.access_token],
        @"Cookie": [NSString stringWithFormat:@"PHPSESSID=%@", self.session],
    };
    
    NSDictionary *response = [self URLFetch:@"GET" url:url headers:papi_headers params:params data:nil];
    NSError* error;
    NSDictionary* json_result = [NSJSONSerialization JSONObjectWithData:response[@"data"] options:kNilOptions error:&error];
    //NSLog(@"pixiv json: %@", json_result);
    if (error) {
        return nil;
    }
  
    return [PAPIIllustList parseJsonDictionaryToModelList:json_result isWork:isWork];
}

- (NSArray *)_PAPI_URLPost:(NSString *)api_url payload:(NSDictionary *)payload
{
    NSString *url = [NSString stringWithFormat:@"%@%@", self.papi_root, api_url];
    
    if (![self _has_auth]) {
        NSLog(@"Authentication required! Call login: or set_session: first!");
        return nil;
    }
    NSDictionary *papi_headers = @{
        @"Authorization": [NSString stringWithFormat:@"Bearer %@", self.access_token],
        @"Cookie": [NSString stringWithFormat:@"PHPSESSID=%@", self.session],
    };
    
    NSDictionary *response = [self URLFetch:@"POST" url:url headers:papi_headers params:nil data:payload];
    if (!response[@"data"]) {
        NSLog(@"POST %@ return data: nil: %@", url, response);
        return nil;
    }
    
    NSError* error;
    NSDictionary* json_result = [NSJSONSerialization JSONObjectWithData:response[@"data"] options:kNilOptions error:&error];
    if ((error) || (!json_result[@"status"]) || (![json_result[@"status"] isEqualToString:@"success"])) {
        NSLog(@"POST %@ failed: %@", url, json_result);
        return nil;
    }
    
    return json_result[@"response"];
}

- (BOOL)_PAPI_URLDelete:(NSString *)api_url params:(NSDictionary *)params
{
    NSString *url = [NSString stringWithFormat:@"%@%@", self.papi_root, api_url];
    
    if (![self _has_auth]) {
        NSLog(@"Authentication required! Call login: or set_session: first!");
        return NO;
    }
    NSDictionary *papi_headers = @{
        @"Authorization": [NSString stringWithFormat:@"Bearer %@", self.access_token],
        @"Cookie": [NSString stringWithFormat:@"PHPSESSID=%@", self.session],
    };
    
    NSDictionary *response = [self URLFetch:@"DELETE" url:url headers:papi_headers params:params data:nil];
    if (!response[@"data"]) {
        NSLog(@"POST %@ return data: nil: %@", url, response);
        return NO;
    }
    
    NSError* error;
    NSDictionary* json_result = [NSJSONSerialization JSONObjectWithData:response[@"data"] options:kNilOptions error:&error];
    if ((error) || (!json_result[@"status"]) || (![json_result[@"status"] isEqualToString:@"success"])) {
        NSLog(@"DELETE %@ failed: %@", url, json_result);
        return NO;
    }
    
    return YES;
}

#pragma mark - Public-API define

- (PAPIIllust *)PAPI_works:(NSInteger)illust_id
{
    NSString *api_url = [NSString stringWithFormat:@"works/%lu.json", (unsigned long)illust_id];
    NSDictionary *params = @{
        @"profile_image_sizes": @"px_170x170,px_50x50",
        @"image_sizes": @"px_128x128,small,medium,large,px_480mw",
        @"include_stats": @"true",
    };
    return [self _PAPI_URLFetch:api_url params:params isIllust:YES];
}

- (PAPIAuthor *)PAPI_users:(NSInteger)author_id
{
    NSString *api_url = [NSString stringWithFormat:@"users/%lu.json", (unsigned long)author_id];
    NSDictionary *params = @{
        @"profile_image_sizes": @"px_170x170,px_50x50",
        @"image_sizes": @"px_128x128,small,medium,large,px_480mw",
        @"include_stats": @1,
        @"include_profile": @1,
        @"include_workspace": @1,
        @"include_contacts": @1,
    };
    return [self _PAPI_URLFetch:api_url params:params isIllust:NO];
}

- (PAPIIllustList *)PAPI_me_feeds:(BOOL)show_r18
{
    NSString *api_url = @"me/feeds.json";
    NSDictionary *params = @{
        @"relation": @"all",
        @"type": @"touch_nottext",
        @"show_r18": show_r18 ? @1 : @0,
    };
    return [self _PAPI_URLFetchList:api_url params:params isWork:YES];
}

- (PAPIIllustList *)PAPI_users_works:(NSInteger)author_id page:(NSInteger)page publicity:(BOOL)publicity
{
  NSString *api_url = [NSString stringWithFormat:@"users/%ld/works.json", (unsigned long)author_id];
  NSDictionary *params = @{
      @"page": @(page),
      @"per_page": @30,
      @"publicity": publicity ? @"public" : @"private",
      @"include_work": @"true",
      @"include_stats": @"true",
      @"image_sizes": @"px_128x128,px_480mw,large",
      @"profile_image_sizes": @"px_170x170,px_50x50",
  };
  return [self _PAPI_URLFetchList:api_url params:params isWork:YES];
}

- (PAPIIllustList *)PAPI_users_favorite_works:(NSInteger)author_id page:(NSInteger)page publicity:(BOOL)publicity
{
    NSString *api_url = [NSString stringWithFormat:@"users/%ld/favorite_works.json", (unsigned long)author_id];
    NSDictionary *params = @{
        @"page": @(page),
        @"per_page": @30,
        @"publicity": publicity ? @"public" : @"private",
        @"include_work": @"true",
        @"include_stats": @"true",
        @"image_sizes": @"px_128x128,small,medium,large,px_480mw",
        @"profile_image_sizes": @"px_170x170,px_50x50",
    };
    // response has a header outside each work, so set isWork:NO
    return [self _PAPI_URLFetchList:api_url params:params isWork:NO];
}

- (NSInteger)PAPI_add_favorite_works:(NSInteger)illust_id publicity:(BOOL)publicity
{
    NSString *api_url = @"me/favorite_works";
    NSDictionary *payload = @{
        @"work_id": @(illust_id),
        @"publicity": publicity ? @"public" : @"private",
    };
    
    NSArray *response = [self _PAPI_URLPost:api_url payload:payload];
    if ([response firstObject][@"id"]) {
        return [[response firstObject][@"id"] integerValue];
    } else {
        return PIXIV_ID_INVALID;
    }
}

- (BOOL)PAPI_del_favorite_works:(NSInteger)favorite_id
{
    NSString *api_url = @"me/favorite_works";
    NSDictionary *params = @{
        @"ids": @(favorite_id),
    };
    return [self _PAPI_URLDelete:api_url params:params];
}

- (PAPIIllustList *)PAPI_ranking_all:(NSString *)mode page:(NSInteger)page
{
  NSString *api_url = @"ranking/all";
  NSDictionary *params = @{
      @"mode": mode,
      @"page": @(page),
      @"per_page": @50,
      @"image_sizes": @"px_128x128,px_480mw,large",
      @"profile_image_sizes": @"px_170x170,px_50x50",
      @"include_stats": @"true",
      @"include_sanity_level": @"true",
  };
  return [self _PAPI_URLFetchList:api_url params:params isWork:NO];
}

- (PAPIIllustList *)PAPI_ranking_log:(NSString *)mode page:(NSInteger)page date:(NSString *)date
{
  NSString *api_url = @"ranking/all";
  NSDictionary *params = @{
      @"mode": mode,
      @"page": @(page),
      @"per_page": @50,
      @"date": date,
      @"image_sizes": @"px_128x128,px_480mw,large",
      @"profile_image_sizes": @"px_170x170,px_50x50",
      @"include_stats": @"true",
      @"include_sanity_level": @"true",
  };
  return [self _PAPI_URLFetchList:api_url params:params isWork:NO];
}

@end
