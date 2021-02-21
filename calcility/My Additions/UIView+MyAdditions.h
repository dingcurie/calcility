//
//  UIView+MyAdditions.h
//
//  Created by curie on 8/6/14.
//  Copyright (c) 2014 Fish Tribe. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface UIView (MyAdditions)

@property (nonatomic, weak, readonly) UIViewController *my_viewController;

- (UIView *)my_containingViewOfClass:(Class)theClass;
- (void)my_refresh;

@end
