//
//  MathFactorial.h
//  iCalculator
//
//  Created by curie on 13-4-9.
//  Copyright (c) 2013年 Fish Tribe. All rights reserved.
//

#import "MathOperator.h"


@interface MathFactorial : MathOperator

+ (instancetype)factorial;

- (MathResult *)operateOnOperand:(MathResult *)operand;

@end
