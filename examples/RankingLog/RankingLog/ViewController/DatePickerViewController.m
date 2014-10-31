//
//  DatePickerViewController.m
//  RankingLog
//
//  Created by Zhou Hao on 14/10/29.
//  Copyright (c) 2014年 Zhou Hao. All rights reserved.
//

#import "DatePickerViewController.h"
#import "ModelSettings.h"

@interface DatePickerViewController () <UIPickerViewDataSource, UIPickerViewDelegate>

@property (weak, nonatomic) IBOutlet UITextField *usernameLabel;
@property (weak, nonatomic) IBOutlet UITextField *passwordLabel;
@property (weak, nonatomic) IBOutlet UISwitch *exportToDocumentSwitch;
@property (weak, nonatomic) IBOutlet UISwitch *exportToPhotosAlbumSwitch;
@property (weak, nonatomic) IBOutlet UISwitch *showLargeImageSwitch;

@property (weak, nonatomic) IBOutlet UISlider *maxPageLimitSlider;
@property (weak, nonatomic) IBOutlet UIPickerView *modePicker;
@property (weak, nonatomic) IBOutlet UIDatePicker *datePicker;
@property (weak, nonatomic) IBOutlet UIButton *yesterdayButton;

@end

@implementation DatePickerViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    if (![[ModelSettings sharedInstance] loadSettingFromUserDefaults]) {
        // init mode and date
        [ModelSettings sharedInstance].username = @"username";
        [ModelSettings sharedInstance].password = @"";
        [ModelSettings sharedInstance].pageLimit = 6;
        [ModelSettings sharedInstance].isExportToDocuments = NO;
        [ModelSettings sharedInstance].isExportToPhotosAlbum = YES;
        [ModelSettings sharedInstance].isShowLargeImage = YES;
        [ModelSettings sharedInstance].mode = @"weekly";
        [ModelSettings sharedInstance].date = [[NSDate date] dateByAddingTimeInterval: -86400.0];   // yesterday
    }

    self.usernameLabel.text = [ModelSettings sharedInstance].username;
    self.passwordLabel.text = [ModelSettings sharedInstance].password;

    [self.exportToDocumentSwitch setOn:[ModelSettings sharedInstance].isExportToDocuments];
    [self.exportToPhotosAlbumSwitch setOn:[ModelSettings sharedInstance].isExportToPhotosAlbum];
    [self.showLargeImageSwitch setOn:[ModelSettings sharedInstance].isShowLargeImage];
    
    self.maxPageLimitSlider.value = (float)[ModelSettings sharedInstance].pageLimit;
    
    self.modePicker.delegate = self;
    [self.modePicker setHidden:NO];
    [self.modePicker selectRow:[self.modeArray indexOfObject:[ModelSettings sharedInstance].mode] inComponent:0 animated:NO];
    
    self.datePicker.timeZone = [NSTimeZone timeZoneWithName:@"GTM+8"];
    [self.datePicker setHidden:YES];
    self.datePicker.date = [ModelSettings sharedInstance].date;
    
    [self.yesterdayButton setHidden:YES];
    
    [self.datePicker addTarget:self action:@selector(updatePickerLabelWithChanges:) forControlEvents:UIControlEventValueChanged];
    [self updatePickerLabelWithChanges:self];
}

- (void)viewWillDisappear:(BOOL)animated
{
    if ([self.navigationController.viewControllers indexOfObject:self] == NSNotFound) {
        [[ModelSettings sharedInstance] saveSettingToUserDefaults];
    }
    
    [super viewWillDisappear:animated];
}

- (IBAction)updatePickerLabelWithChanges:(id)sender
{
    if ([sender isKindOfClass:[UIDatePicker class]]) {
        [ModelSettings sharedInstance].date = self.datePicker.date;
        NSLog(@"UIDatePicker changed: %@", [ModelSettings sharedInstance].date);
        
    } else if ([sender isKindOfClass:[UIPickerView class]]) {
        [ModelSettings sharedInstance].mode = [self.modeArray objectAtIndex:[self.modePicker selectedRowInComponent:0]];
        NSLog(@"UIPickerView changed: %@", [ModelSettings sharedInstance].mode);
        
    }
    
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    dateFormat.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"zh_CN"];
    dateFormat.dateFormat = @"yyyy-MM-dd";
    
    self.navigationItem.title = [NSString stringWithFormat:@"%@:max%ld / %@",
                                 [ModelSettings sharedInstance].mode, (long)[ModelSettings sharedInstance].pageLimit,
                                 [dateFormat stringFromDate:[ModelSettings sharedInstance].date]];
}

#pragma mark - Picker DataSource

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    return self.modeArray.count;
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    return [self.modeArray objectAtIndex:row];
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    [self updatePickerLabelWithChanges:pickerView];
}

#pragma mark - UI Actions

- (IBAction)dismissKeyboard:(id)sender
{
    if ([self.usernameLabel isFirstResponder])
        [self.usernameLabel resignFirstResponder];
    if ([self.passwordLabel isFirstResponder])
        [self.passwordLabel resignFirstResponder];
}

- (IBAction)usernameValueChanged:(UITextField *)sender
{
    [ModelSettings sharedInstance].username = self.usernameLabel.text;
}

- (IBAction)passwordValueChanged:(UITextField *)sender
{
    [ModelSettings sharedInstance].password = self.passwordLabel.text;
}

- (IBAction)hideKeyboardOnEnterClick:(UITextField *)sender
{
    [sender resignFirstResponder];
}

- (IBAction)exportDocumentsSwitchChanged:(UISwitch *)sender
{
    [ModelSettings sharedInstance].isExportToDocuments = sender.on;
}

- (IBAction)exportPhotosAlbumSwitchChanged:(UISwitch *)sender
{
    [ModelSettings sharedInstance].isExportToPhotosAlbum = sender.on;
}

- (IBAction)showLargeImageSwitchChanged:(UISwitch *)sender
{
    [ModelSettings sharedInstance].isShowLargeImage = sender.on;
}

- (IBAction)pageLimitSliderChanged:(UISlider *)sender
{
    [ModelSettings sharedInstance].pageLimit = lroundf(sender.value);
    [self updatePickerLabelWithChanges:sender];
}

- (IBAction)pickerSegmentChanged:(UISegmentedControl *)sender
{
    if (sender.selectedSegmentIndex == 0) {
        [self.modePicker setHidden:NO];
        [self.datePicker setHidden:YES];
        [self.yesterdayButton setHidden:YES];
    } else {
        [self.modePicker setHidden:YES];
        [self.datePicker setHidden:NO];
        [self.yesterdayButton setHidden:NO];
    }
}

- (IBAction)goToYesterday:(UIButton *)sender
{
    [ModelSettings sharedInstance].date = [[NSDate date] dateByAddingTimeInterval: -86400.0];
    [self.datePicker setDate:[ModelSettings sharedInstance].date animated:YES];
    
    [self updatePickerLabelWithChanges:self];
}

@end
