//
//  MathExpressionView.h
//  iCalculator
//
//  Created by curie on 12-8-10.
//  Copyright (c) 2012年 Fish Tribe. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MathExpression.h"
#import "FTInputSystem.h"


@interface MathExpressionView : UIView <FTInputting>

- (id)initWithFrame:(CGRect)frame;  //: Designated Initializer

@property (nonatomic, strong) MathExpression *expression;
@property (nonatomic, strong) MathRange *selectedRange;
@property (nonatomic) CGFloat fontSize;
@property (nonatomic) UIEdgeInsets insets;

@end
