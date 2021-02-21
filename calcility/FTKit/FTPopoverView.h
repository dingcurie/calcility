//
//  FTPopoverView.h
//
//  Created by curie on 12/12/14.
//  Copyright (c) 2014 Fish Tribe. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface FTPopoverView : UIView

- (instancetype)init;  //: Designated Initializer

@property (nonatomic, weak, readonly) UIView *contentView;
@property (nonatomic) UIEdgeInsets keepoutMargin;

- (void)showFromView:(UIView *)sourceView withInsets:(UIEdgeInsets)insets;
- (void)dismissAnimated:(BOOL)animated;

@end
