//
//  FTPopoverView.m
//
//  Created by curie on 12/12/14.
//  Copyright (c) 2014 Fish Tribe. All rights reserved.
//

#import "FTPopoverView.h"


@interface FTPopoverView ()

@property (nonatomic, weak, readonly) UIImageView *arrow;

@end


@implementation FTPopoverView

- (instancetype)init
{
    self = [super initWithFrame:CGRectZero];
    if (self) {
        [super setBackgroundColor:[UIColor clearColor]];
        self.layer.shadowOpacity = 0.5;
        self.layer.shadowRadius = 4.0;
        self.layer.shadowOffset = CGSizeMake(0.0, 2.0);
        
        UIView *contentView = [[UIView alloc] init];
        contentView.backgroundColor = [UIColor whiteColor];
        contentView.layer.cornerRadius = 5.0;
        contentView.layer.masksToBounds = YES;
        
        UIImageView *arrow = [[UIImageView alloc] init];
        
        [self addSubview:(_arrow = arrow)];
        [self addSubview:(_contentView = contentView)];
    }
    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)showFromView:(UIView *)sourceView withInsets:(UIEdgeInsets)insets
{
    UIView *rootView = sourceView.window.rootViewController.view;
    if (rootView == nil) {
        FTAssert_DEBUG(NO);
        return;
    }
    CGSize rootSize = CGRectStandardize(rootView.bounds).size;
    CGRect sourceRect = UIEdgeInsetsInsetRect([rootView convertRect:sourceView.bounds fromView:sourceView], insets);
    UIImage *arrowImage = [UIImage imageNamed:@"FTPopoverArrow"];
    CGSize arrowSize = arrowImage.size;
    CGFloat capRadius = self.contentView.layer.cornerRadius;
    CGSize contentSize = [self.contentView systemLayoutSizeFittingSize:UILayoutFittingCompressedSize];
    CGFloat minimalDimension = 2.0 * capRadius + arrowSize.width;
    if (contentSize.width < minimalDimension) {
        contentSize.width = minimalDimension;
    }
    if (contentSize.height < minimalDimension) {
        contentSize.height = minimalDimension;
    }
    
    if (contentSize.height + arrowSize.height <= CGRectGetMinY(sourceRect) - self.keepoutMargin.top) {
        // [ ⌄    ]
        self.arrow.image = arrowImage;
        
        CGFloat originX = CGRectGetMidX(sourceRect) - contentSize.width / 2.0;
        CGFloat arrowOriginX = (contentSize.width - arrowSize.width) / 2.0;
        CGFloat leftSpace = originX - self.keepoutMargin.left;
        if (leftSpace < 0.0) {
            originX += -leftSpace;
            arrowOriginX -= MIN(-leftSpace, arrowOriginX - capRadius);
        }
        else {
            CGFloat rightSpace = rootSize.width - self.keepoutMargin.right - (originX + contentSize.width);
            if (rightSpace < 0.0) {
                originX -= -rightSpace;
                arrowOriginX += MIN(-rightSpace, arrowOriginX - capRadius);
            }
        }
        self.frame = CGRectMake(round(originX), round(CGRectGetMinY(sourceRect)) - (contentSize.height + arrowSize.height), contentSize.width, contentSize.height + arrowSize.height);
        self.contentView.frame = CGRectMake(0.0, 0.0, contentSize.width, contentSize.height);
        self.arrow.frame = CGRectMake(round(arrowOriginX), contentSize.height, arrowSize.width, arrowSize.height);
    }
    else if (contentSize.height + arrowSize.height <= rootSize.height - self.keepoutMargin.bottom - CGRectGetMaxY(sourceRect)) {
        // [ ^    ]
        self.arrow.image = [UIImage imageWithCGImage:arrowImage.CGImage scale:arrowImage.scale orientation:UIImageOrientationDown];
        
        CGFloat originX = CGRectGetMidX(sourceRect) - contentSize.width / 2.0;
        CGFloat arrowOriginX = (contentSize.width - arrowSize.width) / 2.0;
        CGFloat leftSpace = originX - self.keepoutMargin.left;
        if (leftSpace < 0.0) {
            originX += -leftSpace;
            arrowOriginX -= MIN(-leftSpace, arrowOriginX - capRadius);
        }
        else {
            CGFloat rightSpace = rootSize.width - self.keepoutMargin.right - (originX + contentSize.width);
            if (rightSpace < 0.0) {
                originX -= -rightSpace;
                arrowOriginX += MIN(-rightSpace, arrowOriginX - capRadius);
            }
        }
        self.frame = CGRectMake(round(originX), round(CGRectGetMaxY(sourceRect)), contentSize.width, arrowSize.height + contentSize.height);
        self.arrow.frame = CGRectMake(round(arrowOriginX), 0.0, arrowSize.width, arrowSize.height);
        self.contentView.frame = CGRectMake(0.0, arrowSize.height, contentSize.width, contentSize.height);
    }
    else if (contentSize.width + arrowSize.height <= rootSize.width - self.keepoutMargin.right - CGRectGetMaxX(sourceRect)) {
        // <[      ]
        self.arrow.image = [UIImage imageWithCGImage:arrowImage.CGImage scale:arrowImage.scale orientation:UIImageOrientationRight];
        
        CGFloat originY = CGRectGetMidY(sourceRect) - contentSize.height / 2.0;
        CGFloat arrowOriginY = (contentSize.height - arrowSize.width) / 2.0;
        CGFloat topSpace = originY - self.keepoutMargin.top;
        if (topSpace < 0.0) {
            originY += -topSpace;
            arrowOriginY -= MIN(-topSpace, arrowOriginY - capRadius);
        }
        else {
            CGFloat bottomSpace = rootSize.height - self.keepoutMargin.bottom - (originY + contentSize.height);
            if (bottomSpace < 0.0) {
                originY -= -bottomSpace;
                arrowOriginY += MIN(-bottomSpace, arrowOriginY - capRadius);
            }
        }
        self.frame = CGRectMake(round(CGRectGetMaxX(sourceRect)), round(originY), arrowSize.height + contentSize.width, contentSize.height);
        self.arrow.frame = CGRectMake(0.0, round(arrowOriginY), arrowSize.height, arrowSize.width);
        self.contentView.frame = CGRectMake(arrowSize.height, 0.0, contentSize.width, contentSize.height);
    }
    else if (contentSize.width + arrowSize.height <= CGRectGetMinX(sourceRect) - self.keepoutMargin.left) {
        // [      ]>
        self.arrow.image = [UIImage imageWithCGImage:arrowImage.CGImage scale:arrowImage.scale orientation:UIImageOrientationLeft];
        
        CGFloat originY = CGRectGetMidY(sourceRect) - contentSize.height / 2.0;
        CGFloat arrowOriginY = (contentSize.height - arrowSize.width) / 2.0;
        CGFloat topSpace = originY - self.keepoutMargin.top;
        if (topSpace < 0.0) {
            originY += -topSpace;
            arrowOriginY -= MIN(-topSpace, arrowOriginY - capRadius);
        }
        else {
            CGFloat bottomSpace = rootSize.height - self.keepoutMargin.bottom - (originY + contentSize.height);
            if (bottomSpace < 0.0) {
                originY -= -bottomSpace;
                arrowOriginY += MIN(-bottomSpace, arrowOriginY - capRadius);
            }
        }
        self.frame = CGRectMake(round(CGRectGetMinX(sourceRect)) - (contentSize.width + arrowSize.height), round(originY), contentSize.width + arrowSize.height, contentSize.height);
        self.contentView.frame = CGRectMake(0.0, 0.0, contentSize.width, contentSize.height);
        self.arrow.frame = CGRectMake(contentSize.width, round(arrowOriginY), arrowSize.height, arrowSize.width);
    }
    else {
        FTAssert_DEBUG(NO);
        return;
    }
    
    NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
    [notificationCenter addObserver:self selector:@selector(respondToApplicationDidReceiveEventNotification:) name:FTApplicationDidReceiveEventNotification object:nil];
    [notificationCenter addObserver:self selector:@selector(respondToApplicationWillChangeStatusBarOrientationNotification:) name:UIApplicationWillChangeStatusBarOrientationNotification object:nil];
    [notificationCenter addObserver:self selector:@selector(respondToApplicationDidEnterBackgroundNotification:) name:UIApplicationDidEnterBackgroundNotification object:nil];

    [rootView addSubview:self];
    self.alpha = 1.0;
}

- (void)dismissAnimated:(BOOL)animated
{
    if (self.alpha < 0.01) return;
    
    NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
    [notificationCenter removeObserver:self name:FTApplicationDidReceiveEventNotification object:nil];
    [notificationCenter removeObserver:self name:UIApplicationWillChangeStatusBarOrientationNotification object:nil];
    [notificationCenter removeObserver:self name:UIApplicationDidEnterBackgroundNotification object:nil];
    
    if (animated) {
        [UIView animateWithDuration:0.25 animations:^{
            self.alpha = 0.0;
        } completion:^(BOOL finished) {
            [self removeFromSuperview];
        }];
    }
    else {
        self.alpha = 0.0;
        [self removeFromSuperview];
    }
}

- (void)respondToApplicationDidReceiveEventNotification:(NSNotification *)notification
{
    if (![notification.userInfo[FTApplicationHitViewUserInfoKey] isDescendantOfView:self]) {
        [self dismissAnimated:YES];
    }
}

- (void)respondToApplicationWillChangeStatusBarOrientationNotification:(NSNotification *)notification
{
    [self dismissAnimated:NO];
}

- (void)respondToApplicationDidEnterBackgroundNotification:(NSNotification *)notification
{
    [self dismissAnimated:NO];
}

@end
