//
//  MathPermille.h
//  iCalculator
//
//  Created by curie on 13-6-6.
//  Copyright (c) 2013年 Fish Tribe. All rights reserved.
//

#import "MathOperator.h"


@interface MathPermille : MathOperator

+ (instancetype)permille;

- (MathResult *)operateOnOperand:(MathResult *)operand;

@end
