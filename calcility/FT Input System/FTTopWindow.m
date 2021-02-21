//
//  FTTopWindow.m
//
//  Created by curie on 13-6-16.
//  Copyright (c) 2013年 Fish Tribe. All rights reserved.
//

#import "FTTopWindow.h"


@interface FTTW_RootViewController : UIViewController

@end


@implementation FTTW_RootViewController

- (BOOL)prefersStatusBarHidden
{
    return [UIApplication sharedApplication].statusBarHidden;
}

@end


#pragma mark -


@interface FTTopWindow ()

- (id)init;  //: Designated Initializer

@end


@implementation FTTopWindow

+ (FTTopWindow *)sharedTopWindow
{
    static FTTopWindow *sharedTopWindow;
    if (sharedTopWindow == nil) {
        sharedTopWindow = [[FTTopWindow alloc] init];
    }
    return sharedTopWindow;
}

- (id)init
{
    self = [super initWithFrame:[UIScreen mainScreen].bounds];
    if (self) {
        [super setWindowLevel:UIWindowLevelStatusBar];
        [super setAutoresizingMask:UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth];
        [super setRootViewController:[[FTTW_RootViewController alloc] init]];
        [super setUserInteractionEnabled:NO];
        [super setOpaque:NO];
    }
    return self;
}

@end
