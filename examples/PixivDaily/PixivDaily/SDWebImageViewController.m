//
//  SDWebImageViewController.m
//  PixivDaily
//
//  Created by Zhou Hao on 14-8-29.
//  Copyright (c) 2014年 Kastark. All rights reserved.
//

#import "SDWebImageViewController.h"
#import <SDWebImage/UIImageView+WebCache.h>

#define MAX_ILLUST_ZOOM_SCALE (2.0)

@interface SDWebImageViewController () <UIScrollViewDelegate, UISplitViewControllerDelegate>

@property (strong, nonatomic) UIImageView *imageView;
@property (strong, nonatomic, readwrite) UIImage *image;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *spinner;

@property (nonatomic) float widthZoomScale;
@property (nonatomic) float heightZoomScale;

@end

@implementation SDWebImageViewController

#pragma mark - View

- (void)singelTap:(UITapGestureRecognizer *)sender
{
    [self.navigationController setNavigationBarHidden:!self.navigationController.isNavigationBarHidden animated:YES];
}

- (void)doubleTap:(UITapGestureRecognizer *)sender
{
    // height -> width -> 1.0
    if (self.scrollView.zoomScale == self.heightZoomScale) {
        self.scrollView.zoomScale = self.widthZoomScale;
    } else if (self.scrollView.zoomScale == self.widthZoomScale) {
        self.scrollView.zoomScale = 1.0;
    } else {
        self.scrollView.zoomScale = self.heightZoomScale;
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.scrollView addSubview:self.imageView];
    
    // single/double tap gesture
    UITapGestureRecognizer *singleTapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(singelTap:)];
    singleTapGesture.numberOfTapsRequired = 1;
    [self.scrollView addGestureRecognizer:singleTapGesture];
    UITapGestureRecognizer *doubleTapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(doubleTap:)];
    doubleTapGesture.numberOfTapsRequired = 2;
    [self.scrollView addGestureRecognizer:doubleTapGesture];
    [singleTapGesture requireGestureRecognizerToFail:doubleTapGesture];
}

- (void)startDonwloadImage
{
    self.image = nil;
    
    if (self.imageURL) {
        [self.spinner startAnimating];
        [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
        NSLog(@"download: %@", self.imageURL);
        
        [self.imageView sd_setImageWithURL:self.imageURL
                                 completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                                     [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
                                     self.image = image;
                                 }];
    }
}

#pragma mark - ScrollView

- (void)setScrollView:(UIScrollView *)scrollView
{
    _scrollView = scrollView;
    _scrollView.maximumZoomScale = MAX_ILLUST_ZOOM_SCALE;
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

- (void)setImage:(UIImage *)image
{
    self.imageView.image = image;
    // *MAX_ILLUST_ZOOM_SCALE for image scale
    self.imageView.frame = CGRectMake(0,0,image.size.width*MAX_ILLUST_ZOOM_SCALE,image.size.height*MAX_ILLUST_ZOOM_SCALE);
    [self.spinner stopAnimating];
    self.scrollView.contentSize = self.image ? self.image.size : CGSizeZero;
    [self initZoom];
}

// Zoom to show as much image as possible
// http://stackoverflow.com/questions/14471298/zooming-uiimageview-inside-uiscrollview-with-autolayout
- (void) initZoom {
    float minZoom = MIN(self.view.bounds.size.width / self.imageView.image.size.width,
                        self.view.bounds.size.height / self.imageView.image.size.height);
    if (minZoom > 1) minZoom = 1.0;
    self.scrollView.minimumZoomScale = minZoom;
    
    self.widthZoomScale = self.view.bounds.size.width / self.imageView.image.size.width;
    self.heightZoomScale = self.view.bounds.size.height / self.imageView.image.size.height;
    
    self.scrollView.zoomScale = self.widthZoomScale;
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    [self initZoom];
}

#pragma mark - UISplitViewControllerDelegate

- (void)awakeFromNib
{
    self.splitViewController.delegate = self;
}

- (BOOL)splitViewController:(UISplitViewController *)svc shouldHideViewController:(UIViewController *)vc inOrientation:(UIInterfaceOrientation)orientation
{
    return UIInterfaceOrientationIsPortrait(orientation);
}

- (void)splitViewController:(UISplitViewController *)svc willHideViewController:(UIViewController *)aViewController withBarButtonItem:(UIBarButtonItem *)barButtonItem forPopoverController:(UIPopoverController *)pc
{
    barButtonItem.title = @"Menu";
    self.navigationItem.leftBarButtonItem = barButtonItem;
}

- (void)splitViewController:(UISplitViewController *)svc willShowViewController:(UIViewController *)aViewController invalidatingBarButtonItem:(UIBarButtonItem *)barButtonItem
{
    self.navigationItem.leftBarButtonItem = nil;
}

@end
