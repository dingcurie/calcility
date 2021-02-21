//
//  MathExpressionView.m
//  iCalculator
//
//  Created by curie on 12-8-10.
//  Copyright (c) 2012年 Fish Tribe. All rights reserved.
//

#import "MathExpressionView.h"
#import "MathNumber.h"
#import "MathConcreteOperators.h"


@interface MathExpressionView ()

@property (nonatomic, readonly) CGRect intrinsicBounds;

@end


@implementation MathExpressionView

@synthesize intrinsicBounds = _intrinsicBounds;

- (void)MathExpressionView_init
{
    _fontSize = 24.0;
    _intrinsicBounds = CGRectNull;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [super setUserInteractionEnabled:NO];
        [super setContentMode:UIViewContentModeBottomLeft];
        
        [self MathExpressionView_init];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)decoder
{
    self = [super initWithCoder:decoder];
    if (self) {
        [self MathExpressionView_init];
    }
    return self;
}

//! WORKAROUND: If the contentOffset of a scroll view is non-zero when transitioning back from another scene, the content will incorrectly be shifted to the right. This should be a bug in auto-layout support of UIScrollView.
- (void)setCenter:(CGPoint)center
{
    if ([self.superview isKindOfClass:[UIScrollView class]]) {
        CGSize size = CGRectStandardize(self.bounds).size;
        center = CGPointMake(size.width / 2.0, size.height / 2.0);
    }
    [super setCenter:center];
}

- (void)setExpression:(MathExpression *)expression
{
    _expression = expression;
    
    [self invalidateIntrinsicContentSize];
    [self setNeedsLayout];
    [self setNeedsDisplay];
    
    // Default to select-all
    self.selectedRange = [[MathRange alloc] initFromPosition:[MathPosition positionAtIndex:0] toPosition:[MathPosition positionAtIndex:(uint32_t)self.expression.elements.count]];
}

- (void)setSelectedRange:(MathRange *)aRange
{
    _selectedRange = aRange;
    
    if (self == [FTInputSystem sharedInputSystem].firstResponder) {
        [[FTInputSystem sharedInputSystem] refresh];
    }
}

- (void)setFontSize:(CGFloat)fontSize
{
    _fontSize = fontSize;
    
    [self invalidateIntrinsicContentSize];
    [self setNeedsLayout];
    [self setNeedsDisplay];
}

- (void)setInsets:(UIEdgeInsets)insets
{
    _insets = insets;
    
    [self invalidateIntrinsicContentSize];
    [self setNeedsLayout];
    [self setNeedsDisplay];
}

- (CGRect)intrinsicBounds
{
    if (CGRectIsNull(_intrinsicBounds)) {
        _intrinsicBounds = CGRectStandardize(my_UIEdgeInsetsOutsetRect([self.expression rectWhenDrawAtPoint:CGPointZero withFontSize:self.fontSize], self.insets));
    }
    return _intrinsicBounds;
}

- (void)invalidateIntrinsicContentSize
{
    _intrinsicBounds = CGRectNull;

    [super invalidateIntrinsicContentSize];
}

- (CGSize)intrinsicContentSize
{
    return self.intrinsicBounds.size;
}

#pragma mark -

- (BOOL)canBecomeFirstResponder
{
    return YES;
}

- (BOOL)becomeFirstResponder
{
    if ([super becomeFirstResponder]) {
        [[FTInputSystem sharedInputSystem] registerFirstResponder:self];
        return YES;
    }
    return NO;
}

- (BOOL)resignFirstResponder
{
    if ([super resignFirstResponder]) {
        [[FTInputSystem sharedInputSystem] unregisterFirstResponder];
        return YES;
    }
    return NO;
}

- (UIView *)contentView
{
    return self;
}

- (CGRect)caretFrame
{
    return CGRectNull;
}

- (CGRect)marqueeFrame
{
    return self.selectedRange.selectionLength ? [self.expression selectionRectForRange:self.selectedRange whenDrawAtPoint:CGPointZero withFontSize:self.fontSize] : CGRectNull;
}

- (FTSelectionSuiteMode)selectionSuiteMode
{
    return FTSelectionSuiteModeDefault;
}

- (BOOL)shouldPreservedWhenUnregistered
{
    return NO;
}

- (void)my_showEditingMenu
{
    if (![self isFirstResponder]) return;
    
    CGRect targetRect = self.selectedRange.selectionLength ? self.marqueeFrame : self.caretFrame;
    if (CGRectIsNull(targetRect)) return;
    
    UIMenuController *menuController = [UIMenuController sharedMenuController];
    [menuController setTargetRect:targetRect inView:self.contentView];
    [menuController setMenuVisible:YES animated:YES];
}

- (void)copy:(id)sender
{
    NSArray *elements = [self.expression elementsInRange:self.selectedRange];
    if (elements.count == 0 ) {
        FTAssert_DEBUG(NO);
        return;
    }
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:elements];
    if (data == nil) {
        FTAssert_DEBUG(NO);
        return;
    }
    
    UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
    // String representation:
    BOOL isComplete = NO;
    NSMutableString *string = [NSMutableString stringWithCapacity:0];
    NSEnumerator *enumerator = [elements objectEnumerator];
    MathElement *element = [enumerator nextObject];
    BOOL isMinus;
    if ((isMinus = [element isKindOfClass:[MathSub class]]) || [element isKindOfClass:[MathAdd class]]) {
        element = [enumerator nextObject];
    }
    if ([element isKindOfClass:[MathNumber class]]) {
        if (isMinus) [string appendString:@"-"];
        [string appendString:((MathNumber *)element).formattedString];
        isComplete = YES;
        element = [enumerator nextObject];
        if ([element isKindOfClass:[MathMul class]]) {
            isComplete = NO;
            element = [enumerator nextObject];
            if ([element isKindOfClass:[MathNumber class]] && [((MathNumber *)element).string isEqualToString:@"10"]) {
                element = [enumerator nextObject];
                if ([element isKindOfClass:[MathPow class]]) {
                    NSEnumerator *expEnumerator = [((MathPow *)element).exponent.elements objectEnumerator];
                    MathElement *expElement = [expEnumerator nextObject];
                    if ((isMinus = [expElement isKindOfClass:[MathSub class]]) || [expElement isKindOfClass:[MathAdd class]]) {
                        expElement = [expEnumerator nextObject];
                    }
                    if ([expElement isKindOfClass:[MathNumber class]]) {
                        [string appendString:@"E"];
                        [string appendString:(isMinus ? @"-" : @"+")];
                        [string appendString:((MathNumber *)expElement).formattedString];
                        if ([expEnumerator nextObject] == nil) {
                            isComplete = YES;
                            element = [enumerator nextObject];
                        }
                    }
                }
            }
        }
        if (isComplete) {
            if ([element isKindOfClass:[MathDegree class]]) {
                [string appendString:@"°"];
                element = [enumerator nextObject];
            }
            if (element) {
                isComplete = NO;
            }
        }
    }
    NSMutableDictionary *item;
    if (isComplete) {
        pasteboard.string = string;
        item = [pasteboard.items[0] mutableCopy];
    }
    else {
        item = [NSMutableDictionary dictionaryWithCapacity:0];
    }
    // Native representation:
    [item setObject:data forKey:@"com.fishtribe.math.elements"];
    pasteboard.items = @[item];
}

#pragma mark -

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    CGRect bounds = CGRectStandardize(self.bounds);
    CGPoint BLOrigin = CGPointMake(0.0, bounds.size.height);
    CGRect intrinsicBounds = self.intrinsicBounds;
    CGPoint intrinsicBLOrigin = CGPointMake(CGRectGetMinX(intrinsicBounds), CGRectGetMaxY(intrinsicBounds));
    CGPoint origin = CGPointMake(0.0 + intrinsicBLOrigin.x - BLOrigin.x, 0.0 + intrinsicBLOrigin.y - BLOrigin.y);
    if (!CGPointEqualToPoint(bounds.origin, origin)) {
        bounds.origin = origin;
        self.bounds = bounds;
        [super layoutSubviews];
    }
}

- (void)drawRect:(CGRect)rect
{
    [self.expression drawAtPoint:CGPointZero withFontSize:self.fontSize];
}

@end
