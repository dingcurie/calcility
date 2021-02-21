//
//  MathLog10.m
//  iCalculator
//
//  Created by curie on 13-4-9.
//  Copyright (c) 2013年 Fish Tribe. All rights reserved.
//

#import "MathLog10.h"


@interface MathLog10 ()

- (id)init;  //: Designated Initializer

@end


@implementation MathLog10

+ (instancetype)log10
{
    static MathLog10 *__weak s_weakRef;
    MathLog10 *strongRef = s_weakRef;
    if (strongRef == nil) {
        s_weakRef = strongRef = [[MathLog10 alloc] init];
    }
    return strongRef;
}

- (id)init
{
    self = [super initWithLeftAffinity:MathNonAffinity rightAffinity:MathLeftUnaryOperatorRightAffinity];
    return self;
}

- (id)initWithCoder:(NSCoder *)decoder
{
    self = [MathLog10 log10];
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
    decQuad operandm1;
    decQuadSubtract(&operandm1, &operandValue, &Dec_1, &DQ_set);
    decQuad tmpDec;
    decQuadAbs(&tmpDec, &operandm1, &DQ_set);
    decQuadCompare(&tmpDec, &tmpDec, &Dec_0p1, &DQ_set);
    double _resultValue;
    if (decQuadIsNegative(&tmpDec)) {
        double _operandm1 = IEEE754_dec2bin(&operandm1);
        _resultValue = log1p(_operandm1) / M_LN10;
    }
    else {
        double _operandValue = IEEE754_dec2bin(&operandValue);
        _resultValue = log10(_operandValue);
    }
    decQuad resultValue;
    IEEE754_bin2dec(_resultValue, &resultValue);
    return [[MathResult alloc] initWithValue:resultValue unitSet:[operand.unitSet unitSetByReconcilingWith:[MathUnitSet none]]];
}

- (CGRect)rectWhenDrawWithContext:(MathDrawingContext *)context
{
    FTAssert(context);
    UIFont *font = [MathDrawingContext functionFontWithSize:context.fontSize];
    NSDictionary *attr = @{NSFontAttributeName: font};
    CGSize size = [@"log" sizeWithAttributes:attr];
    return CGRectMake(context.origin.x, context.origin.y - round(font.ascender), ceil(size.width), ceil(size.height));
}

- (CGRect)drawWithContext:(MathDrawingContext *)context
{
    FTAssert(context);
    UIFont *font = [MathDrawingContext functionFontWithSize:context.fontSize];
    NSDictionary *attr = @{NSFontAttributeName: font};
    CGSize size = [@"log" sizeWithAttributes:attr];
    [@"log" drawAtPoint:CGPointMake(context.origin.x, context.origin.y - font.ascender) withAttributes:attr];
    return CGRectMake(context.origin.x, context.origin.y - round(font.ascender), ceil(size.width), ceil(size.height));
}

@end
