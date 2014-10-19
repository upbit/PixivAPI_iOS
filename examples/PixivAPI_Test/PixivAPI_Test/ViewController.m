//
//  ViewController.m
//  PixivAPI_Test
//
//  Created by Zhou Hao on 14-10-7.
//  Copyright (c) 2014年 Kastark. All rights reserved.
//

#import "ViewController.h"
#import "PixivAPI.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)auth_required_test:(PixivAPI *)api
{
    // PAPI
    /*
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    [api PAPI_works:46363414
          onSuccess:^(NSDictionary *result) {
              [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
              NSDictionary *illust = [result[@"response"] firstObject];
              NSLog(@"%@", illust);
              NSLog(@"origin url: %@", illust[@"image_urls"][@"large"]);
          }
          onFailure:^(NSURLResponse *response, NSInteger responseCode, NSData *data, NSError *connectionError) {
              [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
              NSLog(@"[HTTP %ld] %@", (long)responseCode, connectionError);
          }];
    
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    [api PAPI_users:1184799
          onSuccess:^(NSDictionary *result) {
              [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
              NSDictionary *user = [result[@"response"] firstObject];
              NSLog(@"%@", user);
              NSLog(@"introduction: %@", user[@"profile"][@"introduction"]);
          }
          onFailure:^(NSURLResponse *response, NSInteger responseCode, NSData *data, NSError *connectionError) {
              [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
              NSLog(@"[HTTP %ld] %@", (long)responseCode, connectionError);
          }];
     */
        /*
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    [api SAPI_bookmark:1184799 page:1
             onSuccess:^(NSArray *illusts, BOOL isIllust) {
                 [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
                 for (IllustBaseInfo *illust in illusts) {
                     NSLog(@"%@", illust);
                 }
             }
             onFailure:^(NSURLResponse *response, NSInteger responseCode, NSData *data, NSError *connectionError) {
                 [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
                 NSLog(@"[HTTP %ld] %@", (long)responseCode, connectionError);
             }];


    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    [api SAPI_bookmark_user_all:1184799 page:1
                      onSuccess:^(NSArray *users, BOOL isIllust) {
                          [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
                          for (IllustBaseInfo *user in users) {
                              NSLog(@"%@(@%@)", user.authorName, user.username);
                          }
                      }
                      onFailure:^(NSURLResponse *response, NSInteger responseCode, NSData *data, NSError *connectionError) {
                          [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
                          NSLog(@"[HTTP %ld] %@", (long)responseCode, connectionError);
                      }];
     */

}

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

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.

#if 1
    // sync login
    [[PixivAPI sharedInstance] loginIfNeeded:@"username" password:@"password"];
    
#else
    // login will blocking your main thread, so use this asyncBlockingQueue: in your project
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    [[PixivAPI sharedInstance] asyncBlockingQueue:^{
        
        if ([[PixivAPI sharedInstance] loginIfNeeded:@"username" password:@"password"]) {
            NSLog(@"Login success!");
        } else {
            NSLog(@"Login failed.");
        }
        
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    }];
#endif
    
    [self sapi_test];
}

@end
