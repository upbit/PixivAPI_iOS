//
//  PixivIllustsTableViewController.h
//  PixivDaily
//
//  Created by Zhou Hao on 14-8-31.
//  Copyright (c) 2014年 Kastark. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PixivImageViewController.h"
#import "PixivFetcher.h"

@interface PixivIllustsTableViewController : UITableViewController

@property (strong, nonatomic) NSArray *illusts;     // of IllustModel

// override this for image view action
- (void)prepareImageViewController:(PixivImageViewController *)ivc toDisplayPhoto:(IllustModel *)illust mobileSize:(BOOL)mobileSize;

@end
