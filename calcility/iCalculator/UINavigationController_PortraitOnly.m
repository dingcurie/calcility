//
//  UINavigationController_PortraitOnly.m
//  iCalculator
//
//  Created by curie on 8/1/14.
//  Copyright (c) 2014 Fish Tribe. All rights reserved.
//

#import "UINavigationController_PortraitOnly.h"


@implementation UINavigationController_PortraitOnly

- (UIInterfaceOrientationMask)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait;
}

@end
