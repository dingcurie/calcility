//
//  MathExpression.h
//  iCalculator
//
//  Created by  on 12-6-11.
//  Copyright (c) 2012年 Fish Tribe. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MathResult.h"

@class MathDrawingContext;


@interface MathPosition : NSObject <NSCoding>

+ (instancetype)positionAtIndex:(uint32_t)index;

- (id)initWithIndexPairs:(const uint32_t (*)[2])indexPairs numberOfLevels:(NSUInteger)numberOfLevels;  //: Designated Initializer

@property (nonatomic, readonly) NSUInteger numberOfLevels;
@property (nonatomic, readonly) uint32_t index;
@property (nonatomic, readonly) uint32_t subindex;

- (void)getIndexPairs:(uint32_t (*)[2])indexPairs;
- (MathPosition *)positionByAddingBaseIndexPair:(const uint32_t *)baseIndexPair;
- (MathPosition *)positionByOffset:(NSInteger)offset;

- (NSComparisonResult)compare:(MathPosition *)position;

@end


#pragma mark -


@interface MathRange : NSObject <NSCoding>

- (id)initFromPosition:(MathPosition *)fromPosition toPosition:(MathPosition *)toPosition;  //: Designated Initializer

@property (nonatomic, strong, readonly) MathPosition *fromPosition;
@property (nonatomic, strong, readonly) MathPosition *toPosition;

@property (nonatomic, strong, readonly) MathPosition *selectionStartPosition;
@property (nonatomic, strong, readonly) MathPosition *selectionEndPosition;
@property (nonatomic, readonly) NSUInteger selectionLength;

@end


#pragma mark -


@interface MathExpression : NSObject <NSCoding, NSCopying> {
    NSMutableArray *_elements;
}

+ (instancetype)expressionFromValue:(decQuad)value inDegree:(BOOL)isInDegree;

- (id)initWithElements:(NSArray *)elements;  //: Designated Initializer

@property (nonatomic, strong, readonly) NSArray *elements;
@property (nonatomic, readonly, getter = isGraphical) BOOL graphical;

- (MathResult *)evaluate;

- (void)setMutated;
- (void)resetCache;

- (CGRect)rectWhenDrawAtPoint:(CGPoint)origin withFontSize:(CGFloat)fontSize;
- (CGRect)drawAtPoint:(CGPoint)origin withFontSize:(CGFloat)fontSize;

- (MathPosition *)hitTest:(CGPoint)hitPoint byDistance:(out CGFloat *)outDistance whenDrawAtPoint:(CGPoint)origin withFontSize:(CGFloat)fontSize;
- (MathDrawingContext *)contextAtPosition:(MathPosition *)position whenDrawAtPoint:(CGPoint)origin withFontSize:(CGFloat)fontSize;
- (CGRect)selectionRectForRange:(MathRange *)range whenDrawAtPoint:(CGPoint)origin withFontSize:(CGFloat)fontSize;

- (BOOL)validatePosition:(MathPosition *)position;
- (MathExpression *)subexpressionAtPosition:(MathPosition *)position;
- (NSArray *)elementsInRange:(MathRange *)range;

@end
