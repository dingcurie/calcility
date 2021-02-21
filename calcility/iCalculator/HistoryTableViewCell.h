//
//  HistoryTableViewCell.h
//  iCalculator
//
//  Created by curie on 13-1-8.
//  Copyright (c) 2013年 Fish Tribe. All rights reserved.
//

#import <UIKit/UIKit.h>

@class HistoryRecord, MathExpressionView;


@interface HistoryTableViewCell : UITableViewCell

- (id)initWithHostTableView:(FTTableView *)hostTableView reuseIdentifier:(NSString *)reuseIdentifier;  //: Designated Initializer

@property (nonatomic, weak, readonly) FTTableView *hostTableView;
@property (nonatomic, weak) HistoryRecord *record;

- (MathExpressionView *)expressionViewToHighlightByTouch:(UITouch *)touch;

@end


#define HTVC_HORIZ_MARGIN         (g_isPhone ? 8.0 : 12.0)
#define HTVC_TAG_LEADING_MARGIN   (g_isPhone ? 3.0 :  4.0)

#define HTVC_TAG_TOP_MARGIN         2.0
#define HTVC_TAG_HEIGHT            21.0
#define HTVC_TAG_EDITOR_HEIGHT     30.0
#define HTVC_EXPR_TOP_MARGIN        8.0
#define HTVC_EXPR_DEFAULT_HEIGHT   27.0
#define HTVC_EXPR_ANS_GAP           8.0
#define HTVC_ANS_HEIGHT            31.0
#define HTVC_BOTTOM_MARGIN          6.0
