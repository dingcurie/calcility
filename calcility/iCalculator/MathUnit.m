//
//  MathUnit.m
//  iCalculator
//
//  Created by curie on 9/10/14.
//  Copyright (c) 2014 Fish Tribe. All rights reserved.
//

#import "MathUnit.h"


@implementation MathUnit

+ (instancetype)unit
{
    return [[self alloc] initWithOrder:Dec_1];
}

- (id)initWithOrder:(decQuad)order
{
    self = [super init];
    if (self) {
        _order = order;
    }
    return self;
}

@end
