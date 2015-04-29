Pixiv API for iOS
============

Pixiv API for iOS, supported both SAPI and Public-API (with OAuth / Bearer token)

* [2015/04/29] add React Native support
* [2014/10/19] new NSOperationQueue for async request, add Public-API return Model

## Pixiv API Usage:

1. Simplely drag 'PixivAPI/' to your project (copy if needed);
2. Add **#import "PixivAPI/PixivAPI.h"** to your project;
3. call **login:** and **SAPI / PAPI** functions for you needed;

## API example

Pixiv has two API interface:

1. **SAPI:** [http] spapi.pixiv.net/iphone/
2. **Public-API:** [https] public-api.secure.pixiv.net/

Public-API return full json data, but check Authorization/Cookie in HTTPS header. Before use Public-API, you need call **login:** or **set_session:** to set PHPSESSID.


### Login

Both loginIfNeeded: / login: are used to Pixiv OAuth, but loginIfNeeded: auto save/load auth token from NSUserDefaults.
<span style="color:#F00">so I recommend that use loginIfNeeded: when you need login:</span>

**login** (sync):

```objective-c
    // sync login
    [[PixivAPI sharedInstance] loginIfNeeded:username password:password];
```

**login** (async):

```objective-c
    // use asyncBlockingQueue: for async request
    [[PixivAPI sharedInstance] asyncBlockingQueue:^{
        if ([[PixivAPI sharedInstance] loginIfNeeded:@"username" password:@"password"]) {
            NSLog(@"Login success!");
        } else {
            NSLog(@"Login failed.");
        }
    }];
```

For more information about asyncBlockingQueue, you can read [asyncBlockingQueue: section](https://github.com/upbit/PixivAPI_iOS#asyncblockingqueue)

### SAPI

SAPI return SAPIIllust / NSArray of SAPIIllust, or nil on error:

```objective-c
/**
 *  每日排行
 *  ranking.php
 *
 *  @param page             [1-n]
 *  @param mode             [day, week, month]
 *  @param content          [all, male, female, original]
 *  @param requireAuth      NO
 *
 *  @return NSArray of SAPIIllust
 */
- (NSArray *)SAPI_ranking:(NSUInteger)page mode:(NSString *)mode content:(NSString *)content requireAuth:(BOOL)requireAuth;

/**
 *  过去的排行
 *  ranking_log.php
 *
 *  @param Date_Year        2014
 *  @param Date_Month       4
 *  @param Date_Day         15
 *  @param mode             [daily, weekly, monthly, male, female, rookie], r18[daily_r18, weekly_r18, male_r18, female_r18, r18g]
 *  @param page             [1-n]
 *  @param requireAuth      YES - for r18 set
 *
 *  @return NSArray of SAPIIllust
 */
- (NSArray *)SAPI_ranking_log:(NSUInteger)Date_Year month:(NSUInteger)Date_Month day:(NSUInteger)Date_Day
                         mode:(NSString *)mode page:(NSUInteger)page requireAuth:(BOOL)requireAuth;

/**
 *  作品信息 (新版本已使用 PAPI_works: 代替)
 *  illust.php
 *
 *  @param illust_id        [id for illust]
 *  @param requireAuth      YES - for r18 result
 *
 *  @return SAPIIllust
 */
- (SAPIIllust *)SAPI_illust:(NSUInteger)illust_id requireAuth:(BOOL)requireAuth;

/**
 *  用户作品列表
 *  member_illust.php
 *
 *  @param author_id        [id for author]
 *  @param page             [1-n]
 *  @param requireAuth      YES - for r18 result
 *
 *  @return NSArray of SAPIIllust
 */
- (NSArray *)SAPI_member_illust:(NSUInteger)author_id page:(NSUInteger)page requireAuth:(BOOL)requireAuth;

/**
 *  用户资料 (新版本已使用 PAPI_users: 代替)
 *  user.php
 *
 *  @param user_id          [id for author]
 *  @param requireAuth      NO
 *
 *  @return SAPIIllust(Author)
 */
- (SAPIIllust *)SAPI_user:(NSUInteger)author_id requireAuth:(BOOL)requireAuth;

/**
 *  用户收藏 (新版本已使用 PAPI_users_favorite_works: 代替)
 *  bookmark.php (Authentication required)
 *
 *  @param author_id        [id for author]
 *  @param page             [1-n]
 *  @param requireAuth      YES - for r18 result
 *
 *  @return NSArray of SAPIIllust
 */
- (NSArray *)SAPI_bookmark:(NSUInteger)author_id page:(NSUInteger)page requireAuth:(BOOL)requireAuth;

/**
 *  标记书签的用户
 *  illust_bookmarks.php
 *
 *  @param illust_id        [id for illust]
 *  @param page             [1-n]
 *  @param requireAuth      NO
 *
 *  @return NSArray of SAPIIllust(Author)
 */
- (NSArray *)SAPI_illust_bookmarks:(NSUInteger)illust_id page:(NSUInteger)page requireAuth:(BOOL)requireAuth;

/**
 *  关注
 *  bookmark_user_all.php (Authentication required)
 *
 *  @param author_id [id for author]
 *  @param page      [1-n]
 *
 *  @return NSArray of SAPIIllust(Author)
 */
- (NSArray *)SAPI_bookmark_user_all:(NSUInteger)author_id page:(NSUInteger)page requireAuth:(BOOL)requireAuth;

/**
 *  好P友
 *  mypixiv_all.php
 *
 *  @param author_id [id for author]
 *  @param page      [1-n]
 *
 *  @return NSArray of SAPIIllust(Author)
 */
- (NSArray *)SAPI_mypixiv_all:(NSUInteger)author_id page:(NSUInteger)page requireAuth:(BOOL)requireAuth;
```

### Public API

PAPI return PAPIIllust(PAPIAuthor) / PAPIIllustList models, or nil on error:

```objective-c
/**
 *  作品详细
 *  works/<illust_id>.json
 *
 *  @return PAPIIllust
 */
- (PAPIIllust *)PAPI_works:(NSUInteger)illust_id;

/**
 *  用户资料
 *  users/<author_id>.json
 *
 *  @return PAPIAuthor
 */
- (PAPIAuthor *)PAPI_users:(NSUInteger)author_id;

/**
 *  我的订阅
 *  me/feeds.json
 *
 *  @param show_r18         NO - hide r18 illusts
 *
 *  @return PAPIIllustList
 */
- (PAPIIllustList *)PAPI_me_feeds:(BOOL)show_r18;

/**
 *  用户收藏
 *  users/<author_id>/favorite_works.json
 *
 *  @param page             [1-n]
 *  @param publicity        YES - public; NO - private (only auth user)
 *
 *  @return PAPIIllustList
 */
- (PAPIIllustList *)PAPI_users_favorite_works:(NSUInteger)author_id page:(NSUInteger)page publicity:(BOOL)publicity;
```

### asyncBlockingQueue

```objective-c
/**
 *  Async run operation in Queue, and then call onCompletion
 *
 *  @param queuePriority     set 0 for NSOperationQueuePriorityNormal
 *  @param mainOperations    code block for sync(blocking) api
 *  @param onCompletion      completion block on mainQueue
 */
- (void)asyncBlockingQueue:(void (^)(void))mainOperations;
- (void)asyncBlockingQueue:(NSOperationQueuePriority)queuePriority operations:(void (^)(void))mainOperations completion:(void (^)(void))onCompletion;
```

API use asyncBlockingQueue: for async request, for example:

```objective-c
    [[PixivAPI sharedInstance] asyncBlockingQueue:^{
        NSArray *illusts = [[PixivAPI sharedInstance] SAPI_ranking:1 mode:@"all" content:@"day" requireAuth:NO];

        // 1 - sync fetch
        for (SAPIIllust *illust in [illusts subarrayWithRange:NSMakeRange(0, 3)]) {
            NSLog(@"(%lu) %@", (unsigned long)[PixivAPI sharedInstance].operationQueue.operationCount, illust);

            SAPIIllust *author = [[PixivAPI sharedInstance] SAPI_user:illust.authorId requireAuth:NO];
            NSLog(@"(%lu) %@", (unsigned long)[PixivAPI sharedInstance].operationQueue.operationCount, author);
            NSLog(@"   fetch %ld complete", (long)author.authorId);
        }

        NSLog(@"1 - sync fetch illust[1,2,3] complete");

        // 2 - async batch fetch
        for (SAPIIllust *illust in [illusts subarrayWithRange:NSMakeRange(3, 3)]) {
            [[PixivAPI sharedInstance] asyncBlockingQueue:^{
                SAPIIllust *author = [[PixivAPI sharedInstance] SAPI_user:illust.authorId requireAuth:NO];
                NSLog(@"(%lu) %@", (unsigned long)[PixivAPI sharedInstance].operationQueue.operationCount, author);
                NSLog(@"   fetch %ld complete", (long)author.authorId);
            }];
        }

        NSLog(@"2 - async illust[4,5,6] start.");
    }];
```

output:

```
21:59:29.788 (1) Illust: [なごみ＠かんこれ(id=10457532)] 龍驤たちとオネエな提督(id=46597437)
21:59:29.926 (1) Author: なごみ＠かんこれ(id=10457532)
21:59:29.927   fetch 10457532 complete
21:59:29.927 (1) Illust: [松竜(id=2159670)] 凛さん(id=46599697)
21:59:30.060 (1) Author: 松竜(id=2159670)
21:59:30.060    fetch 2159670 complete
21:59:30.060 (1) Illust: [柳田史太(id=1774701)] 「私はサポート役だから」とか思ってる系女子(id=46599040)
21:59:30.202 (1) Author: 柳田史太(id=1774701)
21:59:30.202    fetch 1774701 complete
21:59:33.217 1 - sync fetch illust[1,2,3] complete
21:59:33.217 2 - async illust[4,5,6] start.
21:59:33.592 (3) Author: ポ～ン（出水ぽすか）(id=33333)
21:59:33.593    fetch 33333 complete
21:59:33.593 (3) Author: JaneMere(id=49693)
21:59:33.593    fetch 49693 complete
21:59:33.765 (1) Author: ふぉぶ(id=465361)
21:59:33.765    fetch 465361 complete
```

_Tips:_ MAX_CONCURRENT_OPERATION_COUNT(2) limit only 2 operations run in queue, so operationCount=1 when "21:59:33.765 (1) Author: ふぉぶ(id=465361)" request started.

**Update UI on mainQueue:**

asyncBlockingQueue: run operations on operationQueue, it causing UI update delay. So use **onMainQueue:** when you reloadData for UI:

```objective-c
    __weak ViewController *weakSelf = self;
    [[PixivAPI sharedInstance] asyncBlockingQueue:^{
        NSArray *illusts = [[PixivAPI sharedInstance] SAPI_ranking:page mode:@"day" content:@"all" requireAuth:NO];

        [[PixivAPI sharedInstance] onMainQueue:^{
            // update UI here
            weakSelf.illusts = [weakSelf.illusts arrayByAddingObjectsFromArray:illusts];
            [weakSelf.tableView reloadData];
        }];
    }];
```
