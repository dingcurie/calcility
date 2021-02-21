//
//  MathTanh.m
//  iCalculator
//
//  Created by curie on 13-11-19.
//  Copyright (c) 2013年 Fish Tribe. All rights reserved.
//

#import "MathTanh.h"


@interface MathTanh ()

- (id)init;  //: Designated Initializer

@end


@implementation MathTanh

+ (instancetype)tanh
{
    static MathTanh *__weak s_weakRef;
    MathTanh *strongRef = s_weakRef;
    if (strongRef == nil) {
        s_weakRef = strongRef = [[MathTanh alloc] init];
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
    self = [MathTanh tanh];
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
    double _resultValue = tanh(_operandValue);
    IEEE754_bin2dec(_resultValue, &resultValue);
    return [[MathResult alloc] initWithValue:resultValue unitSet:[MathUnitSet none]];
}

- (CGRect)rectWhenDrawWithContext:(MathDrawingContext *)context
{
    FTAssert(context);
    UIFont *font = [MathDrawingContext functionFontWithSize:context.fontSize];
    NSDictionary *attr = @{NSFontAttributeName: font};
    CGSize size = [@"tanh" sizeWithAttributes:attr];
    return CGRectMake(context.origin.x, context.origin.y - round(font.ascender), ceil(size.width), ceil(size.height));
}

- (CGRect)drawWithContext:(MathDrawingContext *)context
{
    FTAssert(context);
    UIFont *font = [MathDrawingContext functionFontWithSize:context.fontSize];
    NSDictionary *attr = @{NSFontAttributeName: font};
    CGSize size = [@"tanh" sizeWithAttributes:attr];
    [@"tanh" drawAtPoint:CGPointMake(context.origin.x, context.origin.y - font.ascender) withAttributes:attr];
    return CGRectMake(context.origin.x, context.origin.y - round(font.ascender), ceil(size.width), ceil(size.height));
}

@end
