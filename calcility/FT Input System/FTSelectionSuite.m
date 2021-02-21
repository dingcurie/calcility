//
//  FTSelectionSuite.m
//
//  Created by curie on 13-1-27.
//  Copyright (c) 2013年 Fish Tribe. All rights reserved.
//

#import "FTInputSystem.h"


@interface FTSelectionSuite ()

@property (nonatomic, readwrite) FTSelectionSuiteMode mode;

@property (nonatomic, strong, readonly) NSArray<UIView *> *anchorViews;

@property (nonatomic, strong) NSArray<NSLayoutConstraint *> *constraints;
@property (nonatomic, strong) NSArray<NSLayoutConstraint *> *constraintsToAnchorViews;

@end


@implementation FTSelectionSuite

@synthesize marquee = _marquee;
@synthesize selectionHandles = _selectionHandles;
@synthesize anchorViews = _anchorViews;

- (UIView *)marquee
{
    if (_marquee == nil) {
        _marquee = [[UIImageView alloc] initWithImage:[[UIImage imageNamed:@"selection-marquee"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate]];
        _marquee.userInteractionEnabled = NO;
    }
    return _marquee;
}

- (NSArray *)selectionHandles
{
    if (_selectionHandles == nil) {
        NSMutableArray<FTSelectionHandle *> *selectionHandles = [NSMutableArray arrayWithCapacity:FTSelectionHandleTypeNum];
        for (FTSelectionHandleType type = 0; type < FTSelectionHandleTypeNum; type++) {
            FTSelectionHandle *selectionHandle = [[FTSelectionHandle alloc] initWithType:type];
            /* Default mode */
            selectionHandle.alpha = 0.0;
            
            [selectionHandles addObject:selectionHandle];
        }
        selectionHandles[FTSelectionHandleTypeStart].pairingSelectionHandle = selectionHandles[FTSelectionHandleTypeEnd];
        selectionHandles[FTSelectionHandleTypeEnd].pairingSelectionHandle = selectionHandles[FTSelectionHandleTypeStart];
        
        _selectionHandles = selectionHandles;
    }
    return _selectionHandles;
}

- (NSArray *)anchorViews
{
    if (_anchorViews == nil) {
        NSMutableArray<UIView *> *anchorViews = [NSMutableArray arrayWithCapacity:FTSelectionHandleTypeNum];
        for (FTSelectionHandleType type = 0; type < FTSelectionHandleTypeNum; type++) {
            UIView *anchorView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, 2.0, 2.0)];
            anchorView.hidden = YES;
            
            [anchorViews addObject:anchorView];
        }
        _anchorViews = anchorViews;
    }
    return _anchorViews;
}

- (void)setConstraints:(NSArray<NSLayoutConstraint *> *)constraints
{
    if (_constraints) {
        [NSLayoutConstraint deactivateConstraints:_constraints];
    }
    _constraints = constraints;
}

- (void)setConstraintsToAnchorViews:(NSArray<NSLayoutConstraint *> *)constraintsToAnchorViews
{
    if (_constraintsToAnchorViews) {
        [NSLayoutConstraint deactivateConstraints:_constraintsToAnchorViews];
    }
    _constraintsToAnchorViews = constraintsToAnchorViews;
}

- (void)setHidden:(BOOL)hidden
{
    if (_hidden == hidden) return;
    _hidden = hidden;
    
    self.marquee.hidden = hidden;
    for (FTSelectionHandleType type = 0; type < FTSelectionHandleTypeNum; type++) {
        self.selectionHandles[type].hidden = hidden;
    }
}

- (void)setMode:(FTSelectionSuiteMode)mode
{
    if (_mode == mode) return;
    _mode = mode;
    
    if (mode == FTSelectionSuiteModeDefault) {
        for (FTSelectionHandleType type = 0; type < FTSelectionHandleTypeNum; type++) {
            self.selectionHandles[type].alpha = 0.0;
        }
        
        self.constraints = nil;
        self.constraintsToAnchorViews = nil;
    }
    else if (mode == FTSelectionSuiteModeLine) {
        for (FTSelectionHandleType type = 0; type < FTSelectionHandleTypeNum; type++) {
            self.selectionHandles[type].alpha = 1.0;
        }
        
        NSMutableArray *constraints = [NSMutableArray arrayWithCapacity:8];
        FTSelectionHandle *startSelectionHandle = self.selectionHandles[FTSelectionHandleTypeStart];
        [constraints addObject:[NSLayoutConstraint constraintWithItem:startSelectionHandle.pole attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:self.marquee attribute:NSLayoutAttributeHeight multiplier:1.0 constant:0.0]];
        [constraints addObject:[NSLayoutConstraint constraintWithItem:startSelectionHandle.pole attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self.marquee attribute:NSLayoutAttributeCenterY multiplier:1.0 constant:0.0]];
        [constraints addObject:[NSLayoutConstraint constraintWithItem:startSelectionHandle attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self.marquee attribute:NSLayoutAttributeLeft multiplier:1.0 constant:0.0]];
        [[constraints lastObject] setPriority:UILayoutPriorityDefaultHigh];
        FTSelectionHandle *endSelectionHandle = self.selectionHandles[FTSelectionHandleTypeEnd];
        [constraints addObject:[NSLayoutConstraint constraintWithItem:endSelectionHandle.pole attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:self.marquee attribute:NSLayoutAttributeHeight multiplier:1.0 constant:0.0]];
        [constraints addObject:[NSLayoutConstraint constraintWithItem:endSelectionHandle.pole attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self.marquee attribute:NSLayoutAttributeCenterY multiplier:1.0 constant:0.0]];
        [constraints addObject:[NSLayoutConstraint constraintWithItem:endSelectionHandle attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self.marquee attribute:NSLayoutAttributeRight multiplier:1.0 constant:0.0]];
        [[constraints lastObject] setPriority:UILayoutPriorityDefaultHigh];
        [NSLayoutConstraint activateConstraints:(self.constraints = constraints)];
        
        NSMutableArray *constraintsToAnchorViews = [NSMutableArray arrayWithCapacity:2];
        for (FTSelectionHandleType type = 0; type < FTSelectionHandleTypeNum; type++) {
            [constraintsToAnchorViews addObject:[NSLayoutConstraint constraintWithItem:self.selectionHandles[type] attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self.anchorViews[type] attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:0.0]];
        }
        self.constraintsToAnchorViews = constraintsToAnchorViews;
    }
    else {
        FTAssert_DEBUG(NO);
    }
}

- (void)my_refresh
{
    UIResponder<FTInputting> *firstResponder = [FTInputSystem sharedInputSystem].firstResponder;
    if (firstResponder == nil) return;
    
    if ([FTInputSystem sharedInputSystem].firstResponderIsResigned) {
        self.mode = FTSelectionSuiteModeDefault;
        self.marquee.tintColor = [UIColor colorWithWhite:0.5 alpha:1.0];
    }
    else {
        self.mode = firstResponder.selectionSuiteMode;
    }
    
    CGRect frame = firstResponder.marqueeFrame;
    if (CGRectIsNull(frame)) {
        self.hidden = YES;
    }
    else {
        if (![self.marquee isHidden] || (self.mode == FTSelectionSuiteModeLine)) {
            self.marquee.frame = frame;
            [firstResponder.contentView layoutIfNeeded];
            self.hidden = NO;
        }
        else {
            self.marquee.frame = self.marquee.superview.bounds;
            self.marquee.hidden = NO;
            [UIView animateWithDuration:0.25 delay:0.0 options:UIViewAnimationOptionCurveEaseOut animations:^{
                self.marquee.frame = frame;
            } completion:^(BOOL finished) {
                [firstResponder.contentView layoutIfNeeded];
                self.hidden = NO;
            }];
        }
    }
}

- (void)addToSuperview:(UIView *)newSuperview
{
    FTAssert(newSuperview);
    [newSuperview addSubview:self.marquee];
    for (FTSelectionHandleType type = 0; type < FTSelectionHandleTypeNum; type++) {
        [newSuperview addSubview:self.selectionHandles[type]];
        [newSuperview addSubview:self.anchorViews[type]];
    }
}

- (void)removeFromSuperview
{
    [self.marquee removeFromSuperview];
    for (FTSelectionHandleType type = 0; type < FTSelectionHandleTypeNum; type++) {
        [self.selectionHandles[type] removeFromSuperview];
        [self.anchorViews[type] removeFromSuperview];
    }
    
    self.marquee.tintColor = nil;
    self.hidden = YES;
}

- (void)snapSelectionHandleOfType:(FTSelectionHandleType)type toPoint:(CGPoint)point inView:(UIView *)view
{
    self.constraintsToAnchorViews[type].active = YES;
    
    UIView *anchorView = self.anchorViews[type];
    anchorView.center = [anchorView.superview convertPoint:point fromView:view];
}

- (void)unsnapSelectionHandleOfType:(FTSelectionHandleType)type
{
    self.constraintsToAnchorViews[type].active = NO;
}

@end
