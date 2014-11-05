//
//  PixivDetailScrollImageViewController.m
//  RankingLog
//
//  Created by Zhou Hao on 14/10/30.
//  Copyright (c) 2014年 Zhou Hao. All rights reserved.
//

#import "PixivDetailScrollImageViewController.h"
#import <SVProgressHUD/SVProgressHUD.h>
#import <AssetsLibrary/AssetsLibrary.h>

#import "AppDelegate.h"
#import "ModelSettings.h"
#import "PixivAPI.h"

#import "DetailInfoContainerViewController.h"
#import "UserWorksWaterfallViewController.h"

@interface PixivDetailScrollImageViewController ()
@property (weak, nonatomic) IBOutlet UIView *contantButtomView;
@end

@implementation PixivDetailScrollImageViewController

- (DetailInfoContainerViewController *)_embedViewController
{
    return (DetailInfoContainerViewController *)[self.childViewControllers firstObject];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.showLargeSize = [ModelSettings sharedInstance].isShowLargeImage;
    [self reloadImage];
}

- (BOOL)replaceSAPIIllustToPAPIIllustAtIndex:(NSInteger)index
{
    id raw_illust = self.illusts[index];
    if ((self.showLargeSize) && ([raw_illust isKindOfClass:[SAPIIllust class]])) {
        SAPIIllust *SAPI_illust = (SAPIIllust *)raw_illust;
        PAPIIllust *PAPI_illust = [[PixivAPI sharedInstance] PAPI_works:SAPI_illust.illustId];
        if (PAPI_illust) {
            NSMutableArray *new_illusts = [[NSMutableArray alloc] initWithArray:self.illusts];
            [new_illusts replaceObjectAtIndex:index withObject:PAPI_illust];
            self.illusts = new_illusts;
        }
        return YES;
    }
    return NO;
}

// override for progress
- (void)realShowImageWithBaseInfo:(NSDictionary *)illust_record
{
    NSInteger illust_id = [illust_record[@"illust_id"] integerValue];
    NSString *image_url = illust_record[@"image_url"];
    NSString *title = illust_record[@"title"];
    self.navigationItem.title = illust_record[@"title"];
    
    NSLog(@"download(%@, id=%ld): %@", title, (long)illust_id, image_url);
    
    [self simulatePixivRefererAndUserAgent:illust_id];
    
    __weak PixivDetailScrollImageViewController *weakSelf = self;
    [self.imageView sd_setImageWithURL:[NSURL URLWithString:image_url]
                      placeholderImage:self.preloadImageView.image options:(SDWebImageHighPriority|SDWebImageRetryFailed)
                              progress:^(NSInteger receivedSize, NSInteger expectedSize) {
                                  //NSLog(@"download id=%ld: %.1f%%", (long)illust_id, (float)receivedSize/expectedSize*100);
                                  [[weakSelf _embedViewController] updateDownloadProgress:(float)receivedSize/expectedSize];
                              }
                             completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                                 if (error) {
                                     NSLog(@"download(%@, id=%ld) error: %@", title, (long)illust_id, error);
                                 } else {
                                     NSLog(@"download(%@, id=%ld) completed.", title, (long)illust_id);
                                 }
                                 
                                 dispatch_async(dispatch_get_main_queue(), ^{
                                     [weakSelf onImageDownloaded:image];
                                     // hide progress bar
                                     [[weakSelf _embedViewController] updateDownloadProgress:-1.0];
                                 });
                             }];
}

// override for progress
- (void)preloadImageWithBaseInfo:(NSDictionary *)illust_record index:(NSInteger)index
{
    NSInteger illust_id = [illust_record[@"illust_id"] integerValue];
    NSString *image_url = illust_record[@"image_url"];
    NSString *title = illust_record[@"title"];
    
    NSLog(@" preload(%@, id=%ld): %@", title, (long)illust_id, image_url);
    
    [self simulatePixivRefererAndUserAgent:illust_id];
    
    __weak PixivDetailScrollImageViewController *weakSelf = self;
    SDWebImageManager *manager = [SDWebImageManager sharedManager];
    [manager downloadImageWithURL:[NSURL URLWithString:image_url] options:0
                         progress:^(NSInteger receivedSize, NSInteger expectedSize) {
                             //NSLog(@" preload id=%ld: %.1f%%", (long)illust_id, (float)receivedSize/expectedSize*100);
                             [[weakSelf _embedViewController] updatePreloadProgress:(float)receivedSize/expectedSize];
                         }
                        completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, BOOL finished, NSURL *imageURL) {
                            NSLog(@" preload id=%ld: completed", (long)illust_id);
                            [[weakSelf _embedViewController] updatePreloadProgress:-1.0];
                        }];
}

- (void)reloadImage
{
    __weak PixivDetailScrollImageViewController *weakSelf = self;
    [[PixivAPI sharedInstance] asyncBlockingQueue:^{
        [weakSelf replaceSAPIIllustToPAPIIllustAtIndex:weakSelf.index];
        
        [[PixivAPI sharedInstance] onMainQueue:^{
            NSDictionary *illust_record = [weakSelf illustRecordWithIndex:weakSelf.index];
            if (!illust_record) {
                //NSLog(@"safeGetIllustBaseInfo(%ld) error", (long)self.index);
                return;
            }
            [weakSelf realShowImageWithBaseInfo:illust_record];
            
            // update embedView for PAPIIllust
            DetailInfoContainerViewController *dicvc = [weakSelf _embedViewController];
            if (dicvc) {
                dicvc.illust = weakSelf.illusts[weakSelf.index];
                [dicvc updateEmbedView];
            }
        }];
    }];

    // preload next 2 illust
    for (NSInteger i = 1; i <= 2; i++) {
        if (self.index+i >= self.illusts.count) {
            // TO-DO: fetch next page here
            continue;
        }

        [[PixivAPI sharedInstance] asyncBlockingQueue:^{
            [weakSelf replaceSAPIIllustToPAPIIllustAtIndex:weakSelf.index+i];

            [[PixivAPI sharedInstance] onMainQueue:^{
                NSDictionary *preload_record = [weakSelf illustRecordWithIndex:weakSelf.index+i];
                if (!preload_record) {
                    NSLog(@"safeGetIllustBaseInfo(%ld) error", (long)(weakSelf.index+i));
                    return;
                }
                [weakSelf preloadImageWithBaseInfo:preload_record index:i];
            }];
        }];
    }
}

- (void)singleTap:(UITapGestureRecognizer *)sender
{
    [self.navigationController setNavigationBarHidden:!self.navigationController.isNavigationBarHidden animated:YES];
    
    if (self.navigationController.isNavigationBarHidden) {
        [self.contantButtomView setHidden:YES];
    } else {
        [self.contantButtomView setHidden:NO];
    }
    
    [self updateZoom];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"embedView"]) {
        DetailInfoContainerViewController *dicvc = (DetailInfoContainerViewController *)segue.destinationViewController;
        dicvc.illust = self.illusts[self.index];
        
    } else if ([segue.identifier isEqualToString:@"UserWorksSegue"]) {
        UserWorksWaterfallViewController *uwvc = (UserWorksWaterfallViewController *)segue.destinationViewController;
        id raw_illust = self.illusts[self.index];
        if ([raw_illust isKindOfClass:[SAPIIllust class]]) {
            SAPIIllust *illust = (SAPIIllust *)raw_illust;
            uwvc.author_id = illust.authorId;
        } else if ([raw_illust isKindOfClass:[PAPIIllust class]]) {
            PAPIIllust *illust = (PAPIIllust *)raw_illust;
            uwvc.author_id =  illust.author_id;
        } else {
            NSLog(@"unknow illust %@ type at index %ld", raw_illust, (long)self.index);
            uwvc.author_id = 0;
        }
    }
}

#pragma mark - Export Image

- (NSString *)documentsPathForFileName:(NSString *)name
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask, YES);
    NSString *documentsPath = [paths objectAtIndex:0];
    return [documentsPath stringByAppendingPathComponent:name];
}

- (void)exportImageToDocuments:(UIImage *)image filename:(NSString *)filename ext:(NSString *)ext
{
    NSLog(@"export to: %@", [self documentsPathForFileName:filename]);
    
    [SVProgressHUD showWithStatus:[NSString stringWithFormat:@"Export '%@' to Documents", filename]];
    
    dispatch_queue_t exportQueue = dispatch_queue_create("export illust", NULL);
    dispatch_async(exportQueue, ^{
        // export to Documents/
        BOOL success;
        if ([ext isEqualToString:@"png"]) {
            success = [UIImagePNGRepresentation(image) writeToFile:[self documentsPathForFileName:filename] atomically:YES];
        } else {
            success = [UIImageJPEGRepresentation(image, 0.92) writeToFile:[self documentsPathForFileName:filename] atomically:YES];
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if (!success) {
                [SVProgressHUD showErrorWithStatus:[NSString stringWithFormat:@"Export %@ to Documents/ failed.", filename]];
            } else {
                [SVProgressHUD dismiss];
            }
        });
    });
}

- (void)exportImageToPhotosAlbum:(UIImage *)image filename:(NSString *)filename
{
    [SVProgressHUD showWithStatus:[NSString stringWithFormat:@"Export '%@' to Photos Album", filename]];
    
    // export to Photos Album
    ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
    [library writeImageToSavedPhotosAlbum:[image CGImage]
                              orientation:(ALAssetOrientation)[image imageOrientation]
                          completionBlock:^(NSURL *assetURL, NSError *error) {
                              // on main queue
                              dispatch_async(dispatch_get_main_queue(), ^{
                                  if (error) {
                                      [SVProgressHUD showErrorWithStatus:[NSString stringWithFormat:@"Export error: %@", [error localizedDescription]]];
                                  } else {
                                      [SVProgressHUD dismiss];
                                  }
                              });
                          }];
}

- (IBAction)exportIllust:(UIBarButtonItem *)sender
{
    NSDictionary *current_record = [self illustRecordWithIndex:self.index];
    
    NSInteger illust_id = [current_record[@"illust_id"] integerValue];
    NSString *image_url = current_record[@"image_url"];
    NSString *title = current_record[@"title"];
    NSString *ext = [image_url substringFromIndex:image_url.length-3];
    
    NSString *exportName = [NSString stringWithFormat:@"illist_id_%ld.%@", (long)illust_id, ext];
    NSLog(@"export name[%@] to '%@'", title, exportName);
    
    if ([ModelSettings sharedInstance].isExportToDocuments)
        [self exportImageToDocuments:self.image filename:exportName ext:ext];
    
    if ([ModelSettings sharedInstance].isExportToPhotosAlbum)
        [self exportImageToPhotosAlbum:self.image filename:exportName];
}

@end
