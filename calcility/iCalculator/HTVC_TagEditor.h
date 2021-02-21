//
//  HTVC_TagEditor.h
//  iCalculator
//
//  Created by curie on 11/21/14.
//  Copyright (c) 2014 Fish Tribe. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface HTVC_TagEditor : UIImageView

@property (nonatomic, weak, readonly) UITextField *textField;
@property (nonatomic) uint32_t colorIndex;

@property (nonatomic, weak, readonly) NSLayoutConstraint *colorBlockLeadingMarginConstraint;
@property (nonatomic, weak, readonly) NSLayoutConstraint *colorBlockWidthConstraint;
@property (nonatomic, weak, readonly) NSLayoutConstraint *textLeadingMarginConstraint;
@property (nonatomic, weak, readonly) NSLayoutConstraint *textTrailingMarginConstraint;

@end


#import "HistoryTableViewCell.h"

#define HTVC_TAG_EDITOR_COLOR_BLOCK_LEADING_MARGIN   HTVC_HORIZ_MARGIN
#define HTVC_TAG_EDITOR_COLOR_BLOCK_WIDTH            HTVC_TAG_HEIGHT
#define HTVC_TAG_EDITOR_TEXT_LEADING_MARGIN         (g_isPhone ? 14.0 : 18.0)
#define HTVC_TAG_EDITOR_TEXT_TRAILING_MARGIN        (g_isPhone ? 12.0 : 16.0)
