//
//  MathArccosh.h
//  iCalculator
//
//  Created by curie on 13-11-19.
//  Copyright (c) 2013年 Fish Tribe. All rights reserved.
//

#import "MathOperator.h"


@interface MathArccosh : MathOperator

+ (instancetype)arccosh;

- (MathResult *)operateOnOperand:(MathResult *)operand;

@end
