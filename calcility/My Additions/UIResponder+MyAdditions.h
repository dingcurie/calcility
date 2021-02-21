//
//  UIResponder+MyAdditions.h
//
//  Created by curie on 13-5-25.
//  Copyright (c) 2013年 Fish Tribe. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface UIResponder (MyAdditions)

+ (UIResponder *)my_firstResponder;

- (void)my_becomeFirstResponderIfNotAlready;
- (void)my_resignFirstResponderIfNotAlready;
- (void)my_showEditingMenu;

@end
