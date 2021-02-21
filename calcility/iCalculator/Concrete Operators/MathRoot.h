//
//  MathRoot.h
//  iCalculator
//
//  Created by curie on 3/31/14.
//  Copyright (c) 2014 Fish Tribe. All rights reserved.
//

#import "MathCompositeOperator.h"


@interface MathRoot : MathCompositeOperator

- (id)initWithIndex:(MathExpression *)index radicand:(MathExpression *)radicand;  //: Designated Initializer

@property (nonatomic, strong, readonly) MathExpression *index;
@property (nonatomic, strong, readonly) MathExpression *radicand;

- (MathResult *)operate;

@end
