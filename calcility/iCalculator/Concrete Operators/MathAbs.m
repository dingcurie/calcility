//
//  MathAbs.m
//  iCalculator
//
//  Created by curie on 13-11-18.
//  Copyright (c) 2013年 Fish Tribe. All rights reserved.
//

#import "MathAbs.h"


@implementation MathAbs

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
    MathResult *content = [self.content evaluate];
    if (content == nil) return nil;
    decQuad contentValue = content.value;
    decQuad resultValue;
    decQuadAbs(&resultValue, &contentValue, &DQ_set);
    return [[MathResult alloc] initWithValue:resultValue unitSet:content.unitSet];
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

#define LINE_WIDTH_RATIO    (1.0 / 20.0)

- (CGRect)drawWithContext:(MathDrawingContext *)context
{
    static CGMutablePathRef hemiGlyphPath;
    if (hemiGlyphPath == NULL) {
        hemiGlyphPath = CGPathCreateMutable();
        CGPathMoveToPoint(hemiGlyphPath, NULL, 0.6, -1.0);
        CGPathAddLineToPoint(hemiGlyphPath, NULL, 0.6, 1.0);
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
    CGFloat lineWidth = context.fontSize * LINE_WIDTH_RATIO;
    
    CGContextSaveGState(ctx);
    CGContextTranslateCTM(ctx, context.origin.x, midline);
    CGContextScaleCTM(ctx, hemiGlyphWidth, halfHeight - lineWidth);
    CGContextAddPath(ctx, hemiGlyphPath);
    CGContextRestoreGState(ctx);
    
    CGContextSaveGState(ctx);
    CGContextTranslateCTM(ctx, context.origin.x + ceil(hemiGlyphWidth) + CGRectGetWidth(contentRect) + ceil(hemiGlyphWidth), midline);
    CGContextScaleCTM(ctx, -hemiGlyphWidth, halfHeight - lineWidth);
    CGContextAddPath(ctx, hemiGlyphPath);
    CGContextRestoreGState(ctx);
    
    CGContextSaveGState(ctx);
    CGContextSetLineWidth(ctx, lineWidth);
    CGContextSetLineCap(ctx, kCGLineCapSquare);
    CGContextStrokePath(ctx);
    CGContextRestoreGState(ctx);
    
    return my_UIEdgeInsetsOutsetRect(contentRect, outsets);
}

@end
