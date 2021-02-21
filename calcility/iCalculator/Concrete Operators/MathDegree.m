//
//  MathDegree.m
//  iCalculator
//
//  Created by curie on 13-4-9.
//  Copyright (c) 2013年 Fish Tribe. All rights reserved.
//

#import "MathDegree.h"
#import "MathConcreteOperators.h"


@interface MathDegree ()

- (id)init;  //: Designated Initializer

@end


@implementation MathDegree

+ (instancetype)degree
{
    static MathDegree *__weak s_weakRef;
    MathDegree *strongRef = s_weakRef;
    if (strongRef == nil) {
        s_weakRef = strongRef = [[MathDegree alloc] init];
    }
    return strongRef;
}

- (id)init
{
    self = [super initWithLeftAffinity:MathRightUnaryOperatorLeftAffinity rightAffinity:MathNonAffinity];
    return self;
}

- (id)initWithCoder:(NSCoder *)decoder
{
    self = [MathDegree degree];
    return self;
}

- (void)encodeWithCoder:(NSCoder *)encoder
{
    return;
}

- (MathResult *)operateOnOperand:(MathResult *)operand
{
    FTAssert(operand);
    decQuad operandValue = operand.value;
    decQuad resultValue;
    decQuadMultiply(&resultValue, &operandValue, &Dec_pi_180, &DQ_set);
    return [[MathResult alloc] initWithValue:resultValue unitSet:[[MathUnitSet alloc] initWithUnits:@[[MathAngleUnitDegree unit]]]];
}

- (MathDrawingTrait)drawingTrait
{
    return MathDrawingInheritedTrait;
}

#define LEFT_MARGIN_RATIO       (1.0 / 20.0)
#define EXTRA_LEFT_MARGIN_RATIO (1.0 / 10.0)
#define RIGHT_MARGIN_RATIO      (1.0 / 10.0)
#define STROKE_WIDTH_RATIO      (1.0 / 20.0)
#define DIAMETER_RATIO          (1.0 /  5.0)

- (CGRect)rectWhenDrawWithContext:(MathDrawingContext *)context
{
    FTAssert(context);
    CGFloat leftMargin;
    if ([context.previousElement isKindOfClass:[MathPow class]]) {
        leftMargin = context.fontSize * (LEFT_MARGIN_RATIO + EXTRA_LEFT_MARGIN_RATIO);
    }
    else {
        leftMargin = context.fontSize * LEFT_MARGIN_RATIO;
    }
    CGFloat rightMargin = context.fontSize * RIGHT_MARGIN_RATIO;
    CGFloat diameter = context.fontSize * DIAMETER_RATIO;
    return CGRectMake(context.origin.x, CGRectGetMinY(context.previousElementRect), ceil(leftMargin + diameter + rightMargin), CGRectGetHeight(context.previousElementRect));
}

- (CGRect)drawWithContext:(MathDrawingContext *)context
{
    FTAssert(context);
    CGFloat leftMargin;
    if ([context.previousElement isKindOfClass:[MathPow class]]) {
        leftMargin = context.fontSize * (LEFT_MARGIN_RATIO + EXTRA_LEFT_MARGIN_RATIO);
    }
    else {
        leftMargin = context.fontSize * LEFT_MARGIN_RATIO;
    }
    CGFloat rightMargin = context.fontSize * RIGHT_MARGIN_RATIO;
    CGFloat strokeWidth = context.fontSize * STROKE_WIDTH_RATIO;
    CGFloat diameter = context.fontSize * DIAMETER_RATIO;
    
    CGPoint ringOrigin;
    ringOrigin.x = context.origin.x + leftMargin;
    if (context.previousElementIsGraphical) {
        ringOrigin.y = CGRectGetMinY(context.previousElementRect) + 2.0 * strokeWidth;
    }
    else {
        UIFont *virtualBaseFont = [MathDrawingContext primaryFontWithSize:context.fontSize];
        ringOrigin.y = context.origin.y - virtualBaseFont.capHeight - 2.0 * strokeWidth;
    }
    CGRect ringRect = CGRectMake(ringOrigin.x, ringOrigin.y, diameter, diameter);

    CGContextRef ctx = UIGraphicsGetCurrentContext();
    CGContextSaveGState(ctx);
    CGContextSetLineWidth(ctx, strokeWidth);
    CGContextStrokeEllipseInRect(ctx, ringRect);
    CGContextRestoreGState(ctx);
    
    return CGRectMake(context.origin.x, CGRectGetMinY(context.previousElementRect), ceil(leftMargin + diameter + rightMargin), CGRectGetHeight(context.previousElementRect));
}

@end
