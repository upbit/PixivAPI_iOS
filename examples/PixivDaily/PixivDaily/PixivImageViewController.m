//
//  PixivImageViewController.m
//  PixivDaily
//
//  Created by Zhou Hao on 14-9-2.
//  Copyright (c) 2014年 Kastark. All rights reserved.
//

#import "PixivImageViewController.h"
#import <AssetsLibrary/AssetsLibrary.h>

@interface PixivImageViewController ()

@end

@implementation PixivImageViewController

#pragma mark - Export Image

- (NSString *)documentsPathForFileName:(NSString *)name
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask, YES);
    NSString *documentsPath = [paths objectAtIndex:0];
    return [documentsPath stringByAppendingPathComponent:name];
}

- (IBAction)exportIllust:(UIBarButtonItem *)sender
{
    if ((!self.illust) || (self.illust.illustId == PIXIV_ID_INVALID))
        return;
    
    NSString *illustName = [NSString stringWithFormat:@"illist_id_%u.%@", (unsigned int)self.illust.illustId, self.illust.ext];
    NSString *illustPath = [self documentsPathForFileName:illustName];
    NSLog(@"export: %@", illustPath);
    
    __weak PixivImageViewController *weakSelf = self;
    dispatch_queue_t exportQueue = dispatch_queue_create("export illust", NULL);
    dispatch_async(exportQueue, ^{
#if 0
        // export to Documents/
        if ([weakSelf.illust.ext isEqualToString:@"png"]) {
            [UIImagePNGRepresentation(weakSelf.image) writeToFile:illustPath atomically:YES];
        } else {
            [UIImageJPEGRepresentation(weakSelf.image, 0.92) writeToFile:illustPath atomically:YES];
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Export Success!"
                                                                message:illustName
                                                               delegate:self
                                                      cancelButtonTitle:nil
                                                      otherButtonTitles:@"OK", nil];
            [alertView show];
        });
#else
        // export to Photos Album
        ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
        [library writeImageToSavedPhotosAlbum:[weakSelf.image CGImage]
                                  orientation:(ALAssetOrientation)[weakSelf.image imageOrientation]
                              completionBlock:^(NSURL *assetURL, NSError *error) {
                                  dispatch_async(dispatch_get_main_queue(), ^{
                                      if (!error) {
                                          UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Export Success!"
                                                                                              message:illustName
                                                                                             delegate:self
                                                                                    cancelButtonTitle:nil
                                                                                    otherButtonTitles:@"OK", nil];
                                          [alertView show];
                                      } else {
                                          NSLog(@"export error: %@", [error localizedDescription]);
                                          
                                          UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error!"
                                                                                              message:[error localizedDescription]
                                                                                             delegate:self
                                                                                    cancelButtonTitle:nil
                                                                                    otherButtonTitles:@"OK", nil];
                                          [alertView show];
                                      }
                                  });
                              }];
#endif
    });
}

@end
