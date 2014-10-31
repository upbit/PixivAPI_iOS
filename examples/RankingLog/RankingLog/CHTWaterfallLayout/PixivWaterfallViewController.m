//
//  PixivWaterfallViewController.m
//  PixivWalker
//
//  Created by Zhou Hao on 14-10-11.
//  Copyright (c) 2014年 Kastark. All rights reserved.
//

#import "PixivWaterfallViewController.h"
#import <CHTCollectionViewWaterfallLayout/CHTCollectionViewWaterfallLayout.h>
#import "PixivAPI.h"

#define __MainScreenFrame   [[UIScreen mainScreen] bounds]
#define __MainScreen_Width  __MainScreenFrame.size.width
#define __MainScreen_Height __MainScreenFrame.size.height

// Cell的最小显示大小(决定列数)
#define MIN_CELL_COLUMN_SIZE        (96)
#define MIN_CELL_COLUMN_SIZE_IPAD   (150)

@interface PixivWaterfallViewController () <UICollectionViewDataSource, CHTCollectionViewDelegateWaterfallLayout>

@end

@implementation PixivWaterfallViewController

- (NSInteger)safeGetIllustId:(NSInteger)index
{
    if ((index >= 0) && (index < self.illusts.count)) {
        return [self.illusts[index][@"illust_id"] integerValue];
    }
    return -1;
}

- (void)setIllusts:(NSArray *)illusts
{
    _illusts = illusts;
    NSLog(@"set illusts, count = %ld", (unsigned long)_illusts.count);
    
    [self.collectionView reloadData];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    CHTCollectionViewWaterfallLayout *layout = [[CHTCollectionViewWaterfallLayout alloc] init];
    
    layout.sectionInset = UIEdgeInsetsMake(5, 2, 5, 2);
    layout.minimumColumnSpacing = 1;
    layout.minimumInteritemSpacing = 1;
    layout.columnCount = 3;
    
    self.collectionView.collectionViewLayout = layout;
    self.collectionView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    self.collectionView.dataSource = self;
    self.collectionView.delegate = self;
    
    //layout.headerHeight = 44;
    //[self.collectionView registerClass:[CHTCollectionViewHeader class] forSupplementaryViewOfKind:CHTCollectionElementKindSectionHeader withReuseIdentifier:@"HeaderView"];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self updateLayoutForOrientation:[UIApplication sharedApplication].statusBarOrientation];
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    [super willAnimateRotationToInterfaceOrientation:toInterfaceOrientation duration:duration];
    [self updateLayoutForOrientation:toInterfaceOrientation];
}

- (void)updateLayoutForOrientation:(UIInterfaceOrientation)orientation
{
    CHTCollectionViewWaterfallLayout *layout = (CHTCollectionViewWaterfallLayout *)self.collectionView.collectionViewLayout;
    
    CGFloat width = __MainScreen_Width;
    if (UIInterfaceOrientationIsLandscape(orientation)) {
        width = __MainScreen_Height;
    }
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        layout.columnCount = width / MIN_CELL_COLUMN_SIZE_IPAD;
    } else {
        layout.columnCount = width / MIN_CELL_COLUMN_SIZE;
    }
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return [self.illusts count];
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    CHTCollectionViewCell *cell = (CHTCollectionViewCell *)[collectionView dequeueReusableCellWithReuseIdentifier:CELL_IDENTIFIER forIndexPath:indexPath];
    
    id raw_illust = self.illusts[indexPath.row];
    NSString *image_url = nil;

    if ([raw_illust isKindOfClass:[NSDictionary class]]) {      // DB:IllustBase
        NSDictionary *illust = (NSDictionary *)raw_illust;
        cell.label.text = illust[@"title"];
        image_url = illust[@"url_px_128x128"];

    } else if ([raw_illust isKindOfClass:[PAPIIllust class]]) {
        PAPIIllust *illust = (PAPIIllust *)raw_illust;
        cell.label.text = illust.title;
        image_url = illust.url_px_128x128;

    } else if ([raw_illust isKindOfClass:[SAPIIllust class]]) {
        SAPIIllust *illust = (SAPIIllust *)raw_illust;
        cell.label.text = illust.title;
        image_url = illust.thumbURL;

    } else {
        cell.label.text = @"unhandle class";
    }

    if (image_url) {
        [cell.image sd_setImageWithURL:[NSURL URLWithString:image_url]
                      placeholderImage:[UIImage imageNamed:@"placeholder"] options:indexPath.row == 0 ? SDWebImageRefreshCached : 0];
    }

    return cell;
}

// this method will ask for supplementary views - headers and footers - for each section
- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
{
/*
    if ([kind isEqualToString:CHTCollectionElementKindSectionHeader]) {
        CHTCollectionViewHeader *headerCell = (CHTCollectionViewHeader*)[collectionView dequeueReusableSupplementaryViewOfKind:kind withReuseIdentifier:HEADER_IDENTIFIER forIndexPath:indexPath];
        headerCell.title.text = @"Ranking Log";
        headerCell.rightButton.titleLabel.text = @"Edit";
        return headerCell;
    }
*/
    return nil;
}

#pragma mark - CHTCollectionViewDelegateWaterfallLayout

// this method asks for the size of cell at indexpath
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    CGSize size = CGSizeMake(50, 50);
    return size;
}

// this method is called when a cell is selected (tapped on)
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"Cell at %ld is selected", (long)[indexPath row]);
}

@end
