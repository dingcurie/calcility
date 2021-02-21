//
//  MathElement.m
//  iCalculator
//
//  Created by  on 12-6-11.
//  Copyright (c) 2012年 Fish Tribe. All rights reserved.
//

#import "MathElement.h"
#import "MathExpression.h"
#import "MathConcreteOperators.h"


@interface MathDrawingContext ()

@property (nonatomic, readonly) CGFloat spaceWidth;
@property (nonatomic, readonly) CGFloat thinSpaceWidth;

@end


@implementation MathDrawingContext {
    CGRect _relPlaceholderRect;
    
    NSEnumerator *_elementsEnumerator;
    BOOL _needsReplaceAddSubWithPosNeg;
}

+ (UIFont *)primaryFontWithSize:(CGFloat)fontSize
{
    return [UIFont fontWithName:@"TimesNewRomanPSMT" size:fontSize];
}

+ (UIFont *)symbolFontWithSize:(CGFloat)fontSize
{
    return [UIFont fontWithName:@"TimesNewRomanPSMT" size:fontSize];
}

+ (UIFont *)variableFontWithSize:(CGFloat)fontSize
{
    return [UIFont fontWithName:@"TimesNewRomanPS-ItalicMT" size:fontSize];
}

+ (UIFont *)functionFontWithSize:(CGFloat)fontSize
{
    return [UIFont fontWithName:@"TimesNewRomanPS-BoldMT" size:fontSize];
}

+ (UIColor *)errorColor
{
    return [UIColor colorWithRed:253/255.0 green:71/255.0 blue:43/255.0 alpha:1.0];
}

+ (UIColor *)dullColor
{
    return [UIColor colorWithWhite:0.5 alpha:1.0];
}

- (id)initWithExpression:(MathExpression *)expression toDrawAtOrigin:(CGPoint)origin withFontSize:(CGFloat)fontSize
{
    FTAssert(expression && fontSize != 0.0);
    self = [super init];
    if (self) {
        _expression = expression;
        _origin = origin;
        _fontSize = fontSize;
        
        _previousElementRect = CGRectNull;
        _precedingPlaceholderRect = CGRectNull;
    }
    return self;
}

- (CGRect)relPlaceholderRect
{
    if (CGRectIsEmpty(_relPlaceholderRect)) {
        UIFont *font = [MathDrawingContext primaryFontWithSize:_fontSize];
        CGSize size = [@"0" sizeWithAttributes:@{NSFontAttributeName: font}];
        _relPlaceholderRect = CGRectMake(0.0, _origin.y - round(font.ascender), ceil(size.width), ceil(size.height));
    }
    return _relPlaceholderRect;
}

- (CGFloat)spaceWidth
{
    return MAX(1.0, round(_fontSize * (1.0 / 5.0)));
}

- (CGFloat)thinSpaceWidth
{
    return MAX(1.0, round(_fontSize * (1.0 / 10.0)));
}

- (MathElement *)nextElement
{
    if (_elementsEnumerator == nil) {
        _elementsEnumerator = [_expression.elements objectEnumerator];
        _needsReplaceAddSubWithPosNeg = YES;
    }
    
    FTAssert_DEBUG(_currentElement == nil && CGRectIsNull(_precedingPlaceholderRect));  //: You might forget to call -advanceByCurrentElementRect:!
    if ((_currentElement = [_elementsEnumerator nextObject])) {
        if (_needsReplaceAddSubWithPosNeg) {
            if ([_currentElement isKindOfClass:[MathSub class]]) {
                _currentElement = [MathNeg neg];
            }
            else if ([_currentElement isKindOfClass:[MathAdd class]]) {
                _currentElement = [MathPos pos];
            }
            else {
                _needsReplaceAddSubWithPosNeg = NO;
            }
        }
        
        if (_previousElement == nil) {
            /*  | 0 0  :  |123 , |( )
             *  | 0 1  :  |sin , |-
             *  | 1 0  :  |[]%
             *  | 1 1  :  |[]__×
             */
            if (_currentElement.leftAffinity) {
                _precedingPlaceholderRect = self.relPlaceholderRect;
                _precedingPlaceholderRect.origin.x = _origin.x;
                _origin.x += _precedingPlaceholderRect.size.width;
                if (_currentElement.rightAffinity) {
                    _origin.x += self.spaceWidth;
                }
                //$ _previousElement = nil;
                _previousElementRect = _precedingPlaceholderRect;
                _previousElementIsGraphical = NO;
            }
        }
        else {
            switch (!!_previousElement.rightAffinity << 1 | !!_currentElement.leftAffinity) {
                case 0x0: {
                    /*  0 0  0 0  :  123( ) , ( )123 , ( )( )
                     *  0 0  0 1  :  123_sin , ( )_sin
                     *  1 0  0 0  :  %123 , %( )
                     *  1 0  0 1  :  %_sin
                     */
                    if (_currentElement.rightAffinity) {
                        _origin.x += self.thinSpaceWidth;
                    }
                    break;
                }
                case 0x1: {
                    /*  0 0  1 0  :  123% , ( )%
                     *  0 0  1 1  :  123__× , ( )__×
                     *  1 0  1 0  :  %!
                     *  1 0  1 1  :  %__×
                     */
                    if (_currentElement.rightAffinity) {
                        _origin.x += self.spaceWidth;
                    }
                    break;
                }
                case 0x2: {
                    /*  0 1  0 0  :  sin123 , sin( ) , |-123 , |-( )
                     *  0 1  0 1  :  sin_cos , |-_cos , |-+
                     *  1 1  0 0  :  ×__123 , ×__( )
                     *  1 1  0 1  :  ×__sin
                     */
                    if (_previousElement.leftAffinity) {
                        _origin.x += self.spaceWidth;
                    }
                    else if (_currentElement.rightAffinity && !_needsReplaceAddSubWithPosNeg) {
                        _origin.x += self.thinSpaceWidth;
                    }
                    break;
                }
                case 0x3: {
                    /*  0 1  1 0  :  sin[]% , |-[]%
                     *  0 1  1 1  :  sin[]__× , |-[]__×
                     *  1 1  1 0  :  ×__[]%
                     *  1 1  1 1  :  ×__[]__×
                     */
                    _precedingPlaceholderRect = self.relPlaceholderRect;
                    if (_previousElement.leftAffinity) {
                        _origin.x += self.spaceWidth;
                    }
                    _precedingPlaceholderRect.origin.x = _origin.x;
                    _origin.x += _precedingPlaceholderRect.size.width;
                    if (_currentElement.rightAffinity) {
                        _origin.x += self.spaceWidth;
                    }
                    _previousElement = nil;
                    _previousElementRect = _precedingPlaceholderRect;
                    _previousElementIsGraphical = NO;
                    break;
                }
            }
        }
    }
    else {
        if (_previousElement == nil) {
            /*  |  |  :  |[]|
             */
            _precedingPlaceholderRect = self.relPlaceholderRect;
            _precedingPlaceholderRect.origin.x = _origin.x;
            _origin.x += _precedingPlaceholderRect.size.width;
            //$ _previousElement = nil;
            _previousElementRect = _precedingPlaceholderRect;
            _previousElementIsGraphical = NO;
        }
        else {
            /*  0 0 |  :  123| , ( )|
             *  0 1 |  :  sin[]| , |-[]|
             *  1 0 |  :  %|
             *  1 1 |  :  ×__[]|
             */
            if (_previousElement.rightAffinity) {
                _precedingPlaceholderRect = self.relPlaceholderRect;
                if (_previousElement.leftAffinity) {
                    _origin.x += self.spaceWidth;
                }
                _precedingPlaceholderRect.origin.x = _origin.x;
                _origin.x += _precedingPlaceholderRect.size.width;
                _previousElement = nil;
                _previousElementRect = _precedingPlaceholderRect;
                _previousElementIsGraphical = NO;
            }
        }
    }
    
    return _currentElement;
}

- (void)advanceByCurrentElementRect:(CGRect)currentElementRect
{
    _index++;
    _origin.x = CGRectGetMaxX(currentElementRect);
    
    _previousElement = _currentElement;
    _previousElementRect = currentElementRect;
    MathDrawingTrait currentElementDrawingTrait = _currentElement.drawingTrait;
    if (currentElementDrawingTrait != MathDrawingInheritedTrait) {
        _previousElementIsGraphical = currentElementDrawingTrait == MathDrawingGraphicalTrait;
    }
    
    _currentElement = nil;
    _precedingPlaceholderRect = CGRectNull;
}

@end


#pragma mark -


@implementation MathElement

- (id)initWithLeftAffinity:(MathAffinity)leftAffinity rightAffinity:(MathAffinity)rightAffinity
{
    self = [super init];
    if (self) {
        _leftAffinity = leftAffinity;
        _rightAffinity = rightAffinity;
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)decoder
{
    self = [super init];
    if (self) {
        _leftAffinity = [decoder decodeInt32ForKey:@"leftAffinity"];
        _rightAffinity = [decoder decodeInt32ForKey:@"rightAffinity"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)encoder
{
    [encoder encodeInt32:_leftAffinity forKey:@"leftAffinity"];
    [encoder encodeInt32:_rightAffinity forKey:@"rightAffinity"];
}

- (id)copyWithZone:(NSZone *)zone
{
    return self;
}

- (MathDrawingTrait)drawingTrait
{
    return MathDrawingTextualTrait;
}

- (void)resetCache
{
    return;
}

- (CGRect)rectWhenDrawWithContext:(MathDrawingContext *)context
{
    return CGRectNull;
}

- (CGRect)drawWithContext:(MathDrawingContext *)context
{
    return CGRectNull;
}

@end
