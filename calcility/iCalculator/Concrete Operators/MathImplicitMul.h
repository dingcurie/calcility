//
//  MathImplicitMul.h
//  iCalculator
//
//  Created by curie on 12-12-21.
//  Copyright (c) 2012年 Fish Tribe. All rights reserved.
//

#import "MathOperator.h"


@interface MathImplicitMul : MathOperator

+ (instancetype)implicitMul;

- (MathResult *)operateOnLeftOperand:(MathResult *)leftOperand rightOperand:(MathResult *)rightOperand;

@end
