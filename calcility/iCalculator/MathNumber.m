//
//  MathNumber.m
//  iCalculator
//
//  Created by  on 12-6-11.
//  Copyright (c) 2012年 Fish Tribe. All rights reserved.
//

#import "MathNumber.h"


@interface MN_NumericAttributedString : NSAttributedString

- (id)initWithString:(NSString *)string correspondingValue:(decQuad)value;  //: Designated Initializer

@property (nonatomic, readonly) NSUInteger *commaIndexes;
@property (nonatomic, readonly) NSUInteger numberOfCommas;

- (CGSize)sizeWithFontSize:(CGFloat)fontSize;

@end


@implementation MN_NumericAttributedString {
    NSMutableAttributedString *_attrString;
    CGFloat _sizeCacheTag;
    CGSize _sizeCache;
}

@synthesize commaIndexes = _commaIndexes;
@synthesize numberOfCommas = _numberOfCommas;

- (id)initWithString:(NSString *)string correspondingValue:(decQuad)value
{
    self = [super init];
    if (self) {
        if (decQuadIsNaN(&value)) {
            _attrString = [[NSMutableAttributedString alloc] initWithString:string attributes:@{NSForegroundColorAttributeName: [MathDrawingContext errorColor]}];
        }
        else {
            const char *s0 = [string cStringUsingEncoding:NSASCIIStringEncoding];
            NSUInteger len = string.length;
            NSUInteger maximumNumberOfCommas = len / 3;
            char s[len + maximumNumberOfCommas + 1/*NUL*/];
            _commaIndexes = malloc(sizeof(*_commaIndexes) * (maximumNumberOfCommas + 1/*Needed by algorithm*/));
            char *pPoint = strchr(s0, '.');
            NSUInteger iPoint = pPoint ? pPoint - s0 : len;
            const char *p0 = s0;
            char *p = s;
            NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
            if ([userDefaults boolForKey:@"MathThousandsSeparatorLeftIsOn"]) {
                switch (iPoint % 3) {
                    case 2: {
                        *p++ = *p0++;
                    }
                    case 1: {
                        *p++ = *p0++;
                        _commaIndexes[_numberOfCommas] = p - s - _numberOfCommas;
                        _numberOfCommas++;
                        *p++ = ',';
                        break;
                    }
                    case 0: {
                        break;
                    }
                }
                for (NSUInteger m = iPoint / 3; m != 0; m--) {
                    *p++ = *p0++;
                    *p++ = *p0++;
                    *p++ = *p0++;
                    _commaIndexes[_numberOfCommas] = p - s - _numberOfCommas;
                    _numberOfCommas++;
                    *p++ = ',';
                }
                if (_numberOfCommas != 0) {
                    FTAssert_DEBUG(s < p && *(p - 1) == ',');
                    --p;
                    --_numberOfCommas;
                }
            }
            else {
                NSUInteger n = iPoint;
                memcpy(p, p0, n);
                p += n;
                p0 += n;
            }
            if (iPoint < len) {
                FTAssert_DEBUG(*p0 == '.');
                *p++ = *p0++;
                if ([userDefaults boolForKey:@"MathThousandsSeparatorRightIsOn"]) {
                    for (NSUInteger m = (len - iPoint - 1) / 3; m != 0; m--) {
                        *p++ = *p0++;
                        *p++ = *p0++;
                        *p++ = *p0++;
                        _commaIndexes[_numberOfCommas] = p - s - _numberOfCommas;
                        _numberOfCommas++;
                        *p++ = ',';
                    }
                    switch ((len - iPoint - 1) % 3) {
                        case 2: {
                            *p++ = *p0++;
                        }
                        case 1: {
                            *p++ = *p0++;
                            break;
                        }
                        case 0: {
                            if (*(p - 1) == ',') {
                                --p;
                                --_numberOfCommas;
                            }
                            break;
                        }
                    }
                }
                else {
                    NSUInteger n = len - iPoint - 1;
                    memcpy(p, p0, n);
                    p += n;
#ifdef DEBUG
                    p0 += n;
#endif
                }
            }
            *p = '\0';
            FTAssert_DEBUG(p0 == s0 + len);
            FTAssert_DEBUG(p < s + sizeof(s));
            FTAssert_DEBUG(_numberOfCommas <= maximumNumberOfCommas);
            
            _attrString = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithCString:s encoding:NSASCIIStringEncoding]];
            UIColor *commaColor = [MathDrawingContext dullColor];
            for (NSUInteger i = 0; i < _numberOfCommas; i++) {
                [_attrString addAttribute:NSForegroundColorAttributeName value:commaColor range:NSMakeRange(_commaIndexes[i] + i, 1)];  //! SUPPRESS ISSUE: The left operand of '+' is a garbage value.
            }
        }
    }
    return self;
}

- (void)dealloc
{
    if (_commaIndexes) {
        free(_commaIndexes);
    }
}

- (NSString *)string
{
    return [_attrString string];
}

- (NSDictionary *)attributesAtIndex:(NSUInteger)location effectiveRange:(NSRangePointer)range
{
    return [_attrString attributesAtIndex:location effectiveRange:range];
}

- (CGSize)sizeWithFontSize:(CGFloat)fontSize
{
    if (_sizeCacheTag == fontSize) {
        return _sizeCache;
    }
    _sizeCacheTag = fontSize;
    
    UIFont *font = [MathDrawingContext primaryFontWithSize:fontSize];
    [_attrString addAttribute:NSFontAttributeName value:font range:NSMakeRange(0, _attrString.length)];
    UIFont *commaFont = [font fontWithSize:(fontSize * 0.6)];
    for (NSUInteger i = 0; i < _numberOfCommas; i++) {
        [_attrString addAttribute:NSFontAttributeName value:commaFont range:NSMakeRange(_commaIndexes[i] + i, 1)];
    }
    
    return (_sizeCache = [_attrString size]);
}

@end


#pragma mark -


@interface MathNumber ()

@property (nonatomic, strong, readonly) MN_NumericAttributedString *attrString;

@end


@implementation MathNumber {
    BOOL _valueCacheTag;
}

@synthesize value = _value;
@synthesize attrString = _attrString;

- (id)initWithString:(NSString *)aString
{
    FTAssert([aString length]);
    self = [super initWithLeftAffinity:MathNonAffinity rightAffinity:MathNonAffinity];
    if (self) {
        _string = [aString mutableCopy];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)decoder
{
    self = [super initWithCoder:decoder];
    if (self) {
        _string = [decoder decodeObjectForKey:@"string"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)encoder
{
    [super encodeWithCoder:encoder];
    [encoder encodeObject:_string forKey:@"string"];
}

- (id)copyWithZone:(NSZone *)zone
{
    return [[[self class] alloc] initWithString:_string];
}

- (decQuad)value
{
    if (!_valueCacheTag) {
        decQuadFromString(&_value, [self.string cStringUsingEncoding:NSASCIIStringEncoding], &DQ_set);
        _valueCacheTag = YES;
    }
    return _value;
}

- (MN_NumericAttributedString *)attrString
{
    if (_attrString == nil) {
        _attrString = [[MN_NumericAttributedString alloc] initWithString:self.string correspondingValue:self.value];
    }
    return _attrString;
}

- (NSString *)formattedString
{
    return [self.attrString.string copy];
}

- (void)setMutated
{
    _valueCacheTag = NO;
    _attrString = nil;
}

- (void)resetCache
{
    [super resetCache];
    
    _valueCacheTag = NO;
    _attrString = nil;
}

- (CGRect)rectWhenDrawWithContext:(MathDrawingContext *)context
{
    FTAssert(context);
    CGPoint origin = context.origin;
    CGFloat fontSize = context.fontSize;
    UIFont *font = [MathDrawingContext primaryFontWithSize:fontSize];
    CGSize size = [self.attrString sizeWithFontSize:fontSize];
    return CGRectMake(origin.x, origin.y - round(font.ascender), ceil(size.width), ceil(size.height));
}

- (CGRect)drawWithContext:(MathDrawingContext *)context
{
    FTAssert(context);
    CGPoint origin = context.origin;
    CGFloat fontSize = context.fontSize;
    UIFont *font = [MathDrawingContext primaryFontWithSize:fontSize];
    CGSize size = [self.attrString sizeWithFontSize:fontSize];
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    CGContextSaveGState(ctx);
    [self.attrString drawAtPoint:CGPointMake(origin.x, origin.y - font.ascender)];
    CGContextRestoreGState(ctx);
    return CGRectMake(origin.x, origin.y - round(font.ascender), ceil(size.width), ceil(size.height));
}

- (NSUInteger)closestIndexToPoint:(CGPoint)hitPoint whenDrawWithContext:(MathDrawingContext *)context
{
    CGFloat localHitPointX = hitPoint.x - context.origin.x;
    if (localHitPointX < 0) {
        return 0;
    }
    
    NSUInteger maxIndex = [self.string length];
    CGSize attrStringSize = [self.attrString sizeWithFontSize:context.fontSize];
    NSUInteger index = MIN(lround(localHitPointX / (attrStringSize.width / maxIndex)), maxIndex);
    CGFloat offset = [self offsetForIndex:index whenDrawWithFontSize:context.fontSize];
    if (localHitPointX < offset) {
        for (; 0 < index; index--) {
            CGFloat nextOffset = [self offsetForIndex:(index - 1) whenDrawWithFontSize:context.fontSize];;
            if ((nextOffset + offset) / 2.0 <= localHitPointX) break;
            offset = nextOffset;
        }
    }
    else {
        for (; index < maxIndex; index++) {
            CGFloat nextOffset = [self offsetForIndex:(index + 1) whenDrawWithFontSize:context.fontSize];;
            if (localHitPointX <= (offset + nextOffset) / 2.0) break;
            offset = nextOffset;
        }
    }
    return index;
}

- (CGFloat)offsetForIndex:(NSUInteger)index whenDrawWithFontSize:(CGFloat)fontSize
{
    NSUInteger *commaIndexes = self.attrString.commaIndexes;
    NSUInteger numberOfCommas = self.attrString.numberOfCommas;
    NSUInteger numberOfCommasAhead;
    if (numberOfCommas == 0) {
        numberOfCommasAhead = 0;
    }
    else {
        NSUInteger iSml = 0;
        NSUInteger iBig = numberOfCommas - 1;
        while (iSml < iBig) {
            NSUInteger iMid = (iSml + iBig) / 2;
            if (commaIndexes[iMid] < index) {
                iSml = iMid + 1;
            }
            else {
                iBig = iMid;
            }
        }
        if (commaIndexes[iBig] <= index) {
            numberOfCommasAhead = iBig + 1;
        }
        else {
            numberOfCommasAhead = iBig;
        }
    }
    (void)[self.attrString sizeWithFontSize:fontSize];
    return [[self.attrString attributedSubstringFromRange:NSMakeRange(0, index + numberOfCommasAhead)] size].width;
}

@end
