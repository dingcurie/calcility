//
//  MathTan.h
//  iCalculator
//
//  Created by curie on 13-4-9.
//  Copyright (c) 2013年 Fish Tribe. All rights reserved.
//

#import "MathOperator.h"


@interface MathTan : MathOperator

+ (instancetype)tan;

- (MathResult *)operateOnOperand:(MathResult *)operand;

@end
