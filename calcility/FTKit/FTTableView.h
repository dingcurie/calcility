//
//  FTTableView.h
//
//  Created by curie on 1/1/15.
//  Copyright (c) 2015 Fish Tribe. All rights reserved.
//

#import <UIKit/UIKit.h>


typedef NS_ENUM(NSUInteger, FTTableViewMode) {
    FTTableViewNormalMode = 0,
    FTTableViewBatchEditingMode,
    FTTableViewEditingInPlaceMode,
};


@class FTTableView;


@protocol FTTableViewDelegate <UITableViewDelegate>

- (void)tableViewDidTriggerPullDownAction:(FTTableView *)tableView;

@optional

- (void)tableView:(FTTableView *)tableView willTransitionToMode:(FTTableViewMode)targetMode animated:(BOOL)animated;
- (void)tableView:(FTTableView *)tableView didTransitionFromMode:(FTTableViewMode)previousMode animated:(BOOL)animated;

@end


@interface FTTableView : UITableView

@property (nonatomic) FTTableViewMode mode;
@property (nonatomic, weak) id<FTTableViewDelegate> delegate;
@property (nonatomic) BOOL discardsChanges;
@property (nonatomic) BOOL drawoutHeaderIsHidden;
@property (nonatomic, strong) UIView *drawoutHeaderView;
@property (nonatomic, strong) UIView *highlightedDrawoutHeaderView;

- (void)setMode:(FTTableViewMode)mode animated:(BOOL)animated;
- (void)reloadDataSmoothly;

@end
