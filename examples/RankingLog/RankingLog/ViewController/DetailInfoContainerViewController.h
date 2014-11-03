//
//  DetailInfoContainerViewController.h
//  RankingLog
//
//  Created by Zhou Hao on 14/11/3.
//  Copyright (c) 2014年 Zhou Hao. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DetailInfoContainerViewController : UIViewController

@property (strong, nonatomic) id illust;        // PAPIIllust / SAPIIllust

- (void)updateEmbedView;
- (void)updateDownloadProgress:(float)progress;
- (void)updatePreloadProgress:(float)progress;

@end
