Pixiv API for iOS
============

Pixiv API for iOS, supported both SAPI and Public-API (with OAuth / Bearer token)

## Pixiv API Usage:

1. Simplely drag 'PixivAPI/' to your project (copy if needed);
2. Alloc and init: **PixivAPI *api = [[PixivAPI alloc] init];**;
3. **[api SAPI_ranking:onSuccess:^()]** will return NSArray of IllustModels;

```objective-c
#import "PixivAPI.h"

- (void)getDailyRanking
{
    PixivAPI *api = [[PixivAPI alloc] init];

    // change 1 -> 2 for page2
    [api SAPI_ranking:1 mode:@"all" content:@"day"
            onSuccess:^(NSArray *illusts, BOOL isIllust) {
                for (IllustModel *illust in illusts) {
                    NSLog(@"%@", illust);
                }
            }
            onFailure:^(NSURLResponse *response, NSInteger responseCode, NSData *data, NSError *connectionError) {
                NSLog(@"[HTTP %ld] %@", (long)responseCode, connectionError);
            }];
}
```

## API example

Pixiv has two API interface:

1. **SAPI:** [http] spapi.pixiv.net/iphone/
2. **Public-API:** [https] public-api.secure.pixiv.net/

Public-API return full json data, but check Authorization/Cookie in HTTPS header. Before use Public-API, you need call login: or set_session: prepare PHPSESSID.

### Login

Example for **login:**

```objective-c
/**
 *  oauth.secure.pixiv.net/auth/token
 */
- (void)login:(NSString *)username password:(NSString *)password
    onSuccess:(SuccessLoginBlock)onSuccessHandler onFailure:(FailureFetchBlock)onFailureHandler;
```

```objective-c
    PixivAPI *api = [[PixivAPI alloc] init];

    [api login:self.username password:self.password
     onSuccess:^(NSString *raw_cookie) {
         // api.session will set before onSuccess: called
         // when onSuccess: get illust_id=46363414 from PAPI_works:
         [api PAPI_works:46363414
               onSuccess:^(NSDictionary *result) {
                   NSDictionary *illust = [result[@"response"] firstObject];
                   NSLog(@"%@", illust);
                   NSLog(@"origin url: %@", illust[@"image_urls"][@"large"]);
               }
               onFailure:^(NSURLResponse *response, NSInteger responseCode, NSData *data, NSError *connectionError) {
                   NSLog(@"[HTTP %ld] %@", (long)responseCode, connectionError);
               }];

     }
     onFailure:^(NSURLResponse *response, NSInteger responseCode, NSData *data, NSError *connectionError) {
         NSLog(@"[HTTP %ld] %@", (long)responseCode, connectionError);
     }];
```

### SAPI

Example for **SAPI_ranking:**

```objective-c
/**
 *  ranking.php
 *
 *  @param page    [1-n]
 *  @param mode    [day, week, month]
 *  @param content [all, male, female, original]
 *
 *  @return NSArray of IllustModel
 */
- (void)SAPI_ranking:(NSUInteger)page mode:(NSString *)mode content:(NSString *)content
           onSuccess:(SuccessIllustListBlock)onSuccessHandler onFailure:(FailureFetchBlock)onFailureHandler;
```

```objective-c
    [api SAPI_ranking:1 mode:@"male" content:@"week"
            onSuccess:^(NSArray *illusts, BOOL isIllust) {
                for (IllustModel *illust in illusts) {
                    NSLog(@"%@", illust);
                }
            }
            onFailure:^(NSURLResponse *response, NSInteger responseCode, NSData *data, NSError *connectionError) {
                NSLog(@"[HTTP %ld] %@", (long)responseCode, connectionError);
            }];
```

Example for **SAPI_mypixiv_all:**

```objective-c
/**
 *  mypixiv_all.php
 *
 *  @param author_id [id for author]
 *  @param page      [1-n]
 *
 *  @return NSArray of IllustModel (isIllust = NO)
 */
- (void)SAPI_mypixiv_all:(NSUInteger)author_id page:(NSUInteger)page
               onSuccess:(SuccessIllustListBlock)onSuccessHandler onFailure:(FailureFetchBlock)onFailureHandler;
```

```objective-c
    [api SAPI_mypixiv_all:1184799 page:1
                onSuccess:^(NSArray *users, BOOL isIllust) {
                    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
                    for (IllustModel *user in users) {
                        NSLog(@"%@(@%@)", user.authorName, user.username);
                    }
                }
                onFailure:^(NSURLResponse *response, NSInteger responseCode, NSData *data, NSError *connectionError) {
                    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
                    NSLog(@"[HTTP %ld] %@", (long)responseCode, connectionError);
                }];
```


### Public-API

```objective-c
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
```

Example for **PAPI_users:**

```objective-c
    PixivAPI *api = [[PixivAPI alloc] init];

    [api login:self.username password:self.password
     onSuccess:^(NSString *raw_cookie) {

        // get author_id=1184799 introduction from PAPI_users:
        [api PAPI_users:1184799
              onSuccess:^(NSDictionary *result) {
                  NSDictionary *user = [result[@"response"] firstObject];
                  NSLog(@"%@", user);
                  NSLog(@"introduction: %@", user[@"profile"][@"introduction"]);
              }
              onFailure:^(NSURLResponse *response, NSInteger responseCode, NSData *data, NSError *connectionError) {
                  NSLog(@"[HTTP %ld] %@", (long)responseCode, connectionError);
              }];

     }
     onFailure:^(NSURLResponse *response, NSInteger responseCode, NSData *data, NSError *connectionError) {
         NSLog(@"[HTTP %ld] %@", (long)responseCode, connectionError);
     }];
```

## Example - [PixivDaily](https://github.com/upbit/PixivAPI_iOS/tree/master/examples/PixivDaily)

Fetch Pixiv daily ranking and list illusts in a UITableView (cache supported by [SDWebImage](https://github.com/rs/SDWebImage))

![PixivDaily Screenshot1](https://raw.github.com/upbit/PixivAPI_iOS/master/examples/screenshots/PixivDaily_01.png)

![PixivDaily Screenshot2](https://raw.github.com/upbit/PixivAPI_iOS/master/examples/screenshots/PixivDaily_02.png)

![PixivDaily iPad Screenshot](https://raw.github.com/upbit/PixivAPI_iOS/master/examples/screenshots/PixivDaily_03.png)

![PixivDaily iPad Screenshot2](https://raw.github.com/upbit/PixivAPI_iOS/master/examples/screenshots/PixivDaily_04.png)
