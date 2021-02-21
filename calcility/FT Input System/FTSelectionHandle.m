//
//  FTSelectionHandle.m
//
//  Created by curie on 13-4-24.
//  Copyright (c) 2013年 Fish Tribe. All rights reserved.
//

#import "FTInputSystem.h"


@implementation FTSelectionHandle

- (id)initWithType:(FTSelectionHandleType)type
{
    self = [super initWithFrame:CGRectZero];
    if (self) {
        [super setTranslatesAutoresizingMaskIntoConstraints:NO];
        [super setExclusiveTouch:YES];
        
        _type = type;
        
        UIImageView *pole = [[UIImageView alloc] initWithImage:[[UIImage imageNamed:@"selection-handle-pole"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate]];
        pole.translatesAutoresizingMaskIntoConstraints = NO;
        [super addSubview:(_pole = pole)];
        
        UIImageView *knob = [[UIImageView alloc] initWithImage:[[UIImage imageNamed:@"selection-handle-knob"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate]];
        knob.translatesAutoresizingMaskIntoConstraints = NO;
        [super addSubview:(_knob = knob)];
        
        NSDictionary *views = NSDictionaryOfVariableBindings(pole, knob);
        [NSLayoutConstraint constraintWithItem:self attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:0.0 constant:44.0].active = YES;
        [NSLayoutConstraint constraintWithItem:self attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:pole attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:0.0].active = YES;
        [NSLayoutConstraint activateConstraints:[NSLayoutConstraint constraintsWithVisualFormat:(type == FTSelectionHandleTypeStart ? @"V:|-16.0-[knob][pole]-16.0-|" : @"V:|-16.0-[pole][knob]-16.0-|") options:NSLayoutFormatAlignAllCenterX metrics:nil views:views]];
        
        UILongPressGestureRecognizer *pressGestureRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(respondToPressGesture:)];
        pressGestureRecognizer.minimumPressDuration = 0.0;
        [super addGestureRecognizer:pressGestureRecognizer];
    }
    return self;
}

- (void)enableUserInteraction
{
    self.userInteractionEnabled = YES;
}

- (void)setHidden:(BOOL)hidden
{
    if (self.hidden == hidden) return;
    [super setHidden:hidden];
    
    if (hidden) {
        [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(enableUserInteraction) object:nil];
        self.userInteractionEnabled = NO;
    }
    else {
        [self performSelector:@selector(enableUserInteraction) withObject:nil afterDelay:0.25];
    }
}

- (void)setAlpha:(CGFloat)alpha
{
    if (self.alpha == alpha) return;
    [super setAlpha:alpha];
    
    if (alpha < 0.01) {
        [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(enableUserInteraction) object:nil];
        self.userInteractionEnabled = NO;
    }
    else {
        [self performSelector:@selector(enableUserInteraction) withObject:nil afterDelay:0.25];
    }
}

- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event
{
    CGRect bounds = self.bounds;
    
    if (self.pairingSelectionHandle) {
        FTSelectionSuiteMode mode = [FTInputSystem sharedInputSystem].selectionSuite.mode;
        if (mode & FTSelectionSuiteModeLine) {
            CGFloat xOverlap;
            if (self.type == FTSelectionHandleTypeStart) {
                xOverlap = CGRectGetMinX(self.pairingSelectionHandle.frame) - CGRectGetMaxX(self.frame);
                if (xOverlap < 0.0) bounds = CGRectOffset(bounds, xOverlap / 2.0, 0.0);
            }
            else {
                xOverlap = CGRectGetMinX(self.frame) - CGRectGetMaxX(self.pairingSelectionHandle.frame);
                if (xOverlap < 0.0) bounds = CGRectOffset(bounds, -xOverlap / 2.0, 0.0);
            }
        }
    }
    
    return CGRectContainsPoint(bounds, point);
}

- (void)respondToPressGesture:(UILongPressGestureRecognizer *)longPressGestureRecognizer
{
    UIResponder<FTInputting> *firstResponder = [FTInputSystem sharedInputSystem].firstResponder;
    if ([firstResponder respondsToSelector:@selector(selectionHandle:respondToPressGesture:)]) {
        [firstResponder selectionHandle:self respondToPressGesture:longPressGestureRecognizer];
    }
}

@end
