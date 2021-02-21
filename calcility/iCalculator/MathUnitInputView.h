//
//  MathUnitInputView.h
//  iCalculator
//
//  Created by curie on 12/7/14.
//  Copyright (c) 2014 Fish Tribe. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface MathUnitInputView : UIView

+ (MathUnitInputView *)sharedUnitInputView;

@end


@interface UIViewController (MathUnitInputViewClient)

- (void)handleCancelButtonTap:(id)sender;
- (void)handleDoneButtonTap:(id)sender;
- (void)handlePrevItemButtonTap:(id)sender;
- (void)handleNextItemButtonTap:(id)sender;
- (BOOL)hasPrevItem;
- (BOOL)hasNextItem;

@end
