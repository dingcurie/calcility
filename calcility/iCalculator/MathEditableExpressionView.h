//
//  MathEditableExpressionView.h
//  iCalculator
//
//  Created by curie on 12-12-31.
//  Copyright (c) 2012年 Fish Tribe. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MathExpressionView.h"
#import "MathKeyboard.h"

@class MathEditableExpressionView;


@protocol MathEditableExpressionViewDelegate <NSObject>

- (BOOL)editableExpressionViewShouldReturn:(MathEditableExpressionView *)editableExpressionView;

@optional

- (void)editableExpressionViewDidBecomeFirstResponder:(MathEditableExpressionView *)editableExpressionView;
- (void)editableExpressionViewDidResignFirstResponder:(MathEditableExpressionView *)editableExpressionView;
- (void)editableExpressionViewWillChange:(MathEditableExpressionView *)editableExpressionView;
- (void)editableExpressionViewDidChange:(MathEditableExpressionView *)editableExpressionView;
- (void)editableExpressionViewWillChangeSelection:(MathEditableExpressionView *)editableExpressionView;
- (void)editableExpressionViewDidChangeSelection:(MathEditableExpressionView *)editableExpressionView;
- (BOOL)editableExpressionView:(MathEditableExpressionView *)editableExpressionView scrollForTrackingPoint:(CGPoint)point;
- (CGPoint)editableExpressionView:(MathEditableExpressionView *)editableExpressionView willSetLoupeMagnifyingCenter:(CGPoint)magnifyingCenter inView:(UIView *)aView;

@end


@interface MathEditableExpressionView : MathExpressionView <MathInput>

- (id)initWithFrame:(CGRect)frame;  //: Designated Initializer

@property (nonatomic, weak) id<MathEditableExpressionViewDelegate> delegate;
@property (nonatomic, weak, readonly) UILongPressGestureRecognizer *longPressGestureRecognizer;
@property (nonatomic, weak) UIView *highlightView;

- (void)setExpression:(MathExpression *)expression withSelectedRange:(MathRange *)selectedRange;

@end
