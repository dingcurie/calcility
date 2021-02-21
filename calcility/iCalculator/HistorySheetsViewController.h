//
//  HistorySheetsViewController.h
//  iCalculator
//
//  Created by curie on 7/7/14.
//  Copyright (c) 2014 Fish Tribe. All rights reserved.
//

#import <UIKit/UIKit.h>

@class HistorySheetsViewController, HistorySheet;


@protocol HistorySheetSelectingDelegate <NSObject>

- (void)historySheetsViewControllerWillDismiss:(HistorySheetsViewController *)historySheetsVC;

@end


@interface HistorySheetsViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, UIPopoverPresentationControllerDelegate>

@property (nonatomic, weak) id<HistorySheetSelectingDelegate> delegate;
@property (nonatomic, strong) HistorySheet *selectedHistorySheet;
@property (nonatomic, copy) NSString *prompt;

@end
