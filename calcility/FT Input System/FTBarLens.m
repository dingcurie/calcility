//
//  FTBarLens.m
//
//  Created by curie on 13-2-7.
//  Copyright (c) 2013年 Fish Tribe. All rights reserved.
//

#import "FTBarLens.h"
#import "FTTopWindow.h"
#import "FTInputSystem.h"


@interface FTBarLens_WorkerView : UIView

@property (nonatomic) CGPoint location;

@end


@implementation FTBarLens_WorkerView

- (void)drawRect:(CGRect)rect
{
    UIView *marquee = [FTInputSystem sharedInputSystem].selectionSuite.marquee;
    if (marquee.window == nil) return;
    CGRect selectionRect = marquee.frame;
    
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    CGFloat maskTopMargin = 1.5;
    CGFloat maskHeight = g_isPhone ? 32.0 : 45.0;
    CGContextTranslateCTM(ctx, CGRectGetWidth(self.bounds) / 2.0, maskTopMargin + maskHeight / 2.0);
    CGFloat scale = MIN(maskHeight / (CGRectGetHeight(selectionRect) + 2.0), 1.2);
    CGContextScaleCTM(ctx, scale, scale);
    CGContextTranslateCTM(ctx, -self.location.x, -CGRectGetMidY(selectionRect));
    [marquee.superview.layer renderInContext:ctx];
}

@end


#pragma mark -


@interface FTBarLens ()

- (id)init;  //: Designated Initializer

@property (nonatomic, weak, readonly) FTBarLens_WorkerView *workerView;

@end


@implementation FTBarLens

+ (FTBarLens *)sharedBarLens
{
    static FTBarLens *sharedBarLens;
    if (sharedBarLens == nil) {
        sharedBarLens = [[FTBarLens alloc] init];
        [[FTTopWindow sharedTopWindow] addSubview:sharedBarLens];
    }
    return sharedBarLens;
}

- (id)init
{
    UIImage *maskImage = [UIImage imageNamed:@"bar-lens-mask"];
    CGSize size = maskImage.size;
    CGRect frame = CGRectMake(0.0, 0.0, size.width, size.height);

    self = [super initWithFrame:frame];
    if (self) {
        [super setHidden:YES];
        
        FTBarLens_WorkerView *workerView = [[FTBarLens_WorkerView alloc] initWithFrame:frame];
        workerView.backgroundColor = [UIColor whiteColor];
        CALayer *maskLayer = [CALayer layer];
        maskLayer.frame = frame;
        maskLayer.contents = (__bridge id)(maskImage.CGImage);
        workerView.layer.mask = maskLayer;
        [super addSubview:(_workerView = workerView)];
        
        [super addSubview:[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"bar-lens"]]];
    }
    return self;
}

- (void)setLocation:(CGPoint)location inView:(UIView *)aView
{
    FTAssert(aView && aView.window);
    UIView *marquee = [FTInputSystem sharedInputSystem].selectionSuite.marquee;
    if (marquee.window == nil || marquee.window != aView.window) return;
    
    self.workerView.location = [marquee.superview convertPoint:location fromView:aView];
    [self my_refresh];
}

- (void)my_refresh
{
    UIView *marquee = [FTInputSystem sharedInputSystem].selectionSuite.marquee;
    if (marquee.window == nil) return;
    
    [marquee.superview layoutIfNeeded];
    [self.workerView setNeedsDisplay];
    
    CGRect selectionRect = [self.window convertRect:[marquee convertRect:marquee.bounds toView:nil] fromWindow:marquee.window];
    CGPoint location = [self.window convertPoint:[marquee.superview convertPoint:self.workerView.location toView:nil] fromWindow:marquee.window];
    CGFloat bottomY = CGRectGetMinY(selectionRect);
    CGFloat height = CGRectGetHeight(self.bounds);
    if (bottomY >= height) {
        self.center = CGPointMake(location.x, bottomY - height / 2.0);
    }
    else {
        self.center = CGPointMake(location.x, height / 2.0);
    }
}

- (void)setHidden:(BOOL)hidden atPoint:(CGPoint)point inView:(UIView *)aView
{
    FTAssert(aView);
    if (self.hidden == hidden) return;
    
    CGPoint pointInWindow = [self.window convertPoint:[aView convertPoint:point toView:nil] fromView:aView.window];
    if (hidden) {
        [UIView animateWithDuration:0.2 animations:^{
            self.transform = CGAffineTransformMakeScale(0.01, 0.01);
            self.center = pointInWindow;
        } completion:^(BOOL finished) {
            self.transform = CGAffineTransformIdentity;
            [super setHidden:YES];
            [FTTopWindow sharedTopWindow].hidden = YES;
        }];
    }
    else {
        CGPoint centerBak = self.center;
        self.center = pointInWindow;
        self.transform = CGAffineTransformMakeScale(0.01, 0.01);
        [super setHidden:NO];
        [FTTopWindow sharedTopWindow].hidden = NO;
        [UIView animateWithDuration:0.1 animations:^ {
            self.transform = CGAffineTransformIdentity;
            self.center = centerBak;
        }];
    }
}

- (void)setHidden:(BOOL)hidden
{
    if (self.workerView) {
        CGSize size = CGRectStandardize(self.bounds).size;
        [self setHidden:hidden atPoint:CGPointMake(size.width / 2.0, size.height) inView:self];
    }
    else {
        //! [super init...] improperly calls -setHidden: on self, which causes this overriding version to be called.
        [super setHidden:hidden];
    }
}

@end
