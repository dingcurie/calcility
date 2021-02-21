//
//  MathAdd.h
//  iCalculator
//
//  Created by  on 12-6-12.
//  Copyright (c) 2012年 Fish Tribe. All rights reserved.
//

#import "MathOperator.h"


@interface MathAdd : MathOperator

+ (instancetype)add;

- (MathResult *)operateOnLeftOperand:(MathResult *)leftOperand rightOperand:(MathResult *)rightOperand;

@end
