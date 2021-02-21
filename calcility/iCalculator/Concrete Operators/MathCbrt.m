//
//  MathCbrt.m
//  iCalculator
//
//  Created by curie on 2/18/14.
//  Copyright (c) 2014 Fish Tribe. All rights reserved.
//

#import "MathCbrt.h"
#import "MathRoot.h"
#import "MathNumber.h"


@implementation MathCbrt

- (id)initWithCoder:(NSCoder *)decoder
{
    self = (id)[[MathRoot alloc] initWithIndex:[[MathExpression alloc] initWithElements:@[[[MathNumber alloc] initWithString:@"3"]]] radicand:((NSArray *)[decoder decodeObjectForKey:@"subexpressions"])[0]];
    return self;
}

- (void)encodeWithCoder:(NSCoder *)encoder
{
    FTAssert(NO);  //: Deprecated!
    return;
}

@end
