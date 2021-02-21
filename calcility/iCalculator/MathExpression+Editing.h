//
//  MathExpression+Editing.h
//  iCalculator
//
//  Created by curie on 12-8-15.
//  Copyright (c) 2012年 Fish Tribe. All rights reserved.
//

#import "MathExpression.h"


extern NSString * const strMathLocalSelectedRangeSelectAll;

#define MathLocalSelectedRangeDefault       nil
#define MathLocalSelectedRangeSelectAll     ((id)strMathLocalSelectedRangeSelectAll)


typedef NS_ENUM(NSInteger, MathExpressionDeletionResult) {
    MathExpressionNothingDeleted = 0,
    MathExpressionOnlyCaretShifted,
    MathExpressionOneDigitDeleted,
    MathExpressionPartialNumberDeleted,
    MathExpressionWholeNumberDeleted,
    MathExpressionOneOperatorDeleted,
    MathExpressionSelectionDeleted,
};


@interface MathExpression (Editing)

- (MathPosition *)closestPositionToPoint:(CGPoint)hitPoint byDistance:(out CGFloat *)outDistance whenDrawAtPoint:(CGPoint)origin withFontSize:(CGFloat)fontSize;
- (CGRect)caretRectForPosition:(MathPosition *)position whenDrawAtPoint:(CGPoint)origin withFontSize:(CGFloat)fontSize;

- (MathPosition *)insertNumericString:(NSString *)aNumericString atPosition:(MathPosition *)position;
- (MathRange *)replaceElementsInRange:(MathRange *)range withElements:(NSArray *)elements localSelectedRange:(MathRange *)localSelectedRange;
- (MathPosition *)deleteBackwardFromPosition:(MathPosition *)position aggressively:(BOOL)aggressively withResult:(out MathExpressionDeletionResult *)outResult;

@end
