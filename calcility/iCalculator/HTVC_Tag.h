//
//  HTVC_Tag.h
//  iCalculator
//
//  Created by curie on 11/20/14.
//  Copyright (c) 2014 Fish Tribe. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface HTVC_Tag : UIImageView

@property (nonatomic, weak, readonly) UILabel *label;
@property (nonatomic) uint32_t colorIndex;

@property (nonatomic, weak, readonly) NSLayoutConstraint *colorBlockLeadingMarginConstraint;
@property (nonatomic, weak, readonly) NSLayoutConstraint *colorBlockWidthConstraint;
@property (nonatomic, weak, readonly) NSLayoutConstraint *textLeadingMarginConstraint;
@property (nonatomic, weak, readonly) NSLayoutConstraint *textTrailingMarginConstraint;

@end


#import "HistoryTableViewCell.h"

#define HTVC_TAG_COLOR_BLOCK_LEADING_MARGIN    0.0
#define HTVC_TAG_COLOR_BLOCK_WIDTH             5.0
#define HTVC_TAG_TEXT_LEADING_MARGIN           7.0
#define HTVC_TAG_TEXT_TRAILING_MARGIN         10.0
