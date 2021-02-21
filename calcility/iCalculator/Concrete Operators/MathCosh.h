//
//  MathCosh.h
//  iCalculator
//
//  Created by curie on 13-11-19.
//  Copyright (c) 2013年 Fish Tribe. All rights reserved.
//

#import "MathOperator.h"


@interface MathCosh : MathOperator

+ (instancetype)cosh;

- (MathResult *)operateOnOperand:(MathResult *)operand;

@end
