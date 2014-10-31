//
//  CHTCollectionViewCell.h
//  PixivWalker
//
//  Created by Zhou Hao on 14-10-10.
//  Copyright (c) 2014年 Kastark. All rights reserved.
//

#import <UIKit/UIKit.h>

#define CELL_IDENTIFIER @"WaterfallCell"

@interface CHTCollectionViewCell : UICollectionViewCell

@property (weak, nonatomic) IBOutlet UIImageView *image;
@property (weak, nonatomic) IBOutlet UILabel *label;

@end
