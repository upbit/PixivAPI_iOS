//
//  RecentsViewController.m
//  PixivDaily
//
//  Created by Zhou Hao on 14-8-31.
//  Copyright (c) 2014年 Kastark. All rights reserved.
//

#import "RecentsViewController.h"
#import "SAPIIllust.h"

@interface RecentsViewController ()

@end

@implementation RecentsViewController

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self showRecents];
}

- (IBAction)showRecents
{
    [self.refreshControl endRefreshing];
    
    NSArray *recents = [[NSUserDefaults standardUserDefaults] objectForKey:KEY_RECENT_ILLUSTS];
    NSMutableArray *illusts = [[NSMutableArray alloc] init];
    
    for (NSArray *data in recents) {
        [illusts addObject:[SAPIIllust parseDataArrayToModel:data]];
    }
    
    self.illusts = illusts;
}

- (IBAction)cleanAllRecents:(UIBarButtonItem *)sender
{
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:KEY_RECENT_ILLUSTS];
    [[NSUserDefaults standardUserDefaults] synchronize];
    self.illusts = @[];
}

@end
