//
//  FTApplication.m
//
//  Created by curie on 2/10/15.
//  Copyright (c) 2015 Fish Tribe. All rights reserved.
//

#import "FTApplication.h"


NSString * const FTApplicationDidReceiveEventNotification = @"FTApplicationDidReceiveEventNotification";
NSString * const FTApplicationHitViewUserInfoKey = @"FTApplicationHitViewUserInfoKey";


@interface FTApplication ()

@property (nonatomic, strong, readonly) NSNotification *reusableDidReceiveEventNotification;

@end


@implementation FTApplication

@synthesize reusableDidReceiveEventNotification = _reusableDidReceiveEventNotification;

- (NSNotification *)reusableDidReceiveEventNotification
{
    if (_reusableDidReceiveEventNotification == nil) {
        _reusableDidReceiveEventNotification = [NSNotification notificationWithName:FTApplicationDidReceiveEventNotification object:self userInfo:[NSMutableDictionary dictionaryWithCapacity:0]];
    }
    return _reusableDidReceiveEventNotification;
}

- (void)sendEvent:(UIEvent *)event
{
    //! EXPEDIENT: Specific to dismiss an instance of FTPopoverView.
    NSNotification *notification = self.reusableDidReceiveEventNotification;
    NSMutableDictionary *userInfo = (NSMutableDictionary *)notification.userInfo;
    switch (event.type) {
        case UIEventTypeTouches: {
            UITouch *touch = [[event allTouches] anyObject];
            if (touch.phase == UITouchPhaseBegan && touch.view) {
                userInfo[FTApplicationHitViewUserInfoKey] = touch.view;
                [[NSNotificationCenter defaultCenter] postNotification:notification];
            }
            break;
        }
        case UIEventTypeMotion: {
            //! Shake motion event ≠ Shake gesture
            break;
        }
        case UIEventTypeRemoteControl: {
            //! Supposed to be irrelevant.
            break;
        }
        default: {
            break;
        }
    }
    
    [super sendEvent:event];
}

@end
