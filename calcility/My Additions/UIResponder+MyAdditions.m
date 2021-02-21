//
//  UIResponder+MyAdditions.m
//
//  Created by curie on 13-5-25.
//  Copyright (c) 2013年 Fish Tribe. All rights reserved.
//

#import "UIResponder+MyAdditions.h"


static UIResponder *__weak l_firstResponder;


@implementation UIResponder (MyAdditions)

+ (UIResponder *)my_firstResponder
{
    if (![l_firstResponder isFirstResponder]) {
        if ([[UIApplication sharedApplication] sendAction:@selector(my_reportAsFirstResponder:) to:nil from:nil forEvent:nil]) {
            FTAssert_DEBUG([l_firstResponder isFirstResponder]);
        }
        else {
            l_firstResponder = nil;
        }
    }
    return l_firstResponder;
}

- (void)my_reportAsFirstResponder:(id)sender
{
    l_firstResponder = self;
}

- (void)my_becomeFirstResponderIfNotAlready
{
    if (![self isFirstResponder]) {
        [self becomeFirstResponder];
    }
}

- (void)my_resignFirstResponderIfNotAlready
{
    if ([self isFirstResponder]) {
        [self resignFirstResponder];
    }
}

- (void)my_showEditingMenu
{
    return;
}

@end
