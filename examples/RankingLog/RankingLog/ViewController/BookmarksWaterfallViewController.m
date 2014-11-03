//
//  BookmarksWaterfallViewController.m
//  RankingLog
//
//  Created by Zhou Hao on 14/11/3.
//  Copyright (c) 2014年 Zhou Hao. All rights reserved.
//

#import "BookmarksWaterfallViewController.h"
#import "PixivDetailScrollImageViewController.h"

#import "AppDelegate.h"
#import "PixivAPI.h"

@interface BookmarksWaterfallViewController ()
@property (nonatomic) NSInteger nextPage;
@end

@implementation BookmarksWaterfallViewController

- (void)updateTitleWithPagination:(NSInteger)current pages:(NSInteger)pages
{
    [[PixivAPI sharedInstance] onMainQueue:^{
        self.navigationItem.title = [NSString stringWithFormat:@"Bookmarks(%ld/%ld)", (long)current, (long)pages];
    }];
}

- (NSArray *)fetchNextBookmarks
{
    PAPIIllustList *PAPI_illusts = [[PixivAPI sharedInstance] PAPI_users_favorite_works:[PixivAPI sharedInstance].user_id page:self.nextPage publicity:YES];
    [self updateTitleWithPagination:PAPI_illusts.current pages:PAPI_illusts.pages];
    
    NSLog(@"get Bookmarks: return %ld works, next page %ld", (long)PAPI_illusts.count, (long)PAPI_illusts.next);
    
    self.nextPage = PAPI_illusts.next;
    return PAPI_illusts.illusts;
}

- (void)asyncGetBookmarks
{
    if (self.nextPage == PIXIV_INT_INVALID)
        return;
    
    __weak BookmarksWaterfallViewController *weakSelf = self;
    [ApplicationDelegate setNetworkActivityIndicatorVisible:YES];
    [[PixivAPI sharedInstance] asyncBlockingQueue:^{
        
        NSArray *PAPI_illusts = [weakSelf fetchNextBookmarks];
        [[PixivAPI sharedInstance] onMainQueue:^{
            [ApplicationDelegate setNetworkActivityIndicatorVisible:NO];
            if (PAPI_illusts) {
                weakSelf.illusts = [weakSelf.illusts arrayByAddingObjectsFromArray:PAPI_illusts];
            } else {
                NSLog(@"fetchNextBookmarks: failed.");
            }
        }];
        
    }];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.illusts = @[];
    
    self.nextPage = 1;
    [self asyncGetBookmarks];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"ImageDetail"]) {
        if ([segue.destinationViewController isKindOfClass:[PixivDetailScrollImageViewController class]]) {
            PixivDetailScrollImageViewController *ivc = (PixivDetailScrollImageViewController *)segue.destinationViewController;
            NSArray *indexPaths = [self.collectionView indexPathsForSelectedItems];
            NSIndexPath *indexPath = [indexPaths objectAtIndex:0];
            ivc.illusts = self.illusts;
            ivc.index = indexPath.row;
        }
    }
}

#pragma mark - UICollectionView

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == [self.illusts count]-1) {
        // fetch next
        [self asyncGetBookmarks];
    }
    return [super collectionView:collectionView cellForItemAtIndexPath:indexPath];
}

@end
