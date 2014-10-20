//
//  PixivImageViewController.h
//  PixivDaily
//
//  Created by Zhou Hao on 14-9-2.
//  Copyright (c) 2014年 Kastark. All rights reserved.
//

#import "SDWebImageViewController.h"
#import "SAPIIllust.h"

@interface PixivImageViewController : SDWebImageViewController
@property (strong, nonatomic) SAPIIllust *illust;
@end
