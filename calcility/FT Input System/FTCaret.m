//
//  FTCaret.m
//
//  Created by curie on 13-1-28.
//  Copyright (c) 2013年 Fish Tribe. All rights reserved.
//

#import "FTInputSystem.h"


@interface FTCaret ()

@property (nonatomic, strong, readonly) CABasicAnimation *blinkAnimation;

@end


@implementation FTCaret

@synthesize blinkAnimation = _blinkAnimation;

- (id)init
{
    self = [super initWithImage:[[UIImage imageNamed:@"caret"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate]];
    if (self) {
        [super setUserInteractionEnabled:NO];
        _blinking = YES;
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(respondToApplicationWillEnterForegroundNotification:) name:UIApplicationWillEnterForegroundNotification object:nil];
    }
    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (CABasicAnimation *)blinkAnimation
{
    if (_blinkAnimation == nil) {
        _blinkAnimation = [CABasicAnimation animationWithKeyPath:@"hidden"];
        _blinkAnimation.fromValue = @NO;
        _blinkAnimation.toValue = @YES;
        _blinkAnimation.duration = 0.5;
        _blinkAnimation.autoreverses = YES;
        _blinkAnimation.repeatCount = 1.0 / 0.0;
    }
    return _blinkAnimation;
}

- (void)setBlinking:(BOOL)blinking
{
    _blinking = blinking;
    
    if (![self isHidden]) {
        if (blinking) {
            [self.layer addAnimation:self.blinkAnimation forKey:@"blink"];
        }
        else {
            [self.layer removeAnimationForKey:@"blink"];
        }
    }
}

- (void)setHidden:(BOOL)hidden
{
    [super setHidden:hidden];
    
    if (hidden) {
        [self.layer removeAllAnimations];
    }
    else {
        if ([self isBlinking]) {
            [self.layer addAnimation:self.blinkAnimation forKey:@"blink"];
        }
    }
}

- (void)my_refresh
{
    UIResponder<FTInputting> *firstResponder = [FTInputSystem sharedInputSystem].firstResponder;
    if (firstResponder == nil) return;
    
    if ([FTInputSystem sharedInputSystem].firstResponderIsResigned) {
        self.tintColor = [UIColor colorWithWhite:0.5 alpha:1.0];
        self.blinking = NO;
    }

    CGRect frame = firstResponder.caretFrame;
    if (CGRectIsNull(frame)) {
        self.hidden = YES;
    }
    else {
        self.frame = frame;
        self.hidden = NO;
    }
}

- (void)addToSuperview:(UIView *)newSuperview
{
    FTAssert(newSuperview);
    [newSuperview addSubview:self];
}

- (void)removeFromSuperview
{
    [super removeFromSuperview];
    
    self.tintColor = nil;
    self.blinking = YES;
}

- (void)respondToApplicationWillEnterForegroundNotification:(NSNotification *)notification
{
    if (![self isHidden] && [self isBlinking]) {
        [self.layer addAnimation:self.blinkAnimation forKey:@"blink"];  //! WORKAROUND: Otherwise, it will stop blinking after re-entering foreground.
    }
}

@end
