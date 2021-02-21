//
//  MathNeg.m
//  iCalculator
//
//  Created by curie on 12-12-21.
//  Copyright (c) 2012年 Fish Tribe. All rights reserved.
//

#import "MathNeg.h"


@interface MathNeg ()

- (id)init;  //: Designated Initializer

@end


@implementation MathNeg

+ (instancetype)neg
{
    static MathNeg *__weak s_weakRef;
    MathNeg *strongRef = s_weakRef;
    if (strongRef == nil) {
        s_weakRef = strongRef = [[MathNeg alloc] init];
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
    self = [MathNeg neg];
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
    decQuadMinus(&resultValue, &operandValue, &DQ_set);
    return [[MathResult alloc] initWithValue:resultValue unitSet:operand.unitSet];
}

- (CGRect)rectWhenDrawWithContext:(MathDrawingContext *)context
{
    FTAssert(context);
    UIFont *font = [MathDrawingContext symbolFontWithSize:context.fontSize];
    NSDictionary *attr = @{NSFontAttributeName: font};
    CGSize size = [@"−" sizeWithAttributes:attr];
    return CGRectMake(context.origin.x, context.origin.y - round(font.ascender), ceil(size.width), ceil(size.height));
}

- (CGRect)drawWithContext:(MathDrawingContext *)context
{
    FTAssert(context);
    UIFont *font = [MathDrawingContext symbolFontWithSize:context.fontSize];
    NSDictionary *attr = @{NSFontAttributeName: font};
    CGSize size = [@"−" sizeWithAttributes:attr];
    [@"−" drawAtPoint:CGPointMake(context.origin.x, context.origin.y - font.ascender) withAttributes:attr];
    return CGRectMake(context.origin.x, context.origin.y - round(font.ascender), ceil(size.width), ceil(size.height));
}

@end
