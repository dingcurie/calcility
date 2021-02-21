//
//  TipsMasterViewController_iPad.m
//  iCalculator
//
//  Created by curie on 13-7-21.
//  Copyright (c) 2013年 Fish Tribe. All rights reserved.
//

#import "TipsMasterViewController_iPad.h"
#import "TipsDetailViewController.h"
#import <MessageUI/MessageUI.h>


@interface TipsMasterViewController_iPad () <MFMailComposeViewControllerDelegate>

- (IBAction)goReview:(id)sender;
- (IBAction)emailUs:(id)sender;

@end


@implementation TipsMasterViewController_iPad

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.clearsSelectionOnViewWillAppear = NO;
    
    NSIndexPath *indexPathForFirstRow = [NSIndexPath indexPathForRow:0 inSection:0];
    [self.tableView selectRowAtIndexPath:indexPathForFirstRow animated:NO scrollPosition:UITableViewScrollPositionNone];
    [self tableView:self.tableView didSelectRowAtIndexPath:indexPathForFirstRow];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//! WORKAROUND: UITableViewController, when used as UISplitView's master, doesn't get its table view's insets auto-adjusted since iOS 7.
- (void)viewDidLayoutSubviews
{
    UIEdgeInsets insets = UIEdgeInsetsMake(self.topLayoutGuide.length, 0.0, self.bottomLayoutGuide.length, 0.0);
    self.tableView.contentInset = insets;
    self.tableView.scrollIndicatorInsets = insets;
}

#pragma mark -

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UISplitViewController *splitViewController = (UISplitViewController *)self.parentViewController;
    TipsDetailViewController *tipsDetailVC = splitViewController.viewControllers[1];
    
    if (indexPath.section == 0) {
        NSString *pageName = [@"tip" stringByAppendingFormat:@"%ld", (long)indexPath.row];
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
    if ([MFMailComposeViewController canSendMail]) {
        MFMailComposeViewController *mailComposeViewComtroller = [[MFMailComposeViewController alloc] init];
        mailComposeViewComtroller.mailComposeDelegate = self;
        [mailComposeViewComtroller setToRecipients:@[@"fish.tribe@icloud.com"]];
        [mailComposeViewComtroller setSubject:NSLocalizedString(@"Customer Feedback", nil)];
        [self presentViewController:mailComposeViewComtroller animated:YES completion:nil];
    }
    else {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Oops, this device can not send mail", nil) message:nil preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"OK", nil) style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {}];
        [alert addAction:cancelAction];
        [self presentViewController:alert animated:YES completion:nil];
    }
}

- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
