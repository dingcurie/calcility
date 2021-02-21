//
//  MathEnvironment.m
//  iCalculator
//
//  Created by curie on 13-6-16.
//  Copyright (c) 2013年 Fish Tribe. All rights reserved.
//

#import "MathEnvironment.h"


@interface MathEnvironment ()

- (id)init;  //: Designated Initializer

@end


@implementation MathEnvironment

+ (MathEnvironment *)sharedEnvironment
{
    static MathEnvironment *sharedEnvironment;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedEnvironment = [[MathEnvironment alloc] init];
    });
    return sharedEnvironment;
}

- (id)init
{
    self = [super init];
    if (self) {
        _maximumSignificantDigits = 15;
    }
    return self;
}

@end
