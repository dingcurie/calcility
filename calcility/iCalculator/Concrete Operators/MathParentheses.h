//
//  MathParentheses.h
//  iCalculator
//
//  Created by curie on 12-9-8.
//  Copyright (c) 2012年 Fish Tribe. All rights reserved.
//

#import "MathCompositeOperator.h"


@interface MathParentheses : MathCompositeOperator

- (id)initWithContent:(MathExpression *)content;  //: Designated Initializer

@property (nonatomic, strong, readonly) MathExpression *content;

- (MathResult *)operate;

@end
