//
//  MathPercent.m
//  iCalculator
//
//  Created by curie on 13-4-9.
//  Copyright (c) 2013年 Fish Tribe. All rights reserved.
//

#import "MathPercent.h"


@interface MathPercent ()

- (id)init;  //: Designated Initializer

@end


@implementation MathPercent

+ (instancetype)percent
{
    static MathPercent *__weak s_weakRef;
    MathPercent *strongRef = s_weakRef;
    if (strongRef == nil) {
        s_weakRef = strongRef = [[MathPercent alloc] init];
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
    self = [MathPercent percent];
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
    decQuadDivide(&resultValue, &operandValue, &Dec_100, &DQ_set);
    return [[MathResult alloc] initWithValue:resultValue unitSet:operand.unitSet];
}

- (CGRect)rectWhenDrawWithContext:(MathDrawingContext *)context
{
    FTAssert(context);
    UIFont *font = [MathDrawingContext symbolFontWithSize:context.fontSize];
    NSDictionary *attr = @{NSFontAttributeName: font};
    CGSize size = [@"%" sizeWithAttributes:attr];
    return CGRectMake(context.origin.x, context.origin.y - round(font.ascender), ceil(size.width), ceil(size.height));
}

- (CGRect)drawWithContext:(MathDrawingContext *)context
{
    FTAssert(context);
    UIFont *font = [MathDrawingContext symbolFontWithSize:context.fontSize];
    NSDictionary *attr = @{NSFontAttributeName: font};
    CGSize size = [@"%" sizeWithAttributes:attr];
    [@"%" drawAtPoint:CGPointMake(context.origin.x, context.origin.y - font.ascender) withAttributes:attr];
    return CGRectMake(context.origin.x, context.origin.y - round(font.ascender), ceil(size.width), ceil(size.height));
}

@end
