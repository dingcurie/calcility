//
//  HTVC_ColorPallete.m
//  iCalculator
//
//  Created by curie on 11/27/14.
//  Copyright (c) 2014 Fish Tribe. All rights reserved.
//

#import "HTVC_ColorPallete.h"


@implementation HTVC_ColorPallete

+ (NSArray *)allColors
{
    static NSArray *allColors;
    if (allColors == nil) {
        allColors = @[
            [UIColor colorWithHue:342/359.0 saturation:0.84 brightness:1.00 alpha:1.0],
            [UIColor colorWithHue: 35/359.0 saturation:1.00 brightness:1.00 alpha:1.0],
            [UIColor colorWithHue: 48/359.0 saturation:1.00 brightness:1.00 alpha:1.0],
            [UIColor colorWithHue:104/359.0 saturation:0.74 brightness:0.85 alpha:1.0],
            [UIColor colorWithHue:200/359.0 saturation:0.89 brightness:0.97 alpha:1.0],
            [UIColor colorWithHue:289/359.0 saturation:0.49 brightness:0.88 alpha:1.0],
            [UIColor colorWithHue: 34/359.0 saturation:0.42 brightness:0.64 alpha:1.0],
        ];
    }
    return allColors;
}

+ (UIColor *)colorAtIndex:(uint32_t)index
{
    return index < [self allColors].count ? [self allColors][index] : nil;
}

@end
