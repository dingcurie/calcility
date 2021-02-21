//
//  MathExpression+Editing.m
//  iCalculator
//
//  Created by curie on 12-8-15.
//  Copyright (c) 2012年 Fish Tribe. All rights reserved.
//

#import "MathExpression+Editing.h"
#import "MathNumber.h"
#import "MathConcreteOperators.h"


NSString * const strMathLocalSelectedRangeSelectAll = @"MathLocalSelectedRangeSelectAll";


static
CGRect caretRectWithContextAndSubindex(MathDrawingContext *context, NSUInteger subindex)
{
    CGFloat caretOriginX;
    CGRect caretRefRect;
    MathElement *currentElement = context.currentElement;
    if ([currentElement isKindOfClass:[MathNumber class]]) {
        caretOriginX = context.origin.x + round([(MathNumber *)currentElement offsetForIndex:subindex whenDrawWithFontSize:context.fontSize]);
        caretRefRect = context.relPlaceholderRect;
    }
    else {
        MathElement *previousElement = context.previousElement;
        CGRect previousElementRect = context.previousElementRect;
        if (previousElement) {
            if (previousElement.leftAffinity && previousElement.rightAffinity && currentElement && !currentElement.leftAffinity) {
                //  x__?
                caretOriginX = context.origin.x;
                caretRefRect = context.relPlaceholderRect;
            }
            else {
                // *?*
                caretOriginX = CGRectGetMaxX(previousElementRect);
                caretRefRect = previousElementRect;
            }
        }
        else {
            if (CGRectIsNull(previousElementRect)) {
                // |?
                caretOriginX = context.origin.x;
                caretRefRect = context.relPlaceholderRect;
            }
            else {
                // []?
                caretOriginX = CGRectGetMinX(previousElementRect);
                caretRefRect = previousElementRect;
            }
        }
    }
    return CGRectMake(caretOriginX, CGRectGetMinY(caretRefRect), g_isPhone ? 2.0 : 3.0, CGRectGetHeight(caretRefRect));
}


static
CGFloat distanceFromPointToRect(CGPoint point, CGRect rect)
{
    CGFloat deltaX;
    if (point.x < CGRectGetMinX(rect)) {
        deltaX = CGRectGetMinX(rect) - point.x;
    }
    else if (point.x <= CGRectGetMaxX(rect)) {
        deltaX = 0.0;
    }
    else {
        deltaX = point.x - CGRectGetMaxX(rect);
    }
    
    CGFloat deltaY;
    if (point.y < CGRectGetMinY(rect)) {
        deltaY = CGRectGetMinY(rect) - point.y;
    }
    else if (point.y <= CGRectGetMaxY(rect)) {
        deltaY = 0.0;
    }
    else {
        deltaY = point.y - CGRectGetMaxY(rect);
    }
    
    return hypot(deltaX, deltaY);
}


@implementation MathExpression (Editing)

- (MathPosition *)closestPositionToPoint:(CGPoint)hitPoint byDistance:(out CGFloat *)outDistance whenDrawAtPoint:(CGPoint)origin withFontSize:(CGFloat)fontSize
{
    // First, find the closest position at the current expression level.
    MathDrawingContext *context = [[MathDrawingContext alloc] initWithExpression:self toDrawAtOrigin:origin withFontSize:fontSize];
    MathElement *element;
    uint32_t indexPair[2] = {0, 0};
    while ((element = [context nextElement])) {
        CGRect elementRect = [element rectWhenDrawWithContext:context];
        if (hitPoint.x < CGRectGetMaxX(elementRect)) {
            // Find it.
            if ([element isKindOfClass:[MathNumber class]]) {
                NSUInteger indexIntoNumber = [(MathNumber *)element closestIndexToPoint:hitPoint whenDrawWithContext:context];
                if (indexIntoNumber < [((MathNumber *)element).string length]) {
                    indexPair[1] = (uint32_t)indexIntoNumber;
                }
                else {
                    [context advanceByCurrentElementRect:elementRect];
                    indexPair[0]++;
                    element = [context nextElement];  //$
                }
            }
            else {
                if (CGRectGetMidX(elementRect) < hitPoint.x) {
                    [context advanceByCurrentElementRect:elementRect];
                    indexPair[0]++;
                    element = [context nextElement];  //$
                }
            }
            break;
        }
        [context advanceByCurrentElementRect:elementRect];
        indexPair[0]++;
    }
    CGRect caretRect = caretRectWithContextAndSubindex(context, indexPair[1]);
    MathPosition *closestPosition = [[MathPosition alloc] initWithIndexPairs:&indexPair numberOfLevels:1];
    CGFloat shortestDistance = hypot(hitPoint.x - CGRectGetMinX(caretRect), hitPoint.y - CGRectGetMidY(caretRect));
    
    // Second, compare it with the closest positions in the subexpression levels.
    context = [[MathDrawingContext alloc] initWithExpression:self toDrawAtOrigin:origin withFontSize:fontSize];
    indexPair[0] = indexPair[1] = 0;
    while ((element = [context nextElement])) {
        CGRect elementRect = [element rectWhenDrawWithContext:context];
        if (distanceFromPointToRect(hitPoint, elementRect) < shortestDistance && [element isKindOfClass:[MathCompositeOperator class]]) {
            MathCompositeOperator *compositeOperator = (MathCompositeOperator *)element;
            for (MathExpression *subexpression in compositeOperator.subexpressions) {
                CGPoint suborigin = [compositeOperator originOfSubexpressionAtIndex:indexPair[1] whenDrawWithContext:context];
                CGFloat subfontSize = [compositeOperator fontSizeOfSubexpressionAtIndex:indexPair[1] whenDrawWithContext:context];
                CGFloat distance;
                MathPosition *subposition = [subexpression closestPositionToPoint:hitPoint byDistance:&distance whenDrawAtPoint:suborigin withFontSize:subfontSize];
                if (distance < shortestDistance) {
                    closestPosition = [subposition positionByAddingBaseIndexPair:indexPair];
                    shortestDistance = distance;
                }
                indexPair[1]++;
            }
            indexPair[1] = 0;
        }
        [context advanceByCurrentElementRect:elementRect];
        indexPair[0]++;
    }
    
    if (outDistance) {
        *outDistance = shortestDistance;
    }
    return closestPosition;
}

- (CGRect)caretRectForPosition:(MathPosition *)position whenDrawAtPoint:(CGPoint)origin withFontSize:(CGFloat)fontSize
{
    FTAssert(position);
    MathDrawingContext *context = [self contextAtPosition:position whenDrawAtPoint:origin withFontSize:fontSize];
    return caretRectWithContextAndSubindex(context, position.subindex);
}

- (MathPosition *)insertNumericString:(NSString *)aNumericString atPosition:(MathPosition *)position
{
    FTAssert(aNumericString && position);
    uint32_t indexPairs[position.numberOfLevels][2];
    [position getIndexPairs:indexPairs];
    MathExpression *mySelf = self;
    [mySelf setMutated];
    NSUInteger level;
    for (level = 0; level < position.numberOfLevels - 1; level++) {
        FTAssert_DEBUG(indexPairs[level][0] < mySelf->_elements.count);
        MathElement *element = mySelf->_elements[indexPairs[level][0]];
        FTAssert_DEBUG([element isKindOfClass:[MathCompositeOperator class]]);
        MathCompositeOperator *compositeOperator = (MathCompositeOperator *)element;
        FTAssert_DEBUG(indexPairs[level][1] < compositeOperator.subexpressions.count);
        mySelf = compositeOperator.subexpressions[indexPairs[level][1]];
        [mySelf setMutated];
    }
    FTAssert_DEBUG(indexPairs[level][0] <= mySelf->_elements.count);
    
    MathElement *element;
    if (indexPairs[level][0] < mySelf->_elements.count && [(element = mySelf->_elements[indexPairs[level][0]]) isKindOfClass:[MathNumber class]]) {
        MathNumber *theNumber = (MathNumber *)element;
        FTAssert_DEBUG(indexPairs[level][1] < [theNumber.string length]);
        [theNumber.string insertString:aNumericString atIndex:indexPairs[level][1]];
        [theNumber setMutated];
        indexPairs[level][1] += (uint32_t)[aNumericString length];
    }
    else if (indexPairs[level][0] != 0 && [(element = mySelf->_elements[indexPairs[level][0] - 1]) isKindOfClass:[MathNumber class]]) {
        MathNumber *theNumber = (MathNumber *)element;
        [theNumber.string appendString:aNumericString];
        [theNumber setMutated];
        FTAssert_DEBUG(indexPairs[level][1] == 0);
    }
    else {
        [mySelf->_elements insertObject:[[MathNumber alloc] initWithString:aNumericString] atIndex:indexPairs[level][0]];
        indexPairs[level][0]++;
        FTAssert_DEBUG(indexPairs[level][1] == 0);
    }
    
    return [[MathPosition alloc] initWithIndexPairs:indexPairs numberOfLevels:(level + 1)];
}

- (NSUInteger)mergePreviousNumberWithNumberAtIndex:(NSUInteger)index
{
    NSUInteger indexIntoMergedNumber = 0;
    MathElement *element, *previousElement;
    if (index < _elements.count && [(element = _elements[index]) isKindOfClass:[MathNumber class]] && index != 0 && [(previousElement = _elements[index - 1]) isKindOfClass:[MathNumber class]]) {
        NSString *numberString = ((MathNumber *)element).string;
        NSString *previousNumberString = ((MathNumber *)previousElement).string;
        FTAssert_DEBUG(numberString.length && previousNumberString.length);
        MathNumber *mergedNumber = [[MathNumber alloc] initWithString:[previousNumberString stringByAppendingString:numberString]];
        indexIntoMergedNumber = [previousNumberString length];
        [_elements removeObjectAtIndex:index];
        _elements[index - 1] = mergedNumber;
    }
    return indexIntoMergedNumber;
}

- (MathRange *)replaceElementsInRange:(MathRange *)range withElements:(NSArray *)elements localSelectedRange:(MathRange *)localSelectedRange
{
    FTAssert(range && elements);
    if (localSelectedRange == nil) {
        uint32_t indexPairs[2][2] = {{0, 0}, {0, 0}};
        NSUInteger level = 0;
        for (MathElement *element in elements) {
            if ([element isKindOfClass:[MathCompositeOperator class]]) {
                for (MathExpression *subexpression in ((MathCompositeOperator *)element).subexpressions) {
                    if (subexpression.elements.count == 0) {
                        // Find an empty subexpression, then done.
                        level = 1;
                        break;
                    }
                    indexPairs[0][1]++;
                }
                if (level) {
                    break;
                }
                else {
                    indexPairs[0][1] = 0;
                }
            }
            indexPairs[0][0]++;
        }
        MathPosition *caretPosition = [[MathPosition alloc] initWithIndexPairs:indexPairs numberOfLevels:(level + 1)];
        localSelectedRange = [[MathRange alloc] initFromPosition:caretPosition toPosition:caretPosition];
    }
    else if (localSelectedRange == MathLocalSelectedRangeSelectAll) {
        localSelectedRange = [[MathRange alloc] initFromPosition:[MathPosition positionAtIndex:0] toPosition:[MathPosition positionAtIndex:(uint32_t)elements.count]];
    }
    else {
        //: Here comes normal MathRange.
    }
    
    NSUInteger fromNumberOfLevels = range.selectionStartPosition.numberOfLevels - 1 + localSelectedRange.fromPosition.numberOfLevels;
    NSUInteger toNumberOfLevels = range.selectionStartPosition.numberOfLevels - 1 + localSelectedRange.toPosition.numberOfLevels;
    uint32_t indexPairs[MAX(fromNumberOfLevels, toNumberOfLevels)][2];
    [range.selectionStartPosition getIndexPairs:indexPairs];
    MathExpression *mySelf = self;
    [mySelf setMutated];
    NSUInteger level;
    for (level = 0; level < range.selectionStartPosition.numberOfLevels - 1; level++) {
        FTAssert_DEBUG(indexPairs[level][0] < mySelf->_elements.count);
        MathElement *element = mySelf->_elements[indexPairs[level][0]];
        FTAssert_DEBUG([element isKindOfClass:[MathCompositeOperator class]]);
        MathCompositeOperator *compositeOperator = (MathCompositeOperator *)element;
        FTAssert_DEBUG(indexPairs[level][1] < compositeOperator.subexpressions.count);
        mySelf = compositeOperator.subexpressions[indexPairs[level][1]];
        [mySelf setMutated];
    }
    FTAssert_DEBUG(indexPairs[level][0] <= mySelf->_elements.count);
    
    NSMutableArray *replacementElements = [elements mutableCopy];
    if (range.selectionStartPosition.subindex != 0) {
        FTAssert_DEBUG(range.selectionStartPosition.index < mySelf->_elements.count);
        MathNumber *theNumber = mySelf->_elements[range.selectionStartPosition.index];
        FTAssert_DEBUG([theNumber isKindOfClass:[MathNumber class]]);
        FTAssert_DEBUG(range.selectionStartPosition.subindex < [theNumber.string length]);
        [replacementElements insertObject:[[MathNumber alloc] initWithString:[theNumber.string substringToIndex:range.selectionStartPosition.subindex]] atIndex:0];
        indexPairs[level][0]++;
        indexPairs[level][1] = 0;
    }
    if (range.selectionEndPosition.subindex != 0) {
        FTAssert_DEBUG(range.selectionEndPosition.index < mySelf->_elements.count);
        MathNumber *theNumber = mySelf->_elements[range.selectionEndPosition.index];
        FTAssert_DEBUG([theNumber isKindOfClass:[MathNumber class]]);
        FTAssert_DEBUG(range.selectionEndPosition.subindex < [theNumber.string length]);
        [replacementElements addObject:[[MathNumber alloc] initWithString:[theNumber.string substringFromIndex:range.selectionEndPosition.subindex]]];
    }
    [mySelf->_elements replaceObjectsInRange:NSMakeRange(range.selectionStartPosition.index, range.selectionLength == 0 && range.selectionStartPosition.subindex != 0 ? 1 : range.selectionLength) withObjectsFromArray:replacementElements];
    
    if (elements.count == 0) {
        NSUInteger indexIntoMergedNumber = [mySelf mergePreviousNumberWithNumberAtIndex:indexPairs[level][0]];
        if (indexIntoMergedNumber) {
            indexPairs[level][0]--;
            indexPairs[level][1] = (uint32_t)indexIntoMergedNumber;
        }
        MathPosition *caretPosition = [[MathPosition alloc] initWithIndexPairs:indexPairs numberOfLevels:(level + 1)];
        return [[MathRange alloc] initFromPosition:caretPosition toPosition:caretPosition];
    }
    else {
        NSUInteger indexOfInsertionPoint = indexPairs[level][0];
        
        NSUInteger indexIntoMergedNumberAtTheBeginning = [mySelf mergePreviousNumberWithNumberAtIndex:indexOfInsertionPoint];
        if (indexIntoMergedNumberAtTheBeginning) {
            indexOfInsertionPoint--;
        }
        NSUInteger indexIntoMergedNumberAtTheEnd = [mySelf mergePreviousNumberWithNumberAtIndex:(indexOfInsertionPoint + elements.count)];
        
        [localSelectedRange.fromPosition getIndexPairs:(indexPairs + level)];
        if (indexIntoMergedNumberAtTheBeginning && indexPairs[level][0] == 0) {
            FTAssert_DEBUG(localSelectedRange.fromPosition.numberOfLevels == 1 && indexPairs[level][1] < [((MathNumber *)elements[0]).string length]);
            indexPairs[level][1] += (uint32_t)indexIntoMergedNumberAtTheBeginning;
        }
        else if (indexIntoMergedNumberAtTheEnd && indexPairs[level][0] == elements.count) {
            FTAssert_DEBUG(localSelectedRange.fromPosition.numberOfLevels == 1 && indexPairs[level][1] == 0);
            indexPairs[level][0]--;
            indexPairs[level][1] = (uint32_t)indexIntoMergedNumberAtTheEnd;
        }
        indexPairs[level][0] += (uint32_t)indexOfInsertionPoint;
        MathPosition *fromPosition = [[MathPosition alloc] initWithIndexPairs:indexPairs numberOfLevels:fromNumberOfLevels];
        
        [localSelectedRange.toPosition getIndexPairs:(indexPairs + level)];
        if (indexIntoMergedNumberAtTheBeginning && indexPairs[level][0] == 0) {
            FTAssert_DEBUG(localSelectedRange.toPosition.numberOfLevels == 1 && indexPairs[level][1] < [((MathNumber *)elements[0]).string length]);
            indexPairs[level][1] += (uint32_t)indexIntoMergedNumberAtTheBeginning;
        }
        else if (indexIntoMergedNumberAtTheEnd && indexPairs[level][0] == elements.count) {
            FTAssert_DEBUG(localSelectedRange.toPosition.numberOfLevels == 1 && indexPairs[level][1] == 0);
            indexPairs[level][0]--;
            indexPairs[level][1] = (uint32_t)indexIntoMergedNumberAtTheEnd;
        }
        indexPairs[level][0] += (uint32_t)indexOfInsertionPoint;
        MathPosition *toPosition = [[MathPosition alloc] initWithIndexPairs:indexPairs numberOfLevels:toNumberOfLevels];
        
        return [[MathRange alloc] initFromPosition:fromPosition toPosition:toPosition];
    }
}

- (MathPosition *)deleteBackwardFromPosition:(MathPosition *)position aggressively:(BOOL)aggressively withResult:(out MathExpressionDeletionResult *)outResult
{
    FTAssert(position);
    uint32_t indexPairs[position.numberOfLevels + 1][2];
    [position getIndexPairs:indexPairs];
    MathExpression *lastSelf = nil;
    MathExpression *mySelf = self;
    [mySelf setMutated];
    NSUInteger level;
    for (level = 0; level < position.numberOfLevels - 1; level++) {
        FTAssert_DEBUG(indexPairs[level][0] < mySelf->_elements.count);
        MathElement *element = mySelf->_elements[indexPairs[level][0]];
        FTAssert_DEBUG([element isKindOfClass:[MathCompositeOperator class]]);
        MathCompositeOperator *compositeOperator = (MathCompositeOperator *)element;
        FTAssert_DEBUG(indexPairs[level][1] < compositeOperator.subexpressions.count);
        lastSelf = mySelf;
        mySelf = compositeOperator.subexpressions[indexPairs[level][1]];
        [mySelf setMutated];
    }
    FTAssert_DEBUG(indexPairs[level][0] <= mySelf->_elements.count);
    
    MathExpressionDeletionResult result;
    if (indexPairs[level][1] != 0) {
        //: Within a number.
        FTAssert_DEBUG(indexPairs[level][0] < mySelf->_elements.count);
        MathNumber *theNumber = mySelf->_elements[indexPairs[level][0]];
        FTAssert_DEBUG([theNumber isKindOfClass:[MathNumber class]]);
        FTAssert_DEBUG(indexPairs[level][1] < [theNumber.string length]);
        if (aggressively) {
            [theNumber.string deleteCharactersInRange:NSMakeRange(0, indexPairs[level][1])];
            indexPairs[level][1] = 0;
            result = MathExpressionPartialNumberDeleted;
        }
        else {
            indexPairs[level][1]--;
            [theNumber.string deleteCharactersInRange:NSMakeRange(indexPairs[level][1], 1)];
            result = MathExpressionOneDigitDeleted;
        }
        [theNumber setMutated];
    }
    else {
        //: The previous element is of interest.
        if (indexPairs[level][0] != 0) {
            //: Has previous element (in this level).
            MathElement *previousElement = mySelf->_elements[indexPairs[level][0] - 1];
            if ([previousElement isKindOfClass:[MathNumber class]]) {
                NSMutableString *previousNumberString = ((MathNumber *)previousElement).string;
                FTAssert_DEBUG([previousNumberString length]);
                if (aggressively || [previousNumberString length] == 1) {
                    indexPairs[level][0]--;
                    indexPairs[level][1] = 0;  //$
                    [mySelf->_elements removeObjectAtIndex:indexPairs[level][0]];
                    result = MathExpressionWholeNumberDeleted;
                }
                else {
                    [previousNumberString deleteCharactersInRange:NSMakeRange([previousNumberString length] - 1, 1)];
                    [(MathNumber *)previousElement setMutated];
                    result = MathExpressionOneDigitDeleted;
                }
            }
            else if ([previousElement isKindOfClass:[MathCompositeOperator class]] && ((MathCompositeOperator *)previousElement).subexpressions.count > [(MathCompositeOperator *)previousElement barrier]) {
                NSArray *subexpressions = ((MathCompositeOperator *)previousElement).subexpressions;
                MathExpression *lastSubexpression = [subexpressions lastObject];
                indexPairs[level][0]--;
                indexPairs[level][1] = (uint32_t)(subexpressions.count - 1);
                level++;
                indexPairs[level][0] = (uint32_t)lastSubexpression->_elements.count;
                indexPairs[level][1] = 0;
                result = MathExpressionOnlyCaretShifted;
            }
            else {
                indexPairs[level][0]--;
                indexPairs[level][1] = 0;  //$
                [mySelf->_elements removeObjectAtIndex:indexPairs[level][0]];
                NSUInteger indexIntoMergedNumber = [mySelf mergePreviousNumberWithNumberAtIndex:indexPairs[level][0]];
                if (indexIntoMergedNumber) {
                    indexPairs[level][0]--;
                    indexPairs[level][1] = (uint32_t)indexIntoMergedNumber;
                }
                result = MathExpressionOneOperatorDeleted;
            }
        }
        else {
            //: No previous element (in this level).
            if (level != 0) {
                //: Not the lowest level.
                MathCompositeOperator *compositeOperator = lastSelf->_elements[indexPairs[level - 1][0]];
                if (indexPairs[level - 1][1] > [compositeOperator barrier]) {
                    if ([compositeOperator isKindOfClass:[MathFraction class]]
                        && ((MathExpression *)compositeOperator.subexpressions[1])->_elements.count == 0)
                    {
                        level--;
                        mySelf = lastSelf;
                        NSArray *remainingElements = ((MathExpression *)compositeOperator.subexpressions[0])->_elements;
                        [mySelf->_elements replaceObjectsInRange:NSMakeRange(indexPairs[level][0], 1) withObjectsFromArray:remainingElements];
                        indexPairs[level][1] = 0;
                        NSUInteger indexIntoMergedNumber;
                        indexIntoMergedNumber = [mySelf mergePreviousNumberWithNumberAtIndex:indexPairs[level][0]];
                        if (indexIntoMergedNumber) {
                            indexPairs[level][0]--;
                            indexPairs[level][1] = (uint32_t)indexIntoMergedNumber;
                        }
                        if (remainingElements.count != 0) {
                            indexPairs[level][0] += (uint32_t)remainingElements.count;
                            indexPairs[level][1] = 0;
                            indexIntoMergedNumber = [mySelf mergePreviousNumberWithNumberAtIndex:indexPairs[level][0]];
                            if (indexIntoMergedNumber) {
                                indexPairs[level][0]--;
                                indexPairs[level][1] = (uint32_t)indexIntoMergedNumber;
                            }
                        }
                        result = MathExpressionOneOperatorDeleted;
                    }
                    else {
                        indexPairs[level - 1][1]--;
                        MathExpression *subexpression = compositeOperator.subexpressions[indexPairs[level - 1][1]];
                        indexPairs[level][0] = (uint32_t)subexpression->_elements.count;
                        indexPairs[level][1] = 0;  //$
                        result = MathExpressionOnlyCaretShifted;
                    }
                }
                else if (indexPairs[level - 1][1] == [compositeOperator barrier]) {
                    level--;
                    mySelf = lastSelf;
                    indexPairs[level][1] = 0;
                    if ([compositeOperator isEmpty]) {
                        [mySelf->_elements removeObjectAtIndex:indexPairs[level][0]];
                        NSUInteger indexIntoMergedNumber = [mySelf mergePreviousNumberWithNumberAtIndex:indexPairs[level][0]];
                        if (indexIntoMergedNumber) {
                            indexPairs[level][0]--;
                            indexPairs[level][1] = (uint32_t)indexIntoMergedNumber;
                        }
                        result = MathExpressionOneOperatorDeleted;
                    }
                    else {
                        result = MathExpressionOnlyCaretShifted;
                    }
                }
                else {
                    result = MathExpressionNothingDeleted;
                }
            }
            else {
                //: Already the lowest level.
                result = MathExpressionNothingDeleted;
            }
        }
    }
    
    if (outResult) {
        *outResult = result;
    }
    return result ? [[MathPosition alloc] initWithIndexPairs:indexPairs numberOfLevels:(level + 1)] : position;
}

@end
