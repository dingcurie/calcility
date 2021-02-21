//
//  MathKeyboard.m
//  iCalculator
//
//  Created by curie on 12-11-11.
//  Copyright (c) 2012年 Fish Tribe. All rights reserved.
//

#import "MathKeyboard_Subclass.h"
#import "MathKeyboard_iPhone.h"
#import "MathKeyboard_iPad.h"
#import "MathNumber.h"
#import "MathConcreteOperators.h"
#import "MathExpression+Editing.h"
#import <AudioToolbox/AudioToolbox.h>
#import <stdlib.h>


@implementation MathKey {
    UIFont *_portraitTitleFont;
    UIFont *_landscapeTitleFont;
    UIImage *_portraitImage;
    UIImage *_landscapeImage;
    UIImage *_portraitHighlightedImage;
    UIImage *_landscapeHighlightedImage;
    UIImage *_portraitDisabledImage;
    UIImage *_landscapeDisabledImage;
    UIEdgeInsets _portraitInsets;
    UIEdgeInsets _landscapeInsets;
    UIImageView *__weak _lockImageView;
}

- (id)initWithStyle:(MathKeyStyle)style tag:(NSInteger)tag
{
    self = [super initWithFrame:CGRectZero];
    if (self) {
        [super setAdjustsImageWhenHighlighted:NO];
        [super setAdjustsImageWhenDisabled:NO];
        self.layer.borderWidth = [MathKeyboard separatorThickness];
        self.layer.borderColor = [UIColor blackColor].CGColor;
        switch (style) {
            case MathKeyStyleLight: {
                [self setBackgroundImage:[UIImage imageNamed:@"key-background-light"] forState:UIControlStateNormal];
                break;
            }
            case MathKeyStyleDark: {
                [self setBackgroundImage:[UIImage imageNamed:@"key-background-dark"] forState:UIControlStateNormal];
                break;
            }
            case MathKeyStyleFlyout: {
                [self setBackgroundImage:[UIImage imageNamed:@"key-background-light"] forState:UIControlStateNormal];
                break;
            }
            default: {
                break;
            }
        }
        [self setBackgroundImage:[[UIImage imageNamed:@"opaque-point"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateHighlighted];
        [self setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [self setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
        [self setTitleColor:[UIColor colorWithWhite:0.0 alpha:0.2] forState:UIControlStateDisabled];
        self.tag = tag;
    }
    return self;
}

- (void)setTitle:(NSString *)title portraitFont:(UIFont *)portraitFont landscapeFont:(UIFont *)landscapeFont
{
    [self setTitle:title forState:UIControlStateNormal];
    _portraitTitleFont = portraitFont;
    _landscapeTitleFont = landscapeFont;
}

- (void)setPortraitImage:(UIImage *)portraitImage landscapeImage:(UIImage *)landscapeImage
{
    _portraitImage = portraitImage;
    _landscapeImage = landscapeImage;
}

- (void)setPortraitHighlightedImage:(UIImage *)portraitHighlightedImage landscapeHighlightedImage:(UIImage *)landscapeHighlightedImage
{
    _portraitHighlightedImage = portraitHighlightedImage;
    _landscapeHighlightedImage = landscapeHighlightedImage;
}

- (void)setPortraitDisabledImage:(UIImage *)portraitDisabledImage landscapeDisabledImage:(UIImage *)landscapeDisabledImage
{
    _portraitDisabledImage = portraitDisabledImage;
    _landscapeDisabledImage = landscapeDisabledImage;
}

- (void)setPortraitInsets:(UIEdgeInsets)portraitInsets landscapeInsets:(UIEdgeInsets)landscapeInsets
{
    _portraitInsets = portraitInsets;
    _landscapeInsets = landscapeInsets;
}

- (void)setTakingOffMode:(BOOL)takingOffMode
{
    if ((_takingOffMode = takingOffMode)) {
        self.layer.borderWidth = g_isPhone ? 3.0 : 4.0;
    }
    else {
        self.layer.borderWidth = [MathKeyboard separatorThickness];
    }
}

- (BOOL)isLocked
{
    return _lockImageView != nil;
}

- (void)setLocked:(BOOL)locked
{
    if (locked) {
        FTAssert_DEBUG(_lockImageView == nil);  //: Do it only once!
        UIImageView *lockImageView = [[UIImageView alloc] initWithFrame:self.bounds];
        lockImageView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        lockImageView.contentMode = UIViewContentModeTopRight;
        if (g_isPhone) {
            //: Do it elsewhere.
        }
        else {
            lockImageView.image = [UIImage imageNamed:@"lock~iPad"];
        }
        lockImageView.alpha = 0.5;
        [self addSubview:(_lockImageView = lockImageView)];
    }
}

- (void)updateContent
{
    BOOL isPortrait = UIInterfaceOrientationIsPortrait([UIApplication sharedApplication].statusBarOrientation);
    
    if (self.currentTitle) {
        self.titleLabel.font = isPortrait ? _portraitTitleFont : _landscapeTitleFont;
    }
    else {
        if (isPortrait) {
            [self setImage:_portraitImage forState:UIControlStateNormal];
            [self setImage:_portraitHighlightedImage forState:UIControlStateHighlighted];
            [self setImage:_portraitDisabledImage forState:UIControlStateDisabled];
        }
        else {
            [self setImage:_landscapeImage forState:UIControlStateNormal];
            [self setImage:_landscapeHighlightedImage forState:UIControlStateHighlighted];
            [self setImage:_landscapeDisabledImage forState:UIControlStateDisabled];
        }
    }
    self.contentEdgeInsets = isPortrait ? _portraitInsets : _landscapeInsets;
    
    if (g_isPhone && _lockImageView) {
        _lockImageView.image = [UIImage imageNamed:(isPortrait ? @"lock-Portrait~iPhone" : @"lock-Landscape~iPhone")];
    }
}

@end


#pragma mark -


@interface MathKeypad ()

@property (nonatomic, weak, readonly) MathKeyboard *keyboard;
@property (nonatomic, weak, readonly) UIView *flyoutKeypad;
@property (nonatomic, strong, readonly) UIImageView *triangleImageView;
@property (nonatomic, strong, readonly) UIView *dimmingView;

- (void)showFlyoutKeypadFromKey:(MathKey *)sourceKey;

- (void)handleKeyUp:(MathKey *)key;
- (void)handleDeleteKeyDown;
- (void)handleDeleteKeyUp;

@end


@implementation MathKeypad {
    NSUInteger _numberOfOneDigitDeleted;
    BOOL _aggressivelyDeleting;
    BOOL _isSuccessiveTaps;
}

@synthesize triangleImageView = _triangleImageView;
@synthesize dimmingView = _dimmingView;

- (id)initWithFrame:(CGRect)frame keyboard:(MathKeyboard *)keyboard
{
    self = [super initWithFrame:frame];
    if (self) {
        _keyboard = keyboard;
        keyboard.keypad = self;
    }
    return self;
}

- (UIImageView *)triangleImageView
{
    if (g_isPhone) {
        static NSNumber *s_hasBeenPortrait;
        BOOL isPortrait = UIInterfaceOrientationIsPortrait([UIApplication sharedApplication].statusBarOrientation);
        if (s_hasBeenPortrait == nil || [s_hasBeenPortrait boolValue] != isPortrait) {
            s_hasBeenPortrait = @(isPortrait);
            
            if (isPortrait) {
                _triangleImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"keyboard-triangle-stroked-Portrait~iPhone"] highlightedImage:[UIImage imageNamed:@"keyboard-triangle-white-Portrait~iPhone"]];
            }
            else {
                _triangleImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"keyboard-triangle-stroked-Landscape~iPhone"] highlightedImage:[UIImage imageNamed:@"keyboard-triangle-white-Landscape~iPhone"]];
            }
            _triangleImageView.layer.anchorPoint = CGPointZero;
        }
    }
    else {
        if (_triangleImageView == nil) {
            _triangleImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"keyboard-triangle-stroked~iPad"] highlightedImage:[UIImage imageNamed:@"keyboard-triangle-white~iPad"]];
            _triangleImageView.layer.anchorPoint = CGPointZero;
        }
    }
    
    return _triangleImageView;
}

- (UIView *)dimmingView
{
    if (_dimmingView == nil) {
        _dimmingView = [[UIView alloc] initWithFrame:CGRectZero];
        _dimmingView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        _dimmingView.backgroundColor = [UIColor blackColor];
    }
    return _dimmingView;
}

- (void)setDimmed:(BOOL)dimmed
{
    _dimmed = dimmed;
    
    if (dimmed) {
        [self addSubview:self.dimmingView];
        self.dimmingView.frame = self.bounds;
        self.dimmingView.alpha = 0.0;
        [UIView animateWithDuration:0.25 animations:^{
            self.dimmingView.alpha = 0.2;
        }];
    }
    else {
        [self.dimmingView removeFromSuperview];
    }
}

- (void)setHitKey:(MathKey *)hitKey
{
    if (_hitKey) {
        _hitKey.highlighted = NO;
    }
    
    if ((_hitKey = hitKey)) {
        _hitKey.highlighted = YES;
    }
    
    if (_hitKey && _hitKey.flyoutKeys) {
        self.triangleImageView.highlighted = YES;
        CGFloat offset = [MathKeyboard separatorThickness] * 2.0;
        self.triangleImageView.center = [self convertPoint:CGPointMake(offset, offset) fromView:_hitKey];
        [self addSubview:self.triangleImageView];
    }
    else {
        self.triangleImageView.highlighted = NO;
        [UIView animateWithDuration:0.25 animations:^{
            self.triangleImageView.alpha = 0.0;
        } completion:^(BOOL finished) {
            [self.triangleImageView removeFromSuperview];
            self.triangleImageView.alpha = 1.0;
        }];
    }
}

- (void)showFlyoutKeypadFromKey:(MathKey *)sourceKey
{
    if (self.flyoutKeypad) {
        FTAssert_DEBUG(NO);
        [self dismissFlyoutKeypad];
    }
    
    id<MathInput> inputtee = (id<MathInput>)[UIResponder my_firstResponder];
    if (![inputtee conformsToProtocol:@protocol(MathInput)]) {
        FTAssert_DEBUG(NO);
        return;
    }

    static const NSUInteger layoutMatrices[6][2][5] = {
        {
            { 3, 4, 6, 8, 9 },
            { 0, 1, 2, 5, 7 }
            //^
        },
        {
            { 7, 3, 4, 5, 9},
            { 6, 0, 1, 2, 8}
            //   ^
        },
        {
            { 8, 6, 3, 7, 9},
            { 4, 1, 0, 2, 5}
            //   <- ^
        },
        {
            { 9, 7, 3, 6, 8},
            { 5, 2, 0, 1, 4}
            //      ^ ->
        },
        {
            { 9, 5, 4, 3, 7},
            { 8, 2, 1, 0, 6}
            //         ^
        },
        {
            { 9, 8, 6, 4, 3},
            { 7, 5, 2, 1, 0}
            //            ^
        }
    };
    const NSUInteger (* const layoutMatrix)[5] = layoutMatrices[([self.keyboard colIndexOfKey:sourceKey] + 6) % 6];
    
    CGRect sourceKeyRect = [self convertRect:sourceKey.bounds fromView:sourceKey];
    CGFloat keyWidth = CGRectGetWidth(sourceKeyRect);
    CGFloat keyHeight = CGRectGetHeight(sourceKeyRect);
    CGFloat keyBorderWidth = [MathKeyboard separatorThickness];
    
    self.dimmed = YES;
    if ([self.superview isKindOfClass:[UIScrollView class]]) {
        ((UIScrollView *)self.superview).scrollEnabled = NO;
        ((UIScrollView *)self.superview).clipsToBounds = NO;
    }
    
    UIView *flyoutKeypad = [[UIView alloc] initWithFrame:CGRectZero];
    flyoutKeypad.layer.shadowOpacity = 1.0;
    flyoutKeypad.layer.shadowRadius = keyBorderWidth;
    flyoutKeypad.layer.shadowOffset = CGSizeMake(0.0, 0.0);
    [self addSubview:(_flyoutKeypad = flyoutKeypad)];
    
    UIImageView *flyoutKeysetBackboard = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"flyout-keyset-backboard-3"]];
    [flyoutKeypad addSubview:flyoutKeysetBackboard];
    UIImageView *sourceKeyBackground = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"source-key-backboard-0"]];
    [flyoutKeypad addSubview:sourceKeyBackground];
    
    CGFloat xMargin = g_isPhone ? 7.0 : 8.0;
    CGFloat yMargin = g_isPhone ? 5.0 : 6.0;
    NSUInteger numberOfFlyoutKeys = sourceKey.flyoutKeys.count;
    NSUInteger col;
    CGFloat originY[2] = {yMargin, yMargin};
    for (col = 0; col < 5; col++) {
        if (layoutMatrix[0][col] < numberOfFlyoutKeys) {
            originY[1] += keyHeight - keyBorderWidth;
            break;
        }
    }
    
    for (col = 0; col < 5; col++) {
        if (layoutMatrix[1][col] < numberOfFlyoutKeys) break;
    }
    CGFloat originX = xMargin;
    CGFloat xOffset = 0.0;
    BOOL hasFoundInitialFlyoutKey = NO;
    for (; col < 5; col++) {
        NSUInteger indexOfKey[2] = {layoutMatrix[0][col], layoutMatrix[1][col]};
        
        if (hasFoundInitialFlyoutKey) {
            if (indexOfKey[1] >= numberOfFlyoutKeys) break;
        }
        else {
            if (indexOfKey[1] == 0) {
                hasFoundInitialFlyoutKey = YES;
            }
            else {
                xOffset += keyWidth - keyBorderWidth;
            }
        }
        
        for (NSUInteger row = 0; row < 2; row++) {
            if (indexOfKey[row] < numberOfFlyoutKeys) {
                MathKey *key = sourceKey.flyoutKeys[indexOfKey[row]];
                if (key.refreshState) {
                    key.refreshState(inputtee);
                }
                [key updateContent];
                key.frame = CGRectMake(originX, originY[row], keyWidth, keyHeight);
                [flyoutKeypad addSubview:key];
            }
        }
        originX += keyWidth - keyBorderWidth;
    }

    CGFloat flyoutKeysBackgroundWidth = originX + keyBorderWidth + xMargin;
    CGFloat flyoutKeysBackgroundHeight = originY[1] + keyHeight + yMargin;
    flyoutKeypad.frame = CGRectMake(CGRectGetMinX(sourceKeyRect) - xMargin - xOffset,
                                    CGRectGetMinY(sourceKeyRect) - flyoutKeysBackgroundHeight,
                                    flyoutKeysBackgroundWidth,
                                    flyoutKeysBackgroundHeight + keyHeight);
    flyoutKeysetBackboard.frame = CGRectMake(0.0, 0.0, flyoutKeysBackgroundWidth, flyoutKeysBackgroundHeight);
    
    MathKey *sourceKeySubstitute = sourceKey.alternativeKey;
    if (sourceKeySubstitute) {
        if (sourceKeySubstitute.refreshState) {
            sourceKeySubstitute.refreshState(inputtee);
        }
        [sourceKeySubstitute updateContent];
    }
    else {
        sourceKeySubstitute = [[MathKey alloc] initWithStyle:MathKeyStyleFlyout tag:sourceKey.tag];
        if (sourceKey.currentTitle) {
            [sourceKeySubstitute setTitle:[sourceKey titleForState:UIControlStateNormal] forState:UIControlStateNormal];
            sourceKeySubstitute.titleLabel.font = sourceKey.titleLabel.font;
        }
        else {
            [sourceKeySubstitute setImage:[sourceKey imageForState:UIControlStateNormal] forState:UIControlStateNormal];
            [sourceKeySubstitute setImage:[sourceKey imageForState:UIControlStateHighlighted] forState:UIControlStateHighlighted];
        }
        sourceKeySubstitute.contentEdgeInsets =  sourceKey.contentEdgeInsets;
        sourceKeySubstitute.takingOffMode = sourceKey.takingOffMode;
    }
    sourceKeySubstitute.frame = [flyoutKeypad convertRect:sourceKey.bounds fromView:sourceKey];
    [flyoutKeypad addSubview:sourceKeySubstitute];
    
    self.hitKey = sourceKeySubstitute;
    sourceKeyBackground.frame = my_UIEdgeInsetsOutsetRect(sourceKeySubstitute.frame, UIEdgeInsetsMake(0.0, 3.0, 3.0, 3.0));
}

- (void)dismissFlyoutKeypad
{
    if (self.flyoutKeypad == nil) return;
    
    [self.flyoutKeypad removeFromSuperview];
    self.dimmed = NO;
    if ([self.superview isKindOfClass:[UIScrollView class]]) {
        ((UIScrollView *)self.superview).scrollEnabled = YES;
        ((UIScrollView *)self.superview).scrollEnabled = YES;
    }
}

#pragma mark -

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event
{
    if ([super hitTest:point withEvent:event]) {
        return self;
    }
    return nil;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    CGPoint location = [[touches anyObject] locationInView:self];
    UIView *hitView = [super hitTest:location withEvent:event];
    if (hitView && [hitView isKindOfClass:[MathKey class]]) {
        FTAssert_DEBUG(self.hitKey == nil);
        self.hitKey = (MathKey *)hitView;
        if (self.hitKey.tag == MATH_DELETE_KEY_TAG) {
            [self handleDeleteKeyDown];
        }
        if (self.hitKey.flyoutKeys) {
            [self performSelector:@selector(showFlyoutKeypadFromKey:) withObject:self.hitKey afterDelay:0.25];
        }
    }
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    if (self.flyoutKeypad) {
        CGPoint location = [[touches anyObject] locationInView:self.flyoutKeypad];
        UIView *hitView = [self.flyoutKeypad hitTest:location withEvent:event];
        if (hitView && [hitView isKindOfClass:[MathKey class]]) {
            if (hitView == self.hitKey) return;
            if (self.hitKey && self.hitKey.tag == MATH_DELETE_KEY_TAG) {
                [self handleDeleteKeyUp];
            }
            self.hitKey = (MathKey *)hitView;
            if (self.hitKey.tag == MATH_DELETE_KEY_TAG) {
                [self handleDeleteKeyDown];
            }
        }
        else {
            if (self.hitKey == nil) return;
            location = [self.hitKey convertPoint:location fromView:self.flyoutKeypad];
            if (!CGRectContainsPoint(CGRectInset(self.hitKey.bounds, -44.0, -44.0), location)) {
                if (self.hitKey.tag == MATH_DELETE_KEY_TAG) {
                    [self handleDeleteKeyUp];
                }
                self.hitKey = nil;
            }
        }
    }
    else {
        if (self.hitKey == nil) return;
        CGPoint location = [[touches anyObject] locationInView:self.hitKey];
        if (!CGRectContainsPoint(CGRectInset(self.hitKey.bounds, -44.0, -44.0), location)) {
            if (self.hitKey.flyoutKeys) {
                [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(showFlyoutKeypadFromKey:) object:self.hitKey];
            }
            if (self.hitKey.tag == MATH_DELETE_KEY_TAG) {
                [self handleDeleteKeyUp];
            }
            self.hitKey = nil;
        }
    }
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
    if (self.flyoutKeypad) {
        if (self.hitKey) {
            if (self.hitKey.tag == MATH_DELETE_KEY_TAG) {
                [self handleDeleteKeyUp];
            }
            self.hitKey = nil;
        }
        [self dismissFlyoutKeypad];
    }
    else {
        if (self.hitKey == nil) return;
        if (self.hitKey.flyoutKeys) {
            [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(showFlyoutKeypadFromKey:) object:self.hitKey];
        }
        if (self.hitKey.tag == MATH_DELETE_KEY_TAG) {
            [self handleDeleteKeyUp];
        }
        self.hitKey = nil;
    }
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    if (self.flyoutKeypad) {
        if (self.hitKey) {
            if (self.hitKey.tag == MATH_DELETE_KEY_TAG) {
                [self handleDeleteKeyUp];
            }
            else {
                [self handleKeyUp:self.hitKey];
            }
            self.hitKey = nil;
        }
        [self dismissFlyoutKeypad];
    }
    else {
        if (self.hitKey == nil) return;
        if (self.hitKey.flyoutKeys) {
            [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(showFlyoutKeypadFromKey:) object:self.hitKey];
        }
        if (self.hitKey.tag == MATH_DELETE_KEY_TAG) {
            [self handleDeleteKeyUp];
        }
        else {
            [self handleKeyUp:self.hitKey];
        }
        self.hitKey = nil;
    }
}

#pragma mark -

- (void)handleKeyUp:(MathKey *)key
{
    FTAssert(key);
    
    if ([key isLocked]) {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Locked in this Lite Version", nil) message:NSLocalizedString(@"Would you like to upgrade to the full-featured version?", nil) preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"No, thanks", nil) style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {}];
        UIAlertAction *goAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"App Store", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:g_appStdLink]];
        }];
        [alert addAction:cancelAction];
        [alert addAction:goAction];
        [self.my_viewController presentViewController:alert animated:YES completion:nil];
        return;
    }
    
    id<MathInput> inputtee = (id<MathInput>)[UIResponder my_firstResponder];
    if (![inputtee conformsToProtocol:@protocol(MathInput)]) return;
    AudioServicesPlaySystemSound(1104);
    
    NSArray *selectedElements = [inputtee.expression elementsInRange:inputtee.selectedRange];
    MathRange *replacedRange = inputtee.selectedRange;
    NSArray *replacementElements = nil;
    MathRange *localSelectedRange = nil;
    BOOL needsSetUndoCheckpoint = NO;
    
    switch (key.tag) {
        case MATH_NUM_KEY_TAG: {
            [inputtee insertNumericString:[key titleForState:UIControlStateNormal]];
            break;
        }
        case MATH_RETURN_KEY_TAG: {
            [inputtee commitReturn];
            break;
        }
        case MATH_ADD_KEY_TAG: {
            replacementElements = @[[MathAdd add]];
            break;
        }
        case MATH_SUB_KEY_TAG: {
            replacementElements = @[[MathSub sub]];
            break;
        }
        case MATH_MUL_KEY_TAG: {
            replacementElements = @[[MathMul mul]];
            break;
        }
        case MATH_DIV_KEY_TAG: {
            replacementElements = @[[MathDiv div]];
            break;
        }
        case MATH_FRACTION_KEY_TAG: {
            MathPosition *selectionStartPosition = inputtee.selectedRange.selectionStartPosition;
            MathExpression *subexpression = [inputtee.expression subexpressionAtPosition:selectionStartPosition];
            NSInteger offset = 0;
            if (selectionStartPosition.subindex == 0 && selectionStartPosition.index != 0) {
                NSArray *elements = subexpression.elements;
                for (NSInteger i = selectionStartPosition.index - 1; 0 <= i; i--) {
                    MathElement *element = elements[i];
                    if (element.rightAffinity) break;
                    offset--;
                    if (!element.leftAffinity) break;
                }
            }
            MathPosition *newStartPosition = [selectionStartPosition positionByOffset:offset];
            replacedRange = [[MathRange alloc] initFromPosition:newStartPosition toPosition:inputtee.selectedRange.selectionEndPosition];
            NSArray *numeratorElements = [inputtee.expression elementsInRange:[[MathRange alloc] initFromPosition:newStartPosition toPosition:selectionStartPosition]];
            replacementElements = @[[[MathFraction alloc] initWithNumerator:[[MathExpression alloc] initWithElements:numeratorElements] denominator:[[MathExpression alloc] initWithElements:@[]]]];
            MathPosition *localCaretPosition = [[MathPosition alloc] initWithIndexPairs:(uint32_t [][2]){{0, 1}, {0, 0}} numberOfLevels:2];
            localSelectedRange = [[MathRange alloc] initFromPosition:localCaretPosition toPosition:localCaretPosition];
            break;
        }
        case MATH_FRACTION1_KEY_TAG: {
            replacementElements = @[[[MathFraction alloc] initWithNumerator:[[MathExpression alloc] initWithElements:@[]] denominator:[[MathExpression alloc] initWithElements:selectedElements]]];
            break;
        }
        case MATH_FRACTION2_KEY_TAG: {
            if (selectedElements.count) {
                replacementElements = @[[[MathFraction alloc] initWithNumerator:[[MathExpression alloc] initWithElements:selectedElements] denominator:[[MathExpression alloc] initWithElements:@[]]]];
            }
            else {
                MathPosition *caretPosition = inputtee.selectedRange.selectionStartPosition;
                MathExpression *subexpression = [inputtee.expression subexpressionAtPosition:caretPosition];
                replacedRange = [[MathRange alloc] initFromPosition:[caretPosition positionByOffset:-9999] toPosition:[caretPosition positionByOffset:(subexpression.elements.count - caretPosition.index)]];
                replacementElements = @[[[MathFraction alloc] initWithNumerator:[[MathExpression alloc] initWithElements:subexpression.elements] denominator:[[MathExpression alloc] initWithElements:@[]]]];
                MathPosition *localCaretPosition = [[MathPosition alloc] initWithIndexPairs:(uint32_t [][2]){{0, 1}, {0, 0}} numberOfLevels:2];
                localSelectedRange = [[MathRange alloc] initFromPosition:localCaretPosition toPosition:localCaretPosition];
            }
            break;
        }
        case MATH_MOD_KEY_TAG: {
            replacementElements = @[[MathMod mod]];
            break;
        }
        case MATH_PERCENT_KEY_TAG: {
            replacementElements = @[[MathPercent percent]];
            break;
        }
        case MATH_PERMILLE_KEY_TAG: {
            replacementElements = @[[MathPermille permille]];
            break;
        }
        case MATH_EXP_KEY_TAG: {
            replacementElements = @[[MathMul mul], [[MathNumber alloc] initWithString:@"10"], [[MathPow alloc] initWithExponent:[[MathExpression alloc] initWithElements:@[]]]];
            break;
        }
        case MATH_PARENTHESES_KEY_TAG: {
            if ([key isTakingOffMode]) {
                MathParentheses *theParentheses;
                if (selectedElements.count == 1 && [(theParentheses = selectedElements[0]) isKindOfClass:[MathParentheses class]]) {
                    replacementElements = theParentheses.content.elements;
                    localSelectedRange = MathLocalSelectedRangeSelectAll;
                }
            }
            else {
                replacementElements = @[[[MathParentheses alloc] initWithContent:[[MathExpression alloc] initWithElements:selectedElements]]];
                if ([[selectedElements lastObject] rightAffinity]) {
                    MathPosition *caretPosition = [[MathPosition alloc] initWithIndexPairs:(uint32_t [][2]){{0, 0}, {(uint32_t)selectedElements.count, 0}} numberOfLevels:2];
                    localSelectedRange = [[MathRange alloc] initFromPosition:caretPosition toPosition:caretPosition];
                }
            }
            break;
        }
        case MATH_FLOOR_KEY_TAG: {
            if ([key isTakingOffMode]) {
                MathFloor *theFloor;
                if (selectedElements.count == 1 && [(theFloor = selectedElements[0]) isKindOfClass:[MathFloor class]]) {
                    replacementElements = theFloor.content.elements;
                    localSelectedRange = MathLocalSelectedRangeSelectAll;
                }
            }
            else {
                replacementElements = @[[[MathFloor alloc] initWithContent:[[MathExpression alloc] initWithElements:selectedElements]]];
                if ([[selectedElements lastObject] rightAffinity]) {
                    MathPosition *caretPosition = [[MathPosition alloc] initWithIndexPairs:(uint32_t [][2]){{0, 0}, {(uint32_t)selectedElements.count, 0}} numberOfLevels:2];
                    localSelectedRange = [[MathRange alloc] initFromPosition:caretPosition toPosition:caretPosition];
                }
            }
            break;
        }
        case MATH_CEIL_KEY_TAG: {
            if ([key isTakingOffMode]) {
                MathCeil *theCeil;
                if (selectedElements.count == 1 && [(theCeil = selectedElements[0]) isKindOfClass:[MathCeil class]]) {
                    replacementElements = theCeil.content.elements;
                    localSelectedRange = MathLocalSelectedRangeSelectAll;
                }
            }
            else {
                replacementElements = @[[[MathCeil alloc] initWithContent:[[MathExpression alloc] initWithElements:selectedElements]]];
                if ([[selectedElements lastObject] rightAffinity]) {
                    MathPosition *caretPosition = [[MathPosition alloc] initWithIndexPairs:(uint32_t [][2]){{0, 0}, {(uint32_t)selectedElements.count, 0}} numberOfLevels:2];
                    localSelectedRange = [[MathRange alloc] initFromPosition:caretPosition toPosition:caretPosition];
                }
            }
            break;
        }
        case MATH_ABS_KEY_TAG: {
            if ([key isTakingOffMode]) {
                MathAbs *theAbs;
                if (selectedElements.count == 1 && [(theAbs = selectedElements[0]) isKindOfClass:[MathAbs class]]) {
                    replacementElements = theAbs.content.elements;
                    localSelectedRange = MathLocalSelectedRangeSelectAll;
                }
            }
            else {
                replacementElements = @[[[MathAbs alloc] initWithContent:[[MathExpression alloc] initWithElements:selectedElements]]];
                if ([[selectedElements lastObject] rightAffinity]) {
                    MathPosition *caretPosition = [[MathPosition alloc] initWithIndexPairs:(uint32_t [][2]){{0, 0}, {(uint32_t)selectedElements.count, 0}} numberOfLevels:2];
                    localSelectedRange = [[MathRange alloc] initFromPosition:caretPosition toPosition:caretPosition];
                }
            }
            break;
        }
        case MATH_SIN_KEY_TAG: {
            replacementElements = @[[MathSin sin]];
            break;
        }
        case MATH_COS_KEY_TAG: {
            replacementElements = @[[MathCos cos]];
            break;
        }
        case MATH_TAN_KEY_TAG: {
            replacementElements = @[[MathTan tan]];
            break;
        }
        case MATH_ARCSIN_KEY_TAG: {
            replacementElements = @[[MathArcsin arcsin]];
            break;
        }
        case MATH_ARCCOS_KEY_TAG: {
            replacementElements = @[[MathArccos arccos]];
            break;
        }
        case MATH_ARCTAN_KEY_TAG: {
            replacementElements = @[[MathArctan arctan]];
            break;
        }
        case MATH_SINH_KEY_TAG: {
            replacementElements = @[[MathSinh sinh]];
            break;
        }
        case MATH_COSH_KEY_TAG: {
            replacementElements = @[[MathCosh cosh]];
            break;
        }
        case MATH_TANH_KEY_TAG: {
            replacementElements = @[[MathTanh tanh]];
            break;
        }
        case MATH_ARCSINH_KEY_TAG: {
            replacementElements = @[[MathArcsinh arcsinh]];
            break;
        }
        case MATH_ARCCOSH_KEY_TAG: {
            replacementElements = @[[MathArccosh arccosh]];
            break;
        }
        case MATH_ARCTANH_KEY_TAG: {
            replacementElements = @[[MathArctanh arctanh]];
            break;
        }
        case MATH_DEGREE_KEY_TAG: {
            replacementElements = @[[MathDegree degree]];
            break;
        }
        case MATH_PI_KEY_TAG: {
            replacementElements = @[[MathConstant pi]];
            break;
        }
        case MATH_PI_OVER_6_TAG: {
            replacementElements = @[[[MathFraction alloc] initWithNumerator:[[MathExpression alloc] initWithElements:@[[MathConstant pi]]] denominator:[[MathExpression alloc] initWithElements:@[[[MathNumber alloc] initWithString:@"6"]]]]];
            break;
        }
        case MATH_PI_OVER_4_TAG: {
            replacementElements = @[[[MathFraction alloc] initWithNumerator:[[MathExpression alloc] initWithElements:@[[MathConstant pi]]] denominator:[[MathExpression alloc] initWithElements:@[[[MathNumber alloc] initWithString:@"4"]]]]];
            break;
        }
        case MATH_PI_OVER_2_TAG: {
            replacementElements = @[[[MathFraction alloc] initWithNumerator:[[MathExpression alloc] initWithElements:@[[MathConstant pi]]] denominator:[[MathExpression alloc] initWithElements:@[[[MathNumber alloc] initWithString:@"2"]]]]];
            break;
        }
        case MATH_PI_OVER_3_TAG: {
            replacementElements = @[[[MathFraction alloc] initWithNumerator:[[MathExpression alloc] initWithElements:@[[MathConstant pi]]] denominator:[[MathExpression alloc] initWithElements:@[[[MathNumber alloc] initWithString:@"3"]]]]];
            break;
        }
        case MATH_2PI_OVER_3_TAG: {
            replacementElements = @[[[MathFraction alloc] initWithNumerator:[[MathExpression alloc] initWithElements:@[[[MathNumber alloc] initWithString:@"2"], [MathConstant pi]]] denominator:[[MathExpression alloc] initWithElements:@[[[MathNumber alloc] initWithString:@"3"]]]]];
            break;
        }
        case MATH_4PI_OVER_3_TAG: {
            replacementElements = @[[[MathFraction alloc] initWithNumerator:[[MathExpression alloc] initWithElements:@[[[MathNumber alloc] initWithString:@"4"], [MathConstant pi]]] denominator:[[MathExpression alloc] initWithElements:@[[[MathNumber alloc] initWithString:@"3"]]]]];
            break;
        }
        case MATH_E_KEY_TAG: {
            replacementElements = @[[MathConstant e]];
            break;
        }
        case MATH_LOG10_KEY_TAG: {
            replacementElements = @[[MathLog10 log10]];
            break;
        }
        case MATH_LN_KEY_TAG: {
            replacementElements = @[[MathLn ln]];
            break;
        }
        case MATH_LOG2_KEY_TAG: {
            replacementElements = @[[[MathLog alloc] initWithBase:[[MathExpression alloc] initWithElements:@[[[MathNumber alloc] initWithString:@"2"]]]]];
            break;
        }
        case MATH_LOG_KEY_TAG: {
            replacementElements = @[[[MathLog alloc] initWithBase:[[MathExpression alloc] initWithElements:@[]]]];
            break;
        }
        case MATH_SQRT_KEY_TAG: {
            if ([key isTakingOffMode]) {
                MathSqrt *theSqrt;
                if (selectedElements.count == 1 && [(theSqrt = selectedElements[0]) isKindOfClass:[MathSqrt class]]) {
                    replacementElements = theSqrt.radicand.elements;
                    localSelectedRange = MathLocalSelectedRangeSelectAll;
                }
            }
            else {
                replacementElements = @[[[MathSqrt alloc] initWithRadicand:[[MathExpression alloc] initWithElements:selectedElements]]];
                if ([[selectedElements lastObject] rightAffinity]) {
                    MathPosition *caretPosition = [[MathPosition alloc] initWithIndexPairs:(uint32_t [][2]){{0, 0}, {(uint32_t)selectedElements.count, 0}} numberOfLevels:2];
                    localSelectedRange = [[MathRange alloc] initFromPosition:caretPosition toPosition:caretPosition];
                }
            }
            break;
        }
        case MATH_CBRT_KEY_TAG: {
            if ([key isTakingOffMode]) {
                MathRoot *theRoot;
                if (selectedElements.count == 1 && [(theRoot = selectedElements[0]) isKindOfClass:[MathRoot class]]) {
                    replacementElements = theRoot.radicand.elements;
                    localSelectedRange = MathLocalSelectedRangeSelectAll;
                }
            }
            else {
                replacementElements = @[[[MathRoot alloc] initWithIndex:[[MathExpression alloc] initWithElements:@[[[MathNumber alloc] initWithString:@"3"]]] radicand:[[MathExpression alloc] initWithElements:selectedElements]]];
                if ([[selectedElements lastObject] rightAffinity]) {
                    MathPosition *caretPosition = [[MathPosition alloc] initWithIndexPairs:(uint32_t [][2]){{0, 0}, {(uint32_t)selectedElements.count, 0}} numberOfLevels:2];
                    localSelectedRange = [[MathRange alloc] initFromPosition:caretPosition toPosition:caretPosition];
                }
            }
            break;
        }
        case MATH_ROOT_KEY_TAG: {
            if ([key isTakingOffMode]) {
                MathRoot *theRoot;
                if (selectedElements.count == 1 && [(theRoot = selectedElements[0]) isKindOfClass:[MathRoot class]]) {
                    replacementElements = theRoot.radicand.elements;
                    localSelectedRange = MathLocalSelectedRangeSelectAll;
                }
            }
            else {
                replacementElements = @[[[MathRoot alloc] initWithIndex:[[MathExpression alloc] initWithElements:@[]] radicand:[[MathExpression alloc] initWithElements:selectedElements]]];
            }
            break;
        }
        case MATH_SQUARE_KEY_TAG: {
            replacementElements = @[[[MathPow alloc] initWithExponent:[[MathExpression alloc] initWithElements:@[[[MathNumber alloc] initWithString:@"2"]]]]];
            break;
        }
        case MATH_CUBIC_KEY_TAG: {
            replacementElements = @[[[MathPow alloc] initWithExponent:[[MathExpression alloc] initWithElements:@[[[MathNumber alloc] initWithString:@"3"]]]]];
            break;
        }
        case MATH_POW_KEY_TAG: {
            replacementElements = @[[[MathPow alloc] initWithExponent:[[MathExpression alloc] initWithElements:@[]]]];
            break;
        }
        case MATH_FACTORIAL_KEY_TAG: {
            replacementElements = @[[MathFactorial factorial]];
            break;
        }
        case MATH_RAND_KEY_TAG: {
            uint32_t _rand;
            if (SecRandomCopyBytes(kSecRandomDefault, sizeof(_rand), (uint8_t *)&_rand)) {
                srand((unsigned)time(NULL));
                _rand = (uint32_t)rand();
            }
            decQuad rand, max, nrand;
            decQuadFromUInt32(&rand, _rand);
            decQuadFromUInt32(&max, UINT32_MAX);
            decQuadDivide(&nrand, &rand, &max, &DQ_set);
            replacementElements = [MathExpression expressionFromValue:nrand inDegree:NO].elements;
            needsSetUndoCheckpoint = YES;
            break;
        }
        case MATH_PERMUTATION_KEY_TAG: {
            replacementElements = @[[[MathPermutation alloc] initWithn:[[MathExpression alloc] initWithElements:@[]] k:[[MathExpression alloc] initWithElements:@[]]]];
            break;
        }
        case MATH_COMBINATION_KEY_TAG: {
            replacementElements = @[[[MathCombination alloc] initWithn:[[MathExpression alloc] initWithElements:@[]] k:[[MathExpression alloc] initWithElements:@[]]]];
            break;
        }
        default: {
            break;
        }
    }
    if (replacementElements) {
        if (needsSetUndoCheckpoint) {
            [inputtee setUndoCheckpoint];
        }
        [inputtee replaceElementsInRange:replacedRange withElements:replacementElements localSelectedRange:localSelectedRange];
    }
    
    if (g_isPhone) {
        [(MathKeyboard_iPhone *)[MathKeyboard sharedKeyboard] scrollToNumPad];
    }
}

- (void)handleDeleteKeyDown
{
    id<MathInput> inputtee = (id<MathInput>)[UIResponder my_firstResponder];
    if (![inputtee conformsToProtocol:@protocol(MathInput)]) return;

    MathExpressionDeletionResult deletionResult;
    if ((deletionResult = [inputtee deleteBackwardAggressively:_aggressivelyDeleting])) {
        AudioServicesPlaySystemSound(1104);
        
        if (!_aggressivelyDeleting) {
            if (deletionResult == MathExpressionOneDigitDeleted) {
                _numberOfOneDigitDeleted++;
            }
            else {
                _numberOfOneDigitDeleted = 0;
            }
            
            if (_numberOfOneDigitDeleted == 6) {
                _aggressivelyDeleting = YES;
            }
        }
        else {
            if (_numberOfOneDigitDeleted) {
                _isSuccessiveTaps = NO;
                _numberOfOneDigitDeleted = 0;
            }
        }
        
        NSTimeInterval delay;
        if (!_isSuccessiveTaps) {
            delay = 0.6;
            _isSuccessiveTaps = YES;
        }
        else {
            delay = !_aggressivelyDeleting || _numberOfOneDigitDeleted ? 0.1 : 0.2;
        }
        [self performSelector:_cmd withObject:nil afterDelay:delay];
    }
}

- (void)handleDeleteKeyUp
{
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(handleDeleteKeyDown) object:nil];
    _numberOfOneDigitDeleted = 0;
    _aggressivelyDeleting = NO;
    _isSuccessiveTaps = NO;
}

@end


#pragma mark -


@implementation MathKeyboard

+ (MathKeyboard *)sharedKeyboard
{
    static MathKeyboard *sharedKeyboard;
    if (sharedKeyboard == nil) {
        sharedKeyboard = g_isPhone ? [[MathKeyboard_iPhone alloc] init] : [[MathKeyboard_iPad alloc] init];
    }
    return sharedKeyboard;
}

+ (CGFloat)separatorThickness
{
    return g_isPhone ? 0.5 : 1.0;
}

- (void)my_refresh
{
    id<MathInput> inputtee = (id<MathInput>)[UIResponder my_firstResponder];
    if (![inputtee conformsToProtocol:@protocol(MathInput)]) return;
    
    for (MathKey *key in self.staticKeys) {
        if (key.refreshState) {
            key.refreshState(inputtee);
            [key updateContent];
        }
    }
}

- (void)cancelKeyHit
{
    [self.keypad dismissFlyoutKeypad];
    self.keypad.hitKey = nil;
}

- (NSInteger)colIndexOfKey:(MathKey *)key
{
    return 2;
}

@end
