//
//  MathUnitInputView.m
//  iCalculator
//
//  Created by curie on 12/7/14.
//  Copyright (c) 2014 Fish Tribe. All rights reserved.
//

#import "MathUnitInputView.h"


@interface MathUnitInputView ()

- (instancetype)init;  //: Designated Initializer

@property (nonatomic, weak, readonly) UIScrollView *scrollView;
@property (nonatomic, weak, readonly) UIView *dockView;
@property (nonatomic, weak, readonly) UIButton *cancelButton;
@property (nonatomic, weak, readonly) UIButton *doneButton;
@property (nonatomic, weak, readonly) UIButton *prevItemButton;
@property (nonatomic, weak, readonly) UIButton *nextItemButton;

- (UIButton *)keyWithTitle:(NSString *)title;
- (void)handleKeyTap:(UIButton *)key;

- (void)handleCancelButtonTap:(id)sender;
- (void)handleDoneButtonTap:(id)sender;
- (void)handlePrevItemButtonTap:(id)sender;
- (void)handleNextItemButtonTap:(id)sender;

@end


@implementation MathUnitInputView

+ (MathUnitInputView *)sharedUnitInputView
{
    static MathUnitInputView *sharedUnitInputView;
    if (sharedUnitInputView == nil) {
        sharedUnitInputView = [[MathUnitInputView alloc] init];
    }
    return sharedUnitInputView;
}

- (instancetype)init
{
    self = [super initWithFrame:CGRectMake(0.0, 0.0, 1.0, g_isPhone ? 35.0 : 52.0)];
    if (self) {
        [super setBackgroundColor:[UIColor colorWithRed:253/255.0 green:254/255.0 blue:254/255.0 alpha:1.0]];
        
        UIImageView *hairline = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"hairline"]];
        hairline.translatesAutoresizingMaskIntoConstraints = NO;
        
        UIScrollView *scrollView = [[UIScrollView alloc] initWithFrame:CGRectZero];
        scrollView.translatesAutoresizingMaskIntoConstraints = NO;
        scrollView.scrollsToTop = NO;
        scrollView.showsHorizontalScrollIndicator = NO;
        scrollView.decelerationRate = UIScrollViewDecelerationRateFast;
        
        [scrollView addSubview:[self keyWithTitle:@"("]];
        [scrollView addSubview:[self keyWithTitle:@")"]];
        [scrollView addSubview:[self keyWithTitle:@"·"]];
        [scrollView addSubview:[self keyWithTitle:@"/"]];
        [scrollView addSubview:[self keyWithTitle:@"²"]];
        [scrollView addSubview:[self keyWithTitle:@"³"]];

        UIView *dockView = [[UIView alloc] initWithFrame:CGRectZero];
        dockView.translatesAutoresizingMaskIntoConstraints = NO;
        
        [self addSubview:(_scrollView = scrollView)];
        [self addSubview:(_dockView = dockView)];
        [self addSubview:hairline];

        if (g_isPhone) {
            UIButton *cancelButton = [UIButton buttonWithType:UIButtonTypeSystem];
            cancelButton.translatesAutoresizingMaskIntoConstraints = NO;
            cancelButton.contentEdgeInsets = UIEdgeInsetsMake(0.0, 10.0, 0.0, 10.0);
            cancelButton.titleLabel.font = [UIFont systemFontOfSize:17.0];
            [cancelButton setTitle:NSLocalizedString(@"Cancel", nil) forState:UIControlStateNormal];
            [cancelButton addTarget:self action:@selector(handleCancelButtonTap:) forControlEvents:UIControlEventTouchUpInside];
            
            UIButton *doneButton = [UIButton buttonWithType:UIButtonTypeSystem];
            doneButton.translatesAutoresizingMaskIntoConstraints = NO;
            doneButton.contentEdgeInsets = UIEdgeInsetsMake(0.0, 10.0, 0.0, 10.0);
            doneButton.titleLabel.font = [UIFont boldSystemFontOfSize:17.0];
            [doneButton setTitle:NSLocalizedString(@"Done", nil) forState:UIControlStateNormal];
            [doneButton addTarget:self action:@selector(handleDoneButtonTap:) forControlEvents:UIControlEventTouchUpInside];
            
            [dockView addSubview:(_cancelButton = cancelButton)];
            [dockView addSubview:(_doneButton = doneButton)];
            
            NSDictionary *views = NSDictionaryOfVariableBindings(cancelButton, doneButton);
            [NSLayoutConstraint activateConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|[cancelButton][doneButton]|" options:(NSLayoutFormatAlignAllTop | NSLayoutFormatAlignAllBottom) metrics:nil views:views]];
            [NSLayoutConstraint activateConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[doneButton]|" options:0 metrics:nil views:views]];
        }
        else {
            UIButton *prevItemButton = [UIButton buttonWithType:UIButtonTypeSystem];
            prevItemButton.translatesAutoresizingMaskIntoConstraints = NO;
            prevItemButton.contentEdgeInsets = UIEdgeInsetsMake(0.0, 25.0, 0.0, 25.0);
            [prevItemButton setImage:[UIImage imageNamed:@"UIButtonBarArrowRightOpposite"] forState:UIControlStateNormal];
            [prevItemButton addTarget:self action:@selector(handlePrevItemButtonTap:) forControlEvents:UIControlEventTouchUpInside];
            
            UIButton *nextItemButton = [UIButton buttonWithType:UIButtonTypeSystem];
            nextItemButton.translatesAutoresizingMaskIntoConstraints = NO;
            nextItemButton.contentEdgeInsets = UIEdgeInsetsMake(0.0, 25.0, 0.0, 25.0);
            [nextItemButton setImage:[UIImage imageNamed:@"UIButtonBarArrowRight"] forState:UIControlStateNormal];
            [nextItemButton addTarget:self action:@selector(handleNextItemButtonTap:) forControlEvents:UIControlEventTouchUpInside];
            
            [dockView addSubview:(_prevItemButton = prevItemButton)];
            [dockView addSubview:(_nextItemButton = nextItemButton)];
            
            NSDictionary *views = NSDictionaryOfVariableBindings(prevItemButton, nextItemButton);
            [NSLayoutConstraint activateConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|[prevItemButton][nextItemButton]|" options:(NSLayoutFormatAlignAllTop | NSLayoutFormatAlignAllBottom) metrics:nil views:views]];
            [NSLayoutConstraint activateConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[nextItemButton]|" options:0 metrics:nil views:views]];
        }
        
        NSDictionary *views = NSDictionaryOfVariableBindings(hairline, scrollView, dockView);

        [NSLayoutConstraint activateConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|[hairline]|" options:0 metrics:nil views:views]];
        [NSLayoutConstraint constraintWithItem:hairline attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeTop multiplier:1.0 constant:0.0].active = YES;
        
        [NSLayoutConstraint activateConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|[scrollView]|" options:0 metrics:nil views:views]];
        [NSLayoutConstraint activateConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[scrollView]|" options:0 metrics:nil views:views]];
        
        [NSLayoutConstraint activateConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"[dockView]|" options:0 metrics:nil views:views]];
        [NSLayoutConstraint activateConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[dockView]|" options:0 metrics:nil views:views]];
        
        UIButton *previousKey = nil;
        for (UIButton *key in scrollView.subviews) {
            if (previousKey) {
                [NSLayoutConstraint constraintWithItem:key attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:previousKey attribute:NSLayoutAttributeTrailing multiplier:1.0 constant:0.0].active = YES;
            }
            else {
                [NSLayoutConstraint constraintWithItem:key attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:scrollView attribute:NSLayoutAttributeLeading multiplier:1.0 constant:0.0].active = YES;
                [NSLayoutConstraint constraintWithItem:key attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:scrollView attribute:NSLayoutAttributeHeight multiplier:1.0 constant:0.0].active = YES;
            }
            [NSLayoutConstraint constraintWithItem:key attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationGreaterThanOrEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:0.0 constant:(g_isPhone ? 41.0 : 49.0)].active = YES;
            [NSLayoutConstraint constraintWithItem:key attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:scrollView attribute:NSLayoutAttributeTop multiplier:1.0 constant:0.0].active = YES;
            [NSLayoutConstraint constraintWithItem:key attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:scrollView attribute:NSLayoutAttributeBottom multiplier:1.0 constant:0.0].active = YES;
            previousKey = key;
        }
        FTAssert_DEBUG(previousKey);
        [NSLayoutConstraint constraintWithItem:previousKey attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:scrollView attribute:NSLayoutAttributeTrailing multiplier:1.0 constant:0.0].active = YES;
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    self.dockView.hidden = (CGRectGetWidth(self.bounds) < 480.0);
    self.scrollView.contentInset = UIEdgeInsetsMake(0.0, 0.0, 0.0, self.dockView.hidden ? 0.0 : CGRectGetWidth(self.dockView.bounds));
}

- (UIButton *)keyWithTitle:(NSString *)title
{
    UIButton *key = [UIButton buttonWithType:UIButtonTypeCustom];
    key.translatesAutoresizingMaskIntoConstraints = NO;
    [key setBackgroundImage:[UIImage imageNamed:@"accessory-key-background"] forState:UIControlStateNormal];
    [key setBackgroundImage:[UIImage imageNamed:@"accessory-key-background-highlighted"] forState:UIControlStateHighlighted];
    key.titleLabel.font = [UIFont systemFontOfSize:(g_isPhone ? 20.0 : 22.0)];
    [key setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [key setTitle:title forState:UIControlStateNormal];
    [key addTarget:self action:@selector(handleKeyTap:) forControlEvents:UIControlEventTouchUpInside];
    return key;
}

- (void)handleKeyTap:(UIButton *)key
{
    UIResponder *firstResponder = [UIResponder my_firstResponder];
    if ([firstResponder conformsToProtocol:@protocol(UITextInput)]) {
        [(UIResponder<UITextInput> *)firstResponder unmarkText];
        [(UIResponder<UITextInput> *)firstResponder insertText:key.titleLabel.text];
    }
}

- (void)handleCancelButtonTap:(id)sender
{
    UIViewController *vc = [(UIView *)[UIResponder my_firstResponder] my_viewController];
    if ([vc respondsToSelector:@selector(handleCancelButtonTap:)]) {
        [vc performSelector:@selector(handleCancelButtonTap:) withObject:sender];
    }
}

- (void)handleDoneButtonTap:(id)sender
{
    UIViewController *vc = [(UIView *)[UIResponder my_firstResponder] my_viewController];
    if ([vc respondsToSelector:@selector(handleDoneButtonTap:)]) {
        [vc performSelector:@selector(handleDoneButtonTap:) withObject:sender];
    }
}

- (void)handlePrevItemButtonTap:(id)sender
{
    UIViewController *vc = [(UIView *)[UIResponder my_firstResponder] my_viewController];
    if ([vc respondsToSelector:@selector(handlePrevItemButtonTap:)]) {
        [vc handlePrevItemButtonTap:sender];
    }
}

- (void)handleNextItemButtonTap:(id)sender
{
    UIViewController *vc = [(UIView *)[UIResponder my_firstResponder] my_viewController];
    if ([vc respondsToSelector:@selector(handleNextItemButtonTap:)]) {
        [vc handleNextItemButtonTap:sender];
    }
}

- (void)my_refresh
{
    UIViewController *vc = [(UIView *)[UIResponder my_firstResponder] my_viewController];
    self.prevItemButton.enabled = ([vc respondsToSelector:@selector(hasPrevItem)] && [vc hasPrevItem]);
    self.nextItemButton.enabled = ([vc respondsToSelector:@selector(hasNextItem)] && [vc hasNextItem]);
}

@end
