//
//  MathFactorial.m
//  iCalculator
//
//  Created by curie on 13-4-9.
//  Copyright (c) 2013年 Fish Tribe. All rights reserved.
//

#import "MathFactorial.h"


@interface MathFactorial ()

- (id)init;  //: Designated Initializer

@end


@implementation MathFactorial

+ (instancetype)factorial
{
    static MathFactorial *__weak s_weakRef;
    MathFactorial *strongRef = s_weakRef;
    if (strongRef == nil) {
        s_weakRef = strongRef = [[MathFactorial alloc] init];
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
    self = [MathFactorial factorial];
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
    double _operandValue = IEEE754_dec2bin(&operandValue);
    decQuad resultValue;
    if (_operandValue >= 0 && trunc(_operandValue) == _operandValue) {
        double _resultValue = round(tgamma(1 + _operandValue));
        IEEE754_bin2dec(_resultValue, &resultValue);
    }
    else {
        resultValue = DQ_NaN;
    }
    return [[MathResult alloc] initWithValue:resultValue unitSet:[MathUnitSet none]];
}

- (CGRect)rectWhenDrawWithContext:(MathDrawingContext *)context
{
    FTAssert(context);
    UIFont *font = [MathDrawingContext symbolFontWithSize:context.fontSize];
    NSDictionary *attr = @{NSFontAttributeName: font};
    CGSize size = [@"!" sizeWithAttributes:attr];
    return CGRectMake(context.origin.x, context.origin.y - round(font.ascender), ceil(size.width), ceil(size.height));
}

- (CGRect)drawWithContext:(MathDrawingContext *)context
{
    FTAssert(context);
    UIFont *font = [MathDrawingContext symbolFontWithSize:context.fontSize];
    NSDictionary *attr = @{NSFontAttributeName: font};
    CGSize size = [@"!" sizeWithAttributes:attr];
    [@"!" drawAtPoint:CGPointMake(context.origin.x, context.origin.y - font.ascender) withAttributes:attr];
    return CGRectMake(context.origin.x, context.origin.y - round(font.ascender), ceil(size.width), ceil(size.height));
}

@end
