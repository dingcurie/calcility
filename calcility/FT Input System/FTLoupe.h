//
//  FTLoupe.h
//
//  Created by curie on 13-1-27.
//  Copyright (c) 2013年 Fish Tribe. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface FTLoupe : UIView

+ (FTLoupe *)sharedLoupe;

- (void)setMagnifyingCenter:(CGPoint)magnifyingCenter inView:(UIView *)aView;

@end
