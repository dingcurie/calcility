//
//  UIScrollView+Mine.m
//
//  Created by curie on 13-4-18.
//  Copyright (c) 2013年 Fish Tribe. All rights reserved.
//

#import "UIScrollView+MyAdditions.h"


@implementation UIScrollView (MyAdditions)

- (CGPoint)my_contentBLOffset
{
    CGPoint contentOffset = self.contentOffset;
    return CGPointMake(contentOffset.x, self.contentSize.height - contentOffset.y - CGRectGetHeight(self.bounds));
}

- (void)setMy_contentBLOffset:(CGPoint)contentBLOffset
{
    self.contentOffset = CGPointMake(contentBLOffset.x, self.contentSize.height - contentBLOffset.y - CGRectGetHeight(self.bounds));
}

- (CGPoint)my_regularizeCandidateContentOffset:(CGPoint)candidateContentOffset
{
    CGSize boundsSize = CGRectStandardize(self.bounds).size;
    CGSize contentSize = self.contentSize;
    UIEdgeInsets contentInset = self.contentInset;
    
    CGVector headSurplus = CGVectorMake(candidateContentOffset.x + contentInset.left, candidateContentOffset.y + contentInset.top);
    CGVector tailShortage = CGVectorMake(candidateContentOffset.x + boundsSize.width - contentSize.width - contentInset.right, candidateContentOffset.y + boundsSize.height - contentSize.height - contentInset.bottom);
    
    if (headSurplus.dx < 0.0) {
        candidateContentOffset.x -= headSurplus.dx;
    }
    else if (0.0 < tailShortage.dx) {
        candidateContentOffset.x -= MIN(headSurplus.dx, tailShortage.dx);
    }
    
    if (headSurplus.dy < 0.0) {
        candidateContentOffset.y -= headSurplus.dy;
    }
    else if (0.0 < tailShortage.dy) {
        candidateContentOffset.y -= MIN(headSurplus.dy, tailShortage.dy);
    }
    
    return candidateContentOffset;
}

- (void)my_setContentOffset:(CGPoint)contentOffset regularized:(BOOL)regularized
{
    self.contentOffset = regularized ? [self my_regularizeCandidateContentOffset:contentOffset] : contentOffset;
}

- (CGPoint)my_regularizeCandidateContentBLOffset:(CGPoint)candidateContentBLOffset
{
    CGSize boundsSize = CGRectStandardize(self.bounds).size;
    CGSize contentSize = self.contentSize;
    UIEdgeInsets contentInset = self.contentInset;
    
    CGVector headSurplus = CGVectorMake(candidateContentBLOffset.x + contentInset.left, candidateContentBLOffset.y + contentInset.bottom);
    CGVector tailShortage = CGVectorMake(candidateContentBLOffset.x + boundsSize.width - contentSize.width - contentInset.right, candidateContentBLOffset.y + boundsSize.height - contentSize.height - contentInset.top);
    
    if (headSurplus.dx < 0.0) {
        candidateContentBLOffset.x -= headSurplus.dx;
    }
    else if (0.0 < tailShortage.dx) {
        candidateContentBLOffset.x -= MIN(headSurplus.dx, tailShortage.dx);
    }
    
    if (headSurplus.dy < 0.0) {
        candidateContentBLOffset.y -= headSurplus.dy;
    }
    else if (0.0 < tailShortage.dy) {
        candidateContentBLOffset.y -= MIN(headSurplus.dy, tailShortage.dy);
    }
    
    return candidateContentBLOffset;
}

- (void)my_setContentBLOffset:(CGPoint)contentBLOffset regularized:(BOOL)regularized
{
    self.my_contentBLOffset = regularized ? [self my_regularizeCandidateContentBLOffset:contentBLOffset] : contentBLOffset;
}

- (void)my_scrollRectToVisible:(CGRect)aRect animated:(BOOL)animated
{
    CGRect bounds = CGRectStandardize(self.bounds);
    CGRect rect = CGRectOffset(aRect, -bounds.origin.x, -bounds.origin.y);
    UIEdgeInsets contentInset = self.contentInset;
    
    //! The following algorithm scrolls in y-direction only and the top edge takes priority.
    CGPoint contentOffset = bounds.origin;
    CGFloat topMargin = CGRectGetMinY(rect) - contentInset.top;
    if (topMargin < 0.0) {
        contentOffset.y -= -topMargin;
    }
    else {
        CGFloat bottomMargin = bounds.size.height - CGRectGetMaxY(rect) - contentInset.bottom;
        if (bottomMargin < 0.0) {
            contentOffset.y += MIN(-bottomMargin, topMargin);
        }
    }
    
    //! WORKAROUND: Intentionally don't regularize contentOffset, as the contentSize may not have been updated yet at this point (but should be soon after) and the algorithm above reasonably preserves regularization.
    if (!CGPointEqualToPoint(contentOffset, bounds.origin)) {
        if (animated) {
            [UIView animateWithDuration:0.3 animations:^{
                self.contentOffset = contentOffset;
            }];
        }
        else {
            self.contentOffset = contentOffset;
        }
    }
}

@end
