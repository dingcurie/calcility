//
//  MathSqrt.h
//  iCalculator
//
//  Created by curie on 12-12-19.
//  Copyright (c) 2012年 Fish Tribe. All rights reserved.
//

#import "MathCompositeOperator.h"


@interface MathSqrt : MathCompositeOperator

- (id)initWithRadicand:(MathExpression *)radicand;  //: Designated Initializer

@property (nonatomic, strong, readonly) MathExpression *radicand;

- (MathResult *)operate;

@end
