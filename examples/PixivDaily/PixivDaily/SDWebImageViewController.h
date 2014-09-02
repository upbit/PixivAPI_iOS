//
//  SDWebImageViewController.h
//  PixivDaily
//
//  Created by Zhou Hao on 14-8-29.
//  Copyright (c) 2014年 Kastark. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SDWebImageViewController : UIViewController
@property (strong, nonatomic) NSURL *imageURL;
@property (strong, nonatomic, readonly) UIImage *image;
@end
