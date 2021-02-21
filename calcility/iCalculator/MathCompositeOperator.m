//
//  MathCompositeOperator.m
//  iCalculator
//
//  Created by curie on 13-1-6.
//  Copyright (c) 2013年 Fish Tribe. All rights reserved.
//

#import "MathCompositeOperator.h"


@implementation MathCompositeOperator

- (id)initWithCoder:(NSCoder *)decoder
{
    self = [super initWithCoder:decoder];
    if (self) {
        _subexpressions = [decoder decodeObjectForKey:@"subexpressions"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)encoder
{
    [super encodeWithCoder:encoder];
    [encoder encodeObject:_subexpressions forKey:@"subexpressions"];
}

- (id)copyWithZone:(NSZone *)zone
{
    MathCompositeOperator *myCopy = [[[self class] alloc] initWithLeftAffinity:self.leftAffinity rightAffinity:self.rightAffinity];
    myCopy->_subexpressions = [[NSArray alloc] initWithArray:_subexpressions copyItems:YES];
    return myCopy;
}

- (MathDrawingTrait)drawingTrait
{
    return MathDrawingGraphicalTrait;
}

- (CGFloat)fontSizeOfSubexpressionAtIndex:(NSUInteger)subexpressionIndex whenDrawWithContext:(MathDrawingContext *)context
{
    FTAssert(context);
    return context.fontSize;
}

- (CGPoint)originOfSubexpressionAtIndex:(NSUInteger)subexpressionIndex whenDrawWithContext:(MathDrawingContext *)context
{
    FTAssert(context);
    return context.origin;
}

- (NSUInteger)barrier
{
    return 0;
}

- (BOOL)isEmpty
{
    for (NSUInteger index = [self barrier]; index < _subexpressions.count; index++) {
        if (((MathExpression *)_subexpressions[index]).elements.count) {
            return NO;
        }
    }
    return YES;
}

- (void)resetCache
{
    [super resetCache];
    
    for (MathExpression *subexpression in _subexpressions) {
        [subexpression resetCache];
    }
}

@end
