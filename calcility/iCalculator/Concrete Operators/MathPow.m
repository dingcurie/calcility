//
//  MathPower.m
//  iCalculator
//
//  Created by  on 12-6-12.
//  Copyright (c) 2012年 Fish Tribe. All rights reserved.
//

#import "MathPow.h"


@implementation MathPow

- (id)initWithExponent:(MathExpression *)exponent
{
    FTAssert(exponent);
    self = [super initWithLeftAffinity:MathRightUnaryOperatorLeftAffinity rightAffinity:MathNonAffinity];
    if (self) {
        _subexpressions = @[exponent];
    }
    return self;
}

- (MathExpression *)exponent
{
    return _subexpressions[0];
}

- (MathResult *)operateOnOperand:(MathResult *)operand
{
    FTAssert(operand);
    decQuad operandValue = operand.value;
    MathResult *exponent = [self.exponent evaluate];
    if (exponent == nil) return nil;
    decQuad exponentValue = exponent.value;
    decQuad tmpDec;
    decQuadAbs(&tmpDec, &exponentValue, &DQ_set);
    decQuadCompare(&tmpDec, &tmpDec, &Dec_0p1, &DQ_set);
    BOOL usesm1 = decQuadIsNegative(&tmpDec);
    double _exponentValue = IEEE754_dec2bin(&exponentValue);
    double _resultValue;
    do {
        decQuadCompare(&tmpDec, &operandValue, &Dec_e, &DQ_set);
        if (decQuadIsZero(&tmpDec)) {
            _resultValue = usesm1 ? expm1(_exponentValue) : exp(_exponentValue);
            break;
        }
        
        decQuadCompare(&tmpDec, &operandValue, &Dec_2, &DQ_set);
        if (decQuadIsZero(&tmpDec)) {
            _resultValue = usesm1 ? expm1(M_LN2 * _exponentValue) : exp2(_exponentValue);
            break;
        }
        
        /* default: */ {
            if (usesm1) {
                decQuad basem1;
                decQuadSubtract(&basem1, &operandValue, &Dec_1, &DQ_set);
                decQuadAbs(&tmpDec, &basem1, &DQ_set);
                decQuadCompare(&tmpDec, &tmpDec, &Dec_0p1, &DQ_set);
                BOOL uses1pForBase = decQuadIsNegative(&tmpDec);
                double _basex = IEEE754_dec2bin(uses1pForBase ? &basem1 : &operandValue);
                _resultValue = expm1((uses1pForBase ? log1p(_basex) : log(_basex)) * _exponentValue);
            }
            else {
                double _base = IEEE754_dec2bin(&operandValue);
                _resultValue = pow(_base, _exponentValue);
            }
        }
    } while (0);
    decQuad resultValue;
    IEEE754_bin2dec(_resultValue, &resultValue);
    if (usesm1) {
        decQuadAdd(&resultValue, &resultValue, &Dec_1, &DQ_set);
    }
    return [[MathResult alloc] initWithValue:resultValue unitSet:[operand.unitSet unitSetByRaisingToPower:exponentValue]];
}

- (CGFloat)fontSizeOfSubexpressionAtIndex:(NSUInteger)subexpressionIndex whenDrawWithContext:(MathDrawingContext *)context
{
    FTAssert(subexpressionIndex == 0 && context);
    return MAX(3.0, context.fontSize * (2.0 / 3.0));
}

- (CGPoint)originOfSubexpressionAtIndex:(NSUInteger)subexpressionIndex whenDrawWithContext:(MathDrawingContext *)context
{
    FTAssert(subexpressionIndex == 0 && context);
    UIFont *baseFont = [MathDrawingContext primaryFontWithSize:context.fontSize];
    CGFloat exponentFontSize = [self fontSizeOfSubexpressionAtIndex:0 whenDrawWithContext:context];
    UIFont *exponentFont = [MathDrawingContext primaryFontWithSize:exponentFontSize];
    CGPoint exponentOrigin;
    exponentOrigin.x = context.origin.x;
    if (context.previousElementIsGraphical) {
        exponentOrigin.y = CGRectGetMinY(context.previousElementRect) + round(exponentFont.capHeight / 2.0);
    }
    else {
        exponentOrigin.y = context.origin.y - round(baseFont.capHeight - exponentFont.capHeight / 2.0);
    }
    CGRect exponentRect = [self.exponent rectWhenDrawAtPoint:exponentOrigin withFontSize:exponentFontSize];
    CGFloat heightBelowMidline = CGRectGetMaxY(exponentRect) - (context.origin.y - round(baseFont.xHeight / 2.0));
    if (heightBelowMidline > 0.0) {
        exponentOrigin.y -= heightBelowMidline;
    }
    return exponentOrigin;
}

- (CGRect)rectWhenDrawWithContext:(MathDrawingContext *)context
{
    FTAssert(context);
    CGPoint exponentOrigin = [self originOfSubexpressionAtIndex:0 whenDrawWithContext:context];
    CGFloat exponentFontSize = [self fontSizeOfSubexpressionAtIndex:0 whenDrawWithContext:context];
    CGRect exponentRect = [self.exponent rectWhenDrawAtPoint:exponentOrigin withFontSize:exponentFontSize];
    
    CGRect virtualBaseRect = CGRectMake(context.origin.x, CGRectGetMinY(context.previousElementRect), 0.0, CGRectGetHeight(context.previousElementRect));
    return CGRectUnion(virtualBaseRect, exponentRect);
}

- (CGRect)drawWithContext:(MathDrawingContext *)context
{
    FTAssert(context);
    CGPoint exponentOrigin = [self originOfSubexpressionAtIndex:0 whenDrawWithContext:context];
    CGFloat exponentFontSize = [self fontSizeOfSubexpressionAtIndex:0 whenDrawWithContext:context];
    CGRect exponentRect = [self.exponent drawAtPoint:exponentOrigin withFontSize:exponentFontSize];
    
    CGRect virtualBaseRect = CGRectMake(context.origin.x, CGRectGetMinY(context.previousElementRect), 0.0, CGRectGetHeight(context.previousElementRect));
    return CGRectUnion(virtualBaseRect, exponentRect);
}

@end
