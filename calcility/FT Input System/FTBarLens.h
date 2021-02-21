//
//  FTBarLens.h
//
//  Created by curie on 13-2-7.
//  Copyright (c) 2013年 Fish Tribe. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface FTBarLens : UIView

+ (FTBarLens *)sharedBarLens;

- (void)setLocation:(CGPoint)location inView:(UIView *)aView;
- (void)setHidden:(BOOL)hidden atPoint:(CGPoint)point inView:(UIView *)aView;

@end
