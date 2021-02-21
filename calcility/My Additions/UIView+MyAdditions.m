//
//  UIView+MyAdditions.m
//
//  Created by curie on 8/6/14.
//  Copyright (c) 2014 Fish Tribe. All rights reserved.
//

#import "UIView+MyAdditions.h"


@implementation UIView (MyAdditions)

- (UIViewController *)my_viewController
{
    UIResponder *aResponder = self.nextResponder;
    Class theClass = [UIViewController class];
    while (aResponder) {
        if ([aResponder isKindOfClass:theClass]) {
            return (UIViewController *)aResponder;
        }
        else {
            aResponder = aResponder.nextResponder;
        }
    }
    return nil;
}

- (UIView *)my_containingViewOfClass:(Class)theClass
{
    UIView *theView = self.superview;
    while (theView) {
        if ([theView isKindOfClass:theClass]) {
            return theView;
        }
        else {
            theView = theView.superview;
        }
    }
    return nil;
}

- (void)my_refresh
{
    return;
}

@end
