//
//  MathAdd.m
//  iCalculator
//
//  Created by  on 12-6-12.
//  Copyright (c) 2012年 Fish Tribe. All rights reserved.
//

#import "MathAdd.h"


@interface MathAdd ()

- (id)init;  //: Designated Initializer

@end


@implementation MathAdd

+ (instancetype)add
{
    static MathAdd *__weak s_weakRef;
    MathAdd *strongRef = s_weakRef;
    if (strongRef == nil) {
        s_weakRef = strongRef = [[MathAdd alloc] init];
    }
    return strongRef;
}

- (id)init
{
    self = [super initWithLeftAffinity:MathAdditiveOperatorLeftAffinity rightAffinity:MathAdditiveOperatorRightAffinity];
    return self;
}

- (id)initWithCoder:(NSCoder *)decoder
{
    self = [MathAdd add];
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
    decQuadAdd(&resultValue, &leftOperandValue, &rightOperandValue, &DQ_set);
    return [[MathResult alloc] initWithValue:resultValue unitSet:[leftOperand.unitSet unitSetByReconcilingWith:rightOperand.unitSet]];
}

- (CGRect)rectWhenDrawWithContext:(MathDrawingContext *)context
{
    FTAssert(context);
    UIFont *font = [MathDrawingContext symbolFontWithSize:context.fontSize];
    NSDictionary *attr = @{NSFontAttributeName: font};
    CGSize size = [@"+" sizeWithAttributes:attr];
    return CGRectMake(context.origin.x, context.origin.y - round(font.ascender), round(size.width), ceil(size.height));
}

- (CGRect)drawWithContext:(MathDrawingContext *)context
{
    FTAssert(context);
    UIFont *font = [MathDrawingContext symbolFontWithSize:context.fontSize];
    NSDictionary *attr = @{NSFontAttributeName: font};
    CGSize size = [@"+" sizeWithAttributes:attr];
    [@"+" drawAtPoint:CGPointMake(context.origin.x, context.origin.y - font.ascender) withAttributes:attr];
    return CGRectMake(context.origin.x, context.origin.y - round(font.ascender), round(size.width), ceil(size.height));  //: To be accurate, dy should be ceil(font.ascender), and height should be ceil(font.ascender) + ceil(font.descender). However, it's overkill, I think, and, in fact, no help to position the index of nth root accurately. The second round(), instead of ceil(), helps to make even margin on both sides.
}

@end
