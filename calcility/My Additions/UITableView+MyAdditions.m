//
//  UITableView+MyAdditions.m
//
//  Created by curie on 1/1/15.
//  Copyright (c) 2015 Fish Tribe. All rights reserved.
//

#import "UITableView+MyAdditions.h"


@implementation UITableView (MyAdditions)

- (void)my_interactivelySelectRowAtIndexPath:(NSIndexPath *)indexPath animated:(BOOL)animated scrollPosition:(UITableViewScrollPosition)scrollPosition
{
    if ([self.delegate respondsToSelector:@selector(tableView:willSelectRowAtIndexPath:)]) {
        [self.delegate tableView:self willSelectRowAtIndexPath:indexPath];
    }
    [self selectRowAtIndexPath:indexPath animated:animated scrollPosition:scrollPosition];
    if ([self.delegate respondsToSelector:@selector(tableView:didSelectRowAtIndexPath:)]) {
        [self.delegate tableView:self didSelectRowAtIndexPath:indexPath];
    }
}

- (void)my_interactivelyDeselectRowAtIndexPath:(NSIndexPath *)indexPath animated:(BOOL)animated
{
    if ([self.delegate respondsToSelector:@selector(tableView:willDeselectRowAtIndexPath:)]) {
        [self.delegate tableView:self willDeselectRowAtIndexPath:indexPath];
    }
    [self deselectRowAtIndexPath:indexPath animated:animated];
    if ([self.delegate respondsToSelector:@selector(tableView:didDeselectRowAtIndexPath:)]) {
        [self.delegate tableView:self didDeselectRowAtIndexPath:indexPath];
    }
}

@end
