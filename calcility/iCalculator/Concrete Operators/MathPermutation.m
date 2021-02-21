//
//  MathPermutation.m
//  iCalculator
//
//  Created by curie on 13-6-8.
//  Copyright (c) 2013年 Fish Tribe. All rights reserved.
//

#import "MathPermutation.h"


@implementation MathPermutation

- (id)initWithn:(MathExpression *)n k:(MathExpression *)k
{
    FTAssert(n && k);
    self = [super initWithLeftAffinity:MathNonAffinity rightAffinity:MathNonAffinity];
    if (self) {
        _subexpressions = @[n, k];
    }
    return self;
}

- (MathExpression *)n
{
    return _subexpressions[0];
}

- (MathExpression *)k
{
    return _subexpressions[1];
}

- (MathResult *)operate
{
    MathResult *n = [self.n evaluate];
    if (n == nil) return nil;
    decQuad nValue = n.value;
    MathResult *k = [self.k evaluate];
    if (k == nil) return nil;
    decQuad kValue = k.value;
    double _nValue = IEEE754_dec2bin(&nValue);
    double _kValue = IEEE754_dec2bin(&kValue);
    decQuad resultValue;
    if (_nValue >= 0 && _kValue >= 0 && trunc(_nValue) == _nValue && trunc(_kValue) == _kValue) {
        if (_kValue <= _nValue) {
            double _resultValue = round(tgamma(1 + _nValue) / tgamma(1 + _nValue - _kValue));
            IEEE754_bin2dec(_resultValue, &resultValue);
        }
        else {
            decQuadZero(&resultValue);
        }
    }
    else {
        resultValue = DQ_NaN;
    }
    return [[MathResult alloc] initWithValue:resultValue unitSet:[MathUnitSet none]];
}

#define PARENTHESIS_WIDTH_RATIO     0.40
#define HEIGHT_INCREMENT_RATIO      (1.0 / 10.0)

- (CGPoint)originOfSubexpressionAtIndex:(NSUInteger)subexpressionIndex whenDrawWithContext:(MathDrawingContext *)context
{
    FTAssert(context);
    CGFloat parenthesisWidth = context.fontSize * PARENTHESIS_WIDTH_RATIO;
    UIFont *font = [MathDrawingContext functionFontWithSize:context.fontSize];
    NSDictionary *attr = @{NSFontAttributeName: font};
    CGFloat nameWidth = [@"P" sizeWithAttributes:attr].width;
    switch (subexpressionIndex) {
        case 0: {
            return CGPointMake(context.origin.x + ceil(nameWidth + parenthesisWidth), context.origin.y);
        }
        default: {
            FTAssert(subexpressionIndex == 1);
            CGFloat fontSizeOfn = [self fontSizeOfSubexpressionAtIndex:0 whenDrawWithContext:context];
            CGRect rectOfn = [self.n rectWhenDrawAtPoint:CGPointZero withFontSize:fontSizeOfn];
            CGFloat separatorWidth = [@", " sizeWithAttributes:attr].width;
            return CGPointMake(context.origin.x + ceil(nameWidth + parenthesisWidth) + CGRectGetWidth(rectOfn) + ceil(separatorWidth), context.origin.y);
        }
    }
}

- (CGRect)rectWhenDrawWithContext:(MathDrawingContext *)context
{
    FTAssert(context);
    CGPoint originOfn = [self originOfSubexpressionAtIndex:0 whenDrawWithContext:context];
    CGPoint originOfk = [self originOfSubexpressionAtIndex:1 whenDrawWithContext:context];
    CGFloat fontSizeOfn = [self fontSizeOfSubexpressionAtIndex:0 whenDrawWithContext:context];
    CGFloat fontSizeOfk = [self fontSizeOfSubexpressionAtIndex:1 whenDrawWithContext:context];
    CGRect rectOfn = [self.n rectWhenDrawAtPoint:originOfn withFontSize:fontSizeOfn];
    CGRect rectOfk = [self.k rectWhenDrawAtPoint:originOfk withFontSize:fontSizeOfk];
    CGRect rect = CGRectUnion(rectOfn, rectOfk);
    
    CGFloat parenthesisWidth = context.fontSize * PARENTHESIS_WIDTH_RATIO;
    UIFont *font = [MathDrawingContext functionFontWithSize:context.fontSize];
    NSDictionary *attr = @{NSFontAttributeName: font};
    CGFloat nameWidth = [@"P" sizeWithAttributes:attr].width;
    UIFont *symbolFont = [MathDrawingContext symbolFontWithSize:context.fontSize];
    CGFloat midline = context.origin.y - round(symbolFont.capHeight / 2.0);
    CGFloat contentHeightAboveMidline = midline - CGRectGetMinY(rect);
    CGFloat contentHeightBelowMidline = CGRectGetMaxY(rect) - midline;
    UIEdgeInsets outsets = UIEdgeInsetsMake(0.0, ceil(nameWidth + parenthesisWidth), 0.0, ceil(parenthesisWidth));
    if (contentHeightAboveMidline > contentHeightBelowMidline) {
        outsets.bottom = contentHeightAboveMidline - contentHeightBelowMidline;
    }
    else {
        outsets.top = contentHeightBelowMidline - contentHeightAboveMidline;
    }
    if ([self.n isGraphical] || [self.k isGraphical]) {
        CGFloat heightIncrement = round(context.fontSize * HEIGHT_INCREMENT_RATIO);
        outsets.top += heightIncrement;
        outsets.bottom += heightIncrement;
    }
    return my_UIEdgeInsetsOutsetRect(rect, outsets);
}

- (CGRect)drawWithContext:(MathDrawingContext *)context
{
    static CGMutablePathRef boldParenthesisPath;
    if (boldParenthesisPath == NULL) {
        boldParenthesisPath = CGPathCreateMutable();
        CGPathMoveToPoint(boldParenthesisPath, NULL, 0.11, 0.00);
        CGPathAddCurveToPoint(boldParenthesisPath, NULL, 0.11,  0.55, 0.58,  0.97, 0.96,  1.00);
        CGPathAddCurveToPoint(boldParenthesisPath, NULL, 0.83,  0.94, 0.66,  0.82, 0.57,  0.60);
        CGPathAddCurveToPoint(boldParenthesisPath, NULL, 0.45,  0.28, 0.45, -0.28, 0.57, -0.60);
        CGPathAddCurveToPoint(boldParenthesisPath, NULL, 0.66, -0.82, 0.83, -0.94, 0.96, -1.00);
        CGPathAddCurveToPoint(boldParenthesisPath, NULL, 0.58, -0.97, 0.11, -0.55, 0.11,  0.00);
        CGPathCloseSubpath(boldParenthesisPath);
    }

    FTAssert(context);
    CGPoint originOfn = [self originOfSubexpressionAtIndex:0 whenDrawWithContext:context];
    CGPoint originOfk = [self originOfSubexpressionAtIndex:1 whenDrawWithContext:context];
    CGFloat fontSizeOfn = [self fontSizeOfSubexpressionAtIndex:0 whenDrawWithContext:context];
    CGFloat fontSizeOfk = [self fontSizeOfSubexpressionAtIndex:1 whenDrawWithContext:context];
    CGRect rectOfn = [self.n drawAtPoint:originOfn withFontSize:fontSizeOfn];
    CGRect rectOfk = [self.k drawAtPoint:originOfk withFontSize:fontSizeOfk];
    CGRect rect = CGRectUnion(rectOfn, rectOfk);
    
    CGFloat parenthesisWidth = context.fontSize * PARENTHESIS_WIDTH_RATIO;
    UIFont *font = [MathDrawingContext functionFontWithSize:context.fontSize];
    NSDictionary *attr = @{NSFontAttributeName: font};
    CGFloat nameWidth = [@"P" sizeWithAttributes:attr].width;
    UIFont *symbolFont = [MathDrawingContext symbolFontWithSize:context.fontSize];
    CGFloat midline = context.origin.y - round(symbolFont.capHeight / 2.0);
    CGFloat contentHeightAboveMidline = midline - CGRectGetMinY(rect);
    CGFloat contentHeightBelowMidline = CGRectGetMaxY(rect) - midline;
    CGFloat halfHeight;
    UIEdgeInsets outsets = UIEdgeInsetsMake(0.0, ceil(nameWidth + parenthesisWidth), 0.0, ceil(parenthesisWidth));
    if (contentHeightAboveMidline > contentHeightBelowMidline) {
        halfHeight = contentHeightAboveMidline;
        outsets.bottom = contentHeightAboveMidline - contentHeightBelowMidline;
    }
    else {
        halfHeight = contentHeightBelowMidline;
        outsets.top = contentHeightBelowMidline - contentHeightAboveMidline;
    }
    if ([self.n isGraphical] || [self.k isGraphical]) {
        CGFloat heightIncrement = round(context.fontSize * HEIGHT_INCREMENT_RATIO);
        halfHeight += heightIncrement;
        outsets.top += heightIncrement;
        outsets.bottom += heightIncrement;
    }

    [@"P" drawAtPoint:CGPointMake(context.origin.x, context.origin.y - font.ascender) withAttributes:attr];
    [@", " drawAtPoint:CGPointMake(context.origin.x + ceil(nameWidth + parenthesisWidth) + CGRectGetWidth(rectOfn), context.origin.y - font.ascender) withAttributes:attr];
    
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    
    CGContextSaveGState(ctx);
    CGContextTranslateCTM(ctx, context.origin.x + nameWidth, midline);
    CGContextScaleCTM(ctx, parenthesisWidth, halfHeight);
    CGContextAddPath(ctx, boldParenthesisPath);
    CGContextRestoreGState(ctx);
    
    CGContextSaveGState(ctx);
    CGContextTranslateCTM(ctx, context.origin.x + ceil(nameWidth + parenthesisWidth) + CGRectGetWidth(rect) + ceil(parenthesisWidth), midline);
    CGContextScaleCTM(ctx, -parenthesisWidth, halfHeight);
    CGContextAddPath(ctx, boldParenthesisPath);
    CGContextRestoreGState(ctx);
    
    CGContextFillPath(ctx);

    return my_UIEdgeInsetsOutsetRect(rect, outsets);
}

@end
