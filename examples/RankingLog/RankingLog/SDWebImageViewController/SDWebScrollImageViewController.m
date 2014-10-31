//
//  SDWebScrollImageViewController.m
//  PixivWalker
//
//  Created by Zhou Hao on 14-10-15.
//  Copyright (c) 2014年 Kastark. All rights reserved.
//

#import "SDWebScrollImageViewController.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import "AppDelegate.h"
#import "PixivAPI.h"

@interface SDWebScrollImageViewController ()
@property (strong, nonatomic) UIImageView *preloadImageView;
@end

@implementation SDWebScrollImageViewController

- (void)setIndex:(NSInteger)index
{
    if ((index >= 0) && (index < [self.illusts count])) {
        _index = index;
    }
}

- (UIImageView *)preloadImageView
{
    if (!_preloadImageView) _preloadImageView = [[UIImageView alloc] init];
    return _preloadImageView;
}

#pragma mark - View Controller

- (void)viewDidLoad
{
    [super viewDidLoad];

    [SDWebImageManager.sharedManager.imageDownloader setValue:@"PixivIOSApp/5.1.1" forHTTPHeaderField:@"User-Agent"];
    SDWebImageManager.sharedManager.imageDownloader.executionOrder = SDWebImageDownloaderLIFOExecutionOrder;
    
    [self.preloadImageView setHidden:YES];
    [self.scrollView addSubview:self.preloadImageView];
    
    // single/double tap gesture
    UITapGestureRecognizer *singleTapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(singleTap:)];
    singleTapGesture.numberOfTapsRequired = 1;
    [self.scrollView addGestureRecognizer:singleTapGesture];
    UITapGestureRecognizer *doubleTapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(doubleTap:)];
    doubleTapGesture.numberOfTapsRequired = 2;
    [self.scrollView addGestureRecognizer:doubleTapGesture];
    [singleTapGesture requireGestureRecognizerToFail:doubleTapGesture];
    
    // left/right swipe gesture
    self.scrollView.userInteractionEnabled = YES;
    UISwipeGestureRecognizer *leftSwipeGesture = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(leftSwipe:)];
    [leftSwipeGesture setDirection:(UISwipeGestureRecognizerDirectionLeft)];
    [self.scrollView addGestureRecognizer:leftSwipeGesture];
    UISwipeGestureRecognizer *rightSwipeGesture = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(rightSwipe:)];
    [rightSwipeGesture setDirection:(UISwipeGestureRecognizerDirectionRight)];
    [self.scrollView addGestureRecognizer:rightSwipeGesture];
    
    // user default
    self.showLargeSize = NO;
}

#pragma mark - Image Fetcher

- (NSDictionary *)_safeGetIllustBaseInfo:(NSArray *)illusts index:(NSInteger)index largeSize:(BOOL)largeSize
{
    if ((index < 0) || (index >= illusts.count)) {
        return nil;
    }
    
    NSInteger illust_id;
    NSString *image_url;
    NSString *title;
    
    id raw_illust = illusts[index];
    if ([raw_illust isKindOfClass:[NSDictionary class]]) {
        NSDictionary *illust = (NSDictionary *)raw_illust;
        illust_id = [illust[@"illust_id"] integerValue];
        if (largeSize) {
            image_url = illust[@"url_large"];
        } else {
            image_url = illust[@"url_px_480mw"];
        }
        title = illust[@"title"];
    } else if ([raw_illust isKindOfClass:[SAPIIllust class]]) {
        SAPIIllust *illust = (SAPIIllust *)raw_illust;
        illust_id = illust.illustId;
        image_url = illust.mobileURL;
        title = illust.title;
    } else if ([raw_illust isKindOfClass:[PAPIIllust class]]) {
        PAPIIllust *illust = (PAPIIllust *)raw_illust;
        illust_id = illust.illust_id;
        if (largeSize) {
            image_url = illust.true_url_large;
        } else {
            image_url = illust.url_px_480mw;
        }
        title = illust.title;
    } else {
        return nil;
    }
    
    return @{
        @"index": @(index),
        @"illust_id": @(illust_id),
        @"image_url": image_url,
        @"title": title,
    };
}

- (NSDictionary *)illustRecordWithIndex:(NSInteger)index
{
    return [self _safeGetIllustBaseInfo:self.illusts index:index largeSize:self.showLargeSize];
}

- (void)onImageDownloaded:(UIImage *)image
{
    self.image = image;
}

- (void)realShowImageWithBaseInfo:(NSDictionary *)illust_record
{
    NSInteger illust_id = [illust_record[@"illust_id"] integerValue];
    NSString *image_url = illust_record[@"image_url"];
    NSString *title = illust_record[@"title"];
    
    NSLog(@"download(%@, id=%ld): %@", title, (long)illust_id, image_url);
    
    [self simulatePixivRefererAndUserAgent:illust_id];
    
    __weak SDWebScrollImageViewController *weakSelf = self;
    [ApplicationDelegate setNetworkActivityIndicatorVisible:YES];
    
    [self.imageView sd_setImageWithURL:[NSURL URLWithString:image_url]
                      placeholderImage:self.preloadImageView.image
                             completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                                 if (error) {
                                     NSLog(@"download(%@, id=%ld) error: %@", title, (long)illust_id, error);
                                 } else {
                                     NSLog(@"download(%@, id=%ld) completed.", title, (long)illust_id);
                                 }
                                 
                                 dispatch_async(dispatch_get_main_queue(), ^{
                                     [ApplicationDelegate setNetworkActivityIndicatorVisible:NO];
                                     [weakSelf onImageDownloaded:image];
                                 });
                             }];
}

- (void)preloadImageWithBaseInfo:(NSDictionary *)illust_record
{
    NSInteger illust_id = [illust_record[@"illust_id"] integerValue];
    NSString *image_url = illust_record[@"image_url"];
    NSString *title = illust_record[@"title"];
    
    NSLog(@" preload(%@, id=%ld): %@", title, (long)illust_id, image_url);
    
    [self simulatePixivRefererAndUserAgent:illust_id];
    
    SDWebImageManager *manager = [SDWebImageManager sharedManager];
    [manager downloadImageWithURL:[NSURL URLWithString:image_url] options:0
                         progress:^(NSInteger receivedSize, NSInteger expectedSize) {
                             //NSLog(@" preload id=%ld: %.1f%%", (long)illust_id, (float)receivedSize/expectedSize*100);
                         }
                        completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, BOOL finished, NSURL *imageURL) {
                            NSLog(@" preload id=%ld: completed", (long)illust_id);
                        }];
}

- (void)reloadImage
{
    NSDictionary *illust_record = [self illustRecordWithIndex:self.index];
    if (!illust_record) {
        //NSLog(@"safeGetIllustBaseInfo(%ld) error", (long)self.index);
        return;
    }
    [self realShowImageWithBaseInfo:illust_record];
}

- (void)simulatePixivRefererAndUserAgent:(NSInteger)illust_id
{
    if (self.showLargeSize) {
        // 模拟Referer来下载原图
        NSString *referer = [NSString stringWithFormat:@"http://www.pixiv.net/member_illust.php?mode=medium&illust_id=%ld", (long)illust_id];
        NSString *user_agent = @"Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.4 (KHTML, like Gecko) Ubuntu/12.10 Chromium/22.0.1229.94 Chrome/22.0.1229.94 Safari/537.4";
        [SDWebImageManager.sharedManager.imageDownloader setValue:referer forHTTPHeaderField:@"Referer"];
        [SDWebImageManager.sharedManager.imageDownloader setValue:user_agent forHTTPHeaderField:@"User-Agent"];
    } else {
        [SDWebImageManager.sharedManager.imageDownloader setValue:@"PixivIOSApp/5.1.1" forHTTPHeaderField:@"User-Agent"];
    }
}

#pragma mark - Gesture Recognizer

- (void)singleTap:(UITapGestureRecognizer *)sender
{
    NSLog(@"singleTap");
    self.index = self.index + 1;
    [self reloadImage];
}

- (void)doubleTap:(UITapGestureRecognizer *)sender
{
    if (self.scrollView.zoomScale != 1.0) {
        self.scrollView.zoomScale = 1.0;
    } else {
        self.scrollView.zoomScale = self.lastZoomScale;
    }
}

- (void)leftSwipe:(UITapGestureRecognizer *)sender
{
    NSLog(@"leftSwipe");
    self.index = self.index + 1;
    [self reloadImage];
}

- (void)rightSwipe:(UITapGestureRecognizer *)sender
{
    NSLog(@"rightSwipe");
    self.index = self.index - 1;
    [self reloadImage];
}

@end
