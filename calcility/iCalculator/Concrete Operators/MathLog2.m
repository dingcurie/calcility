//
//  MathLog2.m
//  iCalculator
//
//  Created by curie on 13-4-9.
//  Copyright (c) 2013年 Fish Tribe. All rights reserved.
//

#import "MathLog2.h"
#import "MathLog.h"
#import "MathNumber.h"


@implementation MathLog2

- (id)initWithCoder:(NSCoder *)decoder
{
    self = (id)[[MathLog alloc] initWithBase:[[MathExpression alloc] initWithElements:@[[[MathNumber alloc] initWithString:@"2"]]]];
    return self;
}

- (void)encodeWithCoder:(NSCoder *)encoder
{
    FTAssert(NO);  //: Deprecated!
    return;
}

@end
