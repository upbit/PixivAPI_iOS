//
//  DailyRankingCollectionViewController.m
//  PixivDaily
//
//  Created by Zhou Hao on 14-9-12.
//  Copyright (c) 2014年 Kastark. All rights reserved.
//

#import "DailyRankingCollectionViewController.h"
#import "RecentsViewController.h"
#import "PixivAPI.h"

#define MAX_FETCH_RANKING_PAGE_NUM (6)

@interface DailyRankingCollectionViewController ()

@property (nonatomic) NSUInteger currentPage;

@end

@implementation DailyRankingCollectionViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self getPixivDailyRanking];
}

- (IBAction)getPixivDailyRanking
{
    self.illusts = @[];
    self.currentPage = 1;
    [self addPageRankingIllusts:self.currentPage];
}

- (void)addPageRankingIllusts:(NSUInteger)page
{
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    
    __weak DailyRankingCollectionViewController *weakSelf = self;
    [[PixivAPI sharedInstance] asyncBlockingQueue:^{
        NSArray *illusts = [[PixivAPI sharedInstance] SAPI_ranking:page mode:@"day" content:@"all" requireAuth:NO];
        
        // dispatch on mainQueue, so data reload will start immediately
        [[PixivAPI sharedInstance] onMainQueue:^{
            // update UI here
            weakSelf.illusts = [weakSelf.illusts arrayByAddingObjectsFromArray:illusts];
        }];
        
        //[weakSelf.refreshControl endRefreshing];
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    }];
}

#pragma mark - UITableView Load More

- (BOOL)loadMoreIllusts
{
    if (self.currentPage < MAX_FETCH_RANKING_PAGE_NUM) {
        self.currentPage++;
        NSLog(@"Load More - page %lu", (unsigned long)self.currentPage);
        [self addPageRankingIllusts:self.currentPage];
        return YES;
    } else {
        return NO;
    }
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == [self.illusts count]-1) {
        [self loadMoreIllusts];
    }
    
    return [super collectionView:collectionView cellForItemAtIndexPath:indexPath];
}

#pragma mark - override

- (void)addViewedIllustToRecentsArray:(SAPIIllust *)illust
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

- (void)prepareImageViewController:(PixivImageViewController *)ivc toDisplayPhoto:(SAPIIllust *)illust mobileSize:(BOOL)mobileSize
{
    [super prepareImageViewController:ivc toDisplayPhoto:illust mobileSize:mobileSize];
    
    [self addViewedIllustToRecentsArray:illust];
}

@end
