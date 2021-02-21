//
//  MathLog.m
//  iCalculator
//
//  Created by curie on 3/27/14.
//  Copyright (c) 2014 Fish Tribe. All rights reserved.
//

#import "MathLog.h"
#import "MathLog10.h"


@implementation MathLog

- (id)initWithBase:(MathExpression *)base
{
    FTAssert(base);
    self = [super initWithLeftAffinity:MathNonAffinity rightAffinity:MathLeftUnaryOperatorRightAffinity];
    if (self) {
        _subexpressions = @[base];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)decoder
{
    self = [super initWithCoder:decoder];
    if (self) {
        if (_subexpressions == nil) {
            self = (id)[MathLog10 log10];
        }
    }
    return self;
}

- (MathExpression *)base
{
    return _subexpressions[0];
}

- (NSUInteger)barrier
{
    return 1;
}

- (MathResult *)operateOnOperand:(MathResult *)operand
{
    FTAssert(operand);
    decQuad operandValue = operand.value;
    MathResult *base = [self.base evaluate];
    if (base == nil) return nil;
    decQuad baseValue = base.value;
    decQuad operandm1;
    decQuadSubtract(&operandm1, &operandValue, &Dec_1, &DQ_set);
    decQuad tmpDec;
    decQuadAbs(&tmpDec, &operandm1, &DQ_set);
    decQuadCompare(&tmpDec, &tmpDec, &Dec_0p1, &DQ_set);
    BOOL uses1p = decQuadIsNegative(&tmpDec);
    double _operandx = IEEE754_dec2bin(uses1p ? &operandm1 : &operandValue);
    double _resultValue;
    do {
        decQuadCompare(&tmpDec, &baseValue, &Dec_10, &DQ_set);
        if (decQuadIsZero(&tmpDec)) {
            _resultValue = uses1p ? log1p(_operandx) / M_LN10 : log10(_operandx);
            break;
        }
        
        decQuadCompare(&tmpDec, &baseValue, &Dec_e, &DQ_set);
        if (decQuadIsZero(&tmpDec)) {
            _resultValue = uses1p ? log1p(_operandx) : log(_operandx);
            break;
        }
        
        decQuadCompare(&tmpDec, &baseValue, &Dec_2, &DQ_set);
        if (decQuadIsZero(&tmpDec)) {
            _resultValue = uses1p ? log1p(_operandx) / M_LN2 : log2(_operandx);
            break;
        }
        
        /* default: */ {
            decQuad basem1;
            decQuadSubtract(&basem1, &baseValue, &Dec_1, &DQ_set);
            decQuadAbs(&tmpDec, &basem1, &DQ_set);
            decQuadCompare(&tmpDec, &tmpDec, &Dec_0p1, &DQ_set);
            BOOL uses1pForBase = decQuadIsNegative(&tmpDec);
            double _basex = IEEE754_dec2bin(uses1pForBase ? &basem1 : &baseValue);
            _resultValue = (uses1p ? log1p(_operandx) : log(_operandx)) / (uses1pForBase ? log1p(_basex) : log(_basex));
        }
    } while (0);
    decQuad resultValue;
    IEEE754_bin2dec(_resultValue, &resultValue);
    return [[MathResult alloc] initWithValue:resultValue unitSet:[operand.unitSet unitSetByReconcilingWith:[base.unitSet unitSetByRaisingToPower:resultValue]]];
}

- (CGFloat)fontSizeOfSubexpressionAtIndex:(NSUInteger)subexpressionIndex whenDrawWithContext:(MathDrawingContext *)context
{
    FTAssert(context);
    return MAX(3.0, context.fontSize * (2.0 / 3.0));
}

- (CGPoint)originOfSubexpressionAtIndex:(NSUInteger)subexpressionIndex whenDrawWithContext:(MathDrawingContext *)context
{
    FTAssert(subexpressionIndex == 0 && context);
    UIFont *font = [MathDrawingContext functionFontWithSize:context.fontSize];
    NSDictionary *attr = @{NSFontAttributeName: font};
    CGSize nameSize = [@"log" sizeWithAttributes:attr];
    CGFloat baseFontSize = [self fontSizeOfSubexpressionAtIndex:0 whenDrawWithContext:context];
    CGRect baseRect = [self.base rectWhenDrawAtPoint:CGPointZero withFontSize:baseFontSize];
    UIFont *baseFont = [MathDrawingContext primaryFontWithSize:baseFontSize];
    return CGPointMake(context.origin.x + ceil(nameSize.width), context.origin.y - round(font.descender + baseFont.ascender) - CGRectGetMinY(baseRect));
}

- (CGRect)rectWhenDrawWithContext:(MathDrawingContext *)context
{
    FTAssert(context);
    CGPoint baseOrigin = [self originOfSubexpressionAtIndex:0 whenDrawWithContext:context];
    CGFloat baseFontSize = [self fontSizeOfSubexpressionAtIndex:0 whenDrawWithContext:context];
    CGRect baseRect = [self.base rectWhenDrawAtPoint:baseOrigin withFontSize:baseFontSize];
    
    UIFont *font = [MathDrawingContext functionFontWithSize:context.fontSize];
    NSDictionary *attr = @{NSFontAttributeName: font};
    CGSize nameSize = [@"log" sizeWithAttributes:attr];
    return CGRectUnion(CGRectMake(context.origin.x, context.origin.y - round(font.ascender), ceil(nameSize.width), ceil(nameSize.height)), baseRect);
}

- (CGRect)drawWithContext:(MathDrawingContext *)context
{
    FTAssert(context);
    CGPoint baseOrigin = [self originOfSubexpressionAtIndex:0 whenDrawWithContext:context];
    CGFloat baseFontSize = [self fontSizeOfSubexpressionAtIndex:0 whenDrawWithContext:context];
    CGRect baseRect = [self.base drawAtPoint:baseOrigin withFontSize:baseFontSize];
    
    UIFont *font = [MathDrawingContext functionFontWithSize:context.fontSize];
    NSDictionary *attr = @{NSFontAttributeName: font};
    CGSize nameSize = [@"log" sizeWithAttributes:attr];
    [@"log" drawAtPoint:CGPointMake(context.origin.x, context.origin.y - font.ascender) withAttributes:attr];
    return CGRectUnion(CGRectMake(context.origin.x, context.origin.y - round(font.ascender), ceil(nameSize.width), ceil(nameSize.height)), baseRect);
}

@end
