//
//  TipsViewController_iPad.m
//  iCalculator
//
//  Created by curie on 13-7-20.
//  Copyright (c) 2013年 Fish Tribe. All rights reserved.
//

#import "TipsViewController_iPad.h"
#import "PreferencesViewController.h"


@interface TipsViewController_iPad () <UISplitViewControllerDelegate>

@end


@implementation TipsViewController_iPad

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.delegate = self;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)splitViewController:(UISplitViewController *)svc shouldHideViewController:(UIViewController *)vc inOrientation:(UIInterfaceOrientation)orientation
{
    return NO;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    NSString *segueID = segue.identifier;
    if ([segueID isEqualToString:@"info_doneViewingTips"]) {
        PreferencesViewController *preferencesVC = ((UINavigationController *)self.tabBarController.viewControllers[0]).viewControllers[0];
        [preferencesVC save];
    }
}

@end
