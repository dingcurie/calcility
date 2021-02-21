//
//  MathParentheses.m
//  iCalculator
//
//  Created by curie on 12-9-8.
//  Copyright (c) 2012年 Fish Tribe. All rights reserved.
//

#import "MathParentheses.h"


@implementation MathParentheses

- (id)initWithContent:(MathExpression *)content
{
    FTAssert(content);
    self = [super initWithLeftAffinity:MathNonAffinity rightAffinity:MathNonAffinity];
    if (self) {
        _subexpressions = @[content];
    }
    return self;
}

- (MathExpression *)content
{
    return _subexpressions[0];
}

- (MathResult *)operate
{
    return [self.content evaluate];
}

#define HEMI_GLYPH_WIDTH_RATIO      0.35
#define HEIGHT_INCREMENT_RATIO      (1.0 / 10.0)

- (CGPoint)originOfSubexpressionAtIndex:(NSUInteger)subexpressionIndex whenDrawWithContext:(MathDrawingContext *)context
{
    FTAssert(subexpressionIndex == 0 && context);
    CGFloat hemiGlyphWidth = context.fontSize * HEMI_GLYPH_WIDTH_RATIO;
    return CGPointMake(context.origin.x + ceil(hemiGlyphWidth), context.origin.y);
}

- (CGRect)rectWhenDrawWithContext:(MathDrawingContext *)context
{
    FTAssert(context);
    CGPoint contentOrigin = [self originOfSubexpressionAtIndex:0 whenDrawWithContext:context];
    CGFloat contentFontSize = [self fontSizeOfSubexpressionAtIndex:0 whenDrawWithContext:context];
    CGRect contentRect = [self.content rectWhenDrawAtPoint:contentOrigin withFontSize:contentFontSize];
    
    CGFloat hemiGlyphWidth = context.fontSize * HEMI_GLYPH_WIDTH_RATIO;
    UIFont *symbolFont = [MathDrawingContext symbolFontWithSize:context.fontSize];
    CGFloat midline = context.origin.y - round(symbolFont.capHeight / 2.0);
    CGFloat contentHeightAboveMidline = midline - CGRectGetMinY(contentRect);
    CGFloat contentHeightBelowMidline = CGRectGetMaxY(contentRect) - midline;
    UIEdgeInsets outsets = UIEdgeInsetsMake(0.0, ceil(hemiGlyphWidth), 0.0, ceil(hemiGlyphWidth));
    if (contentHeightAboveMidline > contentHeightBelowMidline) {
        outsets.bottom = contentHeightAboveMidline - contentHeightBelowMidline;
    }
    else {
        outsets.top = contentHeightBelowMidline - contentHeightAboveMidline;
    }
    if ([self.content isGraphical]) {
        CGFloat heightIncrement = round(context.fontSize * HEIGHT_INCREMENT_RATIO);
        outsets.top += heightIncrement;
        outsets.bottom += heightIncrement;
    }
    return my_UIEdgeInsetsOutsetRect(contentRect, outsets);
}

- (CGRect)drawWithContext:(MathDrawingContext *)context
{
    static CGMutablePathRef hemiGlyphPath;
    if (hemiGlyphPath == NULL) {
        hemiGlyphPath = CGPathCreateMutable();
        CGPathMoveToPoint(hemiGlyphPath, NULL, 0.11, 0.00);
        CGPathAddCurveToPoint(hemiGlyphPath, NULL, 0.11,  0.45, 0.44,  0.91, 0.93,  1.00);
        CGPathAddCurveToPoint(hemiGlyphPath, NULL, 0.80,  0.95, 0.59,  0.81, 0.49,  0.60);
        CGPathAddCurveToPoint(hemiGlyphPath, NULL, 0.34,  0.28, 0.34, -0.28, 0.49, -0.60);
        CGPathAddCurveToPoint(hemiGlyphPath, NULL, 0.59, -0.81, 0.80, -0.95, 0.93, -1.00);
        CGPathAddCurveToPoint(hemiGlyphPath, NULL, 0.44, -0.91, 0.11, -0.45, 0.11,  0.00);
        CGPathCloseSubpath(hemiGlyphPath);
    }
    
    FTAssert(context);
    CGPoint contentOrigin = [self originOfSubexpressionAtIndex:0 whenDrawWithContext:context];
    CGFloat contentFontSize = [self fontSizeOfSubexpressionAtIndex:0 whenDrawWithContext:context];
    CGRect contentRect = [self.content drawAtPoint:contentOrigin withFontSize:contentFontSize];
    
    CGFloat hemiGlyphWidth = context.fontSize * HEMI_GLYPH_WIDTH_RATIO;
    UIFont *symbolFont = [MathDrawingContext symbolFontWithSize:context.fontSize];
    CGFloat midline = context.origin.y - round(symbolFont.capHeight / 2.0);
    CGFloat contentHeightAboveMidline = midline - CGRectGetMinY(contentRect);
    CGFloat contentHeightBelowMidline = CGRectGetMaxY(contentRect) - midline;
    CGFloat halfHeight;
    UIEdgeInsets outsets = UIEdgeInsetsMake(0.0, ceil(hemiGlyphWidth), 0.0, ceil(hemiGlyphWidth));
    if (contentHeightAboveMidline > contentHeightBelowMidline) {
        halfHeight = contentHeightAboveMidline;
        outsets.bottom = contentHeightAboveMidline - contentHeightBelowMidline;
    }
    else {
        halfHeight = contentHeightBelowMidline;
        outsets.top = contentHeightBelowMidline - contentHeightAboveMidline;
    }
    if ([self.content isGraphical]) {
        CGFloat heightIncrement = round(context.fontSize * HEIGHT_INCREMENT_RATIO);
        halfHeight += heightIncrement;
        outsets.top += heightIncrement;
        outsets.bottom += heightIncrement;
    }
    
    CGContextRef ctx = UIGraphicsGetCurrentContext();

    CGContextSaveGState(ctx);
    CGContextTranslateCTM(ctx, context.origin.x, midline);
    CGContextScaleCTM(ctx, hemiGlyphWidth, halfHeight);
    CGContextAddPath(ctx, hemiGlyphPath);
    CGContextRestoreGState(ctx);
    
    CGContextSaveGState(ctx);
    CGContextTranslateCTM(ctx, context.origin.x + ceil(hemiGlyphWidth) + CGRectGetWidth(contentRect) + ceil(hemiGlyphWidth), midline);
    CGContextScaleCTM(ctx, -hemiGlyphWidth, halfHeight);
    CGContextAddPath(ctx, hemiGlyphPath);
    CGContextRestoreGState(ctx);
    
    CGContextFillPath(ctx);
    
    return my_UIEdgeInsetsOutsetRect(contentRect, outsets);
}

@end
