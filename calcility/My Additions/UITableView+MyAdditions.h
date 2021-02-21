//
//  UITableView+MyAdditions.h
//
//  Created by curie on 1/1/15.
//  Copyright (c) 2015 Fish Tribe. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface UITableView (MyAdditions)

- (void)my_interactivelySelectRowAtIndexPath:(NSIndexPath *)indexPath animated:(BOOL)animated scrollPosition:(UITableViewScrollPosition)scrollPosition;
- (void)my_interactivelyDeselectRowAtIndexPath:(NSIndexPath *)indexPath animated:(BOOL)animated;

@end
