//
//  MathMul.m
//  iCalculator
//
//  Created by  on 12-6-17.
//  Copyright (c) 2012年 Fish Tribe. All rights reserved.
//

#import "MathMul.h"


@interface MathMul ()

- (id)init;  //: Designated Initializer

@end


@implementation MathMul

+ (instancetype)mul
{
    static MathMul *__weak s_weakRef;
    MathMul *strongRef = s_weakRef;
    if (strongRef == nil) {
        s_weakRef = strongRef = [[MathMul alloc] init];
    }
    return strongRef;
}

- (id)init
{
    self = [super initWithLeftAffinity:MathMultiplicativeOperatorLeftAffinity rightAffinity:MathMultiplicativeOperatorRightAffinity];
    return self;
}

- (id)initWithCoder:(NSCoder *)decoder
{
    self = [MathMul mul];
    return self;
}

- (void)encodeWithCoder:(NSCoder *)encoder
{
    return;
}

- (MathResult *)operateOnLeftOperand:(MathResult *)leftOperand rightOperand:(MathResult *)rightOperand
{
    FTAssert(leftOperand && rightOperand);
    decQuad leftOperandValue = leftOperand.value;
    decQuad rightOperandValue = rightOperand.value;
    decQuad resultValue;
    decQuadMultiply(&resultValue, &leftOperandValue, &rightOperandValue, &DQ_set);
    return [[MathResult alloc] initWithValue:resultValue unitSet:[leftOperand.unitSet unitSetByMultiplyingBy:rightOperand.unitSet]];
}

- (CGRect)rectWhenDrawWithContext:(MathDrawingContext *)context
{
    FTAssert(context);
    UIFont *font = [MathDrawingContext symbolFontWithSize:context.fontSize];
    NSDictionary *attr = @{NSFontAttributeName: font};
    CGSize size = [@"×" sizeWithAttributes:attr];
    return CGRectMake(context.origin.x, context.origin.y - round(font.ascender), round(size.width), ceil(size.height));
}

- (CGRect)drawWithContext:(MathDrawingContext *)context
{
    FTAssert(context);
    UIFont *font = [MathDrawingContext symbolFontWithSize:context.fontSize];
    NSDictionary *attr = @{NSFontAttributeName: font};
    CGSize size = [@"×" sizeWithAttributes:attr];
    [@"×" drawAtPoint:CGPointMake(context.origin.x, context.origin.y - font.ascender) withAttributes:attr];
    return CGRectMake(context.origin.x, context.origin.y - round(font.ascender), round(size.width), ceil(size.height));
}

@end
