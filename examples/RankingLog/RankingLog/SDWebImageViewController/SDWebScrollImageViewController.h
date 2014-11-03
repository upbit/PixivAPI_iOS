//
//  SDWebScrollImageViewController.h
//  PixivWalker
//
//  Created by Zhou Hao on 14-10-15.
//  Copyright (c) 2014年 Kastark. All rights reserved.
//

#import "ScrollImageViewController.h"
#import <SDWebImage/UIImageView+WebCache.h>

@interface SDWebScrollImageViewController : ScrollImageViewController

// setIndex: for download start
@property (nonatomic) NSInteger index;
@property (strong, nonatomic) NSArray *illusts;     // of DB:IllustBase
@property (nonatomic) BOOL showLargeSize;

@property (strong, nonatomic) UIImageView *preloadImageView;
- (void)simulatePixivRefererAndUserAgent:(NSInteger)illust_id;

// for override
- (NSDictionary *)illustRecordWithIndex:(NSInteger)index;           // call before illust download/preload
- (void)onImageDownloaded:(UIImage *)image;                         // call on image downloaded
- (void)realShowImageWithBaseInfo:(NSDictionary *)illust_record;    // call on reloadImage
- (void)preloadImageWithBaseInfo:(NSDictionary *)illust_record;     // export, override reloadImage: for preload

// when index changed, call this for update
- (void)reloadImage;

// call on single tap
- (void)singleTap:(UITapGestureRecognizer *)sender;
- (void)doubleTap:(UITapGestureRecognizer *)sender;
- (void)leftSwipe:(UITapGestureRecognizer *)sender;
- (void)rightSwipe:(UITapGestureRecognizer *)sender;

@end
