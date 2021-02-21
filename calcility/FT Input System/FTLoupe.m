//
//  FTLoupe.m
//
//  Created by curie on 13-1-27.
//  Copyright (c) 2013年 Fish Tribe. All rights reserved.
//

#import "FTLoupe.h"
#import "FTTopWindow.h"
#import "FTInputSystem.h"


@interface FTLoupe_WorkerView : UIView

@property (nonatomic) CGPoint magnifyingCenter;

@end


@implementation FTLoupe_WorkerView

- (void)drawRect:(CGRect)rect
{
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    CGSize size = CGRectStandardize(self.bounds).size;
    CGContextTranslateCTM(ctx, size.width / 2.0, size.height / 2.0);
    CGContextScaleCTM(ctx, 1.2, 1.2);
    CGContextTranslateCTM(ctx, -self.magnifyingCenter.x, -self.magnifyingCenter.y);
    for (UIWindow *window in [UIApplication sharedApplication].windows) {
        if (window != self.window && window.screen == [UIScreen mainScreen]) {
            CGContextSaveGState(ctx);
            [window.layer renderInContext:ctx];
            CGContextRestoreGState(ctx);
        }
    }
}

@end


#pragma mark -


@interface FTLoupe ()

- (id)init;  //: Designated Initializer

@property (nonatomic, weak, readonly) FTLoupe_WorkerView *workerView;

@end


@implementation FTLoupe

+ (FTLoupe *)sharedLoupe
{
    static FTLoupe *sharedLoupe;
    if (sharedLoupe == nil) {
        sharedLoupe = [[FTLoupe alloc] init];
        [[FTTopWindow sharedTopWindow] addSubview:sharedLoupe];
    }
    return sharedLoupe;
}

- (id)init
{
    UIImage *maskImage = [UIImage imageNamed:@"loupe-mask"];
    CGSize size = maskImage.size;
    CGRect frame = CGRectMake(0.0, 0.0, size.width, size.height);
    
    self = [super initWithFrame:frame];
    if (self) {
        [super setHidden:YES];
                
        FTLoupe_WorkerView *workerView = [[FTLoupe_WorkerView alloc] initWithFrame:frame];
        workerView.backgroundColor = [UIColor whiteColor];
        CALayer *maskLayer = [CALayer layer];
        maskLayer.frame = frame;
        maskLayer.contents = (__bridge id)(maskImage.CGImage);
        workerView.layer.mask = maskLayer;
        [super addSubview:(_workerView = workerView)];
        
        [super addSubview:[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"loupe"]]];
    }
    return self;
}

- (void)setMagnifyingCenter:(CGPoint)magnifyingCenter inView:(UIView *)aView
{
    FTAssert(aView && aView.window);
    id<UICoordinateSpace> screenCoordinateSpace = aView.window.screen.coordinateSpace;
    CGPoint magnifyingCenterInScreen = [aView convertPoint:magnifyingCenter toCoordinateSpace:screenCoordinateSpace];
    CGPoint magnifyingCenterInWindow = [self.window convertPoint:magnifyingCenterInScreen fromCoordinateSpace:screenCoordinateSpace];
    
    self.workerView.magnifyingCenter = magnifyingCenterInScreen;
    [self.workerView setNeedsDisplay];
    
    self.center = CGPointMake(magnifyingCenterInWindow.x, MAX(8.0, magnifyingCenterInWindow.y - CGRectGetHeight(self.bounds) / 2.0));
}

- (void)setHidden:(BOOL)hidden
{
    if (self.hidden == hidden) return;
    
    CGPoint bottomCenter = CGPointMake(self.center.x, CGRectGetMaxY(self.frame));
    if (hidden) {
        [UIView animateWithDuration:0.2 animations:^{
            self.transform = CGAffineTransformMakeScale(0.01, 0.01);
            self.center = bottomCenter;
        } completion:^(BOOL finished) {
            self.transform = CGAffineTransformIdentity;
            [super setHidden:YES];
            [FTTopWindow sharedTopWindow].hidden = YES;
        }];
        
        [FTInputSystem sharedInputSystem].caret.blinking = YES;
    }
    else {
        CGPoint centerBak = self.center;
        self.center = bottomCenter;
        self.transform = CGAffineTransformMakeScale(0.01, 0.01);
        [super setHidden:NO];
        [FTTopWindow sharedTopWindow].hidden = NO;
        [UIView animateWithDuration:0.1 animations:^ {
            self.transform = CGAffineTransformIdentity;
            self.center = centerBak;
        }];
        
        [FTInputSystem sharedInputSystem].caret.blinking = NO;
    }
}

@end
