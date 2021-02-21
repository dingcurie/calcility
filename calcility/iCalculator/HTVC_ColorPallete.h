//
//  HTVC_ColorPallete.h
//  iCalculator
//
//  Created by curie on 11/27/14.
//  Copyright (c) 2014 Fish Tribe. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface HTVC_ColorPallete : NSObject

+ (NSArray *)allColors;
+ (UIColor *)colorAtIndex:(uint32_t)index;

@end
