//
//  PixivIllustsTableViewController.h
//  PixivDaily
//
//  Created by Zhou Hao on 14-8-31.
//  Copyright (c) 2014年 Kastark. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SDWebImageViewController.h"
#import "PixivFetcher.h"

@interface PixivIllustsTableViewController : UITableViewController

@property (strong, nonatomic) NSArray *illusts;     // of IllustModel

- (void)prepareImageViewController:(SDWebImageViewController *)ivc toDisplayPhoto:(IllustModel *)illust;

@end
