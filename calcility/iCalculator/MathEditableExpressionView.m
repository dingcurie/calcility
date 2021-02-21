//
//  MathEditableExpressionView.m
//  iCalculator
//
//  Created by curie on 12-12-31.
//  Copyright (c) 2012年 Fish Tribe. All rights reserved.
//

#import "MathEditableExpressionView.h"
#import "MathExpression+Editing.h"
#import "MathNumber.h"
#import "MathConcreteOperators.h"
#import "FTInputSystem.h"
#import "FTLoupe.h"
#import "FTBarLens.h"


@interface MathEditableExpressionView () <UIGestureRecognizerDelegate>

@property (nonatomic, getter = isDeleting) BOOL deleting;
@property (nonatomic, weak, readonly) UILongPressGestureRecognizer *tapThenPressGestureRecognizer;
@property (nonatomic, weak, readonly) UITapGestureRecognizer *tripleTapGestureRecognizer;

@end


#define AUTO_SCROLL_DELAY           0.1
#define AUTO_UNDOCHECKPOINT_DELAY   3.0


@implementation MathEditableExpressionView {
    NSUndoManager *_undoManager;
    BOOL _isUndoCheckpointSet;
    
    MathPosition *_previousPosition;
}

- (void)MathEditableExpressionView_init
{
    [super setExpression:[[MathExpression alloc] initWithElements:@[]]];
    [super setFontSize:30.0];
    [super setInsets:(g_isPhone ? UIEdgeInsetsMake(18, 10, 18, 30) : UIEdgeInsetsMake(25, 15, 25, 40))];

    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(respondToTapGesture:)];
    [super addGestureRecognizer:tapGestureRecognizer];
    
    UILongPressGestureRecognizer *longPressGestureRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(respondToLongPressGesture:)];
    [super addGestureRecognizer:(_longPressGestureRecognizer = longPressGestureRecognizer)];
    
    UITapGestureRecognizer *tripleTapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(respondToTripleTapGesture:)];
    tripleTapGestureRecognizer.numberOfTapsRequired = 3;
    tripleTapGestureRecognizer.delegate = self;
    [super addGestureRecognizer:(_tripleTapGestureRecognizer = tripleTapGestureRecognizer)];
    
    UILongPressGestureRecognizer *tapThenPressGestureRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(respondToTapThenPressGesture:)];
    tapThenPressGestureRecognizer.numberOfTapsRequired = 1;
    tapThenPressGestureRecognizer.minimumPressDuration = 0.0;
    tapThenPressGestureRecognizer.delegate = self;
    [super addGestureRecognizer:(_tapThenPressGestureRecognizer = tapThenPressGestureRecognizer)];
    
    [self setUndoCheckpoint];
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [super setUserInteractionEnabled:YES];
        
        [self MathEditableExpressionView_init];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)decoder
{
    self = [super initWithCoder:decoder];
    if (self) {
        [self MathEditableExpressionView_init];
    }
    return self;
}

//! WORKAROUND: -layoutSubviews is not called when size is changed via -layoutIfNeeded in -editableExpressionViewDidChange:.
- (void)setBounds:(CGRect)bounds
{
    if (!CGRectEqualToRect(self.bounds, bounds)) {
        [self setNeedsLayout];
    }
    
    [super setBounds:bounds];
}

- (void)setSelectedRange:(MathRange *)aRange
{
    FTAssert(aRange);
    if ([self.delegate respondsToSelector:@selector(editableExpressionViewWillChangeSelection:)]) {
        [self.delegate editableExpressionViewWillChangeSelection:self];
    }
    
    [super setSelectedRange:aRange];
    if ([self isFirstResponder]) {
        [[MathKeyboard sharedKeyboard] my_refresh];
    }
    
    if ([self.delegate respondsToSelector:@selector(editableExpressionViewDidChangeSelection:)]) {
        [self.delegate editableExpressionViewDidChangeSelection:self];
    }
}

- (void)setHighlightView:(MathExpressionView *)highlightView
{
    if (_highlightView) {
        [_highlightView removeFromSuperview];
    }
    
    if ((_highlightView = highlightView)) {
        [self addSubview:_highlightView];
    }
}

#pragma mark -

- (BOOL)becomeFirstResponder
{
    if ([super becomeFirstResponder]) {
        if ([self.delegate respondsToSelector:@selector(editableExpressionViewDidBecomeFirstResponder:)]) {
            [self.delegate editableExpressionViewDidBecomeFirstResponder:self];
        }
        [[MathKeyboard sharedKeyboard] my_refresh];
        return YES;
    }
    return NO;
}

- (BOOL)resignFirstResponder
{
    if ([super resignFirstResponder]) {
        if ([self.delegate respondsToSelector:@selector(editableExpressionViewDidResignFirstResponder:)]) {
            [self.delegate editableExpressionViewDidResignFirstResponder:self];
        }
        [[MathKeyboard sharedKeyboard] my_refresh];
        return YES;
    }
    return NO;
}

- (CGRect)caretFrame
{
    return self.selectedRange.selectionLength ? CGRectNull : [self.expression caretRectForPosition:self.selectedRange.selectionStartPosition whenDrawAtPoint:CGPointZero withFontSize:self.fontSize];
}

- (FTSelectionSuiteMode)selectionSuiteMode
{
    return FTSelectionSuiteModeLine;
}

- (BOOL)shouldPreservedWhenUnregistered
{
    return YES;
}

- (BOOL)canPerformAction:(SEL)action withSender:(id)sender
{
    UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
    
    if (action == @selector(selectAll:)) {
        if (self.selectedRange.selectionLength == 0 && self.expression.elements.count) {
            return YES;
        }
        return NO;
    }
    else if (action == @selector(copy:) || action == @selector(cut:)) {
        if (self.selectedRange.selectionLength) {
            return YES;
        }
        return NO;
    }
    else if (action == @selector(paste:)) {
        if ([pasteboard containsPasteboardTypes:@[@"com.fishtribe.math.elements"]]) {
            return YES;
        }
        NSString *string = [pasteboard.string copy];
        string = [string stringByReplacingOccurrencesOfString:@"[\\s,]" withString:@"" options:NSRegularExpressionSearch range:NSMakeRange(0, string.length)];
        if (string.length) {
            NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"^(?:\\+|[\\-−])?[0-9.]" options:0 error:NULL];
            if ([regex rangeOfFirstMatchInString:string options:0 range:NSMakeRange(0, string.length)].length) {
                return YES;
            }
        }
        return NO;
    }
    else {
        return [super canPerformAction:action withSender:sender];
    }
}

- (void)selectAll:(id)sender
{
    self.selectedRange = [[MathRange alloc] initFromPosition:[MathPosition positionAtIndex:0] toPosition:[MathPosition positionAtIndex:(uint32_t)self.expression.elements.count]];
    [self my_showEditingMenu];
}

- (void)cut:(id)sender
{
    [self copy:sender];
    
    [self setUndoCheckpoint];
    [self replaceElementsInRange:self.selectedRange withElements:@[] localSelectedRange:nil];
}

- (void)paste:(id)sender
{
    NSArray *elements = nil;
    
    UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
    NSData *data = [pasteboard dataForPasteboardType:@"com.fishtribe.math.elements"];
    if (data) {
        elements = [NSKeyedUnarchiver unarchiveObjectWithData:data];
    }
    else {
        NSString *string = [pasteboard.string copy];
        string = [string stringByReplacingOccurrencesOfString:@"[\\s,]" withString:@"" options:NSRegularExpressionSearch range:NSMakeRange(0, string.length)];
        if (string.length) {
            NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"^(?:\\+|([\\-−]))?([0-9.]+)(?:[Ee](?:\\+|([\\-−]))?([0-9.]+))?(°?)" options:0 error:NULL];
            NSTextCheckingResult *match = [regex firstMatchInString:string options:0 range:NSMakeRange(0, string.length)];
            FTAssert_DEBUG(match, string);
            elements = [NSMutableArray arrayWithCapacity:6];
            NSRange range;
            if ((range = [match rangeAtIndex:2]).length) {
                if ([match rangeAtIndex:1].length) {
                    [(NSMutableArray *)elements addObject:[MathSub sub]];
                }
                [(NSMutableArray *)elements addObject:[[MathNumber alloc] initWithString:[string substringWithRange:range]]];
            }
            if ((range = [match rangeAtIndex:4]).length) {
                [(NSMutableArray *)elements addObject:[MathMul mul]];
                [(NSMutableArray *)elements addObject:[[MathNumber alloc] initWithString:@"10"]];
                NSMutableArray *exponentElements = [NSMutableArray arrayWithCapacity:2];
                if ([match rangeAtIndex:3].length) {
                    [exponentElements addObject:[MathSub sub]];
                }
                [exponentElements addObject:[[MathNumber alloc] initWithString:[string substringWithRange:range]]];
                [(NSMutableArray *)elements addObject:[[MathPow alloc] initWithExponent:[[MathExpression alloc] initWithElements:exponentElements]]];
            }
            if ([match rangeAtIndex:5].length) {
                [(NSMutableArray *)elements addObject:[MathDegree degree]];
            }
        }
    }
    
    if (elements.count) {
        [self setUndoCheckpoint];
        [self replaceElementsInRange:self.selectedRange withElements:elements localSelectedRange:nil];
    }
    else {
        FTAssert_DEBUG(NO);
    }
}

#pragma mark -

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self my_becomeFirstResponderIfNotAlready];
    [super touchesBegan:touches withEvent:event];
}

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer
{
    return [self isFirstResponder];
}

- (void)respondToTapGesture:(UITapGestureRecognizer *)tapGestureRecognizer
{
    CGPoint location = [tapGestureRecognizer locationInView:self];
    MathPosition *position = [self.expression closestPositionToPoint:location byDistance:NULL whenDrawAtPoint:CGPointZero withFontSize:self.fontSize];
    
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(my_showEditingMenu) object:nil];
    UIMenuController *menuController = [UIMenuController sharedMenuController];
    if (self.selectedRange.selectionLength == 0 && [self.selectedRange.selectionStartPosition compare:position] == NSOrderedSame) {
        if ([menuController isMenuVisible]) {
            [menuController setMenuVisible:NO animated:YES];
        }
        else {
            [self performSelector:@selector(my_showEditingMenu) withObject:nil afterDelay:0.25];
        }
    }
    else {
        [menuController setMenuVisible:NO animated:YES];
        self.selectedRange = [[MathRange alloc] initFromPosition:position toPosition:position];
        [self setUndoCheckpoint];
    }
}

- (void)respondToLongPressGesture:(UILongPressGestureRecognizer *)longPressGestureRecognizer
{
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:_cmd object:longPressGestureRecognizer];
    
    CGPoint location = [longPressGestureRecognizer locationInView:self];
    MathPosition *position = [self.expression closestPositionToPoint:location byDistance:NULL whenDrawAtPoint:CGPointZero withFontSize:self.fontSize];
    
    CGPoint magnifyingCenter = location;
    if ([self.delegate respondsToSelector:@selector(editableExpressionView:willSetLoupeMagnifyingCenter:inView:)]) {
        magnifyingCenter = [self.delegate editableExpressionView:self willSetLoupeMagnifyingCenter:magnifyingCenter inView:self];
    }
    
    switch (longPressGestureRecognizer.state) {
        case UIGestureRecognizerStateBegan: {
            [self setUndoCheckpoint];
            self.selectedRange = [[MathRange alloc] initFromPosition:position toPosition:position];
            [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(my_showEditingMenu) object:nil];
            [[UIMenuController sharedMenuController] setMenuVisible:NO animated:YES];
            [[FTLoupe sharedLoupe] setMagnifyingCenter:magnifyingCenter inView:self];
            [FTLoupe sharedLoupe].hidden = NO;
            break;
        }
        case UIGestureRecognizerStateChanged: {
            self.selectedRange = [[MathRange alloc] initFromPosition:position toPosition:position];
            [[FTLoupe sharedLoupe] setMagnifyingCenter:magnifyingCenter inView:self];
            if ([self.delegate respondsToSelector:@selector(editableExpressionView:scrollForTrackingPoint:)]) {
                static BOOL s_nested;
                if (s_nested) {
                    [self performSelector:_cmd withObject:longPressGestureRecognizer afterDelay:AUTO_SCROLL_DELAY];
                }
                else if ([self.delegate editableExpressionView:self scrollForTrackingPoint:location]) {
                    s_nested = YES;
                    [self respondToLongPressGesture:longPressGestureRecognizer];
                    s_nested = NO;
                }
            }
            break;
        }
        case UIGestureRecognizerStateCancelled:
        case UIGestureRecognizerStateEnded: {
            [FTLoupe sharedLoupe].hidden = YES;
            [self my_showEditingMenu];
            break;
        }
        default: {
            FTAssert_DEBUG(NO, longPressGestureRecognizer);
            break;
        }
    }
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    if (gestureRecognizer == self.tapThenPressGestureRecognizer && otherGestureRecognizer == self.tripleTapGestureRecognizer) {
        return YES;
    }
    return NO;
}

- (void)showBarLens
{
    [FTBarLens sharedBarLens].hidden = NO;
}

- (void)respondToTapThenPressGesture:(UILongPressGestureRecognizer *)longPressGestureRecognizer
{
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:_cmd object:longPressGestureRecognizer];
    
    static MathPosition *s_initialFromPosition;
    static MathPosition *s_initialToPosition;
    CGPoint location = [longPressGestureRecognizer locationInView:self];
    switch (longPressGestureRecognizer.state) {
        case UIGestureRecognizerStateBegan: {
            FTAssert_DEBUG(_previousPosition == nil);
            MathPosition *position = [self.expression hitTest:location byDistance:NULL whenDrawAtPoint:CGPointZero withFontSize:self.fontSize];
            if ((_previousPosition = position)) {
                self.selectedRange = [[MathRange alloc] initFromPosition:position toPosition:[position positionByOffset:1]];
                s_initialFromPosition = self.selectedRange.fromPosition;
                s_initialToPosition = self.selectedRange.toPosition;
                [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(my_showEditingMenu) object:nil];
                [[UIMenuController sharedMenuController] setMenuVisible:NO animated:YES];
                [[FTBarLens sharedBarLens] setLocation:location inView:self];
                [self performSelector:@selector(showBarLens) withObject:nil afterDelay:0.25];
            }
            break;
        }
        case UIGestureRecognizerStateChanged: {
            if (_previousPosition) {
                MathPosition *position = [self.expression closestPositionToPoint:location byDistance:NULL whenDrawAtPoint:CGPointZero withFontSize:self.fontSize];
                if ([position compare:_previousPosition] != NSOrderedSame) {
                    if ([s_initialToPosition compare:position] != NSOrderedDescending) {
                        self.selectedRange = [[MathRange alloc] initFromPosition:s_initialFromPosition toPosition:(position.subindex ? [position positionByOffset:1] : position)];
                    }
                    else if ([position compare:s_initialFromPosition] != NSOrderedDescending) {
                        self.selectedRange = [[MathRange alloc] initFromPosition:[position positionByOffset:0] toPosition:s_initialToPosition];
                    }
                    _previousPosition = position;
                }
                [[FTBarLens sharedBarLens] setLocation:location inView:self];
                if ([[FTBarLens sharedBarLens] isHidden]) {
                    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(showBarLens) object:nil];
                    [FTBarLens sharedBarLens].hidden = NO;
                }
                if ([self.delegate respondsToSelector:@selector(editableExpressionView:scrollForTrackingPoint:)]) {
                    static BOOL s_nested;
                    if (s_nested) {
                        [self performSelector:_cmd withObject:longPressGestureRecognizer afterDelay:AUTO_SCROLL_DELAY];
                    }
                    else if ([self.delegate editableExpressionView:self scrollForTrackingPoint:location]) {
                        s_nested = YES;
                        [self respondToTapThenPressGesture:longPressGestureRecognizer];
                        s_nested = NO;
                    }
                }
            }
            break;
        }
        case UIGestureRecognizerStateCancelled:
        case UIGestureRecognizerStateEnded: {
            if (_previousPosition) {
                self.selectedRange = [[MathRange alloc] initFromPosition:self.selectedRange.selectionStartPosition toPosition:self.selectedRange.selectionEndPosition];
                _previousPosition = nil;
                s_initialFromPosition = nil;
                s_initialToPosition = nil;
                [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(showBarLens) object:nil];
                [FTBarLens sharedBarLens].hidden = YES;
                [self performSelector:@selector(my_showEditingMenu) withObject:nil afterDelay:0.25];
            }
            break;
        }
        default: {
            FTAssert_DEBUG(NO, longPressGestureRecognizer);
            break;
        }
    }
}

- (void)respondToTripleTapGesture:(UITapGestureRecognizer *)tapGestureRecognizer
{    
    CGPoint location = [tapGestureRecognizer locationInView:self];
    MathPosition *position = [self.expression hitTest:location byDistance:NULL whenDrawAtPoint:CGPointZero withFontSize:self.fontSize];
    if (position) {
        MathExpression *subexpression = [self.expression subexpressionAtPosition:position];
        self.selectedRange = [[MathRange alloc] initFromPosition:[position positionByOffset:-9999] toPosition:[position positionByOffset:(subexpression.elements.count - position.index)]];
        [self layoutIfNeeded];
        [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(my_showEditingMenu) object:nil];
        [self my_showEditingMenu];
    }
}

- (void)acceptPreviousPositionForSelectionHandle:(FTSelectionHandle *)selectionHandle
{
    FTAssert(_previousPosition);
    if (selectionHandle.type == FTSelectionHandleTypeStart) {
        FTAssert_DEBUG([_previousPosition compare:self.selectedRange.toPosition] == NSOrderedAscending);
        self.selectedRange = [[MathRange alloc] initFromPosition:_previousPosition toPosition:self.selectedRange.toPosition];
    }
    else {
        FTAssert_DEBUG([self.selectedRange.fromPosition compare:_previousPosition] == NSOrderedAscending);
        self.selectedRange = [[MathRange alloc] initFromPosition:self.selectedRange.fromPosition toPosition:_previousPosition];
    }
    [[FTBarLens sharedBarLens] my_refresh];
}

- (void)invokeSelectionHandleRespondToPressGesture:(NSArray *)args
{
    [self selectionHandle:args[0] respondToPressGesture:args[1]];
}

- (void)selectionHandle:(FTSelectionHandle *)selectionHandle respondToPressGesture:(UILongPressGestureRecognizer *)longPressGestureRecognizer
{
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:_cmd object:longPressGestureRecognizer];

    static CGPoint s_locationOffset;
    CGPoint location = [longPressGestureRecognizer locationInView:self];
    
    switch (longPressGestureRecognizer.state) {
        case UIGestureRecognizerStateBegan: {
            CGPoint effectiveLocation = [selectionHandle convertPoint:selectionHandle.pole.center toView:self];
            s_locationOffset = CGPointMake(effectiveLocation.x - location.x, effectiveLocation.y - location.y);
            FTAssert_DEBUG(_previousPosition == nil);
            if (selectionHandle.type == FTSelectionHandleTypeStart) {
                _previousPosition = self.selectedRange.selectionStartPosition;
            }
            else {
                _previousPosition = self.selectedRange.selectionEndPosition;
            }
            [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(my_showEditingMenu) object:nil];
            [[UIMenuController sharedMenuController] setMenuVisible:NO animated:YES];
            [[FTBarLens sharedBarLens] setLocation:effectiveLocation inView:self];
            [self performSelector:@selector(showBarLens) withObject:nil afterDelay:0.25];
            break;
        }
        case UIGestureRecognizerStateChanged: {
            CGPoint effectiveLocation = CGPointMake(location.x + s_locationOffset.x, location.y + s_locationOffset.y);
            MathPosition *position = [self.expression closestPositionToPoint:effectiveLocation byDistance:NULL whenDrawAtPoint:CGPointZero withFontSize:self.fontSize];
            if ([position compare:_previousPosition] != NSOrderedSame) {
                [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(acceptPreviousPositionForSelectionHandle:) object:selectionHandle];
                
                BOOL positionIsAcceptable;
                if (selectionHandle.type == FTSelectionHandleTypeStart) {
                    positionIsAcceptable = [position compare:self.selectedRange.toPosition] == NSOrderedAscending;
                }
                else {
                    positionIsAcceptable = [self.selectedRange.fromPosition compare:position] == NSOrderedAscending;
                }
                if (positionIsAcceptable) {
                    BOOL needsDelayToAccept = NO;
                    if (position.subindex != 0) {
                        MathExpression *subexpression = [self.expression subexpressionAtPosition:position];
                        FTAssert_DEBUG([subexpression.elements[position.index] isKindOfClass:[MathNumber class]]);
                        BOOL fromPositionNotInThatNumber = self.selectedRange.fromPosition.subindex == 0 || self.selectedRange.fromPosition.index != position.index || [self.expression subexpressionAtPosition:self.selectedRange.fromPosition] != subexpression;
                        BOOL toPositionNotInThatNumber = self.selectedRange.toPosition.subindex == 0 || self.selectedRange.toPosition.index != position.index || [self.expression subexpressionAtPosition:self.selectedRange.toPosition] != subexpression;
                        if (fromPositionNotInThatNumber && toPositionNotInThatNumber) {
                            needsDelayToAccept = YES;
                        }
                    }
                    if (needsDelayToAccept) {
                        FTAssert_DEBUG(position.subindex != 0);
                        if (selectionHandle.type == FTSelectionHandleTypeStart) {
                            self.selectedRange = [[MathRange alloc] initFromPosition:[position positionByOffset:0] toPosition:self.selectedRange.toPosition];
                        }
                        else {
                            self.selectedRange = [[MathRange alloc] initFromPosition:self.selectedRange.fromPosition toPosition:[position positionByOffset:1]];
                        }
                        
                        [self performSelector:@selector(acceptPreviousPositionForSelectionHandle:) withObject:selectionHandle afterDelay:0.75];
                    }
                    else {
                        if (selectionHandle.type == FTSelectionHandleTypeStart) {
                            self.selectedRange = [[MathRange alloc] initFromPosition:position toPosition:self.selectedRange.toPosition];
                        }
                        else {
                            self.selectedRange = [[MathRange alloc] initFromPosition:self.selectedRange.fromPosition toPosition:position];
                        }
                    }
                }
                _previousPosition = position;
            }
            
            CGRect expressionRect = [self.expression rectWhenDrawAtPoint:CGPointZero withFontSize:self.fontSize];
            CGFloat minX, maxX;
            if (selectionHandle.type == FTSelectionHandleTypeStart) {
                minX = CGRectGetMinX(expressionRect);
                maxX = selectionHandle.pairingSelectionHandle.center.x;
            }
            else {
                minX = selectionHandle.pairingSelectionHandle.center.x;
                maxX = CGRectGetMaxX(expressionRect);
            }
            if (effectiveLocation.x < minX) {
                effectiveLocation.x = minX;
            }
            else if (effectiveLocation.x > maxX) {
                effectiveLocation.x = maxX;
            }
            [[FTBarLens sharedBarLens] setLocation:effectiveLocation inView:self];
            if ([[FTBarLens sharedBarLens] isHidden]) {
                [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(showBarLens) object:nil];
                [FTBarLens sharedBarLens].hidden = NO;
            }
            [[FTInputSystem sharedInputSystem].selectionSuite snapSelectionHandleOfType:selectionHandle.type toPoint:effectiveLocation inView:self];
            
            if ([self.delegate respondsToSelector:@selector(editableExpressionView:scrollForTrackingPoint:)]) {
                static BOOL s_nested;
                if (s_nested) {
                    [self performSelector:@selector(invokeSelectionHandleRespondToPressGesture:) withObject:@[selectionHandle, longPressGestureRecognizer] afterDelay:AUTO_SCROLL_DELAY];
                }
                else if ([self.delegate editableExpressionView:self scrollForTrackingPoint:effectiveLocation]) {
                    s_nested = YES;
                    [self selectionHandle:selectionHandle respondToPressGesture:longPressGestureRecognizer];
                    s_nested = NO;
                }
            }
            break;
        }
        case UIGestureRecognizerStateCancelled:
        case UIGestureRecognizerStateEnded: {
            [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(acceptPreviousPositionForSelectionHandle:) object:selectionHandle];
            if (selectionHandle.type == FTSelectionHandleTypeStart) {
                self.selectedRange = [[MathRange alloc] initFromPosition:self.selectedRange.selectionStartPosition toPosition:self.selectedRange.toPosition];
            }
            else {
                self.selectedRange = [[MathRange alloc] initFromPosition:self.selectedRange.fromPosition toPosition:self.selectedRange.selectionEndPosition];
            }
            _previousPosition = nil;
            
            CGRect marqueeFrame = [self marqueeFrame];
            CGPoint disappearPoint;
            if (selectionHandle.type == FTSelectionHandleTypeStart) {
                disappearPoint = CGPointMake(CGRectGetMinX(marqueeFrame), CGRectGetMinY(marqueeFrame));
            }
            else {
                disappearPoint = CGPointMake(CGRectGetMaxX(marqueeFrame), CGRectGetMinY(marqueeFrame));
            }
            [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(showBarLens) object:nil];
            [[FTBarLens sharedBarLens] setHidden:YES atPoint:disappearPoint inView:self];
            [UIView animateWithDuration:0.2 animations:^{
                [[FTInputSystem sharedInputSystem].selectionSuite unsnapSelectionHandleOfType:selectionHandle.type];
                [self layoutIfNeeded];
            } completion:^(BOOL finished) {
                [self my_showEditingMenu];
            }];
            break;
        }
        default: {
            FTAssert_DEBUG(NO, longPressGestureRecognizer);
            break;
        }
    }
}

#pragma mark -

- (NSUndoManager *)undoManager
{
    if (_undoManager == nil) {
        _undoManager = [[NSUndoManager alloc] init];
        [_undoManager setLevelsOfUndo:100];
    }
    return _undoManager;
}

- (void)setUndoCheckpoint
{
    _isUndoCheckpointSet = YES;
}

- (void)setExpression:(MathExpression *)expression
{
    FTAssert(expression);
    MathPosition *caretPosition = [MathPosition positionAtIndex:(uint32_t)expression.elements.count];
    [self setExpression:expression withSelectedRange:[[MathRange alloc] initFromPosition:caretPosition toPosition:caretPosition]];
}

- (void)setExpression:(MathExpression *)expression withSelectedRange:(MathRange *)selectedRange
{
    FTAssert(expression && selectedRange);
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(my_showEditingMenu) object:nil];
    [[UIMenuController sharedMenuController] setMenuVisible:NO animated:YES];
    
    if ([self.delegate respondsToSelector:@selector(editableExpressionViewWillChange:)]) {
        [self.delegate editableExpressionViewWillChange:self];
    }
    
    [[self.undoManager prepareWithInvocationTarget:self] setExpression:[self.expression copy] withSelectedRange:self.selectedRange];
    [super setExpression:expression];
    self.selectedRange = selectedRange;
    
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(setUndoCheckpoint) object:nil];
    [self setUndoCheckpoint];
    
    if ([self.delegate respondsToSelector:@selector(editableExpressionViewDidChange:)]) {
        [self.delegate editableExpressionViewDidChange:self];
    }
}

- (void)insertNumericString:(NSString *)aNumericString
{
    FTAssert([aNumericString length]);
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(my_showEditingMenu) object:nil];
    [[UIMenuController sharedMenuController] setMenuVisible:NO animated:YES];

    if ([self.delegate respondsToSelector:@selector(editableExpressionViewWillChange:)]) {
        [self.delegate editableExpressionViewWillChange:self];
    }

    if ([self isDeleting]) {
        self.deleting = NO;
        [self setUndoCheckpoint];
    }
    if (_isUndoCheckpointSet) {
        _isUndoCheckpointSet = NO;
        [[self.undoManager prepareWithInvocationTarget:self] setExpression:[self.expression copy] withSelectedRange:self.selectedRange];
    }
    
    if (self.selectedRange.selectionLength) {
        MathNumber *aNumber = [[MathNumber alloc] initWithString:aNumericString];
        self.selectedRange = [self.expression replaceElementsInRange:self.selectedRange withElements:@[aNumber] localSelectedRange:nil];
    }
    else {
        MathPosition *caretPosition = self.selectedRange.selectionStartPosition;
        caretPosition = [self.expression insertNumericString:aNumericString atPosition:caretPosition];
        self.selectedRange = [[MathRange alloc] initFromPosition:caretPosition toPosition:caretPosition];
    }
    [self invalidateIntrinsicContentSize];
    [self setNeedsLayout];
    [self setNeedsDisplay];
    
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(setUndoCheckpoint) object:nil];
    [self performSelector:@selector(setUndoCheckpoint) withObject:nil afterDelay:AUTO_UNDOCHECKPOINT_DELAY];
    
    if ([self.delegate respondsToSelector:@selector(editableExpressionViewDidChange:)]) {
        [self.delegate editableExpressionViewDidChange:self];
    }
}

- (void)replaceElementsInRange:(MathRange *)range withElements:(NSArray *)elements localSelectedRange:(MathRange *)localSelectedRange
{
    FTAssert(elements);
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(my_showEditingMenu) object:nil];
    [[UIMenuController sharedMenuController] setMenuVisible:NO animated:YES];

    if ([self.delegate respondsToSelector:@selector(editableExpressionViewWillChange:)]) {
        [self.delegate editableExpressionViewWillChange:self];
    }
    
    if ([self isDeleting]) {
        self.deleting = NO;
        [self setUndoCheckpoint];
    }
    if (_isUndoCheckpointSet) {
        _isUndoCheckpointSet = NO;
        [[self.undoManager prepareWithInvocationTarget:self] setExpression:[self.expression copy] withSelectedRange:self.selectedRange];
    }
    
    self.selectedRange = [self.expression replaceElementsInRange:range withElements:elements localSelectedRange:localSelectedRange];
    [self invalidateIntrinsicContentSize];
    [self setNeedsLayout];
    [self setNeedsDisplay];
    
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(setUndoCheckpoint) object:nil];
    [self performSelector:@selector(setUndoCheckpoint) withObject:nil afterDelay:AUTO_UNDOCHECKPOINT_DELAY];
    
    if ([self.delegate respondsToSelector:@selector(editableExpressionViewDidChange:)]) {
        [self.delegate editableExpressionViewDidChange:self];
    }
}

- (MathExpressionDeletionResult)deleteBackwardAggressively:(BOOL)aggressively
{
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(my_showEditingMenu) object:nil];
    [[UIMenuController sharedMenuController] setMenuVisible:NO animated:YES];

    if ([self.delegate respondsToSelector:@selector(editableExpressionViewWillChange:)]) {
        [self.delegate editableExpressionViewWillChange:self];
    }
    
    if (![self isDeleting]) {
        self.deleting = YES;
        [self setUndoCheckpoint];
    }
    MathExpression *oldExpression = [self.expression copy];
    MathRange *oldSelectedRange = self.selectedRange;
    
    MathExpressionDeletionResult result;
    if (self.selectedRange.selectionLength) {
        self.selectedRange = [self.expression replaceElementsInRange:self.selectedRange withElements:@[] localSelectedRange:nil];
        result = MathExpressionSelectionDeleted;
    }
    else {
        MathPosition *caretPosition = self.selectedRange.selectionStartPosition;
        caretPosition = [self.expression deleteBackwardFromPosition:caretPosition aggressively:aggressively withResult:&result];
        self.selectedRange = [[MathRange alloc] initFromPosition:caretPosition toPosition:caretPosition];
    }
    [self invalidateIntrinsicContentSize];
    [self setNeedsLayout];
    [self setNeedsDisplay];
    
    if (result > MathExpressionOnlyCaretShifted && _isUndoCheckpointSet) {
        _isUndoCheckpointSet = NO;
        [[self.undoManager prepareWithInvocationTarget:self] setExpression:oldExpression withSelectedRange:oldSelectedRange];
    }
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(setUndoCheckpoint) object:nil];
    [self performSelector:@selector(setUndoCheckpoint) withObject:nil afterDelay:AUTO_UNDOCHECKPOINT_DELAY];
    
    if ([self.delegate respondsToSelector:@selector(editableExpressionViewDidChange:)]) {
        [self.delegate editableExpressionViewDidChange:self];
    }
    
    return result;
}

- (void)commitReturn
{
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(my_showEditingMenu) object:nil];
    [[UIMenuController sharedMenuController] setMenuVisible:NO animated:YES];

    if ([self.delegate editableExpressionViewShouldReturn:self]) {
        self.deleting = NO;
        
        [self setExpression:[[MathExpression alloc] initWithElements:@[]]];
        
        [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(setUndoCheckpoint) object:nil];
        [self setUndoCheckpoint];
    }
}

@end
