//
//  TipsMasterViewController_iPhone.m
//  iCalculator
//
//  Created by curie on 13-4-18.
//  Copyright (c) 2013年 Fish Tribe. All rights reserved.
//

#import "TipsMasterViewController_iPhone.h"
#import "TipsDetailViewController.h"
#import "PreferencesViewController.h"
#import <MessageUI/MessageUI.h>


@interface TipsMasterViewController_iPhone () <MFMailComposeViewControllerDelegate>

@property (weak, nonatomic) IBOutlet UIButton *theEmailUsButton;

- (IBAction)goReview:(id)sender;
- (IBAction)emailUs:(id)sender;

@end


@implementation TipsMasterViewController_iPhone

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.theEmailUsButton.enabled = [MFMailComposeViewController canSendMail];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    NSString *segueID = segue.identifier;
    if ([segueID isEqualToString:@"info_doneViewingTips"]) {
        PreferencesViewController *preferencesVC = ((UINavigationController *)self.tabBarController.viewControllers[0]).viewControllers[0];
        [preferencesVC save];
    }
    else {
        TipsDetailViewController *tipsDetailVC = segue.destinationViewController;
        NSString *pageName = segue.identifier;
        NSString *pagePath = [[NSBundle mainBundle] pathForResource:pageName ofType:@"html"];
        NSURL *pageURL = [NSURL fileURLWithPath:pagePath isDirectory:NO];
        tipsDetailVC.pageURL = pageURL;
    }
}


- (IBAction)goReview:(id)sender
{
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:g_appLink]];
}

- (IBAction)emailUs:(id)sender
{
    MFMailComposeViewController *mailComposeViewComtroller = [[MFMailComposeViewController alloc] init];
    mailComposeViewComtroller.mailComposeDelegate = self;
    [mailComposeViewComtroller setToRecipients:@[@"fish.tribe@icloud.com"]];
    [mailComposeViewComtroller setSubject:NSLocalizedString(@"Customer Feedback", nil)];
    [self presentViewController:mailComposeViewComtroller animated:YES completion:nil];
}

- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
