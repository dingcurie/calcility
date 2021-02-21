//
//  MathFraction.h
//  iCalculator
//
//  Created by curie on 13-10-25.
//  Copyright (c) 2013年 Fish Tribe. All rights reserved.
//

#import "MathCompositeOperator.h"


@interface MathFraction : MathCompositeOperator

- (id)initWithNumerator:(MathExpression *)numerator denominator:(MathExpression *)denominator;  //: Designated Initializer

@property (nonatomic, strong, readonly) MathExpression *numerator;
@property (nonatomic, strong, readonly) MathExpression *denominator;

- (MathResult *)operate;

@end
