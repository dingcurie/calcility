//
//  MathConstant.m
//  iCalculator
//
//  Created by curie on 13-4-9.
//  Copyright (c) 2013年 Fish Tribe. All rights reserved.
//

#import "MathConstant.h"


@implementation MathConstant

+ (instancetype)posInf
{
    static MathConstant *__weak s_weakRef;
    MathConstant *strongRef = s_weakRef;
    if (strongRef == nil) {
        s_weakRef = strongRef = [[MathConstant alloc] initWithSymbol:NSLocalizedString(@"Too Large", nil) value:DQ_posInf];
    }
    return strongRef;
}

+ (instancetype)negInf
{
    static MathConstant *__weak s_weakRef;
    MathConstant *strongRef = s_weakRef;
    if (strongRef == nil) {
        s_weakRef = strongRef = [[MathConstant alloc] initWithSymbol:NSLocalizedString(@"Too Small", nil) value:DQ_negInf];
    }
    return strongRef;
}

+ (instancetype)nan
{
    static MathConstant *__weak s_weakRef;
    MathConstant *strongRef = s_weakRef;
    if (strongRef == nil) {
        s_weakRef = strongRef = [[MathConstant alloc] initWithSymbol:NSLocalizedString(@"Undefined", nil) value:DQ_NaN];
    }
    return strongRef;
}

+ (instancetype)pi
{
    static MathConstant *__weak s_weakRef;
    MathConstant *strongRef = s_weakRef;
    if (strongRef == nil) {
        s_weakRef = strongRef = [[MathConstant alloc] initWithSymbol:@"π" value:Dec_pi];
    }
    return strongRef;
}

+ (instancetype)e
{
    static MathConstant *__weak s_weakRef;
    MathConstant *strongRef = s_weakRef;
    if (strongRef == nil) {
        s_weakRef = strongRef = [[MathConstant alloc] initWithSymbol:@"e" value:Dec_e];
    }
    return strongRef;
}

- (id)initWithSymbol:(NSString *)symbol value:(decQuad)value
{
    FTAssert([symbol length]);
    self = [super initWithLeftAffinity:MathNonAffinity rightAffinity:MathNonAffinity];
    if (self) {
        _symbol = [symbol copy];
        _value = value;
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)decoder
{
    _symbol = [decoder decodeObjectForKey:@"symbol"];
    if ([_symbol isEqualToString:@"π"]) {
        self = [MathConstant pi];
    }
    else if ([_symbol isEqualToString:@"e"]) {
        self = [MathConstant e];
    }
    else {
        self = [super initWithCoder:decoder];
        if (self) {
            const uint8_t *bytes = [decoder decodeBytesForKey:@"value" returnedLength:NULL];
            memcpy(&_value, bytes, sizeof(_value));
        }
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)encoder
{
    [super encodeWithCoder:encoder];
    [encoder encodeObject:_symbol forKey:@"symbol"];
    [encoder encodeBytes:(uint8_t *)&_value length:sizeof(_value) forKey:@"value"];  //! endian-dependent, and even compiler-dependent
}

- (MathResult *)operate
{
    return [[MathResult alloc] initWithValue:self.value unitSet:[MathUnitSet none]];
}

- (CGRect)rectWhenDrawWithContext:(MathDrawingContext *)context
{
    FTAssert(context);
    const decQuad value = self.value;
    if (decQuadIsFinite(&value)) {
        UIFont *font = [MathDrawingContext variableFontWithSize:context.fontSize];
        NSDictionary *attr = @{NSFontAttributeName: font};
        CGSize size = [self.symbol sizeWithAttributes:attr];
        return CGRectMake(context.origin.x, context.origin.y - round(font.ascender), ceil(size.width), ceil(size.height));
    }
    else {
        UIFont *font = [MathDrawingContext primaryFontWithSize:context.fontSize];
        NSDictionary *attr = @{NSFontAttributeName: font};
        CGSize size = [self.symbol sizeWithAttributes:attr];
        UIFont *drawingFont = [font fontWithSize:(context.fontSize - 4.0)];  //! Answer's fontSize won't be arbitrarily small.
        NSDictionary *drawingAttr = @{NSFontAttributeName: drawingFont};
        CGSize sizeDrawn = [self.symbol sizeWithAttributes:drawingAttr];
        return CGRectMake(context.origin.x, context.origin.y - round(font.ascender), ceil(sizeDrawn.width), ceil(size.height));
    }
}

- (CGRect)drawWithContext:(MathDrawingContext *)context
{
    FTAssert(context);
    const decQuad value = self.value;
    if (decQuadIsFinite(&value)) {
        UIFont *font = [MathDrawingContext variableFontWithSize:context.fontSize];
        NSDictionary *attr = @{NSFontAttributeName: font};
        CGSize size = [self.symbol sizeWithAttributes:attr];
        [self.symbol drawAtPoint:CGPointMake(context.origin.x, context.origin.y - font.ascender) withAttributes:attr];
        return CGRectMake(context.origin.x, context.origin.y - round(font.ascender), ceil(size.width), ceil(size.height));
    }
    else {
        UIFont *font = [MathDrawingContext primaryFontWithSize:context.fontSize];
        NSDictionary *attr = @{NSFontAttributeName: font};
        CGSize size = [self.symbol sizeWithAttributes:attr];
        UIFont *drawingFont = [font fontWithSize:(context.fontSize - 4.0)];  //! Answer's fontSize won't be arbitrarily small.
        NSDictionary *drawingAttr = @{NSFontAttributeName: drawingFont, NSForegroundColorAttributeName: [MathDrawingContext dullColor]};
        CGSize sizeDrawn = [self.symbol sizeWithAttributes:drawingAttr];
        CGFloat baselineOffset = (font.capHeight - drawingFont.capHeight) / 2.0;
        CGContextRef ctx = UIGraphicsGetCurrentContext();
        CGContextSaveGState(ctx);
        [self.symbol drawAtPoint:CGPointMake(context.origin.x, context.origin.y - baselineOffset - drawingFont.ascender) withAttributes:drawingAttr];
        CGContextRestoreGState(ctx);
        return CGRectMake(context.origin.x, context.origin.y - round(font.ascender), ceil(sizeDrawn.width), ceil(size.height));
    }
}

@end

