//
//  MathExpressionToNSDataTransformer.m
//  iCalculator
//
//  Created by curie on 6/14/14.
//  Copyright (c) 2014 Fish Tribe. All rights reserved.
//

#import "MathExpressionToNSDataTransformer.h"


@implementation MathExpressionToNSDataTransformer

+ (Class)transformedValueClass
{
    return [NSData class];
}

- (id)transformedValue:(id)value
{
    return [NSKeyedArchiver archivedDataWithRootObject:value];
}

- (id)reverseTransformedValue:(id)value
{
    @try {
        return [NSKeyedUnarchiver unarchiveObjectWithData:value];
    }
    @catch (NSException *exception) {
        return nil;
    }
}

@end
