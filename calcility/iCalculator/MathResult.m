//
//  MathResult.m
//  iCalculator
//
//  Created by curie on 9/9/14.
//  Copyright (c) 2014 Fish Tribe. All rights reserved.
//

#import "MathResult.h"


@implementation MathResult

- (id)initWithValue:(decQuad)value unitSet:(MathUnitSet *)unitSet
{
    self = [super init];
    if (self) {
        _value = value;
        _unitSet = unitSet;
    }
    return self;
}

@end
