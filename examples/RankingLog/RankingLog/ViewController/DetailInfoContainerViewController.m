//
//  DetailInfoContainerViewController.m
//  RankingLog
//
//  Created by Zhou Hao on 14/11/3.
//  Copyright (c) 2014年 Zhou Hao. All rights reserved.
//

#import "DetailInfoContainerViewController.h"
#import <SDWebImage/UIImageView+WebCache.h>

#import "PixivAPI.h"

@interface DetailInfoContainerViewController ()

@property (weak, nonatomic) IBOutlet UIImageView *image;
@property (weak, nonatomic) IBOutlet UILabel *label;
@property (weak, nonatomic) IBOutlet UIButton *favoriteButton;
@property (weak, nonatomic) IBOutlet UIProgressView *downloadProgress;
@property (weak, nonatomic) IBOutlet UIProgressView *preloadProgress;

@end

@implementation DetailInfoContainerViewController

- (NSInteger)currentIllustId
{
    if (!self.illust)
        return -1;
    if ([self.illust isKindOfClass:[SAPIIllust class]]) {
        SAPIIllust *SAPI_illust = (SAPIIllust *)self.illust;
        return SAPI_illust.illustId;
    } else if ([self.illust isKindOfClass:[PAPIIllust class]]) {
        PAPIIllust *PAPI_illust = (PAPIIllust *)self.illust;
        return PAPI_illust.illust_id;
    }
    return 0;
}

- (void)updateEmbedView
{
    self.label.text = @"";
    self.image.image = nil;
    self.favoriteButton.imageView.image = [UIImage imageNamed:@"Star"];
    self.favoriteButton.tag = 0;
    
    if (!self.illust)
        return;

    if ([self.illust isKindOfClass:[SAPIIllust class]]) {
        SAPIIllust *SAPI_illust = (SAPIIllust *)self.illust;
        self.label.text = SAPI_illust.authorName;

    } else if ([self.illust isKindOfClass:[PAPIIllust class]]) {
        PAPIIllust *PAPI_illust = (PAPIIllust *)self.illust;
        self.label.text = PAPI_illust.name;
        [self.image sd_setImageWithURL:[NSURL URLWithString:PAPI_illust.profile_url_px_50x50]
                      placeholderImage:[UIImage imageNamed:@"placeholder"] options:SDWebImageLowPriority
                             completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                                 NSLog(@"  fetch author=%ld profile 50x50 complete.", (long)PAPI_illust.author_id);
                             }];

        if (PAPI_illust.favorite_id != 0) {
            self.favoriteButton.imageView.image = [UIImage imageNamed:@"StarBlack"];
            self.favoriteButton.tag = PAPI_illust.favorite_id;
        }
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self updateDownloadProgress:-1.0];
    [self updatePreloadProgress:-1.0];
    
    [self updateEmbedView];
}

#pragma mark - UI

- (void)updateDownloadProgress:(float)progress
{
    if (progress > 0.0) {
        [self.downloadProgress setHidden:NO];
        self.downloadProgress.progress = progress;
    } else {
        [self.downloadProgress setHidden:YES];
    }
}
- (void)updatePreloadProgress:(float)progress
{
    if (progress > 0.0) {
        [self.preloadProgress setHidden:NO];
        self.preloadProgress.progress = progress;
    } else {
        [self.preloadProgress setHidden:YES];
    }
}

- (IBAction)favoriteWork:(UIButton *)sender
{
    NSInteger illust_id = [self currentIllustId];
    if (illust_id > 0) {
        if (sender.tag == 0) {
            NSLog(@"add favorite: %ld", (long)illust_id);
        } else {
            NSLog(@"del favorite: %ld", (long)illust_id);
        }
    }
}

@end
