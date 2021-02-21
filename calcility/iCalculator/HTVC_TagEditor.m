//
//  HTVC_TagEditor.m
//  iCalculator
//
//  Created by curie on 11/21/14.
//  Copyright (c) 2014 Fish Tribe. All rights reserved.
//

#import "HTVC_TagEditor.h"
#import "HTVC_ColorPallete.h"
#import "MathUnitInputView.h"


@interface HTVC_TagEditor ()

@property (nonatomic, weak, readonly) UIButton *colorButton;

- (void)handleColorButtonTap:(id)sender;

@end


@implementation HTVC_TagEditor {
    FTPopoverView *__weak _popoverView;
}

- (instancetype)initWithImage:(UIImage *)image
{
    self = [super initWithImage:image];
    if (self) {
        [super setUserInteractionEnabled:YES];
        [super setClipsToBounds:YES];
        
        UIButton *colorButton = [UIButton buttonWithType:UIButtonTypeCustom];
        colorButton.translatesAutoresizingMaskIntoConstraints = NO;
        [colorButton setBackgroundImage:[[UIImage imageNamed:@"opaque-point"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateNormal];
        [colorButton addTarget:self action:@selector(handleColorButtonTap:) forControlEvents:UIControlEventTouchUpInside];
        
        FTTextField *textField = [[FTTextField alloc] initWithFrame:CGRectZero];
        textField.translatesAutoresizingMaskIntoConstraints = NO;
        textField.returnKeyType = UIReturnKeyDone;
        textField.inputAccessoryView = [MathUnitInputView sharedUnitInputView];
        
        [self addSubview:(_colorButton = colorButton)];
        [self addSubview:(_textField = textField)];
        
        NSLayoutConstraint *tmpConstraint;
        tmpConstraint = [NSLayoutConstraint constraintWithItem:colorButton attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeLeading multiplier:1.0 constant:HTVC_TAG_EDITOR_COLOR_BLOCK_LEADING_MARGIN];
        (_colorBlockLeadingMarginConstraint = tmpConstraint).active = YES;
        tmpConstraint = [NSLayoutConstraint constraintWithItem:colorButton attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:0.0 constant:HTVC_TAG_EDITOR_COLOR_BLOCK_WIDTH];
        (_colorBlockWidthConstraint = tmpConstraint).active = YES;
        tmpConstraint = [NSLayoutConstraint constraintWithItem:textField attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:colorButton attribute:NSLayoutAttributeTrailing multiplier:1.0 constant:HTVC_TAG_EDITOR_TEXT_LEADING_MARGIN];
        (_textLeadingMarginConstraint = tmpConstraint).active = YES;
        tmpConstraint = [NSLayoutConstraint constraintWithItem:self attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:textField attribute:NSLayoutAttributeTrailing multiplier:1.0 constant:HTVC_TAG_EDITOR_TEXT_TRAILING_MARGIN];
        (_textTrailingMarginConstraint = tmpConstraint).active = YES;
        
        [NSLayoutConstraint constraintWithItem:textField attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:0.0 constant:HTVC_TAG_HEIGHT].active = YES;
        [NSLayoutConstraint constraintWithItem:textField attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterY multiplier:1.0 constant:0.0].active = YES;
        [NSLayoutConstraint constraintWithItem:colorButton attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:textField attribute:NSLayoutAttributeTop multiplier:1.0 constant:0.0].active = YES;
        [NSLayoutConstraint constraintWithItem:colorButton attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:textField attribute:NSLayoutAttributeBottom multiplier:1.0 constant:0.0].active = YES;
    }
    return self;
}

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event
{
    UIView *hitView = [super hitTest:point withEvent:event];
    if (hitView == self) {
        CGRect colorButtonFrame = self.colorButton.frame;
        CGRect textFieldFrame = self.textField.frame;
        return point.x < (CGRectGetMaxX(colorButtonFrame) + CGRectGetMinX(textFieldFrame)) / 2.0 ? self.colorButton : self.textField;
    }
    return hitView;
}

- (void)setColorIndex:(uint32_t)colorIndex
{
    _colorIndex = colorIndex;
    
    self.tintColor = [HTVC_ColorPallete colorAtIndex:colorIndex];
}

#define STATUS_BAR_HEIGHT   20.0

- (void)handleColorButtonTap:(id)sender
{
    FTPopoverView *popoverView = [[FTPopoverView alloc] init];
    popoverView.keepoutMargin = UIEdgeInsetsMake([UIApplication sharedApplication].statusBarHidden ? 5.0 : STATUS_BAR_HEIGHT, g_isPhone ? 4.0 : 6.0, ((UITableView *)[self my_containingViewOfClass:[UITableView class]]).contentInset.bottom, g_isPhone ? 4.0 : 6.0);
    
    UIView *contentView = popoverView.contentView;
    UIButton *previousButton = nil;
    uint32_t colorIndex = 0;
    for (UIColor *color in [HTVC_ColorPallete allColors]) {
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        button.translatesAutoresizingMaskIntoConstraints = NO;
        button.tintColor = color;
        [button setImage:[[UIImage imageNamed:(colorIndex == self.colorIndex ? @"opaque-block-22-boxed" : @"opaque-block-22")] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateNormal];
        button.tag = colorIndex++;
        [button addTarget:self action:@selector(handleColorSelectingButtonTap:) forControlEvents:UIControlEventTouchUpInside];
        [contentView addSubview:button];
        [NSLayoutConstraint constraintWithItem:button attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:0.0 constant:44.0].active = YES;
        [NSLayoutConstraint constraintWithItem:button attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:0.0 constant:44.0].active = YES;
        if (previousButton) {
            [NSLayoutConstraint constraintWithItem:button attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:previousButton attribute:NSLayoutAttributeTrailing multiplier:1.0 constant:0.0].active = YES;
            [NSLayoutConstraint constraintWithItem:button attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:previousButton attribute:NSLayoutAttributeTop multiplier:1.0 constant:0.0].active = YES;
            [NSLayoutConstraint constraintWithItem:button attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:previousButton attribute:NSLayoutAttributeBottom multiplier:1.0 constant:0.0].active = YES;
        }
        else {
            [NSLayoutConstraint constraintWithItem:button attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:contentView attribute:NSLayoutAttributeLeading multiplier:1.0 constant:0.0].active = YES;
            [NSLayoutConstraint constraintWithItem:button attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:contentView attribute:NSLayoutAttributeTop multiplier:1.0 constant:0.0].active = YES;
            [NSLayoutConstraint constraintWithItem:button attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:contentView attribute:NSLayoutAttributeBottom multiplier:1.0 constant:0.0].active = YES;
        }
        previousButton = button;
    }
    FTAssert_DEBUG(previousButton);
    [NSLayoutConstraint constraintWithItem:previousButton attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:contentView attribute:NSLayoutAttributeTrailing multiplier:1.0 constant:0.0].active = YES;

    [(_popoverView = popoverView) showFromView:sender withInsets:UIEdgeInsetsZero];
}

- (void)handleColorSelectingButtonTap:(UIButton *)button
{
    [[NSUserDefaults standardUserDefaults] setInteger:(self.colorIndex = (uint32_t)button.tag) forKey:@"DefaultTagColorIndex"];
    
    [_popoverView dismissAnimated:YES];
}

@end
