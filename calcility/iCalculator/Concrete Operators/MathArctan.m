//
//  MathArctan.m
//  iCalculator
//
//  Created by curie on 13-4-9.
//  Copyright (c) 2013年 Fish Tribe. All rights reserved.
//

#import "MathArctan.h"


@interface MathArctan ()

- (id)init;  //: Designated Initializer

@end


@implementation MathArctan

+ (instancetype)arctan
{
    static MathArctan *__weak s_weakRef;
    MathArctan *strongRef = s_weakRef;
    if (strongRef == nil) {
        s_weakRef = strongRef = [[MathArctan alloc] init];
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
    self = [MathArctan arctan];
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
    double _resultValue = atan(_operandValue);
    IEEE754_bin2dec(_resultValue, &resultValue);
    return [[MathResult alloc] initWithValue:resultValue unitSet:[[MathUnitSet alloc] initWithUnits:@[[MathAngleUnitUserDefault unit]]]];
}

- (CGRect)rectWhenDrawWithContext:(MathDrawingContext *)context
{
    FTAssert(context);
    UIFont *font = [MathDrawingContext functionFontWithSize:context.fontSize];
    NSDictionary *attr = @{NSFontAttributeName: font};
    CGSize size = [@"arctan" sizeWithAttributes:attr];
    return CGRectMake(context.origin.x, context.origin.y - round(font.ascender), ceil(size.width), ceil(size.height));
}

- (CGRect)drawWithContext:(MathDrawingContext *)context
{
    FTAssert(context);
    UIFont *font = [MathDrawingContext functionFontWithSize:context.fontSize];
    NSDictionary *attr = @{NSFontAttributeName: font};
    CGSize size = [@"arctan" sizeWithAttributes:attr];
    [@"arctan" drawAtPoint:CGPointMake(context.origin.x, context.origin.y - font.ascender) withAttributes:attr];
    return CGRectMake(context.origin.x, context.origin.y - round(font.ascender), ceil(size.width), ceil(size.height));
}

@end
