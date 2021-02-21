//
//  MathArcsin.m
//  iCalculator
//
//  Created by curie on 13-4-9.
//  Copyright (c) 2013年 Fish Tribe. All rights reserved.
//

#import "MathArcsin.h"


@interface MathArcsin ()

- (id)init;  //: Designated Initializer

@end


@implementation MathArcsin

+ (instancetype)arcsin
{
    static MathArcsin *__weak s_weakRef;
    MathArcsin *strongRef = s_weakRef;
    if (strongRef == nil) {
        s_weakRef = strongRef = [[MathArcsin alloc] init];
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
    self = [MathArcsin arcsin];
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
    double _resultValue = asin(_operandValue);
    IEEE754_bin2dec(_resultValue, &resultValue);
    return [[MathResult alloc] initWithValue:resultValue unitSet:[[MathUnitSet alloc] initWithUnits:@[[MathAngleUnitUserDefault unit]]]];
}

- (CGRect)rectWhenDrawWithContext:(MathDrawingContext *)context
{
    FTAssert(context);
    UIFont *font = [MathDrawingContext functionFontWithSize:context.fontSize];
    NSDictionary *attr = @{NSFontAttributeName: font};
    CGSize size = [@"arcsin" sizeWithAttributes:attr];
    return CGRectMake(context.origin.x, context.origin.y - round(font.ascender), ceil(size.width), ceil(size.height));
}

- (CGRect)drawWithContext:(MathDrawingContext *)context
{
    FTAssert(context);
    UIFont *font = [MathDrawingContext functionFontWithSize:context.fontSize];
    NSDictionary *attr = @{NSFontAttributeName: font};
    CGSize size = [@"arcsin" sizeWithAttributes:attr];
    [@"arcsin" drawAtPoint:CGPointMake(context.origin.x, context.origin.y - font.ascender) withAttributes:attr];
    return CGRectMake(context.origin.x, context.origin.y - round(font.ascender), ceil(size.width), ceil(size.height));
}

@end
