//
//  ViewControllerDropAnimator.m
//  iCalculator
//
//  Created by curie on 10/6/14.
//  Copyright (c) 2014 Fish Tribe. All rights reserved.
//

#import "ViewControllerDropAnimator.h"


@interface ViewControllerDropAnimator ()

@property (nonatomic) BOOL isPresenting;

@end


@implementation ViewControllerDropAnimator

- (instancetype)initForPresenting
{
    self = [super init];
    if (self) {
        _isPresenting = YES;
    }
    return self;
}

- (instancetype)initForDismissing
{
    self = [super init];
    if (self) {
        _isPresenting = NO;
    }
    return self;
}

- (NSTimeInterval)transitionDuration:(id<UIViewControllerContextTransitioning>)transitionContext
{
    return 0.6;
}

- (void)animateTransition:(id<UIViewControllerContextTransitioning>)transitionContext
{
    UIImageView *shadow = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"light-shadow-5"]];
    
    if (self.isPresenting) {
        UIViewController *toVC = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
        CGRect finalToFrame = [transitionContext finalFrameForViewController:toVC];
        CGRect initialToFrame = CGRectOffset(finalToFrame, 0.0, -CGRectGetHeight(finalToFrame));
        UIView *toView = [transitionContext viewForKey:UITransitionContextToViewKey];
        
        CGRect finalShadowFrame = CGRectMake(CGRectGetMinX(finalToFrame), CGRectGetMaxY(finalToFrame), CGRectGetWidth(finalToFrame), shadow.image.size.height);
        CGRect initialShadowFrame = CGRectMake(CGRectGetMinX(initialToFrame), CGRectGetMaxY(initialToFrame), CGRectGetWidth(initialToFrame), shadow.image.size.height);
        
        UIView *containerView = [transitionContext containerView];
        [containerView addSubview:toView];
        [containerView addSubview:shadow];
        
        toView.frame = initialToFrame;
        shadow.frame = initialShadowFrame;
        [UIView animateWithDuration:[self transitionDuration:transitionContext] delay:0.0 usingSpringWithDamping:1.0 initialSpringVelocity:0.0 options:UIViewAnimationOptionCurveLinear animations:^{
            toView.frame = finalToFrame;
            shadow.frame = finalShadowFrame;
        } completion:^(BOOL finished) {
            [shadow removeFromSuperview];
            [transitionContext completeTransition:YES];
        }];
    }
    else {
        UIViewController *fromVC = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
        CGRect initialFromFrame = [transitionContext initialFrameForViewController:fromVC];
        CGRect finalFromFrame = CGRectOffset(initialFromFrame, 0.0, -CGRectGetHeight(initialFromFrame));
        UIView *fromView = [transitionContext viewForKey:UITransitionContextFromViewKey];
        
        CGRect initialShadowFrame = CGRectMake(CGRectGetMinX(initialFromFrame), CGRectGetMaxY(initialFromFrame), CGRectGetWidth(initialFromFrame), shadow.image.size.height);
        CGRect finalShadowFrame = CGRectMake(CGRectGetMinX(finalFromFrame), CGRectGetMaxY(finalFromFrame), CGRectGetWidth(finalFromFrame), shadow.image.size.height);
        
        UIView *containerView = [transitionContext containerView];
        [containerView addSubview:shadow];
        
        shadow.frame = initialShadowFrame;
        [UIView animateWithDuration:[self transitionDuration:transitionContext] delay:0.0 usingSpringWithDamping:1.0 initialSpringVelocity:0.0 options:UIViewAnimationOptionCurveLinear animations:^{
            fromView.frame = finalFromFrame;
            shadow.frame = finalShadowFrame;
        } completion:^(BOOL finished) {
            [fromView removeFromSuperview];
            [shadow removeFromSuperview];
            [transitionContext completeTransition:YES];
        }];
    }
}

@end
