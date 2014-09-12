//
//  PixivIllustCollectionViewController.h
//  PixivDaily
//
//  Created by Zhou Hao on 14-9-12.
//  Copyright (c) 2014年 Kastark. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PixivImageViewController.h"
#import "PixivFetcher.h"

@interface PixivIllustCollectionViewController : UICollectionViewController

@property (strong, nonatomic) NSArray *illusts;     // of IllustModel

// override this for image view action
- (void)prepareImageViewController:(PixivImageViewController *)ivc toDisplayPhoto:(IllustModel *)illust mobileSize:(BOOL)mobileSize;

@end
