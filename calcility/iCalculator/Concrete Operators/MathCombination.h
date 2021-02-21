//
//  MathCombination.h
//  iCalculator
//
//  Created by curie on 13-6-8.
//  Copyright (c) 2013年 Fish Tribe. All rights reserved.
//

#import "MathCompositeOperator.h"


@interface MathCombination : MathCompositeOperator

- (id)initWithn:(MathExpression *)n k:(MathExpression *)k;  //: Designated Initializer

@property (nonatomic, strong, readonly) MathExpression *n;
@property (nonatomic, strong, readonly) MathExpression *k;

- (MathResult *)operate;

@end
