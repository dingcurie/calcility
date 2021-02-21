//
//  MathEnvironment.h
//  iCalculator
//
//  Created by curie on 13-6-16.
//  Copyright (c) 2013年 Fish Tribe. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface MathEnvironment : NSObject

+ (MathEnvironment *)sharedEnvironment;

@property (nonatomic) int maximumSignificantDigits;

@end
