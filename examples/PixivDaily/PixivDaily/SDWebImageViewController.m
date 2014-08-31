//
//  SDWebImageViewController.m
//  PixivDaily
//
//  Created by Zhou Hao on 14-8-29.
//  Copyright (c) 2014年 Kastark. All rights reserved.
//

#import "SDWebImageViewController.h"
#import <SDWebImage/UIImageView+WebCache.h>

@interface SDWebImageViewController () <UIScrollViewDelegate>

@property (strong, nonatomic) UIImageView *imageView;
@property (strong, nonatomic) UIImage *image;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *spinner;

@end

@implementation SDWebImageViewController

- (void)setScrollView:(UIScrollView *)scrollView
{
    _scrollView = scrollView;
    _scrollView.maximumZoomScale = 2.0;
    _scrollView.delegate = self;
    self.scrollView.contentSize = self.image ? self.image.size : CGSizeZero;
}

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return self.imageView;
}

- (void)setImageURL:(NSURL *)imageURL
{
    _imageURL = imageURL;
    [self startDonwloadImage];
}

- (UIImageView *)imageView
{
    if (!_imageView) _imageView = [[UIImageView alloc] init];
    return _imageView;
}

- (UIImage *)image
{
    return self.imageView.image;
}

// Zoom to show as much image as possible
// http://stackoverflow.com/questions/14471298/zooming-uiimageview-inside-uiscrollview-with-autolayout
- (void)initZoom
{
    float minZoom = MIN(self.view.bounds.size.width / self.imageView.image.size.width,
                        self.view.bounds.size.height / self.imageView.image.size.height);
    if (minZoom > 1) return;
    
    self.scrollView.minimumZoomScale = minZoom;
    self.scrollView.zoomScale = minZoom;
}

- (void)setImage:(UIImage *)image
{
    self.imageView.image = image;
    self.imageView.frame = CGRectMake(0,0,image.size.width,image.size.height);
    [self.spinner stopAnimating];
    self.scrollView.contentSize = self.image ? self.image.size : CGSizeZero;
    [self initZoom];
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    [self initZoom];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.scrollView addSubview:self.imageView];
}

- (void)startDonwloadImage
{
    self.image = nil;
    
    if (self.imageURL) {
        [self.spinner startAnimating];
        NSLog(@"download: %@", self.imageURL);
        
        [self.imageView sd_setImageWithURL:self.imageURL
                                 completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                                     self.image = image;
                                 }];
    }
}

@end
