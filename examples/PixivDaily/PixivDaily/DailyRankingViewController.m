//
//  DailyRankingViewController.m
//  PixivDaily
//
//  Created by Zhou Hao on 14-8-31.
//  Copyright (c) 2014年 Kastark. All rights reserved.
//

#import "DailyRankingViewController.h"
#import "PixivFetcher.h"
#import "RecentsViewController.h"

@interface DailyRankingViewController ()

@end

@implementation DailyRankingViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self getRanking];
}

- (IBAction)getRanking
{
    __weak DailyRankingViewController *weakSelf = self;
    [PixivFetcher API_getRanking:1 mode:PIXIV_RANKING_MODE_DAY content:PIXIV_RANKING_CONTENT_ALL
                       onSuccess:^(NSArray *illusts, BOOL isIllust) {
                           [weakSelf.refreshControl endRefreshing];
                           weakSelf.illusts = illusts;
                       }
                       onFailure:^(NSURLResponse *response, NSInteger responseCode, NSData *data, NSError *connectionError) {
                           NSLog(@"[HTTP %d] %@", responseCode, connectionError);
                       }];
}

- (void)addViewedIllustToRecentsArray:(IllustModel *)illust
{
    NSMutableArray *recents = [[NSMutableArray alloc] initWithArray:[[NSUserDefaults standardUserDefaults] objectForKey:KEY_RECENT_ILLUSTS]];
    NSArray *dataArray = [illust toDataArray];
    
    // due to illust.view changes every time, remove duplicate might not work here
    if ([recents containsObject:dataArray]) {
        NSUInteger index = [recents indexOfObject:dataArray];
        [recents removeObjectAtIndex:index];
    }
    [recents insertObject:dataArray atIndex:0];
    
    NSArray *newRecents = [recents subarrayWithRange:NSMakeRange(0, MIN([recents count], MAX_RECENT_ILLUST_NUM))];
    [[NSUserDefaults standardUserDefaults] setObject:newRecents forKey:KEY_RECENT_ILLUSTS];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)prepareImageViewController:(SDWebImageViewController *)ivc toDisplayPhoto:(IllustModel *)illust mobileSize:(BOOL)mobileSize
{
    [super prepareImageViewController:ivc toDisplayPhoto:illust mobileSize:mobileSize];
    
    [self addViewedIllustToRecentsArray:illust];
}

@end
