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

@interface PixivDetailScrollImageViewController ()

@end

@implementation PixivDetailScrollImageViewController

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

- (void)realShowImageWithBaseInfo:(NSDictionary *)illust_record
{
    [super realShowImageWithBaseInfo:illust_record];
    self.navigationItem.title = illust_record[@"title"];
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
        }];
    }];

    // preload next 2 illust
    for (NSInteger i = 1; i <= 2; i++) {
        [[PixivAPI sharedInstance] asyncBlockingQueue:^{
            [weakSelf replaceSAPIIllustToPAPIIllustAtIndex:weakSelf.index+i];
            
            [[PixivAPI sharedInstance] onMainQueue:^{
                NSDictionary *preload_record = [weakSelf illustRecordWithIndex:weakSelf.index+i];
                if (!preload_record) {
                    NSLog(@"safeGetIllustBaseInfo(%ld) error", (long)(weakSelf.index+i));
                    return;
                }
                [weakSelf preloadImageWithBaseInfo:preload_record];
            }];
        }];
    }
}

- (void)singleTap:(UITapGestureRecognizer *)sender
{
    [self.navigationController setNavigationBarHidden:!self.navigationController.isNavigationBarHidden animated:YES];
    [self updateZoom];
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
