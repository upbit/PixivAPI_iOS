//
//  PixivIllustsTableViewController.h
//  PixivDaily
//
//  Created by Zhou Hao on 14-8-31.
//  Copyright (c) 2014年 Kastark. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PixivImageViewController.h"
#import "PixivAPI/PixivAPI.h"

@interface PixivIllustsTableViewController : UITableViewController

@property (strong, nonatomic) NSArray *illusts;     // of SAPIIllust

// override this for image view action
- (void)prepareImageViewController:(PixivImageViewController *)ivc toDisplayPhoto:(SAPIIllust *)illust mobileSize:(BOOL)mobileSize;

@end
