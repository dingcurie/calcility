//
//  MathNeg.h
//  iCalculator
//
//  Created by curie on 12-12-21.
//  Copyright (c) 2012年 Fish Tribe. All rights reserved.
//

#import "MathOperator.h"


@interface MathNeg : MathOperator

+ (instancetype)neg;

- (MathResult *)operateOnOperand:(MathResult *)operand;

@end
