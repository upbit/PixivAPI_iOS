//
//  PixivDefines.h
//
//  Created by Zhou Hao on 14/10/20.
//  Copyright (c) 2014 Zhou Hao. All rights reserved.
//

#import "SAPIIllust.h"
#import "PAPIAuthor.h"
#import "PAPIIllust.h"
#import "PAPIIllustList.h"

#pragma mark - configs

// NSOperationQueue maxConcurrentOperationCount define
#define MAX_CONCURRENT_OPERATION_COUNT  (2)
// API fetch timeout
#define MAX_PIXIVAPI_FETCH_TIMEOUT      (30)


#pragma mark - defaults

// return value if a ingeter field is NSNull
#define PIXIV_INT_INVALID               (-1)

// Auth key for NSUserDefaults
#define PIXIV_AUTH_STORAGE_KEY          @"PixivAPI_Auth"

// API URLs
#define PIXIV_LOGIN_ROOT                @"https://oauth.secure.pixiv.net/auth/token"
#define PIXIV_SAPI_ROOT                 @"http://spapi.pixiv.net/iphone/"
#define PIXIV_PAPI_ROOT                 @"https://public-api.secure.pixiv.net/v1/"

#define PIXIV_DEFAULT_HEADERS @{                            \
    @"Referer": @"http://spapi.pixiv.net/",                 \
    @"User-Agent": @"PixivIOSApp/5.1.1",                    \
    @"Content-Type": @"application/x-www-form-urlencoded",  \
}
