//
//  FTTextField.m
//
//  Created by curie on 2/2/15.
//  Copyright (c) 2015 Fish Tribe. All rights reserved.
//

#import "FTTextField.h"


@implementation FTTextField 

- (CGSize)intrinsicContentSize
{
    CGSize intrinsicContentSize = [super intrinsicContentSize];
    intrinsicContentSize.width += 4.0;  //! Verified only in case of system font with size 17.0 pt.
    return intrinsicContentSize;
}

@end
