//
//  MathOperator.h
//  iCalculator
//
//  Created by  on 12-6-11.
//  Copyright (c) 2012年 Fish Tribe. All rights reserved.
//

#import "MathElement.h"
#import "MathResult.h"


@protocol MathOperator <NSObject>

@optional

//! Concrete subclass must implement one (and only one) of the following 3 methods.
- (MathResult *)operate;
- (MathResult *)operateOnOperand:(MathResult *)operand;
- (MathResult *)operateOnLeftOperand:(MathResult *)leftOperand rightOperand:(MathResult *)rightOperand;

@end


#pragma mark -


@interface MathOperator : MathElement <MathOperator>

@end
