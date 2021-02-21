//
//  HTVC_MathExpressionView.h
//  iCalculator
//
//  Created by curie on 11/20/14.
//  Copyright (c) 2014 Fish Tribe. All rights reserved.
//

#import "MathExpressionView.h"

@class HistoryTableViewCell;


@interface HTVC_MathExpressionView : MathExpressionView

- (id)initWithFrame:(CGRect)frame hostCell:(HistoryTableViewCell *)hostCell;  //: Designated Initializer

@property (nonatomic, weak, readonly) HistoryTableViewCell *hostCell;
@property (nonatomic, weak, readonly) UILongPressGestureRecognizer *longPressGestureRecognizer;

@end
