//
//  MathTan.m
//  iCalculator
//
//  Created by curie on 13-4-9.
//  Copyright (c) 2013年 Fish Tribe. All rights reserved.
//

#import "MathTan.h"


@interface MathTan ()

- (id)init;  //: Designated Initializer

@end


@implementation MathTan

+ (instancetype)tan
{
    static MathTan *__weak s_weakRef;
    MathTan *strongRef = s_weakRef;
    if (strongRef == nil) {
        s_weakRef = strongRef = [[MathTan alloc] init];
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
    self = [MathTan tan];
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
    decQuad remainder;
    decQuad quotient;
    
    decQuad sinResultValue;
    quotient = my_decQuadRemainderNear(&remainder, &operandValue, &Dec_pi, &DQ_set);
    if (decQuadIsZero(&remainder)) {
        decQuadZero(&sinResultValue);
    }
    else {
        double _remainder = IEEE754_dec2bin(&remainder);
        double _sinResultValue = sin(_remainder);
        if (decQuadIsInteger(&quotient)) {
            uint8_t quotientBCD[DECQUAD_Pmax];
            decQuadGetCoefficient(&quotient, quotientBCD);
            if (quotientBCD[DECQUAD_Pmax - 1] & 0x1) {
                _sinResultValue *= -1;
            }
        }
        IEEE754_bin2dec(_sinResultValue, &sinResultValue);
    }
    
    decQuad cosResultValue;
    decQuad tmpDec;
    decQuadSubtract(&tmpDec, &Dec_pi_2, &operandValue, &DQ_set);
    quotient = my_decQuadRemainderNear(&remainder, &tmpDec, &Dec_pi, &DQ_set);
    if (decQuadIsZero(&remainder)) {
        decQuadZero(&cosResultValue);
    }
    else {
        double _remainder = IEEE754_dec2bin(&remainder);
        double _cosResultValue = sin(_remainder);
        if (decQuadIsInteger(&quotient)) {
            uint8_t quotientBCD[DECQUAD_Pmax];
            decQuadGetCoefficient(&quotient, quotientBCD);
            if (quotientBCD[DECQUAD_Pmax - 1] & 0x1) {
                _cosResultValue *= -1;
            }
        }
        IEEE754_bin2dec(_cosResultValue, &cosResultValue);
    }

    decQuad resultValue;
    decQuadDivide(&resultValue, &sinResultValue, &cosResultValue, &DQ_set);
    return [[MathResult alloc] initWithValue:resultValue unitSet:[MathUnitSet none]];;
}

- (CGRect)rectWhenDrawWithContext:(MathDrawingContext *)context
{
    FTAssert(context);
    UIFont *font = [MathDrawingContext functionFontWithSize:context.fontSize];
    NSDictionary *attr = @{NSFontAttributeName: font};
    CGSize size = [@"tan" sizeWithAttributes:attr];
    return CGRectMake(context.origin.x, context.origin.y - round(font.ascender), ceil(size.width), ceil(size.height));
}

- (CGRect)drawWithContext:(MathDrawingContext *)context
{
    FTAssert(context);
    UIFont *font = [MathDrawingContext functionFontWithSize:context.fontSize];
    NSDictionary *attr = @{NSFontAttributeName: font};
    CGSize size = [@"tan" sizeWithAttributes:attr];
    [@"tan" drawAtPoint:CGPointMake(context.origin.x, context.origin.y - font.ascender) withAttributes:attr];
    return CGRectMake(context.origin.x, context.origin.y - round(font.ascender), ceil(size.width), ceil(size.height));
}

@end
