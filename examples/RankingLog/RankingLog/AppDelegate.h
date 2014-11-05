//
//  AppDelegate.h
//  RankingLog
//
//  Created by Zhou Hao on 14/10/28.
//  Copyright (c) 2014年 Zhou Hao. All rights reserved.
//

#import <UIKit/UIKit.h>

#define ApplicationDelegate ((AppDelegate *)[[UIApplication sharedApplication] delegate])

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
- (void)setNetworkActivityIndicatorVisible:(BOOL)setVisible;

@end
