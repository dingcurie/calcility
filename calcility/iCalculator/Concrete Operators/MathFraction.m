//
//  MathFraction.m
//  iCalculator
//
//  Created by curie on 13-10-25.
//  Copyright (c) 2013年 Fish Tribe. All rights reserved.
//

#import "MathFraction.h"
#import "MathNumber.h"
#import "MathConcreteOperators.h"


@implementation MathFraction

- (id)initWithNumerator:(MathExpression *)numerator denominator:(MathExpression *)denominator
{
    FTAssert(numerator && denominator);
    self = [super initWithLeftAffinity:MathNonAffinity rightAffinity:MathNonAffinity];
    if (self) {
        _subexpressions = @[numerator, denominator];
    }
    return self;
}

- (MathExpression *)numerator
{
    return _subexpressions[0];
}

- (MathExpression *)denominator
{
    return _subexpressions[1];
}

- (MathResult *)operate
{
    MathResult *numerator = [self.numerator evaluate];
    if (numerator == nil) return nil;
    decQuad numeratorValue = numerator.value;
    MathResult *denominator = [self.denominator evaluate];
    if (denominator == nil) return nil;
    decQuad denominatorValue = denominator.value;
    decQuad resultValue;
    decQuadDivide(&resultValue, &numeratorValue, &denominatorValue, &DQ_set);
    return [[MathResult alloc] initWithValue:resultValue unitSet:[numerator.unitSet unitSetByDividingBy:denominator.unitSet]];
}

#define LINE_WIDTH_RATIO    (1.0 / 20.0)
#define GAP_RATIO           (LINE_WIDTH_RATIO * 1.5)
#define OVERHANG_RATIO      (1.0 / 5.0)
#define MARGIN_RATIO        (1.0 / 10.0)

- (CGPoint)originOfSubexpressionAtIndex:(NSUInteger)subexpressionIndex whenDrawWithContext:(MathDrawingContext *)context
{
    FTAssert(subexpressionIndex < 2 && context);
    CGFloat numeratorFontSize = [self fontSizeOfSubexpressionAtIndex:0 whenDrawWithContext:context];
    CGFloat denominatorFontSize = [self fontSizeOfSubexpressionAtIndex:1 whenDrawWithContext:context];
    CGRect numeratorRect = [self.numerator rectWhenDrawAtPoint:CGPointZero withFontSize:numeratorFontSize];
    CGRect denominatorRect = [self.denominator rectWhenDrawAtPoint:CGPointZero withFontSize:denominatorFontSize];
    CGFloat halfWidthDelta = round((CGRectGetWidth(numeratorRect) - CGRectGetWidth(denominatorRect)) / 2.0);
    CGFloat lineWidth = context.fontSize * LINE_WIDTH_RATIO;
    CGFloat margin = context.fontSize * MARGIN_RATIO;
    CGFloat xOffsetForDot = 0.0;
    if ([context.previousElement isKindOfClass:[MathNumber class]] || [context.previousElement isKindOfClass:[MathPow class]]) {
        CGFloat dotDiameter = 2.0 * lineWidth;
        xOffsetForDot = margin + dotDiameter;
    }
    UIFont *symbolFont = [MathDrawingContext symbolFontWithSize:context.fontSize];
    CGFloat midline = context.origin.y - symbolFont.capHeight / 2.0;
    FTAssert_DEBUG(numeratorFontSize == denominatorFontSize);
    CGFloat gap = numeratorFontSize * GAP_RATIO;
    CGFloat overhang = numeratorFontSize * OVERHANG_RATIO;
    switch (subexpressionIndex) {
        case 0: {
            if (halfWidthDelta > 0.0) {
                return CGPointMake(context.origin.x + ceil(xOffsetForDot + margin + overhang), floor(midline - gap) - CGRectGetMaxY(numeratorRect));
            }
            else {
                return CGPointMake(context.origin.x + ceil(xOffsetForDot + margin + overhang) - halfWidthDelta, floor(midline - gap) - CGRectGetMaxY(numeratorRect));
            }
        }
        default: {
            FTAssert(subexpressionIndex == 1);
            if (halfWidthDelta > 0.0) {
                return CGPointMake(context.origin.x + ceil(xOffsetForDot + margin + overhang) + halfWidthDelta, ceil(midline + gap) - CGRectGetMinY(denominatorRect));
            }
            else {
                return CGPointMake(context.origin.x + ceil(xOffsetForDot + margin + overhang), ceil(midline + gap) - CGRectGetMinY(denominatorRect));
            }
        }
    }
}

- (CGRect)rectWhenDrawWithContext:(MathDrawingContext *)context
{
    FTAssert(context);
    CGPoint numeratorOrigin = [self originOfSubexpressionAtIndex:0 whenDrawWithContext:context];
    CGPoint denominatorOrigin = [self originOfSubexpressionAtIndex:1 whenDrawWithContext:context];
    CGFloat numeratorFontSize = [self fontSizeOfSubexpressionAtIndex:0 whenDrawWithContext:context];
    CGFloat denominatorFontSize = [self fontSizeOfSubexpressionAtIndex:1 whenDrawWithContext:context];
    CGRect numeratorRect = [self.numerator rectWhenDrawAtPoint:numeratorOrigin withFontSize:numeratorFontSize];
    CGRect denominatorRect = [self.denominator rectWhenDrawAtPoint:denominatorOrigin withFontSize:denominatorFontSize];
    CGRect rect = CGRectUnion(numeratorRect, denominatorRect);
    
    CGFloat margin = context.fontSize * MARGIN_RATIO;
    FTAssert_DEBUG(numeratorFontSize == denominatorFontSize);
    CGFloat overhang = numeratorFontSize * OVERHANG_RATIO;
    return CGRectInset(rect, -ceil(margin + overhang), 0.0);
}

- (CGRect)drawWithContext:(MathDrawingContext *)context
{
    FTAssert(context);
    CGPoint numeratorOrigin = [self originOfSubexpressionAtIndex:0 whenDrawWithContext:context];
    CGPoint denominatorOrigin = [self originOfSubexpressionAtIndex:1 whenDrawWithContext:context];
    CGFloat numeratorFontSize = [self fontSizeOfSubexpressionAtIndex:0 whenDrawWithContext:context];
    CGFloat denominatorFontSize = [self fontSizeOfSubexpressionAtIndex:1 whenDrawWithContext:context];
    CGRect numeratorRect = [self.numerator drawAtPoint:numeratorOrigin withFontSize:numeratorFontSize];
    CGRect denominatorRect = [self.denominator drawAtPoint:denominatorOrigin withFontSize:denominatorFontSize];
    CGRect rect = CGRectUnion(numeratorRect, denominatorRect);
    
    CGFloat lineWidth = context.fontSize * LINE_WIDTH_RATIO;
    CGFloat margin = context.fontSize * MARGIN_RATIO;
    UIFont *symbolFont = [MathDrawingContext symbolFontWithSize:context.fontSize];
    CGFloat midline = context.origin.y - symbolFont.capHeight / 2.0;
    FTAssert_DEBUG(numeratorFontSize == denominatorFontSize);
    CGFloat overhang = numeratorFontSize * OVERHANG_RATIO;
    
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    CGContextSaveGState(ctx);
    if ([context.previousElement isKindOfClass:[MathNumber class]] || [context.previousElement isKindOfClass:[MathPow class]]) {
        CGFloat dotDiameter = 2.0 * lineWidth;
        CGContextTranslateCTM(ctx, context.origin.x + margin + dotDiameter, midline);
        CGContextSaveGState(ctx);
        [[MathDrawingContext dullColor] set];
        CGContextFillEllipseInRect(ctx, CGRectMake(-dotDiameter, -(dotDiameter / 2.0), dotDiameter, dotDiameter));
        CGContextRestoreGState(ctx);
    }
    else {
        CGContextTranslateCTM(ctx, context.origin.x, midline);
    }
    CGContextBeginPath(ctx);
    CGContextMoveToPoint(ctx, margin, 0.0);
    CGContextAddLineToPoint(ctx, margin + overhang + CGRectGetWidth(rect) + overhang, 0.0);
    CGContextSetLineWidth(ctx, lineWidth);
    CGContextStrokePath(ctx);
    CGContextRestoreGState(ctx);
    
    return CGRectInset(rect, -ceil(margin + overhang), 0.0);
}

@end
