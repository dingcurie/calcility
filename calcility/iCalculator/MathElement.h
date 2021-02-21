//
//  MathElement.h
//  iCalculator
//
//  Created by  on 12-6-11.
//  Copyright (c) 2012年 Fish Tribe. All rights reserved.
//

#import <Foundation/Foundation.h>

@class MathExpression;
@class MathElement;


@interface MathDrawingContext : NSObject

+ (UIFont *)primaryFontWithSize:(CGFloat)fontSize;
+ (UIFont *)symbolFontWithSize:(CGFloat)fontSize;
+ (UIFont *)variableFontWithSize:(CGFloat)fontSize;
+ (UIFont *)functionFontWithSize:(CGFloat)fontSize;
+ (UIColor *)errorColor;
+ (UIColor *)dullColor;

- (id)initWithExpression:(MathExpression *)expression toDrawAtOrigin:(CGPoint)origin withFontSize:(CGFloat)fontSize;  //: Designated Initializer

@property (nonatomic, strong, readonly) MathExpression *expression;
@property (nonatomic, readonly) NSUInteger index;
@property (nonatomic, readonly) CGPoint origin;
@property (nonatomic, readonly) CGFloat fontSize;

@property (nonatomic, strong, readonly) MathElement *previousElement;
@property (nonatomic, readonly) CGRect previousElementRect;
@property (nonatomic, readonly) BOOL previousElementIsGraphical;

@property (nonatomic, strong, readonly) MathElement *currentElement;
@property (nonatomic, readonly) CGRect precedingPlaceholderRect;

@property (nonatomic, readonly) CGRect relPlaceholderRect;

- (MathElement *)nextElement;
- (void)advanceByCurrentElementRect:(CGRect)currentElementRect;  //: Concpetually, simple "-(void)advance;" is adequate, since a context has all the information needed to  calculate the current element's rect. But, practically, the rect is almost always needed outside the context. By passing it in as argument, calculating it more than once can be avoided.

@end


#pragma mark -


typedef NS_ENUM(uint32_t, MathAffinity) {
    MathNonAffinity = 0,
    MathMinimumAffinity,
    MathAdditiveOperatorLeftAffinity,
    MathAdditiveOperatorRightAffinity,
    MathMultiplicativeOperatorLeftAffinity,
    MathMultiplicativeOperatorRightAffinity,
    MathLeftUnaryOperatorRightAffinity,
    MathImplicitMultiplyLeftAffinity,
    MathImplicitMultiplyRightAffinity,
    MathRightUnaryOperatorLeftAffinity,
};


typedef NS_ENUM(NSInteger, MathDrawingTrait) {
    MathDrawingTextualTrait,
    MathDrawingGraphicalTrait,
    MathDrawingInheritedTrait,
};


@interface MathElement : NSObject <NSCoding, NSCopying>

- (id)initWithLeftAffinity:(MathAffinity)leftAffinity rightAffinity:(MathAffinity)rightAffinity;  //: Designated Initializer

@property (nonatomic, readonly) MathAffinity leftAffinity, rightAffinity;
@property (nonatomic, readonly) MathDrawingTrait drawingTrait;  // Defaults to MathDrawingTextualTrait.

- (void)resetCache;

- (CGRect)rectWhenDrawWithContext:(MathDrawingContext *)context;
- (CGRect)drawWithContext:(MathDrawingContext *)context;
    //! The returned rect MUST have integral top-left offset with respect to the context.origin, and MUST have integral size, but MUST NOT make integral any dimensions passed in via the context.

@end
