//
//  UITabBarController_PortraitOnly.m
//  iCalculator
//
//  Created by curie on 13-6-11.
//  Copyright (c) 2013年 Fish Tribe. All rights reserved.
//

#import "UITabBarController_PortraitOnly.h"


@implementation UITabBarController_PortraitOnly

- (UIInterfaceOrientationMask)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait;
}

@end
