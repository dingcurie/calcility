//
//  ViewControllerDropAnimator.h
//  iCalculator
//
//  Created by curie on 10/6/14.
//  Copyright (c) 2014 Fish Tribe. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface ViewControllerDropAnimator : NSObject <UIViewControllerAnimatedTransitioning>

- (instancetype)initForPresenting;
- (instancetype)initForDismissing;

@end
