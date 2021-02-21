//
//  MathExpression.m
//  iCalculator
//
//  Created by  on 12-6-11.
//  Copyright (c) 2012年 Fish Tribe. All rights reserved.
//

#import "MathExpression.h"
#import "MathEnvironment.h"
#import "MathNumber.h"
#import "MathConcreteOperators.h"


@interface MathPosition () {
    uint32_t (*_indexPairs)[2];
}

@end


@implementation MathPosition

+ (instancetype)positionAtIndex:(uint32_t)index
{
    return [[self alloc] initWithIndexPairs:(uint32_t [][2]){{index, 0}} numberOfLevels:1];
}

- (id)initWithIndexPairs:(const uint32_t (*)[2])indexPairs numberOfLevels:(NSUInteger)numberOfLevels
{
    FTAssert(indexPairs && numberOfLevels);
    self = [super init];
    if (self) {
        _numberOfLevels = numberOfLevels;
        NSUInteger length = sizeof(*_indexPairs) * numberOfLevels;
        _indexPairs = malloc(length);
        if (_indexPairs == NULL) return nil;
        memcpy(_indexPairs, indexPairs, length);
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)decoder
{
    self = [super init];
    if (self) {
        NSUInteger length;
        const uint8_t *bytes = [decoder decodeBytesForKey:@"indexPairs" returnedLength:&length];
        _indexPairs = malloc(length);
        if (_indexPairs == NULL) return nil;
        memcpy(_indexPairs, bytes, length);
        _numberOfLevels = length / sizeof(*_indexPairs);
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)encoder
{
    [encoder encodeBytes:(uint8_t *)_indexPairs length:(sizeof(*_indexPairs) * _numberOfLevels) forKey:@"indexPairs"];  //! endian-dependent
}

- (void)dealloc
{
    free(_indexPairs);
}

- (uint32_t)index
{
    return _indexPairs[self.numberOfLevels - 1][0];
}

- (uint32_t)subindex
{
    return _indexPairs[self.numberOfLevels - 1][1];
}

- (void)getIndexPairs:(uint32_t (*)[2])indexPairs
{
    FTAssert(indexPairs);
    memcpy(indexPairs, _indexPairs, sizeof(*_indexPairs) * self.numberOfLevels);
}

- (MathPosition *)positionByAddingBaseIndexPair:(const uint32_t *)baseIndexPair
{
    FTAssert(baseIndexPair);
    NSUInteger numberOfLevels = self.numberOfLevels + 1;
    uint32_t joinedIndexPairs[numberOfLevels][2];
    joinedIndexPairs[0][0] = baseIndexPair[0];
    joinedIndexPairs[0][1] = baseIndexPair[1];
    [self getIndexPairs:(joinedIndexPairs + 1)];
    return [[MathPosition alloc] initWithIndexPairs:joinedIndexPairs numberOfLevels:numberOfLevels];
}

- (MathPosition *)positionByOffset:(NSInteger)offset
{
    if (offset == 0 && self.subindex == 0) return self;
    
    NSUInteger numberOfLevels = self.numberOfLevels;
    uint32_t indexPairs[numberOfLevels][2];
    [self getIndexPairs:indexPairs];
    NSInteger index = indexPairs[numberOfLevels - 1][0];
    if ((index += offset) < 0) {
        index = 0;
    }
    indexPairs[numberOfLevels - 1][0] = (uint32_t)index;
    indexPairs[numberOfLevels - 1][1] = 0;  //: Always forced to 0 even if offset is 0.
    return [[MathPosition alloc] initWithIndexPairs:indexPairs numberOfLevels:numberOfLevels];
}

- (NSComparisonResult)compare:(MathPosition *)anotherPosition
{
    FTAssert(anotherPosition);
    uint32_t *leftIndexes = (uint32_t *)_indexPairs;
    uint32_t *rightIndexes = (uint32_t *)anotherPosition->_indexPairs;
    NSUInteger minNumberOfIndexes = 2 * MIN(self.numberOfLevels, anotherPosition.numberOfLevels);
    for (NSUInteger i = 0; i < minNumberOfIndexes; i++) {
        if (leftIndexes[i] < rightIndexes[i]) {
            return NSOrderedAscending;
        }
        else if (leftIndexes[i] > rightIndexes[i]) {
            return NSOrderedDescending;
        }
    }
    if (self.numberOfLevels < anotherPosition.numberOfLevels) {
        return NSOrderedAscending;
    }
    else if (self.numberOfLevels > anotherPosition.numberOfLevels) {
        return NSOrderedDescending;
    }
    else {
        return NSOrderedSame;
    }
}

@end


#pragma mark -


@implementation MathRange {
    MathPosition *_selectionStartPosition;
    MathPosition *_selectionEndPosition;
    NSUInteger _selectionLength;
}

- (id)initFromPosition:(MathPosition *)fromPosition toPosition:(MathPosition *)toPosition
{
    FTAssert(fromPosition && toPosition);
    if ([fromPosition compare:toPosition] == NSOrderedDescending) {
        id tmpObj = fromPosition;
        fromPosition = toPosition;
        toPosition = tmpObj;
    }
    self = [super init];
    if (self) {
        _fromPosition = fromPosition;
        _toPosition = toPosition;
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)decoder
{
    self = [super init];
    if (self) {
        _fromPosition = [decoder decodeObjectForKey:@"fromPosition"];
        _toPosition = [decoder decodeObjectForKey:@"toPosition"];
        if (_fromPosition == nil || _toPosition == nil) {
            self = nil;
        }
        else {
            FTAssert_DEBUG([_fromPosition compare:_toPosition] != NSOrderedDescending);
        }
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)encoder
{
    [encoder encodeObject:_fromPosition forKey:@"fromPosition"];
    [encoder encodeObject:_toPosition forKey:@"toPosition"];
}

- (void)determineSelectionRange
{
    FTAssert_DEBUG(_selectionStartPosition == nil && _selectionEndPosition == nil && _selectionLength == 0);  //: Called more than once!
    
    NSUInteger fromNumberOfLevels = self.fromPosition.numberOfLevels;
    uint32_t fromIndexPairs[fromNumberOfLevels][2];
    [self.fromPosition getIndexPairs:fromIndexPairs];
    
    NSUInteger toNumberOfLevels = self.toPosition.numberOfLevels;
    uint32_t toIndexPairs[toNumberOfLevels][2];
    [self.toPosition getIndexPairs:toIndexPairs];
    
    NSUInteger minNumberOfLevels = MIN(fromNumberOfLevels, toNumberOfLevels);
    NSUInteger level;
    for (level = 0; level < minNumberOfLevels; level++) {
        if (fromIndexPairs[level][0] != toIndexPairs[level][0] || fromIndexPairs[level][1] != toIndexPairs[level][1]) break;
    }
    if (level == minNumberOfLevels) {
        level--;
    }
    
    if (fromIndexPairs[level][0] != toIndexPairs[level][0]) {
        //: 'from' and 'to' point to different elements.
        FTAssert_DEBUG(fromIndexPairs[level][0] < toIndexPairs[level][0]);
        if (level == fromNumberOfLevels - 1) {
            //: It can be an element of any kind. Unless it's a MathNumber, the subindex MUST be 0.
            _selectionStartPosition = self.fromPosition;
        }
        else {
            //: It MUST be a MathCompositeOperator.
            fromIndexPairs[level][1] = 0;
            _selectionStartPosition = [[MathPosition alloc] initWithIndexPairs:fromIndexPairs numberOfLevels:(level + 1)];
        }
        
        if (level == toNumberOfLevels - 1) {
            //: It can be an element of any kind. Unless it's a MathNumber, the subindex MUST be 0.
            _selectionEndPosition = self.toPosition;
        }
        else {
            //: It MUST be a MathCompositeOperator.
            toIndexPairs[level][0]++;
            toIndexPairs[level][1] = 0;
            _selectionEndPosition = [[MathPosition alloc] initWithIndexPairs:toIndexPairs numberOfLevels:(level + 1)];
        }
        
        _selectionLength = toIndexPairs[level][0] - fromIndexPairs[level][0] + (toIndexPairs[level][1] ? 1 : 0);
    }
    else if (fromIndexPairs[level][1] != toIndexPairs[level][1]) {
        //: 'from' and 'to' point to the same element, but the subindex is different.
        FTAssert_DEBUG(fromIndexPairs[level][1] < toIndexPairs[level][1]);
        if (level == fromNumberOfLevels - 1 && level == toNumberOfLevels - 1) {
            //: It MUST be a MathNumber.
            _selectionStartPosition = self.fromPosition;
            _selectionEndPosition = self.toPosition;
        }
        else {
            //: It MUST be a MathCompositeOperator.
            if (level == fromNumberOfLevels - 1) {
                FTAssert_DEBUG(fromIndexPairs[level][1] == 0);
                _selectionStartPosition = self.fromPosition;
            }
            else {
                fromIndexPairs[level][1] = 0;
                _selectionStartPosition = [[MathPosition alloc] initWithIndexPairs:fromIndexPairs numberOfLevels:(level + 1)];
            }
            
            FTAssert_DEBUG(level < toNumberOfLevels - 1);
            toIndexPairs[level][0]++;
            toIndexPairs[level][1] = 0;
            _selectionEndPosition = [[MathPosition alloc] initWithIndexPairs:toIndexPairs numberOfLevels:(level + 1)];
        }
        _selectionLength = 1;
    }
    else {
        //: 'from' and 'to' point to the same element, and also have the same subindex.
        FTAssert_DEBUG(level == fromNumberOfLevels - 1 || level == toNumberOfLevels - 1);
        FTAssert_DEBUG(level == fromNumberOfLevels - 1);
        if (level == toNumberOfLevels - 1) {
            //: It can be any element of any type. In fact, the selection degrades to a caret.
            FTAssert_DEBUG([self.fromPosition compare:self.toPosition] == NSOrderedSame);
            _selectionStartPosition = _selectionEndPosition = self.fromPosition;
            _selectionLength = 0;
        }
        else {
            //: It MUST be a MathCompositeOperator.
            FTAssert_DEBUG(fromIndexPairs[level][1] == 0 && toIndexPairs[level][1] == 0);
            _selectionStartPosition = self.fromPosition;
            
            toIndexPairs[level][0]++;
            toIndexPairs[level][1] = 0;  //$
            _selectionEndPosition = [[MathPosition alloc] initWithIndexPairs:toIndexPairs numberOfLevels:(level + 1)];
            
            _selectionLength = 1;
        }
    }
}

- (MathPosition *)selectionStartPosition
{
    if (_selectionStartPosition == nil) {
        [self determineSelectionRange];
    }
    return _selectionStartPosition;
}

- (MathPosition *)selectionEndPosition
{
    if (_selectionStartPosition == nil) {
        [self determineSelectionRange];
    }
    return _selectionEndPosition;
}

- (NSUInteger)selectionLength
{
    if (_selectionStartPosition == nil) {
        [self determineSelectionRange];
    }
    return _selectionLength;
}

@end


#pragma mark -


static
void drawPlaceholder(CGRect placeholderRect)
{
    if (CGRectIsNull(placeholderRect)) return;
    
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    CGContextSaveGState(ctx);
    [[UIColor lightGrayColor] setStroke];
    CGContextStrokeRect(ctx, CGRectInset(placeholderRect, 0.5, 0.5));
    CGContextRestoreGState(ctx);
}


@implementation MathExpression {
    BOOL _answerCacheTag;
    MathResult *_answerCache;
    CGFloat _relRectCacheTag;
    CGRect _relRectCache;
}

+ (instancetype)expressionFromValue:(decQuad)value inDegree:(BOOL)isInDegree
{
    if (isInDegree) {
        decQuadDivide(&value, &value, &Dec_pi_180, &DQ_set);
    }

    NSMutableArray *elements = [NSMutableArray arrayWithCapacity:8];
    switch (decQuadClass(&value)) {
        case_DEC_CLASS_NEG_INF:
        case DEC_CLASS_NEG_INF: {
            [elements addObject:[MathConstant negInf]];
            break;
        }
        case_DEC_CLASS_POS_INF:
        case DEC_CLASS_POS_INF: {
            [elements addObject:[MathConstant posInf]];
            break;
        }
        case DEC_CLASS_QNAN: {
            [elements addObject:[MathConstant nan]];
            break;
        }
        case_DEC_CLASS_ZERO:
        case DEC_CLASS_NEG_ZERO:
        case DEC_CLASS_POS_ZERO: {
            [elements addObject:[[MathNumber alloc] initWithString:@"0"]];
            break;
        }
        case DEC_CLASS_NEG_NORMAL:
        case DEC_CLASS_NEG_SUBNORMAL:
        case DEC_CLASS_POS_NORMAL:
        case DEC_CLASS_POS_SUBNORMAL: {
            /******** underflow & overflow ********/
            static decQuad mag_min, mag_max;
            static dispatch_once_t onceToken;
            dispatch_once(&onceToken, ^{
                decQuadFromString(&mag_min, "4.9406564584124654E-324"/*DBL_TRUE_MIN*/, &DQ_set);
                decQuadFromString(&mag_max, "1.7976931348623157E+308"/*DBL_MAX*/, &DQ_set);
            });
            
            decQuad absValue;
            decQuadCopyAbs(&absValue, &value);
            decQuad tmpDec;
            decQuadCompare(&tmpDec, &absValue, &mag_min, &DQ_set);
            if (decQuadIsNegative(&tmpDec)) {
                goto case_DEC_CLASS_ZERO;
            }
            decQuadCompare(&tmpDec, &absValue, &mag_max, &DQ_set);
            if (decQuadIsPositive(&tmpDec)) {
                if (decQuadIsSigned(&value))
                    goto case_DEC_CLASS_NEG_INF;
                else
                    goto case_DEC_CLASS_POS_INF;
            }
            
            /******** quantize, reduce, & convert to integer if exact ********/
            int maxNumberOfSignificantDigits = [MathEnvironment sharedEnvironment].maximumSignificantDigits;
            int numberOfSignificantDigitsToRoundOff = (int)decQuadDigits(&value) - maxNumberOfSignificantDigits;
            if (numberOfSignificantDigitsToRoundOff > 0) {
                decQuad tmpDec;
                decQuadFromUInt32(&tmpDec, (uint32_t)numberOfSignificantDigitsToRoundOff);
                decQuadScaleB(&tmpDec, &value, &tmpDec, &DQ_set);
                decQuadQuantize(&value, &value, &tmpDec, &DQ_set);
            }
            
            decQuadReduce(&value, &value, &DQ_set);
            
            int exponent = (int)decQuadGetExponent(&value);
            if (exponent > 0 && (int)decQuadDigits(&value) + exponent <= maxNumberOfSignificantDigits) {
                decQuad tmpDec;
                decQuadZero(&tmpDec);
                decQuadQuantize(&value, &value, &tmpDec, &DQ_set);
            }
            
            /******** parse & construct ********/
            char str[DECQUAD_String];
            decQuadToString(&value, str);

            char *p0 = str;
            if (*p0 == '-') {
                [elements addObject:[MathSub sub]];
                p0++;
            }
            char *p;
            for (p = p0 + 1; *p && *p != 'E'; p++);
            if (*p) {
                *p = '\0';
                p++;
            }
            NSString *mantissa = [NSString stringWithCString:p0 encoding:NSASCIIStringEncoding];
            [elements addObject:[[MathNumber alloc] initWithString:mantissa]];
            
            if (*p) {
                [elements addObject:[MathMul mul]];
                [elements addObject:[[MathNumber alloc] initWithString:@"10"]];
                NSMutableArray *exponentElements = [NSMutableArray arrayWithCapacity:2];
                
                if (*p == '-') {
                    [exponentElements addObject:[MathSub sub]];
                }
                p++;  // bypass + or -
                NSString *exponent = [NSString stringWithCString:p encoding:NSASCIIStringEncoding];
                [exponentElements addObject:[[MathNumber alloc] initWithString:exponent]];
                MathExpression *exponentExpression = [[MathExpression alloc] initWithElements:exponentElements];
                [elements addObject:[[MathPow alloc] initWithExponent:exponentExpression]];
            }
            break;
        }
        default: {
            FTAssert_DEBUG(NO);
            return nil;
        }
    }
    
    if (isInDegree && decQuadIsFinite(&value)) {
        [elements addObject:[MathDegree degree]];
    }
    
    return [[self alloc] initWithElements:elements];
}

- (id)initWithElements:(NSArray *)elements
{
    FTAssert(elements);
    self = [super init];
    if (self) {
        _elements = [elements mutableCopy];  //! Needs to consider mutable vs. immutable issue.
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)decoder
{
    self = [super init];
    if (self) {
        _elements = [decoder decodeObjectForKey:@"elements"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)encoder
{
    [encoder encodeObject:_elements forKey:@"elements"];
}

- (id)copyWithZone:(NSZone *)zone
{
    return [[[self class] alloc] initWithElements:[[NSArray alloc] initWithArray:_elements copyItems:YES]];
}

- (NSArray *)elements
{
    return _elements;
}

- (BOOL)isGraphical
{
    for (MathElement *element in _elements) {
        if (element.drawingTrait == MathDrawingGraphicalTrait) {
            return YES;
        }
    }
    return NO;
}

- (MathResult *)evaluate
{
    if (_answerCacheTag) {
        return _answerCache;
    }
    _answerCacheTag = YES;
    
    if (_elements.count == 0) return (_answerCache = nil);

    NSMutableArray *infixExpression = [NSMutableArray arrayWithCapacity:0];
    
    /*** Validate and Preprocess ***/
    BOOL isTextbookConvention = [[NSUserDefaults standardUserDefaults] boolForKey:@"MathPrecedenceTextbookConvention"];
    MathAffinity lastRightAffinity = MathMinimumAffinity;
    BOOL needsReplaceAddSubWithPosNeg = YES;
    for (MathElement *__strong element in _elements) {
        if (needsReplaceAddSubWithPosNeg) {
            if ([element isKindOfClass:[MathSub class]]) {
                element = [MathNeg neg];
            }
            else if ([element isKindOfClass:[MathAdd class]]) {
                element = [MathPos pos];
            }
            else {
                needsReplaceAddSubWithPosNeg = NO;
            }
        }
        if (lastRightAffinity && element.leftAffinity) return (_answerCache = nil);
        if (!lastRightAffinity && !element.leftAffinity) {
            [infixExpression addObject:(isTextbookConvention && !element.rightAffinity ? [MathImplicitMul implicitMul] : [MathMul mul])];  //: sin2π cos2π = sin(2×π) × cos(2×π)
        }
        [infixExpression addObject:element];
        lastRightAffinity = element.rightAffinity;
    }
    if (lastRightAffinity) {  //: sin , ×
        MathElement *theFinalElement = [infixExpression lastObject];
        if (!theFinalElement.leftAffinity) return (_answerCache = nil);  //: sin
    }
    
    /*** Convert Infix-expression to Postfix-expression ***/
    NSMutableArray *postfixExpression = [NSMutableArray arrayWithCapacity:0];
    NSMutableArray *stack = [NSMutableArray arrayWithCapacity:0];
    for (MathElement *element in infixExpression) {
        if (!element.leftAffinity && !element.rightAffinity) {  //: 12 , (1 + 2)
            [postfixExpression addObject:element];
        }
        else {  //: sin , × , %
            if (!element.leftAffinity) {  //: sin
                [stack addObject:element];
            }
            else {  //: × , %
                MathElement *lastElement;
                while ((lastElement = [stack lastObject]) && lastElement.rightAffinity > element.leftAffinity) {
                    [postfixExpression addObject:lastElement];
                    [stack removeLastObject];
                }
                if (!element.rightAffinity) {  //: %
                    [postfixExpression addObject:element];
                }
                else {  //: ×
                    [stack addObject:element];
                }
            }
        }
    }
    if (lastRightAffinity) {  //: ×
        if (stack.count > 1) return (_answerCache = nil);  //: Not the final operation
        [stack removeLastObject];  //$: Discarded
    }
    else {
        MathElement *lastElement;
        while ((lastElement = [stack lastObject])) {
            [postfixExpression addObject:lastElement];
            [stack removeLastObject];
        }
    }
    FTAssert_DEBUG(stack.count == 0);
    
    /*** Evaluate the Postfix-expression ***/
    for (MathElement *element in postfixExpression) {
        MathResult *result;
        
        if ([element isKindOfClass:[MathNumber class]]) {  //: 12
            MathNumber *theNumber = (MathNumber *)element;
            decQuad theNumberValue = theNumber.value;
            result = decQuadIsNaN(&theNumberValue) ? nil : [[MathResult alloc] initWithValue:theNumberValue unitSet:[MathUnitSet none]];
        }
        else {  //: (1 + 2) , sin , × , %
            switch (!!element.leftAffinity + !!element.rightAffinity) {
                case 0: {  //: (1 + 2)
                    result = [(MathOperator *)element operate];
                    break;
                }
                case 1: {  //: sin , %
                    MathResult *operand = [stack lastObject];
                    FTAssert(operand);  //: An invalid expression sneaked in!
                    [stack removeLastObject];
                    result = [(MathOperator *)element operateOnOperand:operand];
                    break;
                }
                case 2: {  //: ×
                    MathResult *rightOperand = [stack lastObject];
                    FTAssert(rightOperand);  //: An invalid expression sneaked in!
                    [stack removeLastObject];
                    MathResult *leftOperand = [stack lastObject];
                    FTAssert(leftOperand);  //: An invalid expression sneaked in!
                    [stack removeLastObject];
                    result = [(MathOperator *)element operateOnLeftOperand:leftOperand rightOperand:rightOperand];
                    break;
                }
            }
        }
        
        if (result == nil) return (_answerCache = nil);
        FTAssert_DEBUG({decQuad resultValue = result.value; !decQuadIsSignaling(&resultValue);});
        [stack addObject:result];
    }
    FTAssert(stack.count == 1);  //: An invalid expression sneaked in!
    return (_answerCache = [stack lastObject]);
}

- (void)setMutated
{
    _answerCacheTag = NO;
    _relRectCacheTag = 0.0;
}

- (void)resetCache
{
    _answerCacheTag = NO;
    _relRectCacheTag = 0.0;
    
    for (MathElement *element in _elements) {
        [element resetCache];
    }
}

- (CGRect)rectWhenDrawAtPoint:(CGPoint)origin withFontSize:(CGFloat)fontSize
{
    if (_relRectCacheTag == fontSize) {
        return CGRectOffset(_relRectCache, origin.x, origin.y);
    }
    
    MathDrawingContext *context = [[MathDrawingContext alloc] initWithExpression:self toDrawAtOrigin:CGPointZero withFontSize:fontSize];
    CGRect relRect = CGRectNull;
    MathElement *element;
    while ((element = [context nextElement])) {
        relRect = CGRectUnion(relRect, context.precedingPlaceholderRect);
        CGRect elementRect = [element rectWhenDrawWithContext:context];
        relRect = CGRectUnion(relRect, elementRect);
        [context advanceByCurrentElementRect:elementRect];
    }
    relRect = CGRectUnion(relRect, context.precedingPlaceholderRect);
    _relRectCache = relRect;
    _relRectCacheTag = fontSize;
    return CGRectOffset(_relRectCache, origin.x, origin.y);
}

- (CGRect)drawAtPoint:(CGPoint)origin withFontSize:(CGFloat)fontSize
{
    MathDrawingContext *context = [[MathDrawingContext alloc] initWithExpression:self toDrawAtOrigin:origin withFontSize:fontSize];
    MathElement *element;
    while ((element = [context nextElement])) {
        drawPlaceholder(context.precedingPlaceholderRect);
        [context advanceByCurrentElementRect:[element drawWithContext:context]];
    }
    drawPlaceholder(context.precedingPlaceholderRect);
    
    return [self rectWhenDrawAtPoint:origin withFontSize:fontSize];
}

- (MathPosition *)hitTest:(CGPoint)hitPoint byDistance:(out CGFloat *)outDistance whenDrawAtPoint:(CGPoint)origin withFontSize:(CGFloat)fontSize
{
    MathPosition *closestPosition = nil;
    CGFloat shortestDistance = 1.0 / 0.0;
    
    MathDrawingContext *context = [[MathDrawingContext alloc] initWithExpression:self toDrawAtOrigin:origin withFontSize:fontSize];
    MathElement *element;
    uint32_t indexPair[2] = {0, 0};
    while ((element = [context nextElement])) {
        CGRect elementRect = CGRectStandardize([element rectWhenDrawWithContext:context]);
        CGFloat widthInset = 0.0, heightInset = 0.0;
        if (elementRect.size.width < 44.0) {
            widthInset = (elementRect.size.width - 44.0) / 2.0;
        }
        if (elementRect.size.height < 44.0) {
            heightInset = (elementRect.size.height - 44.0) / 2.0;
        }
        CGRect extendedElementRect = CGRectInset(elementRect, widthInset, heightInset);
        if (CGRectContainsPoint(extendedElementRect, hitPoint)) {
            BOOL hasHitSubexpression = NO;
            if ([element isKindOfClass:[MathCompositeOperator class]]) {
                MathCompositeOperator *compositeOperator = (MathCompositeOperator *)element;
                for (MathExpression *subexpression in compositeOperator.subexpressions) {
                    CGPoint suborigin = [compositeOperator originOfSubexpressionAtIndex:indexPair[1] whenDrawWithContext:context];
                    CGFloat subfontSize = [compositeOperator fontSizeOfSubexpressionAtIndex:indexPair[1] whenDrawWithContext:context];
                    CGFloat distance;
                    MathPosition *subposition = [subexpression hitTest:hitPoint byDistance:&distance whenDrawAtPoint:suborigin withFontSize:subfontSize];
                    if (subposition) {
                        hasHitSubexpression = YES;
                        if (distance < shortestDistance) {
                            closestPosition = [subposition positionByAddingBaseIndexPair:indexPair];
                            shortestDistance = distance;
                        }
                    }
                    else if (!hasHitSubexpression) {
                        if (CGRectContainsPoint([subexpression rectWhenDrawAtPoint:suborigin withFontSize:subfontSize], hitPoint)) {
                            hasHitSubexpression = YES;
                        }
                    }
                    indexPair[1]++;
                }
                indexPair[1] = 0;
            }
            if (!hasHitSubexpression) {
                CGFloat distance = hypot(CGRectGetMidX(elementRect) - hitPoint.x, CGRectGetMidY(elementRect) - hitPoint.y);
                if (distance < shortestDistance) {
                    closestPosition = [[MathPosition alloc] initWithIndexPairs:&indexPair numberOfLevels:1];
                    shortestDistance = distance;
                }
            }
        }
        else if (hitPoint.x < CGRectGetMinX(extendedElementRect)) {
            break;
        }
        [context advanceByCurrentElementRect:elementRect];
        indexPair[0]++;
    }
    
    if (outDistance) {
        *outDistance = shortestDistance;
    }
    return closestPosition;
}

- (MathDrawingContext *)contextAtPosition:(MathPosition *)position whenDrawAtPoint:(CGPoint)origin withFontSize:(CGFloat)fontSize
{
    FTAssert(position);
    uint32_t indexPairs[position.numberOfLevels][2];
    [position getIndexPairs:indexPairs];
    MathExpression *mySelf = self;
    for (NSUInteger level = 0; ; level++) {
        FTAssert_DEBUG(indexPairs[level][0] <= mySelf->_elements.count);
        MathDrawingContext *context = [[MathDrawingContext alloc] initWithExpression:mySelf toDrawAtOrigin:origin withFontSize:fontSize];
        
        MathElement *element = [context nextElement];
        while (context.index < indexPairs[level][0]) {
            FTAssert_DEBUG(element);
            [context advanceByCurrentElementRect:[element rectWhenDrawWithContext:context]];
            element = [context nextElement];
        }
        
        if (level == position.numberOfLevels - 1) return context;
        
        FTAssert_DEBUG([element isKindOfClass:[MathCompositeOperator class]]);
        MathCompositeOperator *compositeOperator = (MathCompositeOperator *)element;
        FTAssert_DEBUG(indexPairs[level][1] < compositeOperator.subexpressions.count);
        mySelf = compositeOperator.subexpressions[indexPairs[level][1]];
        origin = [compositeOperator originOfSubexpressionAtIndex:indexPairs[level][1] whenDrawWithContext:context];
        fontSize = [compositeOperator fontSizeOfSubexpressionAtIndex:indexPairs[level][1] whenDrawWithContext:context];
    }
}

- (CGRect)selectionRectForRange:(MathRange *)range whenDrawAtPoint:(CGPoint)origin withFontSize:(CGFloat)fontSize
{
    FTAssert(range);
    if (range.selectionLength == 0) {
        FTAssert_DEBUG(NO);  //: Degraded range!
        return CGRectNull;
    }
    
    MathDrawingContext *context = [self contextAtPosition:range.selectionStartPosition whenDrawAtPoint:origin withFontSize:fontSize];
    MathElement *element = context.currentElement;
    CGRect selectionRect = context.precedingPlaceholderRect;
    UIEdgeInsets partialNumberInsets = UIEdgeInsetsZero;
    
    if (range.selectionStartPosition.subindex != 0) {
        FTAssert_DEBUG([element isKindOfClass:[MathNumber class]]);
        MathNumber *theNumber = (MathNumber *)element;
        FTAssert_DEBUG(range.selectionStartPosition.subindex < [theNumber.string length]);
        partialNumberInsets.left = floor([theNumber offsetForIndex:range.selectionStartPosition.subindex whenDrawWithFontSize:context.fontSize]);
    }
    
    do {
        FTAssert_DEBUG(element);
        CGRect elementRect = [element rectWhenDrawWithContext:context];
        selectionRect = CGRectUnion(selectionRect, elementRect);
        [context advanceByCurrentElementRect:elementRect];
        element = [context nextElement];
        selectionRect = CGRectUnion(selectionRect, context.precedingPlaceholderRect);
    } while (context.index < range.selectionStartPosition.index + range.selectionLength);
    
    if (range.selectionEndPosition.subindex != 0) {
        FTAssert_DEBUG([context.previousElement isKindOfClass:[MathNumber class]]);
        MathNumber *theNumber = (MathNumber *)context.previousElement;
        FTAssert_DEBUG(range.selectionEndPosition.subindex < [theNumber.string length]);
        partialNumberInsets.right = CGRectGetWidth(context.previousElementRect) - ceil([theNumber offsetForIndex:range.selectionEndPosition.subindex whenDrawWithFontSize:context.fontSize]);
    }
    
    return UIEdgeInsetsInsetRect(selectionRect, partialNumberInsets);
}

- (BOOL)validatePosition:(MathPosition *)position
{
    if (position == nil) return NO;
    
    uint32_t indexPairs[position.numberOfLevels][2];
    [position getIndexPairs:indexPairs];
    MathExpression *mySelf = self;
    NSUInteger level;
    for (level = 0; level < position.numberOfLevels - 1; level++) {
        if (indexPairs[level][0] >= mySelf->_elements.count) return NO;
        MathElement *element = mySelf->_elements[indexPairs[level][0]];
        if (![element isKindOfClass:[MathCompositeOperator class]]) return NO;
        MathCompositeOperator *compositeOperator = (MathCompositeOperator *)element;
        if (indexPairs[level][1] >= compositeOperator.subexpressions.count) return NO;
        mySelf = compositeOperator.subexpressions[indexPairs[level][1]];
    }
    if (indexPairs[level][0] > mySelf->_elements.count) return NO;
    return YES;
}

- (MathExpression *)subexpressionAtPosition:(MathPosition *)position
{
    FTAssert(position);
    uint32_t indexPairs[position.numberOfLevels][2];
    [position getIndexPairs:indexPairs];
    MathExpression *mySelf = self;
    NSUInteger level;
    for (level = 0; level < position.numberOfLevels - 1; level++) {
        FTAssert_DEBUG(indexPairs[level][0] < mySelf->_elements.count);
        MathElement *element = mySelf->_elements[indexPairs[level][0]];
        FTAssert_DEBUG([element isKindOfClass:[MathCompositeOperator class]]);
        MathCompositeOperator *compositeOperator = (MathCompositeOperator *)element;
        FTAssert_DEBUG(indexPairs[level][1] < compositeOperator.subexpressions.count);
        mySelf = compositeOperator.subexpressions[indexPairs[level][1]];
    }
    FTAssert_DEBUG(indexPairs[level][0] <= mySelf->_elements.count);
    return mySelf;
}

- (NSArray *)elementsInRange:(MathRange *)range
{
    FTAssert(range);
    if (range.selectionLength == 0) return @[];
    
    MathExpression *subexpression = [self subexpressionAtPosition:range.selectionStartPosition];
    if (range.selectionLength == 1 && range.selectionStartPosition.subindex != 0 && range.selectionEndPosition.subindex != 0) {
        FTAssert_DEBUG(range.selectionStartPosition.index == range.selectionEndPosition.index);
        MathNumber *theNumber = subexpression->_elements[range.selectionStartPosition.index];
        FTAssert_DEBUG([theNumber isKindOfClass:[MathNumber class]]);
        FTAssert_DEBUG(range.selectionStartPosition.subindex < range.selectionEndPosition.subindex && range.selectionEndPosition.subindex < [theNumber.string length]);
        return @[[[MathNumber alloc] initWithString:[theNumber.string substringWithRange:NSMakeRange(range.selectionStartPosition.subindex, range.selectionEndPosition.subindex - range.selectionStartPosition.subindex)]]];
    }
    else {
        NSMutableArray *selectedElements = [NSMutableArray arrayWithArray:[subexpression->_elements subarrayWithRange:NSMakeRange(range.selectionStartPosition.index, range.selectionLength)]];
        if (range.selectionStartPosition.subindex != 0) {
            MathNumber *theNumber = selectedElements[0];
            FTAssert_DEBUG([theNumber isKindOfClass:[MathNumber class]]);
            FTAssert_DEBUG(range.selectionStartPosition.subindex < [theNumber.string length]);
            selectedElements[0] = [[MathNumber alloc] initWithString:[theNumber.string substringFromIndex:range.selectionStartPosition.subindex]];
        }
        if (range.selectionEndPosition.subindex != 0) {
            FTAssert_DEBUG(range.selectionEndPosition.index - range.selectionStartPosition.index + 1 == range.selectionLength);
            MathNumber *theNumber = [selectedElements lastObject];
            FTAssert_DEBUG([theNumber isKindOfClass:[MathNumber class]]);
            FTAssert_DEBUG(range.selectionEndPosition.subindex < [theNumber.string length]);
            [selectedElements removeLastObject];
            [selectedElements addObject:[[MathNumber alloc] initWithString:[theNumber.string substringToIndex:range.selectionEndPosition.subindex]]];
        }
        return selectedElements;
    }
}

@end
