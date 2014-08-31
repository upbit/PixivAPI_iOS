//
//  RecentsViewController.m
//  PixivDaily
//
//  Created by Zhou Hao on 14-8-31.
//  Copyright (c) 2014年 Kastark. All rights reserved.
//

#import "RecentsViewController.h"
#import "PixivFetcher.h"

@interface RecentsViewController ()

@end

@implementation RecentsViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self showRecents];
}

- (IBAction)showRecents
{
    [self.refreshControl endRefreshing];
    
    NSArray *recents = [[NSUserDefaults standardUserDefaults] objectForKey:KEY_RECENT_ILLUSTS];
    NSMutableArray *illusts = [[NSMutableArray alloc] init];
    
    for (NSArray *data in recents) {
        [illusts addObject:[PixivFetcher parseDataArrayToModel:data]];
    }
    
    self.illusts = illusts;
}

- (IBAction)cleanAllRecents:(UIBarButtonItem *)sender
{
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:KEY_RECENT_ILLUSTS];
    [[NSUserDefaults standardUserDefaults] synchronize];
    [self.tableView reloadData];
}

@end
