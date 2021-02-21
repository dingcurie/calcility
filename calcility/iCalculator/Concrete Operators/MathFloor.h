//
//  MathFloor.h
//  iCalculator
//
//  Created by curie on 13-10-21.
//  Copyright (c) 2013年 Fish Tribe. All rights reserved.
//

#import "MathCompositeOperator.h"


@interface MathFloor : MathCompositeOperator

- (id)initWithContent:(MathExpression *)content;  //: Designated Initializer

@property (nonatomic, strong, readonly) MathExpression *content;

- (MathResult *)operate;

@end
