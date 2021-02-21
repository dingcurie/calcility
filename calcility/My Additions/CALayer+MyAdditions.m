//
//  CALayer+MyAdditions.m
//
//  Created by curie on 12/18/14.
//  Copyright (c) 2014 Fish Tribe. All rights reserved.
//

#import "CALayer+MyAdditions.h"


@implementation CALayer (MyAdditions)

- (void)my_removeAnimationForKeyPath:(NSString *)keyPath
{
    NSString *keyPathDot = [keyPath stringByAppendingString:@"."];
    for (NSString *theKey in [self animationKeys]) {
        CAAnimation *theAnimation = [self animationForKey:theKey];
        if ([theAnimation isKindOfClass:[CAPropertyAnimation class]]) {
            NSString *theKeyPath = ((CAPropertyAnimation *)theAnimation).keyPath;
            if ([theKeyPath isEqualToString:keyPath] || [theKeyPath hasPrefix:keyPathDot]) {
                [self removeAnimationForKey:theKey];
            }
        }
    }
}

@end
