//
//  UIScrollView+MyAdditions.h
//
//  Created by curie on 13-4-18.
//  Copyright (c) 2013年 Fish Tribe. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface UIScrollView (MyAdditions)

@property (nonatomic) CGPoint my_contentBLOffset;

- (CGPoint)my_regularizeCandidateContentOffset:(CGPoint)candidateContentOffset;
- (void)my_setContentOffset:(CGPoint)contentOffset regularized:(BOOL)regularized;

- (CGPoint)my_regularizeCandidateContentBLOffset:(CGPoint)candidateContentBLOffset;
- (void)my_setContentBLOffset:(CGPoint)contentBLOffset regularized:(BOOL)regularized;

- (void)my_scrollRectToVisible:(CGRect)rect animated:(BOOL)animated;

@end
