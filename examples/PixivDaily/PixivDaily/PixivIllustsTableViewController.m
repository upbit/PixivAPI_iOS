//
//  PixivIllustsTableViewController.m
//  PixivDaily
//
//  Created by Zhou Hao on 14-8-31.
//  Copyright (c) 2014年 Kastark. All rights reserved.
//

#import "PixivIllustsTableViewController.h"
#import <SDWebImage/UIImageView+WebCache.h>

#define FETCH_ILLUST_USER_AGENT @"Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.4 (KHTML, like Gecko) Ubuntu/12.10 Chromium/22.0.1229.94 Chrome/22.0.1229.94 Safari/537.4"

@interface PixivIllustsTableViewController ()

@end

@implementation PixivIllustsTableViewController

- (void)setIllusts:(NSArray *)illusts
{
    _illusts = illusts;
    [self.tableView reloadData];
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    // +1 for "Load More" cell
    return [self.illusts count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Image Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    IllustModel *illust = [self.illusts objectAtIndex:indexPath.row];
    
    cell.textLabel.text = illust.title;
    cell.detailTextLabel.text = [NSString stringWithFormat:@"%@, illust_id=%u", illust.authorName, (unsigned int)illust.illustId];
    
    // download illusts.thumbURL for cell image
    [cell.imageView sd_setImageWithURL:[NSURL URLWithString:illust.thumbURL]
                      placeholderImage:[UIImage imageNamed:@"placeholder"] options:indexPath.row == 0 ? SDWebImageRefreshCached : 0];
    
    return cell;
}

#pragma mark UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    id detail = self.splitViewController.viewControllers[1];
    if ([detail isKindOfClass:[UINavigationController class]]) {
        detail = [((UINavigationController *)detail).viewControllers objectAtIndex:0];
    }
    if ([detail isKindOfClass:[PixivImageViewController class]]) {
        // only on iPad
        [self prepareImageViewController:detail toDisplayPhoto:self.illusts[indexPath.row] mobileSize:NO];
    }
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    if ([sender isKindOfClass:[UITableViewCell class]]) {
        NSIndexPath *indexPath = [self.tableView indexPathForCell:sender];
        if (indexPath) {
            if (([segue.identifier isEqualToString:@"Show Image"]) && ([segue.destinationViewController isKindOfClass:[PixivImageViewController class]])) {
                [segue.destinationViewController setHidesBottomBarWhenPushed:YES];
                [self prepareImageViewController:segue.destinationViewController toDisplayPhoto:self.illusts[indexPath.row] mobileSize:NO];
            }
        }
    }
}

- (void)prepareImageViewController:(PixivImageViewController *)ivc toDisplayPhoto:(IllustModel *)illust mobileSize:(BOOL)mobileSize
{
    // set 'Referer' for illust download
    [SDWebImageManager.sharedManager.imageDownloader setValue:illust.refererURL forHTTPHeaderField:@"Referer"];
    [SDWebImageManager.sharedManager.imageDownloader setValue:FETCH_ILLUST_USER_AGENT forHTTPHeaderField:@"User-Agent"];
    SDWebImageManager.sharedManager.imageDownloader.executionOrder = SDWebImageDownloaderLIFOExecutionOrder;
    
    if (mobileSize) {
        ivc.imageURL = [NSURL URLWithString:illust.mobileURL];
    } else {
        ivc.imageURL = [NSURL URLWithString:illust.imageURL];
    }
    ivc.illust = illust;
    ivc.title = [NSString stringWithFormat:@"[%@] %@", illust.authorName, illust.title];
}

@end
