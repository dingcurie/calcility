//
//  HistorySheetsViewController.m
//  iCalculator
//
//  Created by curie on 7/7/14.
//  Copyright (c) 2014 Fish Tribe. All rights reserved.
//

#import "HistorySheetsViewController.h"
#import "HistorySheet.h"


#define HS_TITLE_WIDTH         (g_isPhone ? 180.0 : 200.0)
#define HS_TEXTFIELD_EXTRA      8.0


#pragma mark -


@interface HistorySheetDefaultCell : UITableViewCell

- (id)initWithReuseIdentifier:(NSString *)reuseIdentifier;  //: Designated Initializer

@property (nonatomic, weak, readonly) UILabel *titleLabel;
@property (nonatomic, weak, readonly) UILabel *countLabel;

@end


@implementation HistorySheetDefaultCell

- (id)initWithReuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifier];
    if (self) {
        UIView *contentView = [super contentView];
        
        UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        titleLabel.translatesAutoresizingMaskIntoConstraints = NO;
        titleLabel.textAlignment = NSTextAlignmentCenter;
        titleLabel.font = [UIFont boldSystemFontOfSize:17.0];
        [contentView addSubview:(_titleLabel = titleLabel)];
        
        UILabel *countLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        countLabel.translatesAutoresizingMaskIntoConstraints = NO;
        countLabel.font = [UIFont systemFontOfSize:12.0];
        countLabel.enabled = NO;
        [contentView addSubview:(_countLabel = countLabel)];
        
        [NSLayoutConstraint constraintWithItem:titleLabel attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:0.0 constant:HS_TITLE_WIDTH].active = YES;
        [NSLayoutConstraint constraintWithItem:titleLabel attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:0.0].active = YES;
        [NSLayoutConstraint constraintWithItem:titleLabel attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:contentView attribute:NSLayoutAttributeTop multiplier:1.0 constant:10.0].active = YES;
        
        [NSLayoutConstraint constraintWithItem:countLabel attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:titleLabel attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:0.0].active = YES;
        [NSLayoutConstraint constraintWithItem:countLabel attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:titleLabel attribute:NSLayoutAttributeBottom multiplier:1.0 constant:8.0].active = YES;
    }
    return self;
}

- (void)willTransitionToState:(UITableViewCellStateMask)state
{
    [super willTransitionToState:state];
    
    if (state) {
        /* Editing mode */
        self.titleLabel.enabled = NO;
    }
    else {
        /* Normal mode */
        self.titleLabel.enabled = YES;
    }
}

@end


#pragma mark -


@interface HistorySheetCell : UITableViewCell

- (id)initWithReuseIdentifier:(NSString *)reuseIdentifier;  //: Designated Initializer

@property (nonatomic, weak) HistorySheet *sheet;
@property (nonatomic, weak) id<UITextFieldDelegate> delegate;

@property (nonatomic, weak, readonly) UILabel *titleLabel;
@property (nonatomic, weak, readonly) UILabel *countLabel;

@property (nonatomic, weak, readonly) UITextField *titleTextField;

@end


@implementation HistorySheetCell

- (id)initWithReuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifier];
    if (self) {
        UIView *contentView = [super contentView];
        
        UITextField *titleTextField = [[UITextField alloc] initWithFrame:CGRectZero];
        titleTextField.translatesAutoresizingMaskIntoConstraints = NO;
        titleTextField.borderStyle = UITextBorderStyleRoundedRect;
        titleTextField.textAlignment = NSTextAlignmentCenter;
        titleTextField.font = [UIFont systemFontOfSize:17.0];
        if (g_isPhone) {
            titleTextField.adjustsFontSizeToFitWidth = YES;
            titleTextField.minimumFontSize = 15.0;
        }
        titleTextField.autocapitalizationType = UITextAutocapitalizationTypeWords;
        titleTextField.returnKeyType = UIReturnKeyDone;
        titleTextField.enablesReturnKeyAutomatically = YES;
        [contentView addSubview:(_titleTextField = titleTextField)];
        titleTextField.hidden = YES;
        
        UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        titleLabel.translatesAutoresizingMaskIntoConstraints = NO;
        titleLabel.lineBreakMode = NSLineBreakByTruncatingMiddle;
        titleLabel.textAlignment = NSTextAlignmentCenter;
        titleLabel.font = [UIFont systemFontOfSize:17.0];
        if (g_isPhone) {
            titleLabel.adjustsFontSizeToFitWidth = YES;
            titleLabel.minimumScaleFactor = 15.0 / 17.0;
        }
        [contentView addSubview:(_titleLabel = titleLabel)];
        
        UILabel *countLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        countLabel.translatesAutoresizingMaskIntoConstraints = NO;
        countLabel.font = [UIFont systemFontOfSize:12.0];
        countLabel.enabled = NO;
        [contentView addSubview:(_countLabel = countLabel)];
        
        [NSLayoutConstraint constraintWithItem:titleLabel attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:0.0 constant:HS_TITLE_WIDTH].active = YES;
        [NSLayoutConstraint constraintWithItem:titleLabel attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:0.0].active = YES;
        [NSLayoutConstraint constraintWithItem:titleLabel attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:contentView attribute:NSLayoutAttributeTop multiplier:1.0 constant:10.0].active = YES;
        
        [NSLayoutConstraint constraintWithItem:countLabel attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:titleLabel attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:0.0].active = YES;
        [NSLayoutConstraint constraintWithItem:countLabel attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:titleLabel attribute:NSLayoutAttributeBottom multiplier:1.0 constant:8.0].active = YES;
        
        [NSLayoutConstraint constraintWithItem:titleTextField attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:0.0 constant:(HS_TITLE_WIDTH + 2.0 * HS_TEXTFIELD_EXTRA)].active = YES;
        [NSLayoutConstraint constraintWithItem:titleTextField attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:titleLabel attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:0.0].active = YES;
        [NSLayoutConstraint constraintWithItem:titleTextField attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:titleLabel attribute:NSLayoutAttributeCenterY multiplier:1.0 constant:0.0].active = YES;
    }
    return self;
}

- (void)setSheet:(HistorySheet *)sheet
{
    _sheet = sheet;
    
    [self my_refresh];
}

- (void)my_refresh
{
    self.titleLabel.text = self.sheet.title;
    NSUInteger count = self.sheet.records.count;
    self.countLabel.text = [NSString stringWithFormat:(count == 1 ? NSLocalizedString(@"%lu record", nil) : NSLocalizedString(@"%lu records", nil)), (unsigned long)count];
}

- (void)setDelegate:(id <UITextFieldDelegate>)delegate
{
    _delegate = delegate;
    
    self.titleTextField.delegate = delegate;
}

//! WORKAROUND: iOS failed to call -[UITableViewCell willTransitionToState:] when dismissing the delete confirmation button in editing mode. [Fixed in iOS 8]
- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event
{
    UIView *hitView = [super hitTest:point withEvent:event];
    if (self.showingDeleteConfirmation && [hitView isDescendantOfView:self.contentView]) {
        return self.contentView.superview;
    }
    return hitView;
}

- (void)resetToNormalMode
{
    self.titleTextField.hidden = YES;
    self.titleTextField.text = @"";
}

- (void)prepareForReuse
{
    [super prepareForReuse];
    
    if (g_osVersionMajor < 8) {
        [self resetToNormalMode];
    }
}

- (void)willTransitionToState:(UITableViewCellStateMask)state
{
    [super willTransitionToState:state];
    
    if (state) {
        /* Editing mode */
        if (state & UITableViewCellStateShowingEditControlMask) {
            self.titleTextField.hidden = NO;
        }
        
        if (state & UITableViewCellStateShowingDeleteConfirmationMask) {
            if ([self.titleTextField isFirstResponder]) {
                [self.titleTextField resignFirstResponder];
            }
        }
    }
    else {
        /* Normal mode */
        [self resetToNormalMode];
    }
}

@end


#pragma mark -


@interface HistorySheetAddingCell : UITableViewCell

- (id)initWithReuseIdentifier:(NSString *)reuseIdentifier;  //: Designated Initializer

@property (nonatomic, weak) id<UITextFieldDelegate> delegate;

@property (nonatomic, weak, readonly) UIImageView *addImageView;
@property (nonatomic, weak, readonly) UITextField *titleTextField;

@end


@implementation HistorySheetAddingCell

- (id)initWithReuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifier];
    if (self) {
        UIView *contentView = [super contentView];
        
        UIImageView *addImageView = [[UIImageView alloc] initWithImage:[[UIImage imageNamed:@"UINavigationBarAddButton"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate]];
        addImageView.translatesAutoresizingMaskIntoConstraints = NO;
        [contentView addSubview:(_addImageView = addImageView)];
        
        UITextField *titleTextField = [[UITextField alloc] initWithFrame:CGRectZero];
        titleTextField.translatesAutoresizingMaskIntoConstraints = NO;
        titleTextField.borderStyle = UITextBorderStyleRoundedRect;
        titleTextField.textAlignment = NSTextAlignmentCenter;
        titleTextField.font = [UIFont systemFontOfSize:17.0];
        if (g_isPhone) {
            titleTextField.adjustsFontSizeToFitWidth = YES;
            titleTextField.minimumFontSize = 15.0;
        }
        titleTextField.autocapitalizationType = UITextAutocapitalizationTypeWords;
        titleTextField.returnKeyType = UIReturnKeyDone;
        titleTextField.clearsOnBeginEditing = YES;
        titleTextField.placeholder = NSLocalizedString(@"Title", nil);
        [contentView addSubview:(_titleTextField = titleTextField)];
        titleTextField.hidden = YES;
        
        [NSLayoutConstraint constraintWithItem:addImageView attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:contentView attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:0.0].active = YES;
        [NSLayoutConstraint constraintWithItem:addImageView attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:contentView attribute:NSLayoutAttributeCenterY multiplier:1.0 constant:0.0].active = YES;
        
        [NSLayoutConstraint constraintWithItem:titleTextField attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:0.0 constant:(HS_TITLE_WIDTH + 2 * HS_TEXTFIELD_EXTRA)].active = YES;
        [NSLayoutConstraint constraintWithItem:titleTextField attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:contentView attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:0.0].active = YES;
        [NSLayoutConstraint constraintWithItem:titleTextField attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:contentView attribute:NSLayoutAttributeCenterY multiplier:1.0 constant:0.0].active = YES;
    }
    return self;
}

- (void)setDelegate:(id <UITextFieldDelegate>)delegate
{
    _delegate = delegate;
    
    self.titleTextField.delegate = delegate;
}

@end


#pragma mark -


@interface HistorySheetsViewController () <UITextFieldDelegate>

@property (nonatomic, strong, readonly) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, strong, readonly) NSMutableArray *historySheets;

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *editBarButtonItem;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *doneBarButtonItem;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *cancelBarButtonItem;

@property (nonatomic, strong, readonly) HistorySheetDefaultCell *defaultCell;
@property (nonatomic, strong, readonly) HistorySheetAddingCell *addingCell;

- (IBAction)handleEditButtonTap:(id)sender;
- (IBAction)handleDoneButtonTap:(id)sender;
- (IBAction)handleCancelButtonTap:(id)sender;

@end


#define HS_TABLEVIEW_CONTENTINSET_BOTTOM_EXTRA  22.0


@implementation HistorySheetsViewController {
    NSIndexPath *_indexPathForScrollTarget;
}

@synthesize historySheets = _historySheets;
@synthesize managedObjectContext = _managedObjectContext;
@synthesize defaultCell = _defalutCell, addingCell = _addingCell;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.navigationItem.prompt = self.prompt;
    
    self.tableView.rowHeight = 60.0;
    self.tableView.separatorInset = UIEdgeInsetsMake(0.0, 15.0, 0.0, 15.0);
    UIEdgeInsets tmpInset = self.tableView.contentInset;
    tmpInset.bottom += HS_TABLEVIEW_CONTENTINSET_BOTTOM_EXTRA;
    self.tableView.contentInset = tmpInset;
    
    if (self.selectedHistorySheet) {
        NSManagedObjectID *selectedSheetID = self.selectedHistorySheet.objectID;
        NSUInteger indexOfOpenedSheet = [self.historySheets indexOfObjectWithOptions:(NSEnumerationReverse | NSEnumerationConcurrent) passingTest:^BOOL(HistorySheet *sheet, NSUInteger index, BOOL *stop) {
            return [sheet.objectID isEqual:selectedSheetID];
        }];
        if (indexOfOpenedSheet == NSNotFound) {
            self.selectedHistorySheet = nil;
        }
        else {
            self.selectedHistorySheet = self.historySheets[indexOfOpenedSheet];
            _indexPathForScrollTarget = [NSIndexPath indexPathForRow:(indexOfOpenedSheet + 1) inSection:0];
        }
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    //! WORKAROUND(1/3): Otherwise, navigation bar will jump to place from underneath the status bar.
    if (g_isPhone && g_osVersionMajor < 8) {
        self.navigationController.navigationBar.frame = CGRectMake(0.0, 0.0, 320.0, 64.0);
    }
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    if (g_isPhone) {
        //! WORKAROUND(3/3): Otherwise, navigation bar will jump to place from underneath the status bar.
        if (g_osVersionMajor < 8) {
            CGPoint contentOffset = self.tableView.contentOffset;
            contentOffset.y -= 20.0;
            [self.tableView my_setContentOffset:contentOffset regularized:YES];
        }
        
        NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
        [notificationCenter addObserver:self selector:@selector(respondToKeyboardWillShowNotification:) name:UIKeyboardWillShowNotification object:nil];
        [notificationCenter addObserver:self selector:@selector(respondToKeyboardWillHideNotification:) name:UIKeyboardWillHideNotification object:nil];
    }
    
    [self.tableView flashScrollIndicators];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    if (g_isPhone) {
        NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
        [notificationCenter removeObserver:self name:UIKeyboardDidShowNotification object:nil];
        [notificationCenter removeObserver:self name:UIKeyboardDidHideNotification object:nil];
    }
}

- (void)viewDidLayoutSubviews
{
    if (_indexPathForScrollTarget) {
        [self.tableView scrollToRowAtIndexPath:_indexPathForScrollTarget atScrollPosition:UITableViewScrollPositionMiddle animated:NO];
        _indexPathForScrollTarget = nil;
    }
    
    //! WORKAROUND(2/3): Otherwise, navigation bar will jump to place from underneath the status bar.
    if (g_isPhone && g_osVersionMajor < 8) {
        CGPoint contentOffset = self.tableView.contentOffset;
        if (contentOffset.y < -64.0) {
            contentOffset.y = -64.0;
            self.tableView.contentOffset = contentOffset;
        }
    }
}

- (NSManagedObjectContext *)managedObjectContext
{
    if (_managedObjectContext == nil) {
        _managedObjectContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
        _managedObjectContext.persistentStoreCoordinator = [AppDelegate sharedPersistentStoreCoordinator];
        _managedObjectContext.undoManager = nil;
    }
    return _managedObjectContext;
}

- (NSMutableArray *)historySheets
{
    if (_historySheets == nil) {
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"HistorySheet"];
        fetchRequest.sortDescriptors = @[[[NSSortDescriptor alloc] initWithKey:@"ordinal" ascending:YES]];
        fetchRequest.fetchBatchSize = 20;
        NSError *error;
        _historySheets = [[self.managedObjectContext executeFetchRequest:fetchRequest error:&error] mutableCopy];
        FTAssert(_historySheets, error);
    }
    return _historySheets;
}

- (HistorySheetDefaultCell *)defaultCell
{
    if (_defalutCell == nil) {
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"HistoryRecord"];
        fetchRequest.predicate = [NSPredicate predicateWithFormat:@"(containingSheet == nil) AND (expression != nil)"];
        NSError *error;
        NSUInteger count = [self.managedObjectContext countForFetchRequest:fetchRequest error:&error];
        if (count == NSNotFound) {
            FTAssert(NO, error);
        }
        
        _defalutCell = [[HistorySheetDefaultCell alloc] initWithReuseIdentifier:nil];
        _defalutCell.titleLabel.text = NSLocalizedString(@"History", nil);
        _defalutCell.countLabel.text = [NSString stringWithFormat:(count == 1 ? NSLocalizedString(@"%lu record", nil) : NSLocalizedString(@"%lu records", nil)), count];
    }
    return _defalutCell;
}

- (HistorySheetAddingCell *)addingCell
{
    if (_addingCell == nil) {
        _addingCell = [[HistorySheetAddingCell alloc] initWithReuseIdentifier:nil];
        _addingCell.delegate = self;
    }
    return _addingCell;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)respondToKeyboardWillShowNotification:(NSNotification *)notification
{
    NSDictionary *userInfo = [notification userInfo];
    BOOL animated = (0.01 < [userInfo[UIKeyboardAnimationDurationUserInfoKey] doubleValue]);
    CGRect keyboardRect = [userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
    keyboardRect = [self.view.window convertRect:keyboardRect fromWindow:nil];
    keyboardRect = [self.view convertRect:keyboardRect fromView:nil];
    
    [UIView animateWithDuration:(animated ? 0.5 : 0.0) delay:(animated ? 0.2 : 0.0) usingSpringWithDamping:1.0 initialSpringVelocity:0.0 options:UIViewAnimationOptionCurveLinear animations:^{
        UITableView *tableView = self.tableView;
        
        UIEdgeInsets insets;
        insets = tableView.scrollIndicatorInsets;
        insets.bottom = CGRectGetHeight(keyboardRect) - 1.0/*:Separator*/;
        tableView.scrollIndicatorInsets = insets;
        tableView.contentInset = insets;
        
        UITableViewCell *cell = (UITableViewCell *)[(UIView *)[UIResponder my_firstResponder] my_containingViewOfClass:[UITableViewCell class]];
        if ([cell isDescendantOfView:tableView]) {
            [tableView my_scrollRectToVisible:[cell convertRect:cell.bounds toView:tableView] animated:NO];
        }
        else {
            FTAssert_DEBUG(NO);
        }
    } completion:nil];
}

- (void)respondToKeyboardWillHideNotification:(NSNotification *)notification
{
    NSDictionary *userInfo = [notification userInfo];
    BOOL animated = (0.01 < [userInfo[UIKeyboardAnimationDurationUserInfoKey] doubleValue]);

    [UIView animateWithDuration:(animated ? 0.5 : 0.0) delay:(animated ? 0.2 : 0.0) usingSpringWithDamping:1.0 initialSpringVelocity:0.0 options:UIViewAnimationOptionCurveLinear animations:^{
        UITableView *tableView = self.tableView;
        
        UIEdgeInsets insets;
        insets = tableView.scrollIndicatorInsets;
        insets.bottom = 0.0;
        tableView.scrollIndicatorInsets = insets;
        insets.bottom = HS_TABLEVIEW_CONTENTINSET_BOTTOM_EXTRA;
        tableView.contentInset = insets;
    } completion:nil];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1 + self.historySheets.count + (self.editing ? 0 : 1);
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger row = indexPath.row;
    
    if (row == 0) {
        self.defaultCell.accessoryType = self.selectedHistorySheet == nil ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;
        return self.defaultCell;
    }
    else if (row < 1 + self.historySheets.count) {
        HistorySheetCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
        if (cell == nil) {
            cell = [[HistorySheetCell alloc] initWithReuseIdentifier:@"Cell"];
            cell.delegate = self;
        }
        HistorySheet *sheet = self.historySheets[row - 1];
        cell.sheet = sheet;
        cell.accessoryType = self.selectedHistorySheet == sheet ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;
        return cell;
    }
    else {
#ifdef LITE_VERSION
        if (self.historySheets.count < 5) {
            self.addingCell.addImageView.tintAdjustmentMode = UIViewTintAdjustmentModeAutomatic;
        }
        else {
            self.addingCell.addImageView.tintAdjustmentMode = UIViewTintAdjustmentModeDimmed;
        }
#endif
        return self.addingCell;
    }
}

- (BOOL)tableView:(UITableView *)tableView shouldHighlightRowAtIndexPath:(NSIndexPath *)indexPath
{
    FTAssert_DEBUG(![tableView isEditing]);
    if ([UIResponder my_firstResponder]) {
        return NO;
    }
    return YES;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger row = indexPath.row;

    if (row < 1 + self.historySheets.count) {
        self.selectedHistorySheet = row == 0 ? nil : self.historySheets[row - 1];
        [self.delegate historySheetsViewControllerWillDismiss:self];
        [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
    }
    else {
        [tableView deselectRowAtIndexPath:indexPath animated:NO];
#ifdef LITE_VERSION
        if (self.addingCell.addImageView.tintAdjustmentMode == UIViewTintAdjustmentModeDimmed) {
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Limited in this Lite Version", nil) message:NSLocalizedString(@"Would you like to upgrade to the full-featured version?", nil) preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"No, thanks", nil) style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {}];
            UIAlertAction *goAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"App Store", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:g_appStdLink]];
            }];
            [alert addAction:cancelAction];
            [alert addAction:goAction];
            [self presentViewController:alert animated:YES completion:nil];
        }
        else
#endif
        {
            [self.addingCell.titleTextField becomeFirstResponder];
        }
    }
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 0) {
        return UITableViewCellEditingStyleNone;
    }
    return UITableViewCellEditingStyleDelete;
}

- (BOOL)tableView:(UITableView *)tableView shouldIndentWhileEditingRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 0) {
        return NO;
    }
    return YES;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 1 + self.historySheets.count) {
        return NO;
    }
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger row = indexPath.row;
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        FTAssert(0 < row && row < 1 + self.historySheets.count);
        NSInteger index = row - 1;
        HistorySheet *sheetToDelete = self.historySheets[index];
        [self.historySheets removeObjectAtIndex:index];
        [self.managedObjectContext deleteObject:sheetToDelete];
        NSError *error;
        if (![self.managedObjectContext save:&error]) {
            FTAssert(NO, error);
        }
        if (self.selectedHistorySheet == sheetToDelete) {
            self.selectedHistorySheet = nil;
        }
        [CATransaction begin];
        [CATransaction setCompletionBlock:^{
            [self.tableView reloadData];
        }];
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
        [CATransaction commit];
    }
}

- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 0) {
        return NO;
    }
    return YES;
}

- (NSIndexPath *)tableView:(UITableView *)tableView targetIndexPathForMoveFromRowAtIndexPath:(NSIndexPath *)sourceIndexPath toProposedIndexPath:(NSIndexPath *)proposedDestinationIndexPath
{
    if (proposedDestinationIndexPath.row == 0) {
        return [NSIndexPath indexPathForRow:1 inSection:0];
    }
    return proposedDestinationIndexPath;
}

- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
    NSInteger fromIndex = fromIndexPath.row - 1;
    NSInteger toIndex = toIndexPath.row - 1;
    if (toIndex == fromIndex) return;
    
    NSMutableArray *sheets = self.historySheets;
    HistorySheet *sheetToMove = sheets[fromIndex];
    
    if (toIndex < fromIndex) {
        HistorySheet *topSheetToShiftDown = sheets[toIndex];
        sheetToMove.ordinal = topSheetToShiftDown.ordinal++;
        HistorySheet *sheetAbove = topSheetToShiftDown;
        for (NSInteger i = toIndex + 1; i < fromIndex; i++) {
            HistorySheet *sheet = sheets[i];
            if (sheetAbove.ordinal < sheet.ordinal) break;
            sheet.ordinal++;
            sheetAbove = sheet;
        }
    }
    else {
        HistorySheet *bottomSheetToShiftUp = sheets[toIndex];
        sheetToMove.ordinal = bottomSheetToShiftUp.ordinal--;
        HistorySheet *sheetBelow = bottomSheetToShiftUp;
        for (NSInteger i = toIndex - 1; fromIndex < i; i--) {
            HistorySheet *sheet = sheets[i];
            if (sheet.ordinal < sheetBelow.ordinal) break;
            sheet.ordinal--;
            sheetBelow = sheet;
        }
    }
    
    if ([self.managedObjectContext hasChanges]) {
        NSError *error;
        if (![self.managedObjectContext save:&error]) {
            FTAssert(NO, error);
        }
    }
    
    [sheets removeObjectAtIndex:fromIndex];
    [sheets insertObject:sheetToMove atIndex:toIndex];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    UITableViewCell *aCell = (UITableViewCell *)[textField my_containingViewOfClass:[UITableViewCell class]];
    if ([self isEditing]) {
        FTAssert([aCell isKindOfClass:[HistorySheetCell class]], aCell);
        HistorySheetCell *cell = (HistorySheetCell *)aCell;
        textField.text = cell.titleLabel.text;
        cell.titleLabel.hidden = YES;
    }
    else {
        FTAssert(aCell == self.addingCell, aCell);
        self.addingCell.addImageView.hidden = YES;
        self.addingCell.titleTextField.hidden = NO;
    }
    
    [self.navigationItem setLeftBarButtonItem:self.cancelBarButtonItem animated:YES];
    [self.navigationItem setRightBarButtonItem:self.doneBarButtonItem animated:YES];
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    UITableViewCell *aCell = (UITableViewCell *)[textField my_containingViewOfClass:[UITableViewCell class]];
    if ([self isEditing]) {
        FTAssert([aCell isKindOfClass:[HistorySheetCell class]], aCell);
        HistorySheetCell *cell = (HistorySheetCell *)aCell;
        if (textField.text.length) {
            cell.sheet.title = cell.titleLabel.text = textField.text;
            NSError *error;
            if (![self.managedObjectContext save:&error]) {
                FTAssert(NO, error);
            }
            textField.text = @"";
        }
        cell.titleLabel.hidden = NO;
        
        [self.navigationItem setLeftBarButtonItem:nil animated:YES];
        [self.navigationItem setRightBarButtonItem:self.doneBarButtonItem animated:YES];
    }
    else {
        FTAssert(aCell == self.addingCell, aCell);
        self.addingCell.addImageView.hidden = NO;
        self.addingCell.titleTextField.hidden = YES;
        if (textField.text.length) {
            HistorySheet *newSheet = [NSEntityDescription insertNewObjectForEntityForName:@"HistorySheet" inManagedObjectContext:self.managedObjectContext];
            newSheet.title = textField.text;
            newSheet.ordinal = (int64_t)([NSDate date].timeIntervalSinceReferenceDate * 1000);
            NSError *error;
            if (![self.managedObjectContext save:&error]) {
                FTAssert(NO, error);
            }
            [self.historySheets addObject:newSheet];
            [self.tableView reloadData];
        }
        
        [self.navigationItem setLeftBarButtonItem:self.editBarButtonItem animated:YES];
        if (g_isPhone) {
            [self.navigationItem setRightBarButtonItem:self.doneBarButtonItem animated:YES];
        }
        else {
            [self.navigationItem setRightBarButtonItem:nil animated:YES];
        }
    }
}

- (void)setEditing:(BOOL)editing animated:(BOOL)animated
{
    [super setEditing:editing animated:animated];
    [self.tableView setEditing:editing animated:animated];
    
    NSIndexPath *indexPathForAddingCell = [NSIndexPath indexPathForRow:(1 + self.historySheets.count) inSection:0];
    if (editing) {
        [self.tableView deleteRowsAtIndexPaths:@[indexPathForAddingCell] withRowAnimation:UITableViewRowAnimationNone];
        
        [self.navigationItem setLeftBarButtonItem:nil animated:animated];
        [self.navigationItem setRightBarButtonItem:self.doneBarButtonItem animated:animated];
    }
    else {
        [self.tableView insertRowsAtIndexPaths:@[indexPathForAddingCell] withRowAnimation:UITableViewRowAnimationNone];
        
        [self.navigationItem setLeftBarButtonItem:self.editBarButtonItem animated:animated];
        if (g_isPhone) {
            [self.navigationItem setRightBarButtonItem:self.doneBarButtonItem animated:animated];
        }
        else {
            [self.navigationItem setRightBarButtonItem:nil animated:animated];
        }
    }
}

- (IBAction)handleEditButtonTap:(id)sender
{
    if ([self.tableView isEditing]) {
        [self.tableView setEditing:NO animated:NO];
    }
    [self setEditing:YES animated:YES];
}

- (IBAction)handleDoneButtonTap:(id)sender
{
    UIResponder *firstResponder = [UIResponder my_firstResponder];
    if (firstResponder) {
        [firstResponder resignFirstResponder];
    }
    else {
        if ([self isEditing]) {
            [self setEditing:NO animated:YES];
        }
        else {
            FTAssert_DEBUG(g_isPhone);
            if ([self.tableView isEditing]) {
                [self.tableView setEditing:NO animated:NO];  //! WORKAROUND: Otherwise, iOS will crash when dismiss with the delete-confirmation button shown.
            }
            [self.delegate historySheetsViewControllerWillDismiss:self];
            [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
        }
    }
}

- (IBAction)handleCancelButtonTap:(id)sender
{
    UIResponder *firstResponder = (UITextField *)[UIResponder my_firstResponder];
    if ([firstResponder isKindOfClass:[UITextField class]]) {
        ((UITextField *)firstResponder).text = @"";
        [firstResponder resignFirstResponder];
    }
    else {
        FTAssert_DEBUG(NO);
    }
}

- (BOOL)popoverPresentationControllerShouldDismissPopover:(UIPopoverPresentationController *)popoverPresentationController
{
    [[UIResponder my_firstResponder] resignFirstResponder];
    return YES;
}

- (void)popoverPresentationControllerDidDismissPopover:(UIPopoverPresentationController *)popoverPresentationController
{
    FTAssert_DEBUG(!g_isPhone);
    [self.delegate historySheetsViewControllerWillDismiss:self];
}

@end
