//
//  MathSin.h
//  iCalculator
//
//  Created by curie on 13-4-9.
//  Copyright (c) 2013年 Fish Tribe. All rights reserved.
//

#import "MathOperator.h"


@interface MathSin : MathOperator

+ (instancetype)sin;

- (MathResult *)operateOnOperand:(MathResult *)operand;

@end
