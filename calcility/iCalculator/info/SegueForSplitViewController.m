//
//  SegueForSplitViewController.m
//  iCalculator
//
//  Created by curie on 13-7-21.
//  Copyright (c) 2013年 Fish Tribe. All rights reserved.
//

#import "SegueForSplitViewController.h"


@implementation SegueForSplitViewController

- (void)perform
{
    UIViewController *sourceViewController = self.sourceViewController;
    UIViewController *destinationViewController = self.destinationViewController;
    NSAssert([sourceViewController.parentViewController isKindOfClass:[UISplitViewController class]], @"The source view controller is not the master view controller of an object of UISplitViewController!");
    UISplitViewController *splitViewController = (UISplitViewController *)sourceViewController.parentViewController;
    splitViewController.viewControllers = @[sourceViewController, destinationViewController];
}

@end
