//
//  MathLog.h
//  iCalculator
//
//  Created by curie on 3/27/14.
//  Copyright (c) 2014 Fish Tribe. All rights reserved.
//

#import "MathCompositeOperator.h"


@interface MathLog : MathCompositeOperator

- (id)initWithBase:(MathExpression *)base;  //: Designated Initializer

@property (nonatomic, strong, readonly) MathExpression *base;

- (MathResult *)operateOnOperand:(MathResult *)operand;

@end
