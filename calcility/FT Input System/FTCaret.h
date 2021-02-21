//
//  FTCaret.h
//
//  Created by curie on 13-1-28.
//  Copyright (c) 2013年 Fish Tribe. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface FTCaret : UIImageView

- (id)init;  //: Designated Initializer

@property (nonatomic, getter = isBlinking) BOOL blinking;

- (void)addToSuperview:(UIView *)newSuperview;

@end
