//
//  MathCos.m
//  iCalculator
//
//  Created by curie on 13-4-9.
//  Copyright (c) 2013年 Fish Tribe. All rights reserved.
//

#import "MathCos.h"


@interface MathCos ()

- (id)init;  //: Designated Initializer

@end


@implementation MathCos

+ (instancetype)cos
{
    static MathCos *__weak s_weakRef;
    MathCos *strongRef = s_weakRef;
    if (strongRef == nil) {
        s_weakRef = strongRef = [[MathCos alloc] init];
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
    self = [MathCos cos];
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
    decQuad tmpDec;
    decQuadSubtract(&tmpDec, &Dec_pi_2, &operandValue, &DQ_set);
    decQuad remainder;
    decQuad quotient = my_decQuadRemainderNear(&remainder, &tmpDec, &Dec_pi, &DQ_set);
    decQuad resultValue;
    if (decQuadIsZero(&remainder)) {
        decQuadZero(&resultValue);
    }
    else {
        double _remainder = IEEE754_dec2bin(&remainder);
        double _resultValue = sin(_remainder);
        if (decQuadIsInteger(&quotient)) {
            uint8_t quotientBCD[DECQUAD_Pmax];
            decQuadGetCoefficient(&quotient, quotientBCD);
            if (quotientBCD[DECQUAD_Pmax - 1] & 0x1) {
                _resultValue *= -1;
            }
        }
        IEEE754_bin2dec(_resultValue, &resultValue);
    }
    return [[MathResult alloc] initWithValue:resultValue unitSet:[MathUnitSet none]];;
}

- (CGRect)rectWhenDrawWithContext:(MathDrawingContext *)context
{
    FTAssert(context);
    UIFont *font = [MathDrawingContext functionFontWithSize:context.fontSize];
    NSDictionary *attr = @{NSFontAttributeName: font};
    CGSize size = [@"cos" sizeWithAttributes:attr];
    return CGRectMake(context.origin.x, context.origin.y - round(font.ascender), ceil(size.width), ceil(size.height));
}

- (CGRect)drawWithContext:(MathDrawingContext *)context
{
    FTAssert(context);
    UIFont *font = [MathDrawingContext functionFontWithSize:context.fontSize];
    NSDictionary *attr = @{NSFontAttributeName: font};
    CGSize size = [@"cos" sizeWithAttributes:attr];
    [@"cos" drawAtPoint:CGPointMake(context.origin.x, context.origin.y - font.ascender) withAttributes:attr];
    return CGRectMake(context.origin.x, context.origin.y - round(font.ascender), ceil(size.width), ceil(size.height));
}

@end
