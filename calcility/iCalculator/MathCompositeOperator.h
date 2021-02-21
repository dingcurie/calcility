//
//  MathCompositeOperator.h
//  iCalculator
//
//  Created by curie on 13-1-6.
//  Copyright (c) 2013年 Fish Tribe. All rights reserved.
//

#import "MathOperator.h"
#import "MathExpression.h"


@interface MathCompositeOperator : MathOperator {
    NSArray *_subexpressions;
}

@property (nonatomic, strong, readonly) NSArray *subexpressions;
@property (nonatomic, readonly) MathDrawingTrait drawingTrait;  // Defaults to MathDrawingGraphicalTrait.

- (CGFloat)fontSizeOfSubexpressionAtIndex:(NSUInteger)subexpressionIndex whenDrawWithContext:(MathDrawingContext *)context;
- (CGPoint)originOfSubexpressionAtIndex:(NSUInteger)subexpressionIndex whenDrawWithContext:(MathDrawingContext *)context;  //! The returned origin MUST be at integral offset with respect to the context.origin, but MUST NOT make integral any dimensions (including the origin) passed in via the context.

- (NSUInteger)barrier;
- (BOOL)isEmpty;

@end
