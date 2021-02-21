//
//  MathPos.h
//  iCalculator
//
//  Created by curie on 13-11-11.
//  Copyright (c) 2013年 Fish Tribe. All rights reserved.
//

#import "MathOperator.h"


@interface MathPos : MathOperator

+ (instancetype)pos;

- (MathResult *)operateOnOperand:(MathResult *)operand;

@end
