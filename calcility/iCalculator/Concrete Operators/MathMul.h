//
//  MathMul.h
//  iCalculator
//
//  Created by  on 12-6-17.
//  Copyright (c) 2012年 Fish Tribe. All rights reserved.
//

#import "MathOperator.h"


@interface MathMul : MathOperator

+ (instancetype)mul;

- (MathResult *)operateOnLeftOperand:(MathResult *)leftOperand rightOperand:(MathResult *)rightOperand;

@end
