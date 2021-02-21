//
//  HistorySectionHeader.m
//  iCalculator
//
//  Created by curie on 6/24/14.
//  Copyright (c) 2014 Fish Tribe. All rights reserved.
//

#import "HistorySectionHeader.h"


@implementation HistorySectionHeader

- (id)initWithReuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithReuseIdentifier:reuseIdentifier];
    if (self) {
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectZero];
        label.translatesAutoresizingMaskIntoConstraints = NO;
        label.font = [UIFont systemFontOfSize:12.0];
        label.enabled = NO;
        
        UIView *contentView = self.contentView;
        [contentView addSubview:(_label = label)];
        
        [NSLayoutConstraint constraintWithItem:label attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:contentView attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:0.0].active = YES;
        [NSLayoutConstraint constraintWithItem:label attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:contentView attribute:NSLayoutAttributeCenterY multiplier:1.0 constant:0.0].active = YES;
    }
    return self;
}

@end
