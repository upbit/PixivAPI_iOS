Pixiv API for iOS
============

PixivAPI_iOS currently only supported non-login API, do nothing about pixiv OAuth2...

## Pixiv API Usage:

1. Simplely drag PixivFetcher/ to your project;
2. Call Pixiv API like **[PixivFetcher API_getRanking:...]**;
3. **API_getRanking:onSuccess:^()** will return NSArray of IllustModels;

```objective-c
#import "PixivFetcher.h"

- (void)getDailyRanking
{
    [PixivFetcher API_getRanking:1 mode:PIXIV_RANKING_MODE_DAY content:PIXIV_RANKING_CONTENT_ALL
                       onSuccess:^(NSArray *illusts, BOOL isIllust) {
                           NSLog(@"%@", illusts);
                       }
                       onFailure:^(NSURLResponse *response, NSInteger responseCode, NSData *data, NSError *connectionError) {
                           NSLog(@"[HTTP %d] %@", responseCode, connectionError);
                       }];
}
```

**IllustModel** propertys:

```objective-c
@interface IllustModel : NSObject

// export Model to NSArray
- (NSArray *)toDataArray;

#pragma mark - Author / Illust common

@property (nonatomic)           NSUInteger      authorId;       // data[1]
@property (strong, nonatomic)   NSString        *authorName;    // data[5]
@property (strong, nonatomic)   NSString        *thumbURL;      // data[6]
@property (strong, nonatomic)   NSString        *username;      // data[24]

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

- (NSString *)imageURL;
- (NSArray *)pageURLs;

@end
```

## Demo - [PixivDaily](https://github.com/upbit/PixivAPI_iOS/tree/master/examples/PixivDaily)

Fetch Pixiv daily ranking and list illusts in a UITableView (cache supported by [SDWebImage](https://github.com/rs/SDWebImage))

![PixivDaily Screenshot1](https://raw.github.com/upbit/PixivAPI_iOS/master/examples/screenshots/PixivDaily_01.png)

![PixivDaily Screenshot2](https://raw.github.com/upbit/PixivAPI_iOS/master/examples/screenshots/PixivDaily_02.png)

![PixivDaily iPad Screenshot](https://raw.github.com/upbit/PixivAPI_iOS/master/examples/screenshots/PixivDaily_03.png)

![PixivDaily iPad Screenshot2](https://raw.github.com/upbit/PixivAPI_iOS/master/examples/screenshots/PixivDaily_04.png)
