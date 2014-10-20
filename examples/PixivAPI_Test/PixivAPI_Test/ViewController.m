//
//  ViewController.m
//  PixivAPI_Test
//
//  Created by Zhou Hao on 14-10-7.
//  Copyright (c) 2014年 Kastark. All rights reserved.
//

#import "ViewController.h"
#import "PixivAPI.h"

// change here to your Pixiv account
#define _USERNAME @"username"
#define _PASSWORD @"password"

@interface ViewController ()

@end

@implementation ViewController

- (void)sapi_test
{
    // 异步获取 SAPI_ranking，注意在 asyncBlockingQueue: 中self指针要用__weak
    [[PixivAPI sharedInstance] asyncBlockingQueue:^{
        NSArray *illusts = [[PixivAPI sharedInstance] SAPI_ranking:1 mode:@"all" content:@"day" requireAuth:NO];
        
        // 1 - 依次请求前3张作品的信息
        for (SAPIIllust *illust in [illusts subarrayWithRange:NSMakeRange(0, 3)]) {
            NSLog(@"(%lu) %@", (unsigned long)[PixivAPI sharedInstance].operationQueue.operationCount, illust);

            SAPIIllust *author = [[PixivAPI sharedInstance] SAPI_user:illust.authorId requireAuth:NO];
            NSLog(@"(%lu) %@", (unsigned long)[PixivAPI sharedInstance].operationQueue.operationCount, author);
            NSLog(@"   fetch %ld complete", (long)author.authorId);
        }
        
        // SAPI_user是阻塞调用，所以执行到这里说明已经全部获取完毕
        NSLog(@"1 - sync fetch illust[1,2,3] complete");
        
        // 2 - 异步获取后3张的作品信息
        for (SAPIIllust *illust in [illusts subarrayWithRange:NSMakeRange(3, 3)]) {
            [[PixivAPI sharedInstance] asyncBlockingQueue:^{
                SAPIIllust *author = [[PixivAPI sharedInstance] SAPI_user:illust.authorId requireAuth:NO];
                NSLog(@"(%lu) %@", (unsigned long)[PixivAPI sharedInstance].operationQueue.operationCount, author);
                NSLog(@"   fetch %ld complete", (long)author.authorId);
            }];
        }
        
        NSLog(@"2 - async illust[4,5,6] start.");
    }];
}

- (void)auth_required_papi
{
    // PAPI
    [[PixivAPI sharedInstance] asyncBlockingQueue:^{
        
        // get illust and output origin url
        PAPIIllust *illust = [[PixivAPI sharedInstance] PAPI_works:46605041];
        NSLog(@"%@", illust);
        
        if (illust.page_count <= 1) {
            NSLog(@"  origin url: %@", illust.url_large);
        } else {
            NSDictionary *page0 = [illust.pages firstObject];
            NSLog(@"  origin page0 url: %@", page0[@"image_urls"][@"large"]);
        }
        
        // get user favorite_works
        PAPIIllustList *illustList = [[PixivAPI sharedInstance] PAPI_users_favorite_works:1184799 page:1 publicity:YES];
        for (PAPIIllust *illust in [illustList.illusts subarrayWithRange:NSMakeRange(0, 5)]) {
            NSLog(@"%@", illust);
        }
        
        NSLog(@">> %ld/%ld favorites with pages %ld, next page %ld (previous %ld)",
              (long)illustList.count, (long)illustList.total, (long)illustList.pages, (long)illustList.next, (long)illustList.previous);
        
    }];
    
    NSLog(@"async fetch PAPI started");
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.

    // some SAPI functions are 'no login required', so just call it async
    [self sapi_test];
    
#if 1
    // sync login
    [[PixivAPI sharedInstance] loginIfNeeded:_USERNAME password:_PASSWORD];
    [self auth_required_papi];
    
#else
    // login will blocking your main thread, so use this asyncBlockingQueue: in your project
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    [[PixivAPI sharedInstance] asyncBlockingQueue:^{
        
        if ([[PixivAPI sharedInstance] loginIfNeeded:_USERNAME password:_PASSWORD]) {
            NSLog(@"Login success!");
        } else {
            NSLog(@"Login failed.");
        }

        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
        
        [self auth_required_papi];
    }];
#endif

    
    
}

@end
