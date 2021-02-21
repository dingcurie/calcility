//
//  MainViewController.m
//  iCalculator
//
//  Created by curie on 12-10-1.
//  Copyright (c) 2012年 Fish Tribe. All rights reserved.
//

#import "MainViewController.h"
#import "ViewControllerDropAnimator.h"
#import "PreferencesViewController.h"
#import "HistorySheetsViewController.h"
#import "HistorySectionHeader.h"
#import "HistoryTableViewCell.h"
#import "HistoryRecord.h"
#import "HistorySheet.h"
#import "MathEnvironment.h"
#import "MathEditableExpressionView.h"
#import "MathNumber.h"
#import "MathConcreteOperators.h"
#import "MathUnitInputView.h"
#import <MessageUI/MessageUI.h>


@interface MainViewController () <HistorySheetSelectingDelegate, UINavigationBarDelegate, NSFetchedResultsControllerDelegate, UITableViewDataSource, FTTableViewDelegate, UIActionSheetDelegate, MathEditableExpressionViewDelegate, UIGestureRecognizerDelegate, UIViewControllerTransitioningDelegate>

@property (nonatomic, copy) BOOL (^statusBarShouldHide)(void);
@property (nonatomic, strong) HistorySheet *historySheet;
@property (nonatomic, strong, readonly) NSFetchedResultsController *fetchedResultsController;
@property (nonatomic, strong, readonly) NSManagedObjectContext *managedObjectContext;

@property (nonatomic, strong, readonly) NSDateFormatter *canonicalDateFormatter;
@property (nonatomic, strong, readonly) NSDateFormatter *succinctDateFormatter;
@property (nonatomic, readonly) NSInteger thisYear;
@property (nonatomic, strong, readonly) NSDate *yesterdayOutset;

@property (weak, nonatomic) IBOutlet FTTableView *historyTableView;

@property (weak, nonatomic) IBOutlet UINavigationBar *navigationBar;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *navigationBarTopToTopGuideConstraint;
@property (strong, nonatomic) IBOutlet UINavigationItem *historyNavigationItem;
@property (weak, nonatomic) IBOutlet UIButton *historySheetTitleButton;
@property (weak, nonatomic) IBOutlet UIImageView *historySheetTitleDisclosureIndicator;

@property (weak, nonatomic) IBOutlet UIToolbar *toolbar;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *toolbarBottomSpaceConstraint;

@property (strong, nonatomic) IBOutlet UIBarButtonItem *listBarButtonItem;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *cancelBarButtonItem;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *doneBarButtonItem;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *infoBarButtonItem;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *selectBarButtonItem;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *deleteBarButtonItem;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *moveBarButtonItem;

@property (weak, nonatomic) IBOutlet UIView *editorBackView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *editorIntrinsicHeightConstraint;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *editorBottomSpaceConstraint;
@property (nonatomic, strong, readonly) NSLayoutConstraint *editorTopClearConstraint;
@property (nonatomic, strong, readonly) NSLayoutConstraint *editorHideAtBottomConstraint;
@property (nonatomic, strong, readonly) NSLayoutConstraint *editorStretchToTopConstraint;
@property (nonatomic, strong, readonly) NSLayoutConstraint *editableExpressionViewMinimumHeightConstraint;

@property (nonatomic, weak, readonly) UIScrollView *editableExpressionScrollView;
@property (nonatomic, weak, readonly) MathEditableExpressionView *editableExpressionView;
@property (nonatomic, weak, readonly) UILabel *equalSign;
@property (nonatomic, weak, readonly) MathExpressionView *answerExpressionView;
@property (nonatomic, strong) MathUnit *answerDeducedAngleUnit;
@property (nonatomic) BOOL answerIsInDegree;
@property (nonatomic) BOOL answerUnitIsAssignedByUser;

@property (nonatomic, weak, readonly) UIView *auxKeypad;
@property (nonatomic, weak, readonly) UIButton *downAuxKey;
@property (nonatomic, weak, readonly) UIButton *undoAuxKey;
@property (nonatomic, weak, readonly) UIButton *redoAuxKey;

- (void)registerKeyboardNotifications;
- (void)unregisterKeyboardNotifications;

- (void)showMathKeyboard;
- (void)hideMathKeyboard;
- (void)handleDownAuxKeyTap:(id)sender;

- (void)updateAnswer;
- (void)setNeedsPerformFetch;
- (void)reloadHistory;
- (void)saveEditorState;

- (IBAction)handleTitleButtonTap:(id)sender;
- (IBAction)handleMoveButtonTap:(id)sender;
- (IBAction)handleListButtonTap:(id)sender;
- (IBAction)handleCancelButtonTap:(id)sender;
- (IBAction)handleDoneButtonTap:(id)sender;
- (IBAction)handleSelectButtonTap:(id)sender;
- (IBAction)handleDeleteButtonTap:(id)sender;

- (void)scrollEditableExpressionView:(MathEditableExpressionView *)editableExpressionView needsBecomeFirstResponder:(BOOL)needsBecomeFirstResponder;

@end


#define FETCH_LIMIT  25
#define STATUS_BAR_HEIGHT      20.0
#define NAVIGATION_BAR_HEIGHT  44.0
#define TOOLBAR_HEIGHT         44.0


@implementation MainViewController {
    NSInvocation *_invocation;
    BOOL _isFirstRun;
    BOOL _needsPerformFetch;
    BOOL _editorIsDragging;
    BOOL _editorNeedsBecomeFirstResponder;
    BOOL _forcesStatusBarHidden;
    BOOL _selectionInverted;
    UIStatusBarAnimation _statusBarAnimation;
    UIEdgeInsets _historyTableViewSeparatorInsetBak;
    UIColor *_historyTableViewBackgroundColorBak;
    UIColor *_historyTableViewCellBackgroundColor;
    CGRect _historyTableViewBoundsBeforeModeTransition;
    CGSize _editableExpressionViewIntrinsicContentSizeBeforeChange;
    CGPoint _editableExpressionScrollViewContentBLOffsetBeforeChange;
    NSIndexPath *_indexPathForScrollTarget;
    NSIndexPath *_indexPathForNewHistoryRecord;
}

@synthesize historySheet = _historySheet;
@synthesize fetchedResultsController = _fetchedResultsController;
@synthesize managedObjectContext = _managedObjectContext;
@synthesize canonicalDateFormatter = _canonicalDateFormatter, succinctDateFormatter = _succinctDateFormatter;
@synthesize thisYear = _thisYear, yesterdayOutset = _yesterdayOutset;

#pragma mark -

- (UIBarPosition)positionForBar:(id<UIBarPositioning>)bar
{
    return UIBarPositionTopAttached;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    UIView *view = self.view;
    CGSize viewSize = CGRectStandardize(view.bounds).size;
    _isFirstRun = YES;
    _editorNeedsBecomeFirstResponder = YES;
    _statusBarAnimation = UIStatusBarAnimationSlide;
    
    UILabel *historySheetTitleLabel = self.historySheetTitleButton.titleLabel;
    historySheetTitleLabel.textAlignment = NSTextAlignmentCenter;
    if (g_isPhone) {
        historySheetTitleLabel.adjustsFontSizeToFitWidth = YES;
        historySheetTitleLabel.minimumScaleFactor = 15.0 / 17.0;
    }
    
    FTTableView *historyTableView = self.historyTableView;
    historyTableView.exclusiveTouch = YES;
    historyTableView.rowHeight = HTVC_EXPR_TOP_MARGIN + HTVC_EXPR_DEFAULT_HEIGHT + HTVC_EXPR_ANS_GAP + HTVC_ANS_HEIGHT + HTVC_BOTTOM_MARGIN + 1.0/*Separator*/;
    historyTableView.backgroundColor = [UIColor colorWithHue:211/359.0 saturation:0.15 brightness:1.0 alpha:1.0];
    _historyTableViewCellBackgroundColor = historyTableView.backgroundColor;
    historyTableView.separatorColor = [UIColor colorWithWhite:0.0 alpha:0.1];
    if ([UIView instancesRespondToSelector:@selector(layoutMargins)]) {
        historyTableView.layoutMargins = UIEdgeInsetsZero;
    }
    historyTableView.separatorInset = UIEdgeInsetsZero;
    
    UILabel *historyDrawoutHeader = [[UILabel alloc] init];
    historyDrawoutHeader.backgroundColor = historyTableView.backgroundColor;
    historyDrawoutHeader.enabled = NO;
    historyDrawoutHeader.text = NSLocalizedString(@"Load More", nil);
    [historyDrawoutHeader sizeToFit];
    historyTableView.drawoutHeaderView = historyDrawoutHeader;
    
    UILabel *highlightedHistoryDrawoutHeader = [[UILabel alloc] initWithFrame:historyDrawoutHeader.frame];
    highlightedHistoryDrawoutHeader.backgroundColor = historyTableView.backgroundColor;
    highlightedHistoryDrawoutHeader.textColor = historyTableView.tintColor;
    highlightedHistoryDrawoutHeader.font = historyDrawoutHeader.font;
    highlightedHistoryDrawoutHeader.text = historyDrawoutHeader.text;
    historyTableView.highlightedDrawoutHeaderView = highlightedHistoryDrawoutHeader;
    
    UINavigationBar *navigationBar = self.navigationBar;
    UIView *editorBackView = self.editorBackView;
    
    MathKeyboard *keyboard = [MathKeyboard sharedKeyboard];
    keyboard.translatesAutoresizingMaskIntoConstraints = NO;
    
    UILayoutGuide *refKeyboard = [[UILayoutGuide alloc] init];
    UILayoutGuide *refEditor = [[UILayoutGuide alloc] init];
    
    [view addLayoutGuide:refEditor];
    [view addLayoutGuide:refKeyboard];
    [view addSubview:keyboard];
    
    UIScrollView *editableExpressionScrollView = [[UIScrollView alloc] initWithFrame:CGRectZero];
    editableExpressionScrollView.translatesAutoresizingMaskIntoConstraints = NO;
    editableExpressionScrollView.delegate = self;
    editableExpressionScrollView.backgroundColor = editorBackView.backgroundColor;
    editableExpressionScrollView.directionalLockEnabled = YES;
    editableExpressionScrollView.decelerationRate = UIScrollViewDecelerationRateFast;
    editableExpressionScrollView.scrollsToTop = NO;
    
    UIView *answerBackView = [[UIView alloc] initWithFrame:CGRectZero];
    answerBackView.translatesAutoresizingMaskIntoConstraints = NO;
    answerBackView.userInteractionEnabled = NO;
    answerBackView.backgroundColor = [UIColor colorWithWhite:0.98 alpha:1.0];
    answerBackView.clipsToBounds = YES;  //! WORKAROUND: Special contentMode of MathExpressionView makes its rotation animation obtrusive since iOS 7.1.
    
    UIView *auxKeypad = [[UIView alloc] initWithFrame:CGRectZero];
    auxKeypad.translatesAutoresizingMaskIntoConstraints = NO;
    auxKeypad.backgroundColor = [UIColor clearColor];
    auxKeypad.alpha = 0.0;
    
    [editorBackView addSubview:(_editableExpressionScrollView = editableExpressionScrollView)];
    [editorBackView addSubview:answerBackView];
    [editorBackView addSubview:(_auxKeypad = auxKeypad)];
    
    MathEditableExpressionView *editableExpressionView = [[MathEditableExpressionView alloc] initWithFrame:CGRectZero];
    editableExpressionView.translatesAutoresizingMaskIntoConstraints = NO;
    editableExpressionView.exclusiveTouch = YES;
    editableExpressionView.backgroundColor = editableExpressionScrollView.backgroundColor;
    editableExpressionView.fontSize = g_isPhone ? 30.0 + MAX(0.0, MIN(5.0, trunc((viewSize.width - 320.0) / 10.0))) : 42.0;
    editableExpressionView.delegate = self;
    editableExpressionView.longPressGestureRecognizer.delegate = self;
    
    [editableExpressionScrollView addSubview:(_editableExpressionView = editableExpressionView)];
    
    MathExpressionView *answerExpressionView = [[MathExpressionView alloc] initWithFrame:CGRectZero];
    answerExpressionView.translatesAutoresizingMaskIntoConstraints = NO;
    answerExpressionView.backgroundColor = answerBackView.backgroundColor;
    answerExpressionView.fontSize = editableExpressionView.fontSize;
    
    UILabel *equalSign = [[UILabel alloc] initWithFrame:CGRectZero];
    equalSign.translatesAutoresizingMaskIntoConstraints = NO;
    equalSign.text = @"= ";
    equalSign.font = [UIFont fontWithName:@"TimesNewRomanPS-BoldMT" size:answerExpressionView.fontSize];
    
    decQuad defaultAnswer;
    decQuadFromString(&defaultAnswer, "1E-9", &DQ_set);
    CGFloat defaultAnswerHeight = CGRectGetHeight([[MathExpression expressionFromValue:defaultAnswer inDegree:NO] rectWhenDrawAtPoint:CGPointZero withFontSize:answerExpressionView.fontSize]);
    UIEdgeInsets editableExpressionViewInsets = editableExpressionView.insets;
    answerExpressionView.insets = UIEdgeInsetsMake(3.0, editableExpressionViewInsets.left + equalSign.intrinsicContentSize.width, 3.0, 0.0);
    CGFloat answerBackViewHeight = answerExpressionView.insets.top + defaultAnswerHeight + answerExpressionView.insets.bottom;
    editableExpressionViewInsets.bottom += answerBackViewHeight;
    editableExpressionView.insets = editableExpressionViewInsets;
    editableExpressionScrollView.scrollIndicatorInsets = UIEdgeInsetsMake(0.0, 0.0, answerBackViewHeight, 0.0);

    [answerBackView addSubview:(_answerExpressionView = answerExpressionView)];
    [answerBackView addSubview:(_equalSign = equalSign)];
    
    UIButton *undoAuxKey = [UIButton buttonWithType:UIButtonTypeCustom];
    undoAuxKey.translatesAutoresizingMaskIntoConstraints = NO;
    [undoAuxKey setImage:[[UIImage imageNamed:@"auxkey-undo"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateNormal];
    [undoAuxKey setImage:[UIImage imageNamed:@"auxkey-undo-disabled"] forState:UIControlStateDisabled];
    [undoAuxKey addTarget:editableExpressionView.undoManager action:@selector(undo) forControlEvents:UIControlEventTouchUpInside];
    undoAuxKey.enabled = NO;
    
    UIButton *redoAuxKey = [UIButton buttonWithType:UIButtonTypeCustom];
    redoAuxKey.translatesAutoresizingMaskIntoConstraints = NO;
    [redoAuxKey setImage:[[UIImage imageNamed:@"auxkey-redo"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateNormal];
    [redoAuxKey setImage:[UIImage imageNamed:@"auxkey-redo-disabled"] forState:UIControlStateDisabled];
    [redoAuxKey addTarget:editableExpressionView.undoManager action:@selector(redo) forControlEvents:UIControlEventTouchUpInside];
    redoAuxKey.enabled = NO;
    
    UIButton *downAuxKey = [UIButton buttonWithType:UIButtonTypeCustom];
    if (g_isPhone) {
        downAuxKey.translatesAutoresizingMaskIntoConstraints = NO;
        [downAuxKey setImage:[[UIImage imageNamed:@"auxkey-down"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateNormal];
        [downAuxKey addTarget:self action:@selector(handleDownAuxKeyTap:) forControlEvents:UIControlEventTouchUpInside];
    }
    
    [auxKeypad addSubview:(_redoAuxKey = redoAuxKey)];
    [auxKeypad addSubview:(_undoAuxKey = undoAuxKey)];
    if (g_isPhone) {
        [auxKeypad addSubview:(_downAuxKey = downAuxKey)];
    }
    
    /**************************************************************************/
    NSDictionary *views = NSDictionaryOfVariableBindings(navigationBar, refEditor, refKeyboard, editorBackView, keyboard, editableExpressionScrollView, editableExpressionView, answerBackView, answerExpressionView, equalSign, auxKeypad, undoAuxKey, redoAuxKey, downAuxKey);
    NSDictionary *metrics = @{@"answerBackViewHeight": @(answerBackViewHeight),
                              @"auxKeyWidth": @(g_isPhone ? (g_isClassic ? 40.0 : 44.0) : 72.0)};
    
    self.editorIntrinsicHeightConstraint.constant = editableExpressionView.intrinsicContentSize.height;
    
    [NSLayoutConstraint activateConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[refEditor][refKeyboard(==keyboard)]|" options:0 metrics:nil views:views]];
    (_editorTopClearConstraint = [NSLayoutConstraint constraintWithItem:refEditor attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:navigationBar attribute:NSLayoutAttributeBottom multiplier:1.0 constant:0.0]).active = YES;

    [NSLayoutConstraint activateConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|[keyboard]|" options:0 metrics:nil views:views]];
    [NSLayoutConstraint activateConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[editorBackView(<=refEditor@999)][keyboard]" options:0 metrics:nil views:views]];
    [keyboard setContentCompressionResistancePriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisVertical];
    [keyboard setContentHuggingPriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisVertical];
    (_editorHideAtBottomConstraint = [NSLayoutConstraint constraintWithItem:editorBackView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:view attribute:NSLayoutAttributeBottom multiplier:1.0 constant:0.0]).active = NO;
    (_editorStretchToTopConstraint = [NSLayoutConstraint constraintWithItem:editorBackView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:view attribute:NSLayoutAttributeTop multiplier:1.0 constant:0.0]).active = NO;
    
    [NSLayoutConstraint activateConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|[editableExpressionScrollView]|" options:0 metrics:nil views:views]];
    [NSLayoutConstraint activateConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[editableExpressionScrollView]|" options:0 metrics:nil views:views]];
    
    [NSLayoutConstraint activateConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|[editableExpressionView(>=editableExpressionScrollView)]|" options:0 metrics:nil views:views]];
    [NSLayoutConstraint activateConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[editableExpressionView]|" options:0 metrics:nil views:views]];
    (_editableExpressionViewMinimumHeightConstraint = [NSLayoutConstraint constraintWithItem:editableExpressionView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationGreaterThanOrEqual toItem:editableExpressionScrollView attribute:NSLayoutAttributeHeight multiplier:1.0 constant:0.0]).active = NO;
    
    [NSLayoutConstraint activateConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|[answerBackView]|" options:0 metrics:nil views:views]];
    [NSLayoutConstraint activateConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[answerBackView(==answerBackViewHeight)]|" options:0 metrics:metrics views:views]];
    
    [NSLayoutConstraint activateConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|[answerExpressionView]|" options:0 metrics:nil views:views]];
    [NSLayoutConstraint activateConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[answerExpressionView]|" options:0 metrics:nil views:views]];
    
    [NSLayoutConstraint constraintWithItem:equalSign attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:answerBackView attribute:NSLayoutAttributeLeading multiplier:1.0 constant:editableExpressionView.insets.left].active = YES;
    [NSLayoutConstraint constraintWithItem:answerBackView attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:equalSign attribute:NSLayoutAttributeBottom multiplier:1.0 constant:answerExpressionView.insets.bottom].active = YES;

    [NSLayoutConstraint constraintWithItem:auxKeypad attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:answerBackView attribute:NSLayoutAttributeTrailing multiplier:1.0 constant:0.0].active = YES;
    [NSLayoutConstraint constraintWithItem:auxKeypad attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:answerBackView attribute:NSLayoutAttributeCenterY multiplier:1.0 constant:0.0].active = YES;

    if (g_isPhone) {
        [NSLayoutConstraint activateConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|[undoAuxKey(==auxKeyWidth)][redoAuxKey(==auxKeyWidth)][downAuxKey(==auxKeyWidth)]|" options:(NSLayoutFormatAlignAllTop | NSLayoutFormatAlignAllBottom) metrics:metrics views:views]];
    }
    else {
        [NSLayoutConstraint activateConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|[undoAuxKey(==auxKeyWidth)][redoAuxKey(==auxKeyWidth)]|" options:(NSLayoutFormatAlignAllTop | NSLayoutFormatAlignAllBottom) metrics:metrics views:views]];
    }
    [NSLayoutConstraint activateConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[undoAuxKey(==44.0)]|" options:0 metrics:nil views:views]];
        
    /**************************************************************************/
    NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
    [notificationCenter addObserver:self selector:@selector(respondToCurrentLocaleDidChangeNotification:) name:NSCurrentLocaleDidChangeNotification object:nil];
    [notificationCenter addObserver:self selector:@selector(respondToTimeZoneDidChangeNotification:) name:NSSystemTimeZoneDidChangeNotification object:nil];
    [notificationCenter addObserver:self selector:@selector(respondToSignificantTimeChangeNotification:) name:UIApplicationSignificantTimeChangeNotification object:nil];
    [notificationCenter addObserver:self selector:@selector(respondToApplicationDidEnterBackgroundNotification:) name:UIApplicationDidEnterBackgroundNotification object:nil];
    [notificationCenter addObserver:self selector:@selector(respondToApplicationWillEnterForegroundNotification:) name:UIApplicationWillEnterForegroundNotification object:nil];
    [notificationCenter addObserver:self selector:@selector(respondToUndoManagerCheckpointNotification:) name:NSUndoManagerCheckpointNotification object:self.editableExpressionView.undoManager];
    [notificationCenter addObserver:self selector:@selector(respondToShouldSaveStateNotification:) name:@"ShouldSaveStateNotification" object:self];
    [notificationCenter addObserver:self selector:@selector(respondToPreferencesDidChangeNotification:) name:@"PreferencesDidChangeNotification" object:nil];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if (_isFirstRun) {
        if (self.managedObjectContext) {
            /****************** Migrate history ******************/
            switch (g_dataVersion) {
                case 0: {
                    NSLog_DEBUG(@"Migrating history from version 0 to version 1 ...");
                    NSURL *historyURL = [[AppDelegate documentsDirectoryURL] URLByAppendingPathComponent:@"history"];
                    NSData *historyData = [NSData dataWithContentsOfURL:historyURL];
                    if (historyData) {
                        NSArray *historyExpressions = nil;
                        
                        NSKeyedUnarchiver *unarchiver = [[NSKeyedUnarchiver alloc] initForReadingWithData:historyData];
                        @try {
                            historyExpressions = [unarchiver decodeObjectForKey:@"historyExpressions"];
                        }
                        @catch (NSException *exception) {
                            FTAssert_DEBUG(NO);
                        }
                        @finally {
                            [unarchiver finishDecoding];
                        }
                        
                        if (historyExpressions) {
                            NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
                            NSDate *prehistory = [NSDate dateWithTimeIntervalSinceReferenceDate:0.0];
                            for (MathExpression *expression in historyExpressions) {
                                HistoryRecord *newRecord = [NSEntityDescription insertNewObjectForEntityForName:@"HistoryRecord" inManagedObjectContext:managedObjectContext];
                                newRecord.expression = expression;
                                newRecord.creationDate = prehistory;
                            }
                            NSError *error;
                            if ([managedObjectContext save:&error]) {
                                [[NSFileManager defaultManager] removeItemAtURL:historyURL error:NULL];
                            }
                            else {
                                FTAssert_DEBUG(NO, error);
                                [managedObjectContext reset];
                            }
                        }
                    }
                    //$ break;
                }
                case DATA_VERSION: {
                    break;
                }
                default: {
                    FTAssert_DEBUG(NO);
                    break;
                }
            }

            /****************** Restore history sheet ******************/
            HistorySheet *restoredHistorySheet = nil;
            NSURL *historySheetURI = [[NSUserDefaults standardUserDefaults] URLForKey:@"MainVC_historySheet"];
            if (historySheetURI) {
                NSManagedObjectID *historySheetID = [self.managedObjectContext.persistentStoreCoordinator managedObjectIDForURIRepresentation:historySheetURI];
                if (historySheetID) {
                    restoredHistorySheet = (HistorySheet *)[self.managedObjectContext existingObjectWithID:historySheetID error:NULL];
                }
            }
            self.historySheet = restoredHistorySheet;
            [self.historyTableView reloadData];
            
            NSInteger indexOfLastSection = [self.historyTableView numberOfSections] - 1;
            if (0 <= indexOfLastSection) {
                NSInteger indexOfLastRowInLastSection = [self.historyTableView numberOfRowsInSection:indexOfLastSection] - 1;
                if (0 <= indexOfLastRowInLastSection) {
                    _indexPathForScrollTarget = [NSIndexPath indexPathForRow:indexOfLastRowInLastSection inSection:indexOfLastSection];
                }
            }
        }
        else {
            [self.historySheetTitleButton setTitle:NSLocalizedString(@"Failded to Load History", nil) forState:UIControlStateNormal];
            self.historySheetTitleButton.enabled = NO;
            self.historySheetTitleDisclosureIndicator.hidden = YES;
            self.listBarButtonItem.enabled = NO;
            _editorNeedsBecomeFirstResponder = NO;
        }
    } //~ _isFirstRun
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    if (_isFirstRun) {
        /****************** Restore editor state ******************/
        MathExpression *restoredExpression = nil;
        MathRange *restoredSelectedRange = nil;
        
        NSURL *editorStateURL = nil;
        BOOL editorStateFileNeedsToBeRemoved = NO;
        switch (g_dataVersion) {
            case 0: {
                NSLog_DEBUG(@"Migrating editor state from version 0 to version 1 ...");
                editorStateURL = [[AppDelegate dataDirectoryURL] URLByAppendingPathComponent:@"editableExpressionViewState"];
                editorStateFileNeedsToBeRemoved = YES;
                break;
            }
            default: {
                editorStateURL = [[AppDelegate dataDirectoryURL] URLByAppendingPathComponent:@"editorState"];
                break;
            }
        }
        NSData *editorStateData = [NSData dataWithContentsOfURL:editorStateURL];
        if (editorStateData) {
            NSKeyedUnarchiver *unarchiver = [[NSKeyedUnarchiver alloc] initForReadingWithData:editorStateData];
            @try {
                restoredExpression = [unarchiver decodeObjectForKey:@"expression"];
                restoredSelectedRange = [unarchiver decodeObjectForKey:@"selectedRange"];
            }
            @catch (NSException *exception) {
                FTAssert_DEBUG(NO);
                editorStateFileNeedsToBeRemoved = YES;
            }
            @finally {
                [unarchiver finishDecoding];
                if (editorStateFileNeedsToBeRemoved) {
                    [[NSFileManager defaultManager] removeItemAtURL:editorStateURL error:NULL];
                }
            }
        }
        if (restoredExpression.elements.count) {
            if (restoredSelectedRange == nil
                || ![restoredExpression validatePosition:restoredSelectedRange.fromPosition]
                || ![restoredExpression validatePosition:restoredSelectedRange.toPosition])
            {
                MathPosition *caretPosition = [MathPosition positionAtIndex:(uint32_t)restoredExpression.elements.count];
                restoredSelectedRange = [[MathRange alloc] initFromPosition:caretPosition toPosition:caretPosition];
            }

            [self.editableExpressionView setExpression:restoredExpression withSelectedRange:restoredSelectedRange];
        }
        
        if (_editorNeedsBecomeFirstResponder) {
            [self.editableExpressionView performSelector:@selector(my_becomeFirstResponderIfNotAlready) withObject:nil afterDelay:0.5];
        }
        
        _isFirstRun = NO;
    }
    else {
        [self scrollEditableExpressionView:self.editableExpressionView needsBecomeFirstResponder:_editorNeedsBecomeFirstResponder];
    }
    [self.historyTableView flashScrollIndicators];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    _editorNeedsBecomeFirstResponder = [self.editableExpressionView isFirstResponder];
    [self unregisterKeyboardNotifications];
}

#pragma mark -

- (id<UIViewControllerAnimatedTransitioning>)animationControllerForPresentedController:(UIViewController *)presented presentingController:(UIViewController *)presenting sourceController:(UIViewController *)source
{
    return [[ViewControllerDropAnimator alloc] initForPresenting];
}

- (id<UIViewControllerAnimatedTransitioning>)animationControllerForDismissedController:(UIViewController *)dismissed
{
    return [[ViewControllerDropAnimator alloc] initForDismissing];
}

- (IBAction)handleTitleButtonTap:(id)sender
{
    FTAssert_DEBUG(self.historyTableView.mode == FTTableViewNormalMode);
    _editorNeedsBecomeFirstResponder = [self.editableExpressionView isFirstResponder];
    [self.editableExpressionView my_resignFirstResponderIfNotAlready];
    [self hideMathKeyboard];
    
    UINavigationController *navigationController = [self.storyboard instantiateViewControllerWithIdentifier:@"selectHistorySheet"];
    HistorySheetsViewController *historySheetsVC = navigationController.viewControllers[0];
    historySheetsVC.delegate = self;
    historySheetsVC.selectedHistorySheet = self.historySheet;
    
    if (g_isPhone) {
        navigationController.modalPresentationStyle = UIModalPresentationOverFullScreen;
        navigationController.transitioningDelegate = self;
        [self presentViewController:navigationController animated:YES completion:nil];
    }
    else {
        navigationController.modalPresentationStyle = UIModalPresentationPopover;
        [self presentViewController:navigationController animated:YES completion:^{
            navigationController.popoverPresentationController.passthroughViews = nil;  //! WORKAROUND
        }];
        UIPopoverPresentationController *popover = navigationController.popoverPresentationController;
        popover.delegate = historySheetsVC;
        popover.sourceView = sender;
        popover.sourceRect = CGRectInset([sender bounds], 13.0, 13.0);
    }
}

- (IBAction)handleMoveButtonTap:(id)sender
{
    FTAssert_DEBUG(self.historyTableView.mode == FTTableViewBatchEditingMode);

    UINavigationController *navigationController = [self.storyboard instantiateViewControllerWithIdentifier:@"selectHistorySheet"];
    HistorySheetsViewController *historySheetsVC = navigationController.viewControllers[0];
    historySheetsVC.delegate = self;
    historySheetsVC.selectedHistorySheet = self.historySheet;
    
    if (g_isPhone) {
        NSUInteger numberOfSelectedRows = [self.historyTableView indexPathsForSelectedRows].count;
        historySheetsVC.prompt = numberOfSelectedRows == 1 ? NSLocalizedString(@"Move one record to …", nil) : [NSString stringWithFormat:NSLocalizedString(@"Move %lu records to …", nil), (unsigned long)numberOfSelectedRows];
        
        navigationController.modalPresentationStyle = UIModalPresentationOverFullScreen;
        navigationController.transitioningDelegate = self;
        [self presentViewController:navigationController animated:YES completion:nil];
    }
    else {
        navigationController.modalPresentationStyle = UIModalPresentationPopover;
        [self presentViewController:navigationController animated:YES completion:^{
            navigationController.popoverPresentationController.passthroughViews = nil;  //! WORKAROUND
        }];
        UIPopoverPresentationController *popover = navigationController.popoverPresentationController;
        popover.delegate = historySheetsVC;
        popover.barButtonItem = sender;
        UIEdgeInsets tmpInsets = popover.popoverLayoutMargins;
        tmpInsets.left = 100.0;  //! No effect, and no workaround at all.
        popover.popoverLayoutMargins = tmpInsets;
    }
}

- (void)historySheetsViewControllerWillDismiss:(HistorySheetsViewController *)historySheetsVC
{
    NSManagedObjectID *selectedHistorySheetID = historySheetsVC.selectedHistorySheet.objectID;
    HistorySheet *selectedHistorySheet = nil;
    if (selectedHistorySheetID) {
        selectedHistorySheet = (HistorySheet *)[self.managedObjectContext objectWithID:selectedHistorySheetID];
        [self.managedObjectContext refreshObject:selectedHistorySheet mergeChanges:NO];
    }
    
    if (selectedHistorySheet == self.historySheet) {
        if (selectedHistorySheet) {
            [self.historySheetTitleButton setTitle:selectedHistorySheet.title forState:UIControlStateNormal];
        }
        if (self.historyTableView.mode == FTTableViewNormalMode && _editorNeedsBecomeFirstResponder) {
            [self.editableExpressionView performSelector:@selector(my_becomeFirstResponderIfNotAlready) withObject:nil afterDelay:(g_isPhone ? 0.5 : 0.0)];  //! WORKAROUND: Otherwise, table view cells will perform layout animations pointlessly.
        }
        return;
    }

    if (self.historyTableView.mode == FTTableViewBatchEditingMode) {
        /* Move */
        NSArray *indexPathsForSelectedRows = [self.historyTableView indexPathsForSelectedRows];
        FTAssert_DEBUG(indexPathsForSelectedRows.count);
        for (NSIndexPath *indexPath in indexPathsForSelectedRows) {
            HistoryRecord *record = [self.fetchedResultsController objectAtIndexPath:indexPath];
            record.containingSheet = selectedHistorySheet;
        }
        self.fetchedResultsController.delegate = nil;
        NSError *error;
        if (![self.managedObjectContext save:&error]) {
            FTAssert(NO, error);
        }
        self.fetchedResultsController.delegate = self;
        
        [self.historyTableView setMode:FTTableViewNormalMode animated:(!g_isPhone)];
    }
    
    /* Open */
    self.historySheet = selectedHistorySheet;
    [self.historyTableView reloadData];
    
    NSInteger indexOfLastSection = [self.historyTableView numberOfSections] - 1;
    if (0 <= indexOfLastSection) {
        NSInteger indexOfLastRowInLastSection = [self.historyTableView numberOfRowsInSection:indexOfLastSection] - 1;
        if (0 <= indexOfLastRowInLastSection) {
            _indexPathForScrollTarget = [NSIndexPath indexPathForRow:indexOfLastRowInLastSection inSection:indexOfLastSection];
            [self.view setNeedsLayout];  //! Although, as of iOS 7.1, -viewDidLayoutSubviews is always called.
        }
        _editorNeedsBecomeFirstResponder = NO;
    }
    else {
        _editorNeedsBecomeFirstResponder = YES;
    }
    
    if (_editorNeedsBecomeFirstResponder) {
        [self.editableExpressionView performSelector:@selector(my_becomeFirstResponderIfNotAlready) withObject:nil afterDelay:0.5];
    }
}

- (IBAction)unwind:(UIStoryboardSegue *)segue
{
    NSString *segueID = segue.identifier;
    if ([segueID hasPrefix:@"info_"]) {
        _editorNeedsBecomeFirstResponder = YES;
    }
}

#pragma mark -

- (NSManagedObjectContext *)managedObjectContext
{
    if (_managedObjectContext == nil && [AppDelegate sharedPersistentStoreCoordinator]) {
        _managedObjectContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
        _managedObjectContext.persistentStoreCoordinator = [AppDelegate sharedPersistentStoreCoordinator];
#ifndef DEBUG
        _managedObjectContext.mergePolicy = NSMergeByPropertyStoreTrumpMergePolicy;
#endif
        _managedObjectContext.undoManager = nil;
    }
    return _managedObjectContext;
}

- (NSFetchedResultsController *)fetchedResultsController
{
    if (_fetchedResultsController == nil && self.managedObjectContext) {
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"HistoryRecord"];
        fetchRequest.sortDescriptors = @[[[NSSortDescriptor alloc] initWithKey:@"creationDate" ascending:YES]];
        
        _fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:self.managedObjectContext sectionNameKeyPath:@"sectionID" cacheName:nil];
        _fetchedResultsController.delegate = self;
    }
    
    if (_needsPerformFetch && _fetchedResultsController) {
        NSFetchRequest *fetchRequest = _fetchedResultsController.fetchRequest;
        fetchRequest.predicate = [NSPredicate predicateWithFormat:@"(containingSheet == %@) AND (expression != nil)", self.historySheet];
        NSUInteger fetchLimitBak = fetchRequest.fetchLimit;
        fetchRequest.fetchLimit = 0;
        fetchRequest.fetchOffset = 0;
        NSError *error = nil;
        NSUInteger countIfNoLimit = [_fetchedResultsController.managedObjectContext countForFetchRequest:fetchRequest error:&error];
        if (countIfNoLimit == NSNotFound) {
            FTAssert(NO, error);
        }
        fetchRequest.fetchLimit = fetchLimitBak;
        if (fetchLimitBak < countIfNoLimit) {
            fetchRequest.fetchOffset = countIfNoLimit - fetchLimitBak;
        }
        if (![_fetchedResultsController performFetch:&error]) {
            FTAssert(NO, error);
        }
        _needsPerformFetch = NO;
        
        self.listBarButtonItem.enabled = (_fetchedResultsController.fetchedObjects.count != 0);
        self.historyTableView.drawoutHeaderIsHidden = (fetchRequest.fetchOffset == 0);
    }
    
    return _fetchedResultsController;
}

- (void)setNeedsPerformFetch
{
    _needsPerformFetch = YES;
}

- (void)setHistorySheet:(HistorySheet *)historySheet
{
    _historySheet = historySheet;

    if (historySheet) {
        historySheet.lastOpenedDate = [NSDate date];
        NSError *error = nil;
        if ([self.managedObjectContext save:&error]) {
            FTAssert_DEBUG(![historySheet.objectID isTemporaryID]);
            [[NSUserDefaults standardUserDefaults] setURL:[historySheet.objectID URIRepresentation] forKey:@"MainVC_historySheet"];
            [self.historySheetTitleButton setTitle:historySheet.title forState:UIControlStateNormal];
        }
        else {
            FTAssert_DEBUG(NO, error);
            [self.managedObjectContext rollback];
            [self setHistorySheet:nil];
        }
    }
    else {
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"MainVC_historySheet"];
        [self.historySheetTitleButton setTitle:NSLocalizedString(@"History", nil) forState:UIControlStateNormal];
    }
    self.fetchedResultsController.fetchRequest.fetchLimit = FETCH_LIMIT;
    [self setNeedsPerformFetch];
}

- (void)reloadHistory
{
    FTTableView *tableView = self.historyTableView;
    NSFetchedResultsController *fetchedResultsController = self.fetchedResultsController;
    
    NSArray *indexPathsForSelectedRows = [tableView indexPathsForSelectedRows];
    NSMutableArray *objsForSelectedRows = [NSMutableArray arrayWithCapacity:indexPathsForSelectedRows.count];
    for (NSIndexPath *indexPath in indexPathsForSelectedRows) {
        [objsForSelectedRows addObject:[fetchedResultsController objectAtIndexPath:indexPath]];
    }
    
    [self setNeedsPerformFetch];
    [tableView reloadDataSmoothly];
    
    for (id obj in objsForSelectedRows) {
        NSIndexPath *indexPath = [fetchedResultsController indexPathForObject:obj];
        if (indexPath) {
            [tableView selectRowAtIndexPath:indexPath animated:NO scrollPosition:UITableViewScrollPositionNone];
        }
    }
}

- (void)saveEditorState
{
    NSMutableData *editorStateData = [NSMutableData dataWithCapacity:0];
    NSKeyedArchiver *archiver = [[NSKeyedArchiver alloc] initForWritingWithMutableData:editorStateData];
    [archiver encodeObject:self.editableExpressionView.expression forKey:@"expression"];
    [archiver encodeObject:self.editableExpressionView.selectedRange forKey:@"selectedRange"];
    [archiver finishEncoding];
    NSURL *editorStateURL = [[AppDelegate dataDirectoryURL] URLByAppendingPathComponent:@"editorState"];
    [editorStateData writeToURL:editorStateURL atomically:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark -

- (UIStatusBarAnimation)preferredStatusBarUpdateAnimation
{
    return _statusBarAnimation;
}

- (BOOL)prefersStatusBarHidden
{
    if (_forcesStatusBarHidden) {
        return YES;
    }
    if (self.statusBarShouldHide) {
        return self.statusBarShouldHide();
    }
    return NO;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations
{
    if (g_isPhone && self.historyTableView.mode == FTTableViewBatchEditingMode) {
        return UIInterfaceOrientationMaskPortrait;
    }
    return [super supportedInterfaceOrientations];
}

- (BOOL)shouldAutorotate
{
    if (_editorIsDragging) {
        return NO;
    }
    return YES;
}

- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator
{
    [super viewWillTransitionToSize:size withTransitionCoordinator:coordinator];
    
    [[MathKeyboard sharedKeyboard] cancelKeyHit];
    CGPoint visibleBLPointInHistoryTableViewBeforeRotating = [self.editorBackView convertPoint:CGPointZero toView:self.historyTableView];
    
    [coordinator animateAlongsideTransition:^(id<UIViewControllerTransitionCoordinatorContext>  _Nonnull context) {
        if (g_isPhone) {
            for (HistoryTableViewCell *cell in [self.historyTableView visibleCells]) {
                [cell my_refresh];
            }
            [self updateAnswer];
        }
        
        CGPoint originOfHistoryTableViewInRootView = [self.view convertPoint:CGRectStandardize(self.historyTableView.bounds).origin fromView:self.historyTableView];
        CGPoint visibleBLPointOfHistoryTableViewInRootView = [self.view convertPoint:CGPointZero fromView:self.editorBackView];
        CGPoint contentOffsetForHistoryTableView = my_CGPointOffset(visibleBLPointInHistoryTableViewBeforeRotating, originOfHistoryTableViewInRootView.x - visibleBLPointOfHistoryTableViewInRootView.x, originOfHistoryTableViewInRootView.y - visibleBLPointOfHistoryTableViewInRootView.y);
        [self.historyTableView my_setContentOffset:contentOffsetForHistoryTableView regularized:YES];
    } completion:^(id<UIViewControllerTransitionCoordinatorContext>  _Nonnull context) {
        [self scrollEditableExpressionView:self.editableExpressionView needsBecomeFirstResponder:NO];
    }];
}

#define MIN_HISTORY_VIEWPORT_HEIGHT  64.0

- (void)traitCollectionDidChange:(UITraitCollection *)previousTraitCollection
{
    UITraitCollection *traitCollection = self.traitCollection;
    BOOL mathKeyboardIsShown = (0.0 < self.editorBottomSpaceConstraint.constant);
    CGFloat mathKeyboardHeight = [MathKeyboard sharedKeyboard].intrinsicContentSize.height;
    
    if (mathKeyboardIsShown) {
        self.editorBottomSpaceConstraint.constant = mathKeyboardHeight;
    }
    
    if (traitCollection.verticalSizeClass == UIUserInterfaceSizeClassRegular) {
        self.statusBarShouldHide = nil;
        _forcesStatusBarHidden = NO;
        
        self.editorStretchToTopConstraint.active = NO;
        self.editableExpressionViewMinimumHeightConstraint.active = NO;
        if (g_isPhone && g_isClassic && mathKeyboardIsShown) {
            self.navigationBar.items = @[];
            self.navigationBarTopToTopGuideConstraint.constant = -NAVIGATION_BAR_HEIGHT;
        }
        else {
            self.navigationBar.items = @[self.historyNavigationItem];
            self.navigationBarTopToTopGuideConstraint.constant = 0.0;
        }
        
        if (traitCollection.horizontalSizeClass == UIUserInterfaceSizeClassRegular) {
            [MathEnvironment sharedEnvironment].maximumSignificantDigits = 15;
            self.auxKeypad.hidden = NO;
        }
        else {
            [MathEnvironment sharedEnvironment].maximumSignificantDigits = 9;
            self.auxKeypad.hidden = YES;
        }
    }
    else {
        typeof(self) __weak weakSelf = self;
        self.statusBarShouldHide = ^{
            if (weakSelf.editableExpressionView.intrinsicContentSize.height > CGRectGetHeight(self.view.bounds) - STATUS_BAR_HEIGHT - mathKeyboardHeight) {
                return YES;
            }
            return NO;
        };
        _forcesStatusBarHidden = !mathKeyboardIsShown;

        self.navigationBar.items = @[];  //$
        self.navigationBarTopToTopGuideConstraint.constant = -(STATUS_BAR_HEIGHT + NAVIGATION_BAR_HEIGHT);
        if (mathKeyboardIsShown) {
            self.editorStretchToTopConstraint.active = YES;
            self.editableExpressionViewMinimumHeightConstraint.active = YES;
        }
        
        [MathEnvironment sharedEnvironment].maximumSignificantDigits = (g_isPhone && g_isClassic) ? 12 : 15;
        self.auxKeypad.hidden = NO;
    }
    
    [self setNeedsStatusBarAppearanceUpdate];
}

- (void)viewDidLayoutSubviews
{
    UIEdgeInsets insets = self.historyTableView.contentInset;
    insets.top = MAX(0.0, CGRectGetMaxY(self.navigationBar.frame));
    switch (self.historyTableView.mode) {
        case FTTableViewNormalMode: {
            if (_editorIsDragging) break;
            insets.bottom = MAX(0.0, CGRectGetHeight(self.view.bounds) - CGRectGetMinY(self.editorBackView.frame));
            break;
        }
        case FTTableViewBatchEditingMode: {
            insets.bottom = self.toolbar ? CGRectGetHeight(self.toolbar.bounds) : 0.0;
            break;
        }
        case FTTableViewEditingInPlaceMode: {
            break;
        }
    }
    self.historyTableView.contentInset = insets;
    self.historyTableView.scrollIndicatorInsets = insets;
    [self.view layoutSubviews];  //! WORKAROUND: Otherwise, archiving, say, x² will lead to crash. [Fixed in iOS 8.1]
    
    if (_indexPathForScrollTarget) {
        [self.historyTableView scrollToRowAtIndexPath:_indexPathForScrollTarget atScrollPosition:UITableViewScrollPositionBottom animated:NO];
        _indexPathForScrollTarget = nil;
    }
}

#pragma mark -

- (void)respondToCurrentLocaleDidChangeNotification:(NSNotification *)notification
{
    if (self.historyTableView.mode == FTTableViewEditingInPlaceMode) {
        _invocation = [NSInvocation invocationWithMethodSignature:[self methodSignatureForSelector:_cmd]];
        _invocation.target = self;
        _invocation.selector = _cmd;
        [_invocation setArgument:&notification atIndex:2];
        [_invocation retainArguments];
    }
    else {
        _canonicalDateFormatter = nil;
        _succinctDateFormatter = nil;
        _thisYear = 0;
        _yesterdayOutset = nil;
        
        [self reloadHistory];
    }
}

- (void)respondToTimeZoneDidChangeNotification:(NSNotification *)notification
{
    if (self.historyTableView.mode == FTTableViewEditingInPlaceMode) {
        _invocation = [NSInvocation invocationWithMethodSignature:[self methodSignatureForSelector:_cmd]];
        _invocation.target = self;
        _invocation.selector = _cmd;
        [_invocation setArgument:&notification atIndex:2];
        [_invocation retainArguments];
    }
    else {
        _thisYear = 0;
        _yesterdayOutset = nil;
        
        [self reloadHistory];
    }
}

- (void)respondToSignificantTimeChangeNotification:(NSNotification *)notification
{
    if (self.historyTableView.mode == FTTableViewEditingInPlaceMode) {
        _invocation = [NSInvocation invocationWithMethodSignature:[self methodSignatureForSelector:_cmd]];
        _invocation.target = self;
        _invocation.selector = _cmd;
        [_invocation setArgument:&notification atIndex:2];
        [_invocation retainArguments];
    }
    else {
        _thisYear = 0;
        _yesterdayOutset = nil;
        
        [self reloadHistory];
    }
}

- (void)respondToApplicationDidEnterBackgroundNotification:(NSNotification *)notification
{
    [self saveEditorState];
}

- (void)respondToApplicationWillEnterForegroundNotification:(NSNotification *)notification
{
    if ([g_lastLeaveTime timeIntervalSinceNow] < -(1.0 * 60 * 60)) {
        FTTableView *tableView = self.historyTableView;
        if (tableView.mode != FTTableViewNormalMode) {  //! Any mode other than the normal mode is considered to be transient, that is, it should not present another view controller to, say, complete a complex task.
            [[UIResponder my_firstResponder] resignFirstResponder];
            tableView.mode = FTTableViewNormalMode;
        }
        if (self.fetchedResultsController.fetchedObjects.count > FETCH_LIMIT) {
            self.fetchedResultsController.fetchRequest.fetchLimit = FETCH_LIMIT;
            [self setNeedsPerformFetch];
            
            CGSize oldContentSize = tableView.contentSize;
            CGPoint oldContentOffset = tableView.contentOffset;
            [tableView reloadData];
            CGSize newContentSize = tableView.contentSize;
            CGPoint newContentOffset = oldContentOffset;
            newContentOffset.y += newContentSize.height - oldContentSize.height;
            [tableView my_setContentOffset:newContentOffset regularized:YES];
        }
    }
}

- (void)respondToUndoManagerCheckpointNotification:(NSNotification *)notification
{
    NSUndoManager *undoManager = notification.object;
    self.undoAuxKey.enabled = [undoManager canUndo];
    self.redoAuxKey.enabled = [undoManager canRedo];
    
    [[NSNotificationQueue defaultQueue] enqueueNotification:[NSNotification notificationWithName:@"ShouldSaveStateNotification" object:self] postingStyle:NSPostWhenIdle coalesceMask:(NSNotificationCoalescingOnName | NSNotificationCoalescingOnSender) forModes:nil];
}

- (void)respondToShouldSaveStateNotification:(NSNotification *)notification
{
    [self saveEditorState];
}

- (void)respondToPreferencesDidChangeNotification:(NSNotification *)notification
{
    for (HistoryRecord *record in self.fetchedResultsController.fetchedObjects) {
        [record.expression resetCache];
    }
    [self.historyTableView reloadData];
    
    //! ASSUMPTION: the editable expression's height will not change.
    [self.editableExpressionView.expression resetCache];
    [self.editableExpressionView invalidateIntrinsicContentSize];
    [self.editableExpressionView setNeedsLayout];
    [self.editableExpressionView setNeedsDisplay];
    [self updateAnswer];
    [[FTInputSystem sharedInputSystem] refresh];
}

#pragma mark -

- (void)showMathKeyboard
{
    BOOL isPortrait = UIInterfaceOrientationIsPortrait([UIApplication sharedApplication].statusBarOrientation);
    CGFloat mathKeyboardHeight = [MathKeyboard sharedKeyboard].intrinsicContentSize.height;
    [UIView animateWithDuration:0.5 delay:0.0 usingSpringWithDamping:1.0 initialSpringVelocity:0.0 options:UIViewAnimationOptionCurveLinear animations:^{
        CGPoint oldTableViewContentOffset = self.historyTableView.contentOffset;
        CGRect oldEditorFrame = self.editorBackView.frame;
        CGRect oldExpressionScrollViewBounds = self.editableExpressionScrollView.bounds;
        CGRect oldExpressionViewBounds = self.editableExpressionView.bounds;
        
        self.editorBottomSpaceConstraint.constant = mathKeyboardHeight;
        if (g_isPhone) {
            if (isPortrait) {
                if (g_isClassic) {
                    self.navigationBar.items = @[];
                    self.navigationBarTopToTopGuideConstraint.constant = -NAVIGATION_BAR_HEIGHT;
                }
            }
            else {
                _forcesStatusBarHidden = NO;
                _statusBarAnimation = UIStatusBarAnimationFade;
                [self setNeedsStatusBarAppearanceUpdate];
                
                self.editorStretchToTopConstraint.active = YES;
                self.editableExpressionViewMinimumHeightConstraint.active = YES;
            }
        }
        [self.view layoutIfNeeded];
        
        if (g_osVersionMajor < 8) {
            CGRect newExpressionScrollViewBounds = self.editableExpressionScrollView.bounds;
            self.editableExpressionScrollView.bounds = oldExpressionScrollViewBounds;
            self.editableExpressionScrollView.bounds = oldExpressionScrollViewBounds;  //! reinforce
            self.editableExpressionScrollView.bounds = newExpressionScrollViewBounds;
            
            CGRect newExpressionViewBounds = self.editableExpressionView.bounds;
            self.editableExpressionView.bounds = oldExpressionViewBounds;
            self.editableExpressionView.bounds = newExpressionViewBounds;
            
            self.historyTableView.contentOffset = oldTableViewContentOffset;
        }
        CGRect newEditorFrame = self.editorBackView.frame;
        CGPoint newTableViewContentOffset = oldTableViewContentOffset;
        newTableViewContentOffset.y += CGRectGetMinY(oldEditorFrame) - CGRectGetMinY(newEditorFrame);
        [self.historyTableView my_setContentOffset:newTableViewContentOffset regularized:YES];
    } completion:^(BOOL finished) {
        /*$ if (g_isPhone && !isPortrait) */{
            _statusBarAnimation = UIStatusBarAnimationSlide;
        }
    }];
}

- (void)hideMathKeyboard
{
    BOOL isPortrait = UIInterfaceOrientationIsPortrait([UIApplication sharedApplication].statusBarOrientation);
    if (g_isPhone && !isPortrait) {
        _forcesStatusBarHidden = YES;
        [self setNeedsStatusBarAppearanceUpdate];
    }
    [UIView animateWithDuration:0.5 delay:0.0 usingSpringWithDamping:1.0 initialSpringVelocity:0.0 options:UIViewAnimationOptionCurveLinear animations:^{
        CGRect oldExpressionScrollViewBounds = self.editableExpressionScrollView.bounds;
        CGRect oldExpressionViewBounds = self.editableExpressionView.bounds;
        
        self.editorBottomSpaceConstraint.constant = 0.0;
        if (g_isPhone) {
            if (isPortrait) {
                if (g_isClassic) {
                    self.navigationBar.items = @[self.historyNavigationItem];
                    self.navigationBarTopToTopGuideConstraint.constant = 0.0;
                }
            }
            else {
                self.editorStretchToTopConstraint.active = NO;
                self.editableExpressionViewMinimumHeightConstraint.active = NO;
            }
        }
        [self.view layoutIfNeeded];
        
        if (g_osVersionMajor < 8) {
            CGRect newExpressionScrollViewBounds = self.editableExpressionScrollView.bounds;
            self.editableExpressionScrollView.bounds = oldExpressionScrollViewBounds;
            self.editableExpressionScrollView.bounds = oldExpressionScrollViewBounds;  //! reinforce
            self.editableExpressionScrollView.bounds = newExpressionScrollViewBounds;
            
            CGRect newExpressionViewBounds = self.editableExpressionView.bounds;
            self.editableExpressionView.bounds = oldExpressionViewBounds;
            self.editableExpressionView.bounds = newExpressionViewBounds;
        }
    } completion:nil];
}

- (void)handleDownAuxKeyTap:(id)sender
{
    [self.editableExpressionView my_resignFirstResponderIfNotAlready];
    [self hideMathKeyboard];
}

- (void)registerKeyboardNotifications
{
    NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
    if (g_isPhone) {
        [notificationCenter addObserver:self selector:@selector(respondToKeyboardWillShowNotification:) name:UIKeyboardWillShowNotification object:nil];
        [notificationCenter addObserver:self selector:@selector(respondToKeyboardWillHideNotification:) name:UIKeyboardWillHideNotification object:nil];
    }
    else {
        [notificationCenter addObserver:self selector:@selector(respondToKeyboardWillChangeFrameNotification:) name:UIKeyboardWillChangeFrameNotification object:nil];
        [notificationCenter addObserver:self selector:@selector(respondToKeyboardDidChangeFrameNotification:) name:UIKeyboardDidChangeFrameNotification object:nil];
    }
}

- (void)unregisterKeyboardNotifications
{
    NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
    if (g_isPhone) {
        [notificationCenter removeObserver:self name:UIKeyboardWillShowNotification object:nil];
        [notificationCenter removeObserver:self name:UIKeyboardWillHideNotification object:nil];
    }
    else {
        [notificationCenter removeObserver:self name:UIKeyboardWillChangeFrameNotification object:nil];
        [notificationCenter removeObserver:self name:UIKeyboardDidChangeFrameNotification object:nil];
    }
}

- (void)exitEditInPlaceMode
{
    if (![UIResponder my_firstResponder]) {
        [self.historyTableView setMode:FTTableViewNormalMode animated:YES];
    }
}

- (void)respondToKeyboardWillShowNotification:(NSNotification *)notification
{
    NSDictionary *userInfo = [notification userInfo];
    CGRect keyboardRect = [userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
    keyboardRect = [self.view.window convertRect:keyboardRect fromWindow:nil];
    keyboardRect = [self.view convertRect:keyboardRect fromView:nil];
    
    [UIView animateWithDuration:0.5 delay:0.2 usingSpringWithDamping:1.0 initialSpringVelocity:0.0 options:UIViewAnimationOptionCurveLinear animations:^{
        UITableView *tableView = self.historyTableView;
        
        UIEdgeInsets insets = tableView.contentInset;
        insets.bottom = CGRectGetHeight(keyboardRect);
        tableView.contentInset = insets;
        tableView.scrollIndicatorInsets = insets;
        
        NSIndexPath *indexPathForSelectedRow = [tableView indexPathForSelectedRow];
        if (indexPathForSelectedRow) {
            [tableView my_scrollRectToVisible:[tableView rectForRowAtIndexPath:indexPathForSelectedRow] animated:NO];
        }
        else {
            FTAssert_DEBUG(NO);
        }
    } completion:nil];
}

- (void)respondToKeyboardWillHideNotification:(NSNotification *)notification
{
    [self performSelector:@selector(exitEditInPlaceMode) withObject:nil afterDelay:0.0];
}

- (void)respondToKeyboardWillChangeFrameNotification:(NSNotification *)notification
{
    NSDictionary *userInfo = [notification userInfo];
    CGRect keyboardRect = [userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
    keyboardRect = [self.view.window convertRect:keyboardRect fromWindow:nil];
    keyboardRect = [self.view convertRect:keyboardRect fromView:nil];
    CGSize windowSize = CGRectStandardize([self.view convertRect:self.view.window.bounds fromView:nil]).size;
    
    if (CGRectGetWidth(keyboardRect) != windowSize.width) return;  //! Can occur when drag the floating keyboard or rotate the interface since iOS 8.
    
    if (CGRectGetMinY(keyboardRect) < windowSize.height) {
        /* Show */
        if (windowSize.height < CGRectGetMaxY(keyboardRect)) return;  //! WORKAROUND: Can occur when split or undock the keyboard in iOS 7.1. [Seems fixed in iOS 8.1]
        [UIView animateWithDuration:0.5 delay:0.2 usingSpringWithDamping:1.0 initialSpringVelocity:0.0 options:UIViewAnimationOptionCurveLinear animations:^{
            UITableView *tableView = self.historyTableView;
            CGRect tableViewRect = [self.view convertRect:tableView.bounds fromView:tableView];
            
            UIEdgeInsets insets = tableView.contentInset;
            insets.bottom = CGRectGetMaxY(tableViewRect) - CGRectGetMinY(keyboardRect);
            tableView.contentInset = insets;
            tableView.scrollIndicatorInsets = insets;
            
            NSIndexPath *indexPathForSelectedRow = [tableView indexPathForSelectedRow];
            if (indexPathForSelectedRow) {
                [tableView my_scrollRectToVisible:[tableView rectForRowAtIndexPath:indexPathForSelectedRow] animated:NO];
            }
            else {
                FTAssert_DEBUG(NO);
            }
        } completion:nil];
    }
    else {
        /* Hide */
        [self performSelector:@selector(exitEditInPlaceMode) withObject:nil afterDelay:0.0];
    }
}

- (void)respondToKeyboardDidChangeFrameNotification:(NSNotification *)notification
{
    NSDictionary *userInfo = [notification userInfo];
    CGRect keyboardRect = [userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
    keyboardRect = [self.view.window convertRect:keyboardRect fromWindow:nil];
    keyboardRect = [self.view convertRect:keyboardRect fromView:nil];
    CGSize windowSize = CGRectStandardize([self.view convertRect:self.view.window.bounds fromView:nil]).size;
    
    if (CGRectGetWidth(keyboardRect) != windowSize.width) return;  //! Can occur when rotate the interface since iOS 8.
    
    if (CGRectGetMinY(keyboardRect) < windowSize.height) {
        if (CGRectGetMinY(keyboardRect) < 90.0) return;  //! WORKAROUND: When the keyboard is split and undocked by dragging, a second notification of such is received reporting keyboard frame with zero origin (or so) since iOS 8.
        
        UITableView *tableView = self.historyTableView;
        CGRect tableViewRect = [self.view convertRect:tableView.bounds fromView:tableView];
        UIEdgeInsets oldInsets = tableView.contentInset;
        UIEdgeInsets newInsets = oldInsets;
        newInsets.bottom = CGRectGetMaxY(tableViewRect) - CGRectGetMinY(keyboardRect);
        if (oldInsets.bottom != newInsets.bottom) {
            [UIView animateWithDuration:0.5 delay:0.0 usingSpringWithDamping:1.0 initialSpringVelocity:0.0 options:UIViewAnimationOptionCurveLinear animations:^{
                tableView.contentInset = newInsets;
                tableView.scrollIndicatorInsets = newInsets;
                
                NSIndexPath *indexPathForSelectedRow = [tableView indexPathForSelectedRow];
                if (indexPathForSelectedRow) {
                    [tableView my_scrollRectToVisible:[tableView rectForRowAtIndexPath:indexPathForSelectedRow] animated:NO];
                }
                else {
                    FTAssert_DEBUG(NO);
                }
            } completion:nil];
        }
    }
}

#pragma mark -

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    if (scrollView == self.editableExpressionScrollView) {
        [[UIMenuController sharedMenuController] setMenuVisible:NO animated:YES];
    }
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (scrollView == self.historyTableView) {
        if (!(0.0 < self.editorBottomSpaceConstraint.constant)) return;
        if (scrollView.panGestureRecognizer.state != UIGestureRecognizerStateChanged) return;  //! WORKAROUND: UIScrollView reports dragging/tracking inaccurately.
        
        CGPoint touchLocation = [scrollView.panGestureRecognizer locationInView:self.view];
        CGFloat rootViewHeight = CGRectGetHeight(self.view.bounds);
        CGRect editorFrame = self.editorBackView.frame;
        CGFloat bottomSpace = rootViewHeight - CGRectGetMaxY(editorFrame);
        CGFloat mathKeyboardHeight = CGRectGetHeight([MathKeyboard sharedKeyboard].bounds);
        FTAssert_DEBUG(0.0 <= bottomSpace && bottomSpace <= mathKeyboardHeight);
        if (!_editorIsDragging) {
            if (touchLocation.y <= CGRectGetMinY(editorFrame)) return;
            _editorIsDragging = YES;
        }
        
        CGFloat targetBottomSpace = rootViewHeight - touchLocation.y - CGRectGetHeight(editorFrame);
        if (targetBottomSpace < 0.0) {
            targetBottomSpace = 0.0;
        }
        else if (mathKeyboardHeight < targetBottomSpace) {
            targetBottomSpace = mathKeyboardHeight;
        }
        if (targetBottomSpace != bottomSpace) {
            BOOL isPortrait = UIInterfaceOrientationIsPortrait([UIApplication sharedApplication].statusBarOrientation);
            CGPoint oldTableViewContentOffset = self.historyTableView.contentOffset;
            
            self.editorBottomSpaceConstraint.constant = targetBottomSpace;
            if (/*$ g_isPhone && */g_isClassic && isPortrait) {
                self.navigationBarTopToTopGuideConstraint.constant = -MIN(NAVIGATION_BAR_HEIGHT, targetBottomSpace);
            }
            [self.view layoutIfNeeded];
            
            self.historyTableView.contentOffset = oldTableViewContentOffset;  //: Never interfere with finger control.
        }
    }
}

- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset
{
    if (scrollView == self.historyTableView) {
        if (!_editorIsDragging) return;
        _editorIsDragging = NO;

        CGFloat rootViewHeight = CGRectGetHeight(self.view.bounds);
        CGRect editorFrame = self.editorBackView.frame;
        CGFloat bottomSpace = rootViewHeight - CGRectGetMaxY(editorFrame);
        CGFloat deceleratingDistance = -velocity.y / (1.0 - UIScrollViewDecelerationRateFast);
        CGFloat settledBottomSpace = bottomSpace - deceleratingDistance;
        CGFloat mathKeyboardHeight = [MathKeyboard sharedKeyboard].intrinsicContentSize.height;
        BOOL isPortrait = UIInterfaceOrientationIsPortrait([UIApplication sharedApplication].statusBarOrientation);
        if (settledBottomSpace < mathKeyboardHeight * 0.75) {
            CGPoint contentOffset = scrollView.contentOffset;
            if ((*targetContentOffset).y < contentOffset.y) {
                *targetContentOffset = contentOffset;  //: Stop scrolling down once finger is lifted.
            }
            
            CGRect oldScrollViewBounds = scrollView.bounds;
            NSTimeInterval duration = 0.25;
            CGFloat Vy = velocity.y < 0.0 ? (-velocity.y * 1000) : 0.0;
            CGFloat Vy_ = bottomSpace / 0.25;
            CGFloat theta = atan(Vy / Vy_);
            CAMediaTimingFunction *timingFunction = [CAMediaTimingFunction functionWithControlPoints:(0.42 * cos(theta)) :(0.42 * sin(theta)) :0.58 :1.0];
            
            [self.editableExpressionView my_resignFirstResponderIfNotAlready];
            [UIView animateWithDuration:duration animations:^{
                [CATransaction begin];
                [CATransaction setAnimationTimingFunction:timingFunction];
                
                self.editorBottomSpaceConstraint.constant = 0.0;
                if (/*$ g_isPhone && */g_isClassic && isPortrait) {
                    self.navigationBar.items = @[self.historyNavigationItem];
                    self.navigationBarTopToTopGuideConstraint.constant = 0.0;
                }
                [self.view layoutIfNeeded];
                
                [CATransaction commit];
            }];
            
            if (8 <= g_osVersionMajor) {  //! WORKAROUND: Remove the annoying jitter before normal animation.
                [scrollView.layer my_removeAnimationForKeyPath:@"bounds"];
                CABasicAnimation *scrollViewBoundsAnimation = [CABasicAnimation animationWithKeyPath:@"bounds"];
                scrollViewBoundsAnimation.timingFunction = timingFunction;
                scrollViewBoundsAnimation.duration = duration;
                scrollViewBoundsAnimation.fromValue = [NSValue valueWithCGRect:oldScrollViewBounds];
                [scrollView.layer addAnimation:scrollViewBoundsAnimation forKey:@"bounds"];
            }
        }
        else {
            [UIView animateWithDuration:0.25 animations:^{
                self.editorBottomSpaceConstraint.constant = mathKeyboardHeight;
                if (/*$ g_isPhone && */g_isClassic && isPortrait) {
                    self.navigationBarTopToTopGuideConstraint.constant = -NAVIGATION_BAR_HEIGHT;
                }
                [self.view layoutIfNeeded];
            }];
        }
    }
}

#pragma mark -

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer
{
    if (gestureRecognizer == self.editableExpressionView.longPressGestureRecognizer) {
        CGPoint location = [gestureRecognizer locationInView:self.answerExpressionView];
        if ([self.answerExpressionView pointInside:location withEvent:nil]) {
            MathResult *answer = [self.editableExpressionView.expression evaluate];
            if (answer && ({decQuad tmpDec = answer.value; decQuadIsFinite(&tmpDec);})) {
                [self.answerExpressionView becomeFirstResponder];
                
                UIMenuController *menuController = [UIMenuController sharedMenuController];
                menuController.menuItems = @[[[UIMenuItem alloc] initWithTitle:(self.answerIsInDegree ? NSLocalizedString(@"= Rad", nil) : @"= °") action:@selector(toggleAnswerAngleUnit:)]];
                [self.answerExpressionView my_showEditingMenu];
                [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(respondToMenuControllerWillHideMenuNotification:) name:UIMenuControllerWillHideMenuNotification object:nil];
                
                return NO;
            }
        }
    }
    return YES;
}

- (void)toggleAnswerAngleUnit:(id)sender
{
    self.answerIsInDegree = !self.answerIsInDegree;
    self.answerUnitIsAssignedByUser = YES;
    if ([self.answerDeducedAngleUnit isKindOfClass:[MathAngleUnitUserDefault class]]) {
        [[NSUserDefaults standardUserDefaults] setBool:self.answerIsInDegree forKey:@"MathAngleUnitDefaultsToDegree"];
    }
    [self updateAnswer];
}

- (void)respondToMenuControllerWillHideMenuNotification:(NSNotification *)notification
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIMenuControllerWillHideMenuNotification object:nil];
    UIMenuController *menuController = [UIMenuController sharedMenuController];
    menuController.menuItems = nil;
    
    [self.editableExpressionView my_becomeFirstResponderIfNotAlready];
}

- (void)updateAnswer
{
    MathResult *answer = [self.editableExpressionView.expression evaluate];
    
    MathUnit *angleUnitUserDefault = [answer.unitSet unitForClass:[MathAngleUnitUserDefault class]];
    MathUnit *angleUnitDegree = [answer.unitSet unitForClass:[MathAngleUnitDegree class]];
    MathUnit *deducedAngleUnit = nil;
    if (angleUnitUserDefault) {
        if (angleUnitDegree) {
            decQuad userDefaultOrder = angleUnitUserDefault.order;
            decQuad degreeOrder = angleUnitDegree.order;
            decQuad tmpDec;
            decQuadAdd(&tmpDec, &userDefaultOrder, &degreeOrder, &DQ_set);
            decQuadCompare(&tmpDec, &tmpDec, &Dec_1, &DQ_set);
            if (decQuadIsZero(&tmpDec)) {
                if (decQuadIsPositive(&degreeOrder)) {  //: 2° × 30° / arcsin0.5 , sqrt(30° × arcsin0.5)
                    deducedAngleUnit = [MathAngleUnitDegree unit];
                }
                else {
                    deducedAngleUnit = [MathAngleUnitUserDefault unit];
                }
            }
        }
        else {
            decQuad tmpDec = angleUnitUserDefault.order;
            decQuadCompare(&tmpDec, &tmpDec, &Dec_1, &DQ_set);
            if (decQuadIsZero(&tmpDec)) {
                deducedAngleUnit = [MathAngleUnitUserDefault unit];
            }
        }
    }
    else {
        if (angleUnitDegree) {
            decQuad tmpDec = angleUnitDegree.order;
            decQuadCompare(&tmpDec, &tmpDec, &Dec_1, &DQ_set);
            if (decQuadIsZero(&tmpDec)) {
                NSArray *elements = self.editableExpressionView.expression.elements;
                if ((elements.count == 2 && [elements[1] isKindOfClass:[MathDegree class]] && [elements[0] isKindOfClass:[MathNumber class]]) || (elements.count == 3 && [elements[2] isKindOfClass:[MathDegree class]] && ([elements[0] isKindOfClass:[MathAdd class]] || [elements[0] isKindOfClass:[MathSub class]]) && [elements[1] isKindOfClass:[MathNumber class]])) {
                    deducedAngleUnit = nil;
                }
                else {
                    deducedAngleUnit = [MathAngleUnitDegree unit];
                }
            }
        }
    }
    self.answerDeducedAngleUnit = deducedAngleUnit;
    
    if (!self.answerUnitIsAssignedByUser) {
        if (self.answerDeducedAngleUnit) {
            if ([self.answerDeducedAngleUnit isKindOfClass:[MathAngleUnitDegree class]]) {
                self.answerIsInDegree = YES;
            }
            else {
                FTAssert_DEBUG([self.answerDeducedAngleUnit isKindOfClass:[MathAngleUnitUserDefault class]]);
                self.answerIsInDegree = [[NSUserDefaults standardUserDefaults] boolForKey:@"MathAngleUnitDefaultsToDegree"];
            }
        }
        else {
            self.answerIsInDegree = NO;
        }
    }
    
    self.answerExpressionView.expression = answer ? [MathExpression expressionFromValue:answer.value inDegree:self.answerIsInDegree] : nil;
}

#pragma mark -

- (void)editableExpressionViewDidBecomeFirstResponder:(MathEditableExpressionView *)editableExpressionView
{
    FTAssert_DEBUG(editableExpressionView == self.editableExpressionView);
    self.auxKeypad.alpha = 1.0;
    [self showMathKeyboard];
}

- (void)editableExpressionViewDidResignFirstResponder:(MathEditableExpressionView *)editableExpressionView
{
    FTAssert_DEBUG(editableExpressionView == self.editableExpressionView);
    self.auxKeypad.alpha = 0.0;
}

- (void)scrollEditableExpressionView:(MathEditableExpressionView *)editableExpressionView needsBecomeFirstResponder:(BOOL)needsBecomeFirstResponder
{
    FTAssert_DEBUG(editableExpressionView == self.editableExpressionView);
    UIScrollView *scrollView = (UIScrollView *)editableExpressionView.superview;
    CGRect startBounds = scrollView.bounds;
    
    if (needsBecomeFirstResponder) {
        [editableExpressionView my_becomeFirstResponderIfNotAlready];
    }
    
    CGRect endBounds = CGRectStandardize(scrollView.bounds);
    UIView *commonSuperview = scrollView.superview;
    CGRect trackedRect = [commonSuperview convertRect:[editableExpressionView.expression caretRectForPosition:editableExpressionView.selectedRange.selectionEndPosition whenDrawAtPoint:CGPointZero withFontSize:editableExpressionView.fontSize] fromView:editableExpressionView];
    CGRect scrollViewRect = scrollView.frame;
    UIEdgeInsets keepoutInsets = editableExpressionView.insets;
    keepoutInsets.left = keepoutInsets.right;
    
    CGFloat leftMargin = CGRectGetMinX(trackedRect) - CGRectGetMinX(scrollViewRect) - scrollView.contentInset.left;
    CGFloat rightMargin = CGRectGetMaxX(scrollViewRect) - CGRectGetMaxX(trackedRect) - scrollView.contentInset.right;
    if (leftMargin < keepoutInsets.left) {
        endBounds.origin.x -= round(CGRectGetWidth(scrollViewRect) / 3.0 - leftMargin);
    }
    else if (rightMargin <  keepoutInsets.right) {
        endBounds.origin.x += round(CGRectGetWidth(scrollViewRect) / 3.0 - rightMargin);
    }
    CGFloat topMargin = CGRectGetMinY(trackedRect) - CGRectGetMinY(scrollViewRect) - scrollView.contentInset.top;
    CGFloat bottomMargin = CGRectGetMaxY(scrollViewRect) - CGRectGetMaxY(trackedRect) - scrollView.contentInset.bottom;
    if (keepoutInsets.top + CGRectGetHeight(trackedRect) + keepoutInsets.bottom <= CGRectGetHeight(scrollViewRect) - scrollView.contentInset.top - scrollView.contentInset.bottom) {
        if (topMargin < keepoutInsets.top) {
            endBounds.origin.y -= round(keepoutInsets.top - topMargin);
        }
        else if (bottomMargin < keepoutInsets.bottom) {
            endBounds.origin.y += round(keepoutInsets.bottom - bottomMargin);
        }
    }
    else {
        endBounds.origin.y += round(CGRectGetMidY(trackedRect) - (CGRectGetMidY(scrollViewRect) + (scrollView.contentInset.top - scrollView.contentInset.bottom) / 2.0) + (keepoutInsets.bottom - keepoutInsets.top) / 2.0);
    }
    endBounds.origin = [scrollView my_regularizeCandidateContentOffset:endBounds.origin];
    
    if (!CGRectEqualToRect(endBounds, startBounds)) {
        CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"bounds"];
        animation.duration = 0.25;
        animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
        animation.fromValue = [NSValue valueWithCGRect:startBounds];
        scrollView.bounds = endBounds;
        [scrollView.layer addAnimation:animation forKey:@"bounds"];
    }
}

- (void)editableExpressionViewWillChange:(MathEditableExpressionView *)editableExpressionView
{
    FTAssert_DEBUG(editableExpressionView == self.editableExpressionView);
    if (editableExpressionView.highlightView && ![[UIApplication sharedApplication] isIgnoringInteractionEvents]) {
        editableExpressionView.highlightView = nil;
    }
    
    _editableExpressionViewIntrinsicContentSizeBeforeChange = editableExpressionView.intrinsicContentSize;
    _editableExpressionScrollViewContentBLOffsetBeforeChange = self.editableExpressionScrollView.my_contentBLOffset;
}

- (void)editableExpressionViewDidChange:(MathEditableExpressionView *)editableExpressionView
{
    FTAssert_DEBUG(editableExpressionView == self.editableExpressionView);
    UIScrollView *editableExpressionScrollView = self.editableExpressionScrollView;
    UITableView *historyTableView = self.historyTableView;

    /*** Update Answer ***/
    [self updateAnswer];
    
    /*** Update Status Bar ***/
    if (g_isPhone && UIInterfaceOrientationIsLandscape([UIApplication sharedApplication].statusBarOrientation) && editableExpressionView.intrinsicContentSize.height != _editableExpressionViewIntrinsicContentSizeBeforeChange.height) {
        [UIView animateWithDuration:0.25 animations:^{
            [self setNeedsStatusBarAppearanceUpdate];
        }];
    }
        
    /*** Adjust UI ***/
    /* First, update editableExpressionScrollView.contentSize, and layout editableExpressionView's subviews (i.e., the caret, selection suite, etc.), without animation. */
    [editableExpressionView layoutIfNeeded];
    [editableExpressionScrollView layoutIfNeeded];
    [editableExpressionScrollView my_setContentBLOffset:_editableExpressionScrollViewContentBLOffsetBeforeChange regularized:YES];
    
    /* Second, update editorBackView's height (the same as editableExpressionScrollView's), animated. */
    CGPoint oldTableViewContentOffset = historyTableView.contentOffset;
    
    BOOL needsBecomeFirstResponder = !([editableExpressionView isFirstResponder] || _isFirstRun);
    [UIView animateWithDuration:(needsBecomeFirstResponder ? 0.0 : 0.1) animations:^{
        CGRect oldScrollViewBounds = editableExpressionScrollView.bounds;
        
        self.editorIntrinsicHeightConstraint.constant = editableExpressionView.intrinsicContentSize.height;
        [self.view layoutIfNeeded];
    
        CGRect newScrollViewBounds = editableExpressionScrollView.bounds;
        if (g_osVersionMajor < 8) {
            editableExpressionScrollView.bounds = oldScrollViewBounds;
            editableExpressionScrollView.bounds = oldScrollViewBounds;  //: reinforce
            editableExpressionScrollView.bounds = newScrollViewBounds;
        }
        if (_indexPathForNewHistoryRecord == nil) {
            CGPoint newTableViewContentOffset = oldTableViewContentOffset;
            newTableViewContentOffset.y += CGRectGetHeight(newScrollViewBounds) - CGRectGetHeight(oldScrollViewBounds);
            if (newTableViewContentOffset.y != oldTableViewContentOffset.y) {
                if (g_osVersionMajor < 8) {
                    historyTableView.contentOffset = oldTableViewContentOffset;
                }
                [historyTableView my_setContentOffset:newTableViewContentOffset regularized:YES];
            }
        }
    } completion:^(BOOL finished) {
        /* Third, scroll to reveal Caret or Right-Selection-Handle. */
        [self scrollEditableExpressionView:editableExpressionView needsBecomeFirstResponder:needsBecomeFirstResponder];
    }];
    
    if (_indexPathForNewHistoryRecord) {
        historyTableView.contentOffset = oldTableViewContentOffset;
        [historyTableView.layer my_removeAnimationForKeyPath:@"bounds"];
        [historyTableView scrollToRowAtIndexPath:_indexPathForNewHistoryRecord atScrollPosition:0 animated:YES];
        _indexPathForNewHistoryRecord = nil;
    }
}

#define AUTO_SCROLLING_MIN_X_STEP   16.0
#define AUTO_SCROLLING_MIN_Y_STEP    0.0

- (BOOL)editableExpressionView:(MathEditableExpressionView *)editableExpressionView scrollForTrackingPoint:(CGPoint)point
{
    FTAssert_DEBUG(editableExpressionView == self.editableExpressionView);
    UIScrollView *editableExpressionScrollView = self.editableExpressionScrollView;

    UIView *commonSuperview = editableExpressionScrollView.superview;
    CGPoint myPoint = [commonSuperview convertPoint:point fromView:editableExpressionView];
    CGRect expressionViewRect = [commonSuperview convertRect:editableExpressionView.bounds fromView:editableExpressionView];
    CGRect scrollViewRect = editableExpressionScrollView.frame;
    UIEdgeInsets keepoutInsets = editableExpressionView.insets;
    keepoutInsets.left = keepoutInsets.right;

    CGPoint oldContentOffset = editableExpressionScrollView.contentOffset;
    CGPoint newContentOffset = oldContentOffset;
    
    CGFloat leftMargin = myPoint.x - CGRectGetMinX(scrollViewRect);
    CGFloat rightMargin = CGRectGetMaxX(scrollViewRect) - myPoint.x;
    if (leftMargin < keepoutInsets.left) {
        newContentOffset.x = MAX(newContentOffset.x - round(keepoutInsets.left - leftMargin + AUTO_SCROLLING_MIN_X_STEP), 0.0);
    }
    else if (rightMargin < keepoutInsets.right) {
        newContentOffset.x = MIN(newContentOffset.x + round(keepoutInsets.right - rightMargin + AUTO_SCROLLING_MIN_X_STEP), CGRectGetWidth(expressionViewRect) - CGRectGetWidth(scrollViewRect));
    }
    CGFloat topMargin = myPoint.y - CGRectGetMinY(scrollViewRect);
    CGFloat bottomMargin = CGRectGetMaxY(scrollViewRect) - myPoint.y;
    if (topMargin < keepoutInsets.top) {
        newContentOffset.y = MAX(newContentOffset.y - round(keepoutInsets.top - topMargin + AUTO_SCROLLING_MIN_Y_STEP), 0.0);
    }
    else if (bottomMargin < keepoutInsets.bottom) {
        newContentOffset.y = MIN(newContentOffset.y + round(keepoutInsets.bottom - bottomMargin + AUTO_SCROLLING_MIN_Y_STEP), CGRectGetHeight(expressionViewRect) - CGRectGetHeight(scrollViewRect));
    }
    
    if (!CGPointEqualToPoint(newContentOffset, oldContentOffset)) {
        self.editableExpressionScrollView.contentOffset = newContentOffset;
        return YES;
    }
    return NO;
}

- (BOOL)editableExpressionViewShouldReturn:(MathEditableExpressionView *)editableExpressionView
{
    FTAssert_DEBUG(editableExpressionView == self.editableExpressionView);

    if (self.managedObjectContext == nil) {
        //... report
        return NO;
    }
    
    MathExpression *expression = editableExpressionView.expression;
    FTAssert_DEBUG(expression.elements.count);
    HistoryRecord *newRecord = [NSEntityDescription insertNewObjectForEntityForName:@"HistoryRecord" inManagedObjectContext:self.managedObjectContext];
    newRecord.creationDate = [NSDate date];
    newRecord.expression = expression;
    newRecord.answerIsInDegree = self.answerIsInDegree;
    newRecord.containingSheet = self.historySheet;
    NSError *error;
    if (![self.managedObjectContext save:&error]) {
        FTAssert(NO, error);
    }
    
    self.answerUnitIsAssignedByUser = NO;
    
    NSInteger indexOfLastSection = [self.historyTableView numberOfSections] - 1;
    if (0 <= indexOfLastSection) {
        NSInteger indexOfLastRowInLastSection = [self.historyTableView numberOfRowsInSection:indexOfLastSection] - 1;
        if (0 <= indexOfLastRowInLastSection) {
            _indexPathForNewHistoryRecord = [NSIndexPath indexPathForRow:indexOfLastRowInLastSection inSection:indexOfLastSection];
        }
    }
    FTAssert_DEBUG(_indexPathForNewHistoryRecord);
    
    if (g_isPhone && UIInterfaceOrientationIsLandscape([UIApplication sharedApplication].statusBarOrientation)) {
        UIView *editorBackView = self.editorBackView;
        UIView *editorBackViewGhost = [[UIView alloc] initWithFrame:CGRectZero];
        editorBackViewGhost.layer.anchorPoint = CGPointMake(0.5, 0.0);
        editorBackViewGhost.frame = editorBackView.frame;
        editorBackViewGhost.layer.backgroundColor = editorBackView.backgroundColor.CGColor;
        editorBackViewGhost.layer.borderColor = [UIColor lightGrayColor].CGColor;
        editorBackViewGhost.layer.borderWidth = 1;
        editorBackViewGhost.userInteractionEnabled = NO;
        [self.view addSubview:editorBackViewGhost];
        
        MathExpressionView *editableExpressionViewGhost = [[MathExpressionView alloc] initWithFrame:[editorBackView convertRect:editableExpressionView.bounds fromView:editableExpressionView]];
        editableExpressionViewGhost.backgroundColor = [UIColor clearColor];
        editableExpressionViewGhost.expression = editableExpressionView.expression;
        editableExpressionViewGhost.fontSize = editableExpressionView.fontSize;
        editableExpressionViewGhost.insets = editableExpressionView.insets;
        [editorBackViewGhost addSubview:editableExpressionViewGhost];
        
        MathExpressionView *answerExpressionView = self.answerExpressionView;
        if (answerExpressionView.expression) {
            MathExpressionView *answerExpressionViewGhost = [[MathExpressionView alloc] initWithFrame:[editorBackView convertRect:answerExpressionView.bounds fromView:answerExpressionView]];
            answerExpressionViewGhost.backgroundColor = [UIColor clearColor];
            answerExpressionViewGhost.expression = answerExpressionView.expression;
            answerExpressionViewGhost.fontSize = answerExpressionView.fontSize;
            answerExpressionViewGhost.insets = answerExpressionView.insets;
            [editorBackViewGhost addSubview:answerExpressionViewGhost];
        }
        
        UILabel *equalSign = self.equalSign;
        UILabel *equalSignGhost = [[UILabel alloc] initWithFrame:[editorBackView convertRect:equalSign.bounds fromView:equalSign]];
        equalSignGhost.backgroundColor = [UIColor clearColor];
        equalSignGhost.text = equalSign.text;
        equalSignGhost.font = equalSign.font;
        [editorBackViewGhost addSubview:equalSignGhost];
        
        id statusBarShouldHideBlockBak = self.statusBarShouldHide;
        self.statusBarShouldHide = ^{ return YES; };
        _statusBarAnimation = UIStatusBarAnimationFade;
        [UIView animateWithDuration:0.25 animations:^{
            [self setNeedsStatusBarAppearanceUpdate];
        }];
        
        [CATransaction begin];
        [CATransaction setCompletionBlock:^{
            [editorBackViewGhost removeFromSuperview];
            
            self.statusBarShouldHide = statusBarShouldHideBlockBak;
            [self setNeedsStatusBarAppearanceUpdate];
            _statusBarAnimation = UIStatusBarAnimationSlide;
        }];
        
        CFTimeInterval currentLocalLayerTime = [editorBackViewGhost.layer convertTime:CACurrentMediaTime() fromLayer:nil];
        
        CABasicAnimation *coloringAnimation = [CABasicAnimation animationWithKeyPath:@"backgroundColor"];
        coloringAnimation.beginTime = currentLocalLayerTime;
        coloringAnimation.duration = 0.5;
        coloringAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn];
        coloringAnimation.fromValue = (__bridge id)(editorBackViewGhost.layer.backgroundColor);
        editorBackViewGhost.layer.backgroundColor = self.historyTableView.backgroundColor.CGColor;
        [editorBackViewGhost.layer addAnimation:coloringAnimation forKey:@"backgroundColor"];
        
        CABasicAnimation *slidingAnimation = [CABasicAnimation animationWithKeyPath:@"anchorPoint"];
        slidingAnimation.fillMode = kCAFillModeBackwards;
        slidingAnimation.beginTime = currentLocalLayerTime + coloringAnimation.duration;
        slidingAnimation.duration = 0.15;
        slidingAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn];
        slidingAnimation.fromValue = [NSValue valueWithCGPoint:editorBackViewGhost.layer.anchorPoint];
        editorBackViewGhost.layer.anchorPoint = CGPointMake(0.5, 1.0);
        [editorBackViewGhost.layer addAnimation:slidingAnimation forKey:@"anchorPoint"];
        
        [CATransaction commit];
    }
    
    return YES;
}

- (CGPoint)editableExpressionView:editableExpressionView willSetLoupeMagnifyingCenter:(CGPoint)magnifyingCenter inView:(UIView *)aView
{
    FTAssert_DEBUG(editableExpressionView == self.editableExpressionView);

    CGPoint magnifyingCenterInRootView = [self.view convertPoint:magnifyingCenter fromView:aView];
    CGFloat minY = 10.0;
    CGFloat maxY = CGRectGetMaxY(self.editorBackView.frame);
    if (magnifyingCenterInRootView.y < minY) {
        magnifyingCenterInRootView.y = minY;
    }
    else if (magnifyingCenterInRootView.y > maxY) {
        magnifyingCenterInRootView.y = maxY;
    }
    return [self.view convertPoint:magnifyingCenterInRootView toView:aView];
}

#pragma mark -

- (NSDateFormatter *)canonicalDateFormatter
{
    if (_canonicalDateFormatter == nil) {
        _canonicalDateFormatter = [[NSDateFormatter alloc] init];
        _canonicalDateFormatter.dateStyle = NSDateFormatterMediumStyle;
        _canonicalDateFormatter.timeStyle = NSDateFormatterNoStyle;
        _canonicalDateFormatter.doesRelativeDateFormatting = YES;
    }
    return _canonicalDateFormatter;
}

- (NSDateFormatter *)succinctDateFormatter
{
    if (_succinctDateFormatter == nil) {
        _succinctDateFormatter = [[NSDateFormatter alloc] init];
        _succinctDateFormatter.dateFormat = [NSDateFormatter dateFormatFromTemplate:@"MMMdE" options:0 locale:[NSLocale currentLocale]];
    }
    return _succinctDateFormatter;
}

- (NSInteger)thisYear
{
    if (_thisYear == 0) {
        _thisYear = [[NSCalendar currentCalendar] components:NSCalendarUnitYear fromDate:[NSDate date]].year;
    }
    return _thisYear;
}

- (NSDate *)yesterdayOutset
{
    if (_yesterdayOutset == nil) {
        NSCalendar *currentCalendar = [NSCalendar currentCalendar];
        NSDate *yesterday = [NSDate dateWithTimeIntervalSinceNow:-(24.0 * 60.0 * 60.0)];
        NSDateComponents *yesterdayBeginningComponents = [currentCalendar components:(NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay) fromDate:yesterday];
        _yesterdayOutset = [currentCalendar dateFromComponents:yesterdayBeginningComponents];
   }
    return _yesterdayOutset;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return self.fetchedResultsController.sections.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)sectionIndex
{
    FTAssert_DEBUG(tableView == self.historyTableView);
    
    id<NSFetchedResultsSectionInfo> section = self.fetchedResultsController.sections[sectionIndex];
    return section.numberOfObjects;
}

- (CGFloat)tableView:(FTTableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    FTAssert_DEBUG(tableView == self.historyTableView);
    HistoryRecord *record = [self.fetchedResultsController objectAtIndexPath:indexPath];
    BOOL isSelected = [indexPath isEqual:[tableView indexPathForSelectedRow]];
    
    return (tableView.mode == FTTableViewEditingInPlaceMode && isSelected ? HTVC_TAG_EDITOR_HEIGHT : (record.annotation.length ? HTVC_TAG_TOP_MARGIN + HTVC_TAG_HEIGHT : 0.0)) + HTVC_EXPR_TOP_MARGIN + CGRectGetHeight([record.expression rectWhenDrawAtPoint:CGPointZero withFontSize:24.0]) + HTVC_EXPR_ANS_GAP + HTVC_ANS_HEIGHT + HTVC_BOTTOM_MARGIN + 1.0/*Separator*/;
}

- (UITableViewCell *)tableView:(FTTableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    FTAssert_DEBUG(tableView == self.historyTableView);
    HistoryRecord *record = [self.fetchedResultsController objectAtIndexPath:indexPath];
    
    HistoryTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
    if (cell == nil) {
        cell = [[HistoryTableViewCell alloc] initWithHostTableView:tableView reuseIdentifier:@"Cell"];
    }
    cell.record = record;
    cell.backgroundColor = _historyTableViewCellBackgroundColor;
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)sectionIndex
{
    FTAssert_DEBUG(tableView == self.historyTableView);

    return 20.0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)sectionIndex
{
    FTAssert_DEBUG(tableView == self.historyTableView);

    if (sectionIndex == [tableView numberOfSections] - 1) {
        return FLT_EPSILON;
    }
    return 1.0;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)sectionIndex
{
    FTAssert_DEBUG(tableView == self.historyTableView);

    HistorySectionHeader *header = [tableView dequeueReusableHeaderFooterViewWithIdentifier:@"Header"];
    if (header == nil) {
        header = [[HistorySectionHeader alloc] initWithReuseIdentifier:@"Header"];
    }
    
    id<NSFetchedResultsSectionInfo> section = self.fetchedResultsController.sections[sectionIndex];
    HistoryRecord *record = [section.objects firstObject];
    if ([record.creationDate timeIntervalSinceReferenceDate] == 0.0) {
        header.label.text = NSLocalizedString(@"Prehistory", nil);
    }
    else if ([record.creationDate compare:self.yesterdayOutset] != NSOrderedAscending) {
        header.label.text = [self.canonicalDateFormatter stringFromDate:record.creationDate];
    }
    else {
        NSInteger thatYear = (NSInteger)(record.sectionID.longLongValue / 1000000LL);
        header.label.text = [(self.thisYear == thatYear ? self.succinctDateFormatter : self.canonicalDateFormatter) stringFromDate:record.creationDate];
    }
    
    return header;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)sectionIndex
{
    FTAssert_DEBUG(tableView == self.historyTableView);

    UITableViewHeaderFooterView *footer = [tableView dequeueReusableHeaderFooterViewWithIdentifier:@"Footer"];
    if (footer == nil) {
        footer = [[UITableViewHeaderFooterView alloc] initWithReuseIdentifier:@"Footer"];
    }
    return footer;
}

- (BOOL)tableView:(FTTableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    FTAssert_DEBUG(tableView == self.historyTableView);
    
    if (tableView.mode == FTTableViewEditingInPlaceMode) {
        return NO;
    }
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    FTAssert_DEBUG(tableView == self.historyTableView);
    HistoryRecord *record = [self.fetchedResultsController objectAtIndexPath:indexPath];
    
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        [CATransaction begin];
        [CATransaction setCompletionBlock:^{
            if (self.fetchedResultsController.fetchedObjects.count) {
                [self.historyTableView performSelector:@selector(reloadDataSmoothly) withObject:nil afterDelay:0.0];  //! WORKAROUND: At this point, contentSize has not yet been updated.
            }
            else {
                [self.editableExpressionView performSelector:@selector(my_becomeFirstResponderIfNotAlready) withObject:nil afterDelay:0.0];
            }
        }];
        [self.managedObjectContext deleteObject:record];
        NSError *error;
        if (![self.managedObjectContext save:&error]) {
            FTAssert(NO, error);
        }
        [self setNeedsPerformFetch];
        [CATransaction commit];
    }
}

- (void)handlePrevItemButtonTap:(id)sender
{
    FTTableView *tableView = self.historyTableView;
    NSIndexPath *indexPathForSelectedRow = [tableView indexPathForSelectedRow];
    if (indexPathForSelectedRow == nil) {
        FTAssert_DEBUG(NO);
        return;
    }
    
    NSInteger sectionIndexOfPrevItem, rowIndexOfPrevItem;
    if (indexPathForSelectedRow.row == 0) {
        if (indexPathForSelectedRow.section == 0) {
            FTAssert_DEBUG(NO);
            return;
        }
        sectionIndexOfPrevItem = indexPathForSelectedRow.section - 1;
        rowIndexOfPrevItem = [tableView numberOfRowsInSection:sectionIndexOfPrevItem] - 1;
    }
    else {
        sectionIndexOfPrevItem = indexPathForSelectedRow.section;
        rowIndexOfPrevItem = indexPathForSelectedRow.row - 1;
    }
    
    FTAssert_DEBUG(tableView.mode == FTTableViewEditingInPlaceMode);
    [tableView my_interactivelySelectRowAtIndexPath:[NSIndexPath indexPathForRow:rowIndexOfPrevItem inSection:sectionIndexOfPrevItem] animated:YES scrollPosition:UITableViewScrollPositionNone];
}

- (void)handleNextItemButtonTap:(id)sender
{
    FTTableView *tableView = self.historyTableView;
    NSIndexPath *indexPathForSelectedRow = [tableView indexPathForSelectedRow];
    if (indexPathForSelectedRow == nil) {
        FTAssert_DEBUG(NO);
        return;
    }
    
    NSInteger sectionIndexOfNextItem, rowIndexOfNextItem;
    if (indexPathForSelectedRow.row == [tableView numberOfRowsInSection:indexPathForSelectedRow.section] - 1) {
        if (indexPathForSelectedRow.section == [tableView numberOfSections] - 1) {
            FTAssert_DEBUG(NO);
            return;
        }
        sectionIndexOfNextItem = indexPathForSelectedRow.section + 1;
        rowIndexOfNextItem = 0;
    }
    else {
        sectionIndexOfNextItem = indexPathForSelectedRow.section;
        rowIndexOfNextItem = indexPathForSelectedRow.row + 1;
    }
    
    FTAssert_DEBUG(tableView.mode == FTTableViewEditingInPlaceMode);
    [tableView my_interactivelySelectRowAtIndexPath:[NSIndexPath indexPathForRow:rowIndexOfNextItem inSection:sectionIndexOfNextItem] animated:YES scrollPosition:UITableViewScrollPositionNone];
}

- (BOOL)hasPrevItem
{
    FTTableView *tableView = self.historyTableView;
    NSIndexPath *indexPathForSelectedRow = [tableView indexPathForSelectedRow];
    
    return indexPathForSelectedRow && (0 < indexPathForSelectedRow.row || 0 < indexPathForSelectedRow.section);
}

- (BOOL)hasNextItem
{
    FTTableView *tableView = self.historyTableView;
    NSIndexPath *indexPathForSelectedRow = [tableView indexPathForSelectedRow];
    
    return indexPathForSelectedRow && (indexPathForSelectedRow.row < [tableView numberOfRowsInSection:indexPathForSelectedRow.section] - 1 || indexPathForSelectedRow.section < [tableView numberOfSections] - 1);
}

- (void)beginEditingTableViewCell:(UITableViewCell *)cell
{
    FTAssert_DEBUG(self.historyTableView.mode == FTTableViewEditingInPlaceMode);
    if ([cell isSelected]) {
        [[cell viewWithTag:1] becomeFirstResponder];
        [[MathUnitInputView sharedUnitInputView] my_refresh];
    }
    else {
        FTAssert_DEBUG(NO);
    }
}

- (void)tableView:(FTTableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    FTAssert_DEBUG(tableView == self.historyTableView);
    
    switch (tableView.mode) {
        case FTTableViewNormalMode: {
            FTAssert_DEBUG(NO);
            break;
        }
        case FTTableViewBatchEditingMode: {
            [self updateBarButtonItemState];
            break;
        }
        case FTTableViewEditingInPlaceMode: {
            UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
            [CATransaction begin];
            [CATransaction setCompletionBlock:^{
                [self performSelector:@selector(beginEditingTableViewCell:) withObject:cell afterDelay:0.0];  //! WORKAROUND: At this point, contentSize has not yet been updated.
            }];
            [tableView beginUpdates];
            [tableView endUpdates];
            [CATransaction commit];
            
            [tableView my_scrollRectToVisible:[tableView rectForRowAtIndexPath:indexPath] animated:YES];
            break;
        }
    }
}

- (void)tableView:(FTTableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath
{
    FTAssert_DEBUG(tableView == self.historyTableView);
    
    switch (tableView.mode) {
        case FTTableViewNormalMode: {
            FTAssert_DEBUG(NO);
            break;
        }
        case FTTableViewBatchEditingMode: {
            [self updateBarButtonItemState];
            break;
        }
        case FTTableViewEditingInPlaceMode: {
            [tableView beginUpdates];
            [tableView endUpdates];
            
            [[MathUnitInputView sharedUnitInputView] my_refresh];
            break;
        }
    }
}

- (void)tableViewDidTriggerPullDownAction:(FTTableView *)tableView
{
    FTAssert_DEBUG(tableView == self.historyTableView);

    switch (tableView.mode) {
        case FTTableViewNormalMode: {
            self.fetchedResultsController.fetchRequest.fetchLimit += FETCH_LIMIT;
            [self reloadHistory];
            break;
        }
        case FTTableViewBatchEditingMode: {
            self.fetchedResultsController.fetchRequest.fetchLimit += FETCH_LIMIT;
            [self reloadHistory];
            [self updateBarButtonItemState];
            break;
        }
        case FTTableViewEditingInPlaceMode: {
            FTAssert_DEBUG(NO);
            break;
        }
    }
}

- (void)tableView:(FTTableView *)tableView willTransitionToMode:(FTTableViewMode)targetMode animated:(BOOL)animated
{
    FTAssert_DEBUG(tableView == self.historyTableView);

    _historyTableViewBoundsBeforeModeTransition = tableView.bounds;
    switch (targetMode) {
        case FTTableViewNormalMode: {
            if (tableView.mode == FTTableViewEditingInPlaceMode) {
                UIResponder *firstResponder;
                if ((firstResponder = [UIResponder my_firstResponder])) {
                    FTAssert_DEBUG(NO);
                    [firstResponder resignFirstResponder];
                }
                NSIndexPath *indexPathForSelectedRow = [tableView indexPathForSelectedRow];
                if (indexPathForSelectedRow) {
                    [tableView my_interactivelyDeselectRowAtIndexPath:indexPathForSelectedRow animated:animated];
                }
                else {
                    FTAssert_DEBUG(NO);
                }
            }
            break;
        }
        case FTTableViewBatchEditingMode: {
            FTAssert_DEBUG(tableView.mode == FTTableViewNormalMode);
            tableView.allowsMultipleSelectionDuringEditing = YES;
            _historyTableViewSeparatorInsetBak = tableView.separatorInset;
            break;
        }
        case FTTableViewEditingInPlaceMode: {
            FTAssert_DEBUG(tableView.mode == FTTableViewNormalMode);
            [self registerKeyboardNotifications];
            _historyTableViewBackgroundColorBak = tableView.backgroundColor;
            break;
        }
    }
}

-(void)tableView:(FTTableView *)tableView didTransitionFromMode:(FTTableViewMode)previousMode animated:(BOOL)animated
{
    FTAssert_DEBUG(tableView == self.historyTableView);

    switch (previousMode) {
        case FTTableViewNormalMode: {
            break;
        }
        case FTTableViewBatchEditingMode: {
            tableView.allowsMultipleSelectionDuringEditing = NO;  //! WORKAROUND: Multi-selecting and swiping-to-delete can not coexist. [Fixed in iOS 8]
            tableView.separatorInset = _historyTableViewSeparatorInsetBak;
            break;
        }
        case FTTableViewEditingInPlaceMode: {
            [self unregisterKeyboardNotifications];
            [UIView animateWithDuration:(animated ? 0.8 : 0.0) delay:0.0 options:0 animations:^{
                tableView.backgroundColor = _historyTableViewBackgroundColorBak;
            } completion:^(BOOL finished) {
                _historyTableViewCellBackgroundColor = tableView.backgroundColor;
                for (UITableViewCell *cell in [tableView visibleCells]) {
                    cell.backgroundColor = _historyTableViewCellBackgroundColor;
                }
                
                if (_invocation) {
                    [_invocation invoke];
                    _invocation = nil;
                }
            }];
            tableView.drawoutHeaderIsHidden = (self.fetchedResultsController.fetchRequest.fetchOffset == 0);
            break;
        }
    }
    
    switch (tableView.mode) {
        case FTTableViewNormalMode: {
            CGFloat __block deltaTableViewContentBottomInset = 0.0;
            [UIView animateWithDuration:(animated ? 0.3 : 0.0) animations:^{
                CGPoint oldTableViewContentOffset = tableView.contentOffset;
                UIEdgeInsets oldTableViewContentInset = tableView.contentInset;
                
                self.editorHideAtBottomConstraint.active = NO;
                self.editorBottomSpaceConstraint.active = YES;
                self.editorBottomSpaceConstraint.constant = 0.0;
                self.toolbarBottomSpaceConstraint.constant = -TOOLBAR_HEIGHT;
                [self.view layoutIfNeeded];
                
                deltaTableViewContentBottomInset = tableView.contentInset.bottom - oldTableViewContentInset.bottom;
                if (0.0 < deltaTableViewContentBottomInset) {
                    CGPoint newTableViewContentOffset = oldTableViewContentOffset;
                    newTableViewContentOffset.y += deltaTableViewContentBottomInset + 20.0;
                    CGPoint regularizedNewTableViewContentOffset = [tableView my_regularizeCandidateContentOffset:newTableViewContentOffset];
                    if (regularizedNewTableViewContentOffset.y < newTableViewContentOffset.y) {
                        if (g_osVersionMajor < 8) {
                            tableView.contentOffset = oldTableViewContentOffset;
                        }
                        tableView.contentOffset = regularizedNewTableViewContentOffset;
                    }
                }
            }];
            if (animated && deltaTableViewContentBottomInset < 0.0) {
                [tableView.layer my_removeAnimationForKeyPath:@"bounds"];
                CABasicAnimation *tableViewBoundsAnimation = [CABasicAnimation animationWithKeyPath:@"bounds"];
                tableViewBoundsAnimation.timingFunction = [CAMediaTimingFunction functionWithControlPoints:0.8 :0.0 :0.6 :1.0];
                tableViewBoundsAnimation.duration = 0.8;
                tableViewBoundsAnimation.fromValue = [NSValue valueWithCGRect:_historyTableViewBoundsBeforeModeTransition];
                [tableView.layer addAnimation:tableViewBoundsAnimation forKey:@"bounds"];
            }
            
            self.historySheetTitleButton.userInteractionEnabled = YES;
            self.historySheetTitleButton.tintColor = nil;
            self.historySheetTitleDisclosureIndicator.hidden = NO;
            if (g_isPhone) {
                [self.historyNavigationItem setLeftBarButtonItem:self.infoBarButtonItem animated:YES];
            }
            else {
                [self.historyNavigationItem setLeftBarButtonItems:@[self.infoBarButtonItem] animated:YES];
            }
            [self.historyNavigationItem setRightBarButtonItem:self.listBarButtonItem animated:YES];
            
            if (self.fetchedResultsController.fetchedObjects.count == 0) {
                [self.editableExpressionView performSelector:@selector(my_becomeFirstResponderIfNotAlready) withObject:nil afterDelay:0.5];
            }
            break;
        }
        case FTTableViewBatchEditingMode: {
            BOOL mathKeyboardWasShown = (0.0 < self.editorBottomSpaceConstraint.constant);
            [self.editableExpressionView my_resignFirstResponderIfNotAlready];
            self.toolbarBottomSpaceConstraint.constant = 0.0;
            [UIView animateWithDuration:(animated ? 0.3 : 0.0) animations:^{
                self.editorBottomSpaceConstraint.active = NO;
                self.editorBottomSpaceConstraint.constant = 0.0;  //$
                self.editorHideAtBottomConstraint.active = YES;
                [self.view layoutIfNeeded];
                
                tableView.separatorInset = UIEdgeInsetsMake(0.0, 15.0, 0.0, 0.0);
            }];
            if (animated && mathKeyboardWasShown) {
                [tableView.layer my_removeAnimationForKeyPath:@"bounds"];
                CABasicAnimation *tableViewBoundsAnimation = [CABasicAnimation animationWithKeyPath:@"bounds"];
                tableViewBoundsAnimation.timingFunction = [CAMediaTimingFunction functionWithControlPoints:0.8 :0.0 :0.6 :1.0];
                tableViewBoundsAnimation.duration = 0.8;
                tableViewBoundsAnimation.fromValue = [NSValue valueWithCGRect:_historyTableViewBoundsBeforeModeTransition];
                [tableView.layer addAnimation:tableViewBoundsAnimation forKey:@"bounds"];
            }
            
            self.historySheetTitleButton.userInteractionEnabled = NO;
            self.historySheetTitleButton.tintColor = [UIColor blackColor];
            self.historySheetTitleDisclosureIndicator.hidden = YES;
            if (g_isPhone) {
                [self.historyNavigationItem setLeftBarButtonItem:self.selectBarButtonItem animated:YES];
            }
            else {
                [self.historyNavigationItem setLeftBarButtonItems:@[self.selectBarButtonItem, self.deleteBarButtonItem, self.moveBarButtonItem] animated:YES];
            }
            [self.historyNavigationItem setRightBarButtonItem:self.doneBarButtonItem animated:YES];
            [self updateBarButtonItemState];
            break;
        }
        case FTTableViewEditingInPlaceMode: {
            _historyTableViewCellBackgroundColor = [UIColor clearColor];
            for (UITableViewCell *cell in [tableView visibleCells]) {
                cell.backgroundColor = _historyTableViewCellBackgroundColor;
            }
            [UIView animateWithDuration:(animated ? 0.25 : 0.0) animations:^{
                tableView.backgroundColor = [UIColor colorWithWhite:0.98 alpha:1.0];
            }];
            
            [self.editableExpressionView my_resignFirstResponderIfNotAlready];
            BOOL isPortrait = UIInterfaceOrientationIsPortrait([UIApplication sharedApplication].statusBarOrientation);
            [UIView animateWithDuration:(animated ? 0.5 : 0.0) delay:0.0 usingSpringWithDamping:1.0 initialSpringVelocity:0.0 options:UIViewAnimationOptionCurveLinear animations:^{
                CGPoint oldTableViewContentOffset = tableView.contentOffset;
                
                self.editorBottomSpaceConstraint.active = NO;
                self.editorBottomSpaceConstraint.constant = 0.0;  //$
                self.editorHideAtBottomConstraint.active = YES;
                if (/*$ g_isPhone && */g_isClassic && isPortrait) {
                    self.navigationBar.items = @[self.historyNavigationItem];
                    self.navigationBarTopToTopGuideConstraint.constant = 0.0;
                }
                [self.view layoutIfNeeded];

                if (/*$ g_isPhone && */g_isClassic && isPortrait) {
                    UITableViewCell *cell = (UITableViewCell *)[(UIView *)[UIResponder my_firstResponder] my_containingViewOfClass:[UITableViewCell class]];
                    if ([cell isDescendantOfView:tableView]) {
                        CGRect cellRect = [cell convertRect:cell.bounds toView:tableView];
                        CGFloat topSpace = CGRectGetMinY(cellRect) - tableView.contentOffset.y - tableView.contentInset.top;
                        if (topSpace < 0.0) {
                            if (g_osVersionMajor < 8) {
                                tableView.contentOffset = oldTableViewContentOffset;
                            }
                            [tableView my_scrollRectToVisible:cellRect animated:NO];
                        }
                    }
                    else {
                        FTAssert_DEBUG(NO);
                    }
                }
            } completion:nil];
            
            self.historySheetTitleButton.userInteractionEnabled = NO;
            self.historySheetTitleButton.tintColor = [UIColor blackColor];
            self.historySheetTitleDisclosureIndicator.hidden = YES;
            if (g_isPhone) {
                [self.historyNavigationItem setLeftBarButtonItem:self.cancelBarButtonItem animated:YES];
            }
            else {
                [self.historyNavigationItem setLeftBarButtonItems:@[self.cancelBarButtonItem] animated:YES];
            }
            [self.historyNavigationItem setRightBarButtonItem:self.doneBarButtonItem animated:YES];
            
            tableView.drawoutHeaderIsHidden = YES;  //! Avoid the hassle of keeping the keyboard on and restoring the first responder status after reloading data.
            break;
        }
    }
}

#pragma mark -

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller
{
    FTAssert_DEBUG(controller == self.fetchedResultsController);

    [self.historyTableView beginUpdates];
}

- (void)controller:(NSFetchedResultsController *)controller didChangeSection:(id <NSFetchedResultsSectionInfo>)section atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type
{
    switch (type) {
        case NSFetchedResultsChangeInsert: {
            [self.historyTableView insertSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
            break;
        }
        case NSFetchedResultsChangeDelete: {
            [self.historyTableView deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
            break;
        }
        case NSFetchedResultsChangeUpdate: {
            break;
        }
        case NSFetchedResultsChangeMove: {
            break;
        }
    }
}

- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(NSIndexPath *)newIndexPath
{
    FTAssert_DEBUG(controller == self.fetchedResultsController);

    switch (type) {
        case NSFetchedResultsChangeInsert: {
            [self.historyTableView insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            
            self.listBarButtonItem.enabled = (_fetchedResultsController.fetchedObjects.count != 0);
            break;
        }
        case NSFetchedResultsChangeDelete: {
            [self.historyTableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
            
            self.listBarButtonItem.enabled = (_fetchedResultsController.fetchedObjects.count != 0);
            break;
        }
        case NSFetchedResultsChangeUpdate: {
            [[self.historyTableView cellForRowAtIndexPath:indexPath] my_refresh];
            break;
        }
        case NSFetchedResultsChangeMove: {
            [self.historyTableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
            [self.historyTableView insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
        }
    }
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
    FTAssert_DEBUG(controller == self.fetchedResultsController);
    
    [self.historyTableView endUpdates];
}

#pragma mark -

#define RADIUS  11.0

- (void)updateBarButtonItemState
{
    NSUInteger numberOfSelectedRows = [self.historyTableView indexPathsForSelectedRows].count;
    NSUInteger totalNumberOfRows = self.fetchedResultsController.fetchedObjects.count;
    
    UIGraphicsBeginImageContextWithOptions(CGSizeMake(2.0 * RADIUS, 2.0 * RADIUS), NO, 0.0);
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    [[UIColor colorWithWhite:0.0 alpha:0.75] set];
    CGContextBeginPath(ctx);
    CGContextMoveToPoint(ctx, RADIUS, RADIUS);
    CGFloat arcAngle;
    if (numberOfSelectedRows == 0) {
        arcAngle = 0.0;
        _selectionInverted = NO;
    }
    else if (numberOfSelectedRows < totalNumberOfRows) {
        NSUInteger percent = numberOfSelectedRows * 100 / totalNumberOfRows;
        if (percent < 1) {
            percent = 1;
        }
        if (99 < percent) {
            percent = 99;
        }
        arcAngle = percent * (M_PI / 50);
    }
    else {
        arcAngle = 2.0 * M_PI;
    }
    CGContextAddArc(ctx, RADIUS, RADIUS, RADIUS, -M_PI_2, -M_PI_2 + (_selectionInverted ? -1 : 1) * arcAngle, _selectionInverted);
    CGContextClosePath(ctx);
    CGContextFillPath(ctx);
    [[UIColor colorWithWhite:0.0 alpha:1.0] set];
    CGContextStrokeEllipseInRect(ctx, CGRectMake(0.5, 0.5, 2.0 * RADIUS - 1.0, 2.0 * RADIUS - 1.0));
    self.selectBarButtonItem.image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    self.deleteBarButtonItem.enabled = self.moveBarButtonItem.enabled = (numberOfSelectedRows != 0);
}

- (IBAction)handleListButtonTap:(id)sender
{
    [self.historyTableView setMode:FTTableViewBatchEditingMode animated:YES];
}

- (IBAction)handleCancelButtonTap:(id)sender
{
    FTTableView *tableView = self.historyTableView;
    switch (self.historyTableView.mode) {
        case FTTableViewNormalMode: {
            FTAssert_DEBUG(NO);
            break;
        }
        case FTTableViewBatchEditingMode: {
            FTAssert_DEBUG(NO);
            break;
        }
        case FTTableViewEditingInPlaceMode: {
            tableView.discardsChanges = YES;
            [[UIResponder my_firstResponder] resignFirstResponder];
            break;
        }
    }
}

- (IBAction)handleDoneButtonTap:(id)sender
{
    FTTableView *tableView = self.historyTableView;
    switch (self.historyTableView.mode) {
        case FTTableViewNormalMode: {
            FTAssert_DEBUG(NO);
            break;
        }
        case FTTableViewBatchEditingMode: {
            [tableView setMode:FTTableViewNormalMode animated:YES];
            break;
        }
        case FTTableViewEditingInPlaceMode: {
            [[UIResponder my_firstResponder] resignFirstResponder];
            break;
        }
    }
}

- (void)invertHistoryRecordsSelection
{
    FTAssert_DEBUG(self.historyTableView.mode == FTTableViewBatchEditingMode);
    UITableView *tableView = self.historyTableView;
    
    NSEnumerator *indexPathsForSelectedRows = [[tableView indexPathsForSelectedRows] sortedArrayUsingSelector:@selector(compare:)].objectEnumerator;
    NSIndexPath *selectedIndexPath = [indexPathsForSelectedRows nextObject];
    
    NSInteger numberOfSections = [tableView numberOfSections];
    for (NSInteger sectionIndex = 0; sectionIndex < numberOfSections; sectionIndex++) {
        NSInteger numberOfRows = [tableView numberOfRowsInSection:sectionIndex];
        for (NSInteger rowIndex = 0; rowIndex < numberOfRows; rowIndex++) {
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:rowIndex inSection:sectionIndex];
            if ([selectedIndexPath isEqual:indexPath]) {
                [tableView deselectRowAtIndexPath:indexPath animated:NO];
                selectedIndexPath = [indexPathsForSelectedRows nextObject];
            }
            else {
                [tableView selectRowAtIndexPath:indexPath animated:NO scrollPosition:UITableViewScrollPositionNone];
            }
        }
    }
}

- (IBAction)handleSelectButtonTap:(id)sender
{
    [self invertHistoryRecordsSelection];
    _selectionInverted = !_selectionInverted;
    [self updateBarButtonItemState];
}

- (IBAction)handleDeleteButtonTap:(id)sender
{
    UIAlertController *actionSheet = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    NSUInteger numberOfSelectedRows = [self.historyTableView indexPathsForSelectedRows].count;
    UIAlertAction *confirmAction = [UIAlertAction actionWithTitle:(numberOfSelectedRows == 1 ? NSLocalizedString(@"Delete One Record", nil) : [NSString stringWithFormat:NSLocalizedString(@"Delete %lu Records", nil), (unsigned long)numberOfSelectedRows]) style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
        NSArray *indexPathsForSelectedRows = [self.historyTableView indexPathsForSelectedRows];
        [CATransaction begin];
        [CATransaction setCompletionBlock:^{
            [self.historyTableView performSelector:@selector(reloadDataSmoothly) withObject:nil afterDelay:0.0];  //! WORKAROUND: At this point, contentSize has not yet been updated.
        }];
        for (NSIndexPath *indexPath in indexPathsForSelectedRows) {
            [self.managedObjectContext deleteObject:[self.fetchedResultsController objectAtIndexPath:indexPath]];
        }
        NSError *error;
        if (![self.managedObjectContext save:&error]) {
            FTAssert(NO, error);
        }
        [self setNeedsPerformFetch];
        [CATransaction commit];
        
        if (self.fetchedResultsController.fetchedObjects.count) {
            [self updateBarButtonItemState];
        }
        else {
            [self.historyTableView setMode:FTTableViewNormalMode animated:YES];
        }
    }];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel", nil) style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {}];
    [actionSheet addAction:confirmAction];
    [actionSheet addAction:cancelAction];
    
    if (g_isPhone) {
        [self presentViewController:actionSheet animated:YES completion:nil];
    }
    else {
        [self presentViewController:actionSheet animated:YES completion:^{
            actionSheet.popoverPresentationController.passthroughViews = nil;  //! WORKAROUND
        }];
        UIPopoverPresentationController *popover = actionSheet.popoverPresentationController;
        popover.barButtonItem = sender;
    }
}

@end
