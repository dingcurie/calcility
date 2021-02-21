//
//  PreferencesViewController.m
//  iCalculator
//
//  Created by curie on 13-4-18.
//  Copyright (c) 2013年 Fish Tribe. All rights reserved.
//

#import "PreferencesViewController.h"


@interface PreferencesViewController ()

@property (weak, nonatomic) IBOutlet UISwitch *precedenceTextbookConventionSwitch;
@property (strong, nonatomic) IBOutletCollection(UIView) NSArray *precedenceTextbookConventionOnExamples;
@property (strong, nonatomic) IBOutletCollection(UIView) NSArray *precedenceTextbookConventionOffExamples;

@property (weak, nonatomic) IBOutlet UISwitch *thousandsSeparatorLeftSwitch;
@property (weak, nonatomic) IBOutlet UILabel *thousandsSeparatorLeftDigits;
@property (weak, nonatomic) IBOutlet UILabel *thousandsSeparatorLeftDigitsWithCommas;
@property (weak, nonatomic) IBOutlet UISwitch *thousandsSeparatorRightSwitch;
@property (weak, nonatomic) IBOutlet UILabel *thousandsSeparatorRightDigits;
@property (weak, nonatomic) IBOutlet UILabel *thousandsSeparatorRightDigitsWithCommas;

- (void)updatePrecedenceExamples;
- (void)updateThousandsSeparatorLeftExample;
- (void)updateThousandsSeparatorRightExample;

- (IBAction)precedenceSettingChanged:(id)sender;
- (IBAction)thousandsSeparatorLeftSettingChanged:(id)sender;
- (IBAction)thousandsSeparatorRightSettingChanged:(id)sender;

@end


@implementation PreferencesViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    if (![userDefaults boolForKey:@"MathPrecedenceTextbookConvention"]) {
        self.precedenceTextbookConventionSwitch.on = NO;
        [self updatePrecedenceExamples];
    }
    if (![userDefaults boolForKey:@"MathThousandsSeparatorLeftIsOn"]) {
        self.thousandsSeparatorLeftSwitch.on = NO;
        [self updateThousandsSeparatorLeftExample];
    }
    if ([userDefaults boolForKey:@"MathThousandsSeparatorRightIsOn"]) {
        self.thousandsSeparatorRightSwitch.on = YES;
        [self updateThousandsSeparatorRightExample];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//! WORKAROUND: Otherwise, navigation bar will jump to place from underneath the status bar.
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if (g_osVersionMajor < 8) {
        [self.navigationController.navigationBar.layer removeAllAnimations];
    }
}

- (void)updatePrecedenceExamples
{
    if ([self.precedenceTextbookConventionSwitch isOn]) {
        for (UILabel *onExample in self.precedenceTextbookConventionOnExamples) {
            onExample.hidden = NO;
        }
        for (UILabel *offExample in self.precedenceTextbookConventionOffExamples) {
            offExample.hidden = YES;
        }
    }
    else {
        for (UILabel *onExample in self.precedenceTextbookConventionOnExamples) {
            onExample.hidden = YES;
        }
        for (UILabel *offExample in self.precedenceTextbookConventionOffExamples) {
            offExample.hidden = NO;
        }
    }
}

- (void)updateThousandsSeparatorLeftExample
{
    if ([self.thousandsSeparatorLeftSwitch isOn]) {
        self.thousandsSeparatorLeftDigits.hidden = YES;
        self.thousandsSeparatorLeftDigitsWithCommas.hidden = NO;
    }
    else {
        self.thousandsSeparatorLeftDigits.hidden = NO;
        self.thousandsSeparatorLeftDigitsWithCommas.hidden = YES;
    }
}

- (void)updateThousandsSeparatorRightExample
{
    if ([self.thousandsSeparatorRightSwitch isOn]) {
        self.thousandsSeparatorRightDigits.hidden = YES;
        self.thousandsSeparatorRightDigitsWithCommas.hidden = NO;
    }
    else {
        self.thousandsSeparatorRightDigits.hidden = NO;
        self.thousandsSeparatorRightDigitsWithCommas.hidden = YES;
    }
}

- (IBAction)precedenceSettingChanged:(id)sender
{
    [self updatePrecedenceExamples];
}

- (IBAction)thousandsSeparatorLeftSettingChanged:(id)sender
{
    [self updateThousandsSeparatorLeftExample];
}

- (IBAction)thousandsSeparatorRightSettingChanged:(id)sender
{
    [self updateThousandsSeparatorRightExample];
}

- (void)save
{
    BOOL changed = NO;
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    BOOL isTextbookConvention = [self.precedenceTextbookConventionSwitch isOn];
    if ([userDefaults boolForKey:@"MathPrecedenceTextbookConvention"] != isTextbookConvention) {
        [userDefaults setBool:isTextbookConvention forKey:@"MathPrecedenceTextbookConvention"];
        changed = YES;
    }
    BOOL thousandsSeparatorLeftIsOn = [self.thousandsSeparatorLeftSwitch isOn];
    if ([userDefaults boolForKey:@"MathThousandsSeparatorLeftIsOn"] != thousandsSeparatorLeftIsOn) {
        [userDefaults setBool:thousandsSeparatorLeftIsOn forKey:@"MathThousandsSeparatorLeftIsOn"];
        changed = YES;
    }
    BOOL thousandsSeparatorRightIsOn = [self.thousandsSeparatorRightSwitch isOn];
    if ([userDefaults boolForKey:@"MathThousandsSeparatorRightIsOn"] != thousandsSeparatorRightIsOn) {
        [userDefaults setBool:thousandsSeparatorRightIsOn forKey:@"MathThousandsSeparatorRightIsOn"];
        changed = YES;
    }
    
    if (changed) {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"PreferencesDidChangeNotification" object:self userInfo:nil];
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    NSString *segueID = segue.identifier;
    if ([segueID isEqualToString:@"info_doneSettingPreferences"]) {
        [self save];
    }
}

@end
