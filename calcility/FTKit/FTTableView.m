//
//  FTTableView.m
//
//  Created by curie on 1/1/15.
//  Copyright (c) 2015 Fish Tribe. All rights reserved.
//

#import "FTTableView.h"


@interface FTTableView ()

@property (nonatomic, weak, readonly) UIView *drawoutHeaderContainerView;

@end


@implementation FTTableView {
    CGPoint _initialContentOffsetForPanGR;
    NSIndexPath *_indexPathForCellContainingFirstResponder;
    NSInteger *_tagOfFirstResponderInContainingCell;
    UITextField *_firstResponderSurrogate;
}

@dynamic delegate;
@synthesize drawoutHeaderContainerView = _drawoutHeaderContainerView;

- (void)setMode:(FTTableViewMode)mode
{
    [self setMode:mode animated:NO];
}

- (void)setMode:(FTTableViewMode)mode animated:(BOOL)animated
{
    if (_mode == mode) return;
    
    if ([self.delegate respondsToSelector:@selector(tableView:willTransitionToMode:animated:)]) {
        [self.delegate tableView:self willTransitionToMode:mode animated:animated];
    }
    
    FTTableViewMode previousMode = _mode;
    _mode = mode;
    if (_mode == FTTableViewBatchEditingMode) {
        if ([self isEditing]) {
            [self setEditing:NO animated:animated];
        }
        [self setEditing:YES animated:animated];
    }
    else {
        if (previousMode == FTTableViewBatchEditingMode) {
            [self setEditing:NO animated:animated];
        }
        self.allowsSelection = (_mode == FTTableViewEditingInPlaceMode);
    }
    self.discardsChanges = NO;
    
    if ([self.delegate respondsToSelector:@selector(tableView:didTransitionFromMode:animated:)]) {
        [self.delegate tableView:self didTransitionFromMode:previousMode animated:animated];
    }
}

- (UIView *)drawoutHeaderContainerView
{
    if (_drawoutHeaderContainerView == nil) {
        UIView *drawoutHeaderContainerView = [[UIView alloc] init];
        drawoutHeaderContainerView.backgroundColor = [UIColor clearColor];
        drawoutHeaderContainerView.layer.anchorPoint = CGPointMake(0.5, 0.0);
        [self addSubview:(_drawoutHeaderContainerView = drawoutHeaderContainerView)];
    }
    return _drawoutHeaderContainerView;
}

- (BOOL)drawoutHeaderIsHidden
{
    return _drawoutHeaderContainerView == nil || _drawoutHeaderContainerView.hidden;
}

- (void)setDrawoutHeaderIsHidden:(BOOL)hidden
{
    if (_drawoutHeaderContainerView) {
        _drawoutHeaderContainerView.hidden = hidden;
    }
}

- (void)setDrawoutHeaderView:(UIView *)aView
{
    if (_drawoutHeaderView == aView) return;
    
    [_drawoutHeaderView removeFromSuperview];
    if ((_drawoutHeaderView = aView)) {
        _drawoutHeaderView.hidden = NO;
        [self.drawoutHeaderContainerView insertSubview:_drawoutHeaderView atIndex:0];
        
        self.drawoutHeaderContainerView.bounds = _drawoutHeaderView.bounds;
    }
}

- (void)setHighlightedDrawoutHeaderView:(UIView *)aView
{
    if (_highlightedDrawoutHeaderView == aView) return;
    
    [_highlightedDrawoutHeaderView removeFromSuperview];
    if ((_highlightedDrawoutHeaderView = aView)) {
        _highlightedDrawoutHeaderView.hidden = YES;
        _highlightedDrawoutHeaderView.contentMode = UIViewContentModeBottom;
        _highlightedDrawoutHeaderView.clipsToBounds = YES;
        [self.drawoutHeaderContainerView addSubview:_highlightedDrawoutHeaderView];
    }
}

#define DRAWOUT_HEADER_VERTICAL_MARGIN      12.0
#define DRAWOUT_HEADER_START_STRETCH_RATIO   0.5  // Range: [0, 1]
#define DRAWOUT_HEADER_STRETCH_FACTOR        0.5  // Range: [0, 1]

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    if (self.drawoutHeaderIsHidden) return;
    FTAssert_DEBUG(self.drawoutHeaderContainerView);
    CGFloat drawoutHeaderHeight = CGRectGetHeight(self.drawoutHeaderContainerView.bounds);
    CGFloat drawoutHeaderStartStretchHeight = drawoutHeaderHeight * DRAWOUT_HEADER_START_STRETCH_RATIO;
    CGFloat drawnOutHeight = -(self.contentOffset.y + self.contentInset.top);
    CGFloat startStretchThreshold = DRAWOUT_HEADER_VERTICAL_MARGIN + drawoutHeaderStartStretchHeight;
    if (drawnOutHeight <= startStretchThreshold) {
        if (self.highlightedDrawoutHeaderView && !self.highlightedDrawoutHeaderView.hidden) {
            [self.highlightedDrawoutHeaderView.layer removeAllAnimations];
            self.highlightedDrawoutHeaderView.hidden = YES;
        }
        self.drawoutHeaderContainerView.layer.position = CGPointMake(CGRectGetMidX(self.bounds), -(DRAWOUT_HEADER_VERTICAL_MARGIN + drawoutHeaderHeight));
        self.drawoutHeaderContainerView.layer.transform = CATransform3DIdentity;
    }
    else if (drawnOutHeight < 2.0 * DRAWOUT_HEADER_VERTICAL_MARGIN + drawoutHeaderHeight) {
        if (/*$ self.drawoutHeaderHighlightedView && */self.highlightedDrawoutHeaderView.hidden) {
            CGFloat k = (drawnOutHeight - startStretchThreshold) / (DRAWOUT_HEADER_VERTICAL_MARGIN + drawoutHeaderHeight - drawoutHeaderStartStretchHeight);
            self.drawoutHeaderContainerView.layer.position = CGPointMake(CGRectGetMidX(self.bounds), -(DRAWOUT_HEADER_VERTICAL_MARGIN + drawoutHeaderHeight) - k * DRAWOUT_HEADER_VERTICAL_MARGIN);
            CGFloat scale = 1.0 + k * (DRAWOUT_HEADER_VERTICAL_MARGIN / drawoutHeaderHeight) * DRAWOUT_HEADER_STRETCH_FACTOR;
            self.drawoutHeaderContainerView.layer.transform = CATransform3DMakeScale(1.0 / sqrt(scale), scale, 1.0);
        }
    }
    else {
        if (/*$ self.drawoutHeaderHighlightedView && */self.highlightedDrawoutHeaderView.hidden) {
            [UIView animateWithDuration:0.5 delay:0.0 usingSpringWithDamping:0.5 initialSpringVelocity:0.0 options:UIViewAnimationOptionCurveLinear animations:^{
                self.drawoutHeaderContainerView.layer.position = CGPointMake(CGRectGetMidX(self.bounds), -(DRAWOUT_HEADER_VERTICAL_MARGIN + drawoutHeaderHeight));
                self.drawoutHeaderContainerView.layer.transform = CATransform3DIdentity;
            } completion:nil];
            
            self.highlightedDrawoutHeaderView.hidden = NO;
            CGRect endFrame = CGRectStandardize(self.highlightedDrawoutHeaderView.frame);
            CGRect startFrame = CGRectMake(endFrame.origin.x, endFrame.origin.y + endFrame.size.height, endFrame.size.width, 0.0);
            self.highlightedDrawoutHeaderView.frame = startFrame;
            [UIView animateWithDuration:1.0 delay:0.0 options:UIViewAnimationOptionCurveLinear animations:^{
                self.highlightedDrawoutHeaderView.frame = endFrame;
            } completion:^(BOOL finished) {
                if (finished) {
                    [self.delegate tableViewDidTriggerPullDownAction:self];
                }
            }];
        }
    }
}

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer
{
    if (gestureRecognizer == self.panGestureRecognizer) {
        _initialContentOffsetForPanGR = [self my_regularizeCandidateContentOffset:self.contentOffset];
    }
    return [super gestureRecognizerShouldBegin:gestureRecognizer];
}

- (void)reloadDataSmoothly
{
    CGFloat oldContentHeight = self.contentSize.height;
    CGPoint oldContentOffset = self.contentOffset;
    
    [self reloadData];  //! REMINDER: It fails to deselect rows before querying the delegate for new heights.
    
    CGFloat newContentHeight = self.contentSize.height;
    CGPoint newContentOffset = oldContentOffset;
    newContentOffset.y += newContentHeight - oldContentHeight;
    self.contentOffset = newContentOffset;
    
    // Make the transition smooth.
    CGPoint regularizedNewContentOffset = [self my_regularizeCandidateContentOffset:newContentOffset];
    if (self.panGestureRecognizer.state == UIGestureRecognizerStateChanged) {
        CGPoint translation = [self.panGestureRecognizer translationInView:nil];
        translation.y = -((oldContentOffset.y - _initialContentOffsetForPanGR.y) + (newContentOffset.y - regularizedNewContentOffset.y));
        [self.panGestureRecognizer setTranslation:translation inView:nil];
    }
    else {
        [UIView animateWithDuration:0.5 delay:0.25 usingSpringWithDamping:1.0 initialSpringVelocity:0.0 options:UIViewAnimationOptionCurveLinear animations:^{
            self.contentOffset = regularizedNewContentOffset;
        } completion:nil];
    }
}

@end
