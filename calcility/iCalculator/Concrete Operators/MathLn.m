//
//  MathLn.m
//  iCalculator
//
//  Created by curie on 13-4-9.
//  Copyright (c) 2013年 Fish Tribe. All rights reserved.
//

#import "MathLn.h"


@interface MathLn ()

- (id)init;  //: Designated Initializer

@end


@implementation MathLn

+ (instancetype)ln
{
    static MathLn *__weak s_weakRef;
    MathLn *strongRef = s_weakRef;
    if (strongRef == nil) {
        s_weakRef = strongRef = [[MathLn alloc] init];
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
    self = [MathLn ln];
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
        _resultValue = log1p(_operandm1);
    }
    else {
        double _operandValue = IEEE754_dec2bin(&operandValue);
        _resultValue = log(_operandValue);
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
    CGSize size = [@"ln" sizeWithAttributes:attr];
    return CGRectMake(context.origin.x, context.origin.y - round(font.ascender), ceil(size.width), ceil(size.height));
}

- (CGRect)drawWithContext:(MathDrawingContext *)context
{
    FTAssert(context);
    UIFont *font = [MathDrawingContext functionFontWithSize:context.fontSize];
    NSDictionary *attr = @{NSFontAttributeName: font};
    CGSize size = [@"ln" sizeWithAttributes:attr];
    [@"ln" drawAtPoint:CGPointMake(context.origin.x, context.origin.y - font.ascender) withAttributes:attr];
    return CGRectMake(context.origin.x, context.origin.y - round(font.ascender), ceil(size.width), ceil(size.height));
}

@end
