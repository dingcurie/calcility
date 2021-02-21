//
//  MathSqrt.m
//  iCalculator
//
//  Created by curie on 12-12-19.
//  Copyright (c) 2012年 Fish Tribe. All rights reserved.
//

#import "MathSqrt.h"


@implementation MathSqrt

- (id)initWithRadicand:(MathExpression *)radicand
{
    FTAssert(radicand);
    self = [super initWithLeftAffinity:MathNonAffinity rightAffinity:MathNonAffinity];
    if (self) {
        _subexpressions = @[radicand];
    }
    return self;
}

- (MathExpression *)radicand
{
    return _subexpressions[0];
}

- (MathResult *)operate
{
    MathResult *radicand = [self.radicand evaluate];
    if (radicand == nil) return nil;
    decQuad radicandValue = radicand.value;
    double _radicandValue = IEEE754_dec2bin(&radicandValue);
    double _resultValue = sqrt(_radicandValue);
    decQuad resultValue;
    IEEE754_bin2dec(_resultValue, &resultValue);
    return [[MathResult alloc] initWithValue:resultValue unitSet:[radicand.unitSet unitSetByRaisingToPowerReciprocal:Dec_2]];
}

#define STANDARD_HOOK_ANGLE         (65.0 * M_PI / 180.0)
#define STANDARD_RAMP_ANGLE         (75.0 * M_PI / 180.0)
#define LINE_WIDTH_RATIO            (1.0 / 20.0)
#define RADICAND_TOP_MARGIN_RATIO   (LINE_WIDTH_RATIO * 1.5)
#define RADICAND_LEFT_MARGIN_RATIO  (1.0 / 6.0)
#define RADICAND_RIGHT_MARGIN_RATIO (1.0 / 5.0)
#define HEIGHT_WEIGHTING_RATIO      (1.0 / 2.0)
#define HOOK_BAR_LENGTH_RATIO       (5.0 / 10.0)
#define HOOK_SERIF_WIDTH_RATIO      (3.0 / 4.0)
#define HOOK_SERIF_LENGTH_RATIO     (1.0 / 4.0)

- (CGPoint)originOfSubexpressionAtIndex:(NSUInteger)subexpressionIndex whenDrawWithContext:(MathDrawingContext *)context
{
    FTAssert(subexpressionIndex == 0 && context);
    CGFloat radicandFontSize = [self fontSizeOfSubexpressionAtIndex:0 whenDrawWithContext:context];
    CGRect radicandRect = [self.radicand rectWhenDrawAtPoint:CGPointZero withFontSize:radicandFontSize];
    CGFloat radicandTopMargin = radicandFontSize * RADICAND_TOP_MARGIN_RATIO;
    CGFloat radicandLeftMargin = radicandFontSize * RADICAND_LEFT_MARGIN_RATIO;
    UIFont *radicandFont = [MathDrawingContext primaryFontWithSize:radicandFontSize];
    CGFloat radicandFontHeight = radicandFont.ascender - radicandFont.descender;
    CGFloat radicandHeight = CGRectGetHeight(radicandRect);
    CGFloat weightedRadicandFontHeight = radicandFontHeight + (radicandHeight - radicandFontHeight) * HEIGHT_WEIGHTING_RATIO;
    CGFloat hookBarLength = weightedRadicandFontHeight * HOOK_BAR_LENGTH_RATIO;
    CGFloat lineWidth = context.fontSize * LINE_WIDTH_RATIO;
    CGFloat hookSerifWidth = lineWidth * HOOK_SERIF_WIDTH_RATIO;
    CGFloat hookSerifLength = hookBarLength * HOOK_SERIF_LENGTH_RATIO;
    CGFloat hookSpan = (hookBarLength + hookSerifWidth / 2.0) * cos(STANDARD_HOOK_ANGLE) + hookSerifLength * sin(STANDARD_HOOK_ANGLE);
    CGFloat rampSpan = (weightedRadicandFontHeight + radicandTopMargin) / tan(STANDARD_RAMP_ANGLE);
    return CGPointMake(context.origin.x + ceil(hookSpan + rampSpan + radicandLeftMargin), context.origin.y);
}

- (CGRect)rectWhenDrawWithContext:(MathDrawingContext *)context
{
    FTAssert(context);
    CGPoint radicandOrigin = [self originOfSubexpressionAtIndex:0 whenDrawWithContext:context];
    CGFloat radicandFontSize = [self fontSizeOfSubexpressionAtIndex:0 whenDrawWithContext:context];
    CGRect radicandRect = [self.radicand rectWhenDrawAtPoint:radicandOrigin withFontSize:radicandFontSize];
    
    CGFloat radicandTopMargin = radicandFontSize * RADICAND_TOP_MARGIN_RATIO;
    CGFloat radicandLeftMargin = radicandFontSize * RADICAND_LEFT_MARGIN_RATIO;
    CGFloat radicandRightMargin = radicandFontSize * RADICAND_RIGHT_MARGIN_RATIO;
    UIFont *radicandFont = [MathDrawingContext primaryFontWithSize:radicandFontSize];
    CGFloat radicandFontHeight = radicandFont.ascender - radicandFont.descender;
    CGFloat radicandHeight = CGRectGetHeight(radicandRect);
    CGFloat weightedRadicandFontHeight = radicandFontHeight + (radicandHeight - radicandFontHeight) * HEIGHT_WEIGHTING_RATIO;
    CGFloat hookBarLength = weightedRadicandFontHeight * HOOK_BAR_LENGTH_RATIO;
    CGFloat lineWidth = context.fontSize * LINE_WIDTH_RATIO;
    CGFloat hookSerifWidth = lineWidth * HOOK_SERIF_WIDTH_RATIO;
    CGFloat hookSerifLength = hookBarLength * HOOK_SERIF_LENGTH_RATIO;
    CGFloat hookSpan = (hookBarLength + hookSerifWidth / 2.0) * cos(STANDARD_HOOK_ANGLE) + hookSerifLength * sin(STANDARD_HOOK_ANGLE);
    CGFloat rampSpan = (weightedRadicandFontHeight + radicandTopMargin) / tan(STANDARD_RAMP_ANGLE);
    return my_UIEdgeInsetsOutsetRect(radicandRect, UIEdgeInsetsMake(ceil(lineWidth + radicandTopMargin), ceil(hookSpan + rampSpan + radicandLeftMargin), ceil(lineWidth), ceil(radicandRightMargin + lineWidth)));
}

- (CGRect)drawWithContext:(MathDrawingContext *)context
{
    FTAssert(context);
    CGPoint radicandOrigin = [self originOfSubexpressionAtIndex:0 whenDrawWithContext:context];
    CGFloat radicandFontSize = [self fontSizeOfSubexpressionAtIndex:0 whenDrawWithContext:context];
    CGRect radicandRect = [self.radicand drawAtPoint:radicandOrigin withFontSize:radicandFontSize];
    
    CGFloat radicandTopMargin = radicandFontSize * RADICAND_TOP_MARGIN_RATIO;
    CGFloat radicandLeftMargin = radicandFontSize * RADICAND_LEFT_MARGIN_RATIO;
    CGFloat radicandRightMargin = radicandFontSize * RADICAND_RIGHT_MARGIN_RATIO;
    UIFont *radicandFont = [MathDrawingContext primaryFontWithSize:radicandFontSize];
    CGFloat radicandFontHeight = radicandFont.ascender - radicandFont.descender;
    CGFloat radicandHeight = CGRectGetHeight(radicandRect);
    CGFloat weightedRadicandFontHeight = radicandFontHeight + (radicandHeight - radicandFontHeight) * HEIGHT_WEIGHTING_RATIO;
    CGFloat hookBarLength = weightedRadicandFontHeight * HOOK_BAR_LENGTH_RATIO;
    CGFloat lineWidth = context.fontSize * LINE_WIDTH_RATIO;
    CGFloat hookSerifWidth = lineWidth * HOOK_SERIF_WIDTH_RATIO;
    CGFloat hookSerifLength = hookBarLength * HOOK_SERIF_LENGTH_RATIO;
    CGFloat hookSpan = (hookBarLength + hookSerifWidth / 2.0) * cos(STANDARD_HOOK_ANGLE) + hookSerifLength * sin(STANDARD_HOOK_ANGLE);
    CGFloat rampSpan = (weightedRadicandFontHeight + radicandTopMargin) / tan(STANDARD_RAMP_ANGLE);
    CGFloat rampHeight = radicandHeight + radicandTopMargin;
    CGFloat realRampAngle;
    CGFloat hookSideBarIndent;
    if (radicandHeight != weightedRadicandFontHeight) {
        realRampAngle = atan(rampHeight / rampSpan);
        hookSideBarIndent = hookSerifWidth * tan(M_PI_2 - M_PI + STANDARD_HOOK_ANGLE + realRampAngle);
    }
    else {
        //$ realRampAngle = STANDARD_RAMP_ANGLE;
        hookSideBarIndent = hookSerifWidth / tan(M_PI - STANDARD_HOOK_ANGLE - STANDARD_RAMP_ANGLE);
    }
    
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    CGContextSaveGState(ctx);
    CGContextTranslateCTM(ctx, CGRectGetMinX(radicandRect) - radicandLeftMargin - rampSpan, CGRectGetMaxY(radicandRect));
    CGContextRotateCTM(ctx, -(M_PI_2 - STANDARD_HOOK_ANGLE));
    CGContextBeginPath(ctx);
    CGContextMoveToPoint(ctx, hookSerifWidth, -hookSideBarIndent);
    CGContextAddLineToPoint(ctx, hookSerifWidth, -hookBarLength);
    CGContextAddLineToPoint(ctx, -hookSerifLength, -hookBarLength);
    CGContextSetLineWidth(ctx, hookSerifWidth);
    CGContextStrokePath(ctx);
    CGContextBeginPath(ctx);
    CGContextMoveToPoint(ctx, 0.0, -hookBarLength);
    CGContextAddLineToPoint(ctx, 0.0, 0.0);
    CGContextRotateCTM(ctx, M_PI_2 - STANDARD_HOOK_ANGLE);
    CGContextAddLineToPoint(ctx, rampSpan, -rampHeight);
    CGContextAddLineToPoint(ctx, rampSpan + radicandLeftMargin + CGRectGetWidth(radicandRect) + radicandRightMargin, -rampHeight);
    CGContextSetLineWidth(ctx, lineWidth);
    CGContextSetLineJoin(ctx, kCGLineJoinBevel);
    CGContextStrokePath(ctx);
    CGContextRestoreGState(ctx);
    return my_UIEdgeInsetsOutsetRect(radicandRect, UIEdgeInsetsMake(ceil(lineWidth + radicandTopMargin), ceil(hookSpan + rampSpan + radicandLeftMargin), ceil(lineWidth), ceil(radicandRightMargin + lineWidth)));
}

@end
