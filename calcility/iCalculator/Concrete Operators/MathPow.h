//
//  MathPow.h
//  iCalculator
//
//  Created by  on 12-6-12.
//  Copyright (c) 2012年 Fish Tribe. All rights reserved.
//

#import "MathCompositeOperator.h"


@interface MathPow : MathCompositeOperator

- (id)initWithExponent:(MathExpression *)exponent;  //: Designated Initializer

@property (nonatomic, strong, readonly) MathExpression *exponent;

- (MathResult *)operateOnOperand:(MathResult *)operand;

@end
