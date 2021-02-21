//
//  HistoryTableViewCell.m
//  iCalculator
//
//  Created by curie on 13-1-8.
//  Copyright (c) 2013年 Fish Tribe. All rights reserved.
//

#import "HistoryTableViewCell.h"
#import "HistoryRecord.h"
#import "HTVC_MathExpressionView.h"
#import "HTVC_Tag.h"
#import "HTVC_TagEditor.h"
#import "MathUnitInputView.h"


@interface HistoryTableViewCell () <UITextFieldDelegate>

@property (nonatomic, weak, readonly) HTVC_Tag *myTag;
@property (nonatomic, weak, readonly) HTVC_TagEditor *tagEditor;
@property (nonatomic, weak, readonly) MathExpressionView *expressionView;
@property (nonatomic, weak, readonly) MathExpressionView *answerExpressionView;
@property (nonatomic, weak, readonly) UIScrollView *expressionScrollView;
@property (nonatomic, weak, readonly) UIImageView *expressionLeftFadingOut;

@property (nonatomic, weak, readonly) NSLayoutConstraint *tagLeadingMarginConstraint;
@property (nonatomic, weak, readonly) NSLayoutConstraint *tagMinimumTrailingMarginConstraint;
@property (nonatomic, weak, readonly) NSLayoutConstraint *tagTopMarginConstraint;
@property (nonatomic, weak, readonly) NSLayoutConstraint *tagHeightConstraint;
@property (nonatomic, weak, readonly) NSLayoutConstraint *tagEditorLeadingMarginConstraint;
@property (nonatomic, weak, readonly) NSLayoutConstraint *tagEditorTopMarginConstraint;
@property (nonatomic, weak, readonly) NSLayoutConstraint *tagEditorHeightConstraint;

@end


@implementation HistoryTableViewCell

#define HTVC_TAG_MINIMUM_TRAILING_MARGIN   38.0  //! Width of the multi-selection control

- (id)initWithHostTableView:(FTTableView *)hostTableView reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifier];
    if (self) {
        _hostTableView = hostTableView;
        
        if ([UIView instancesRespondToSelector:@selector(layoutMargins)]) {
            self.layoutMargins = UIEdgeInsetsZero;
        }
        UIView *selectedBackgroundView = [[UIView alloc] init];
        selectedBackgroundView.backgroundColor = [UIColor colorWithWhite:1.0 alpha:1.0];
        self.selectedBackgroundView = selectedBackgroundView;
        UIView *multipleSelectionBackgroundView = [[UIView alloc] init];
        self.multipleSelectionBackgroundView = multipleSelectionBackgroundView;
        
        UIView *contentView = self.contentView;
        
        UIScrollView *expressionScrollView = [[UIScrollView alloc] initWithFrame:CGRectZero];
        expressionScrollView.translatesAutoresizingMaskIntoConstraints = NO;
        expressionScrollView.decelerationRate = UIScrollViewDecelerationRateFast;
        expressionScrollView.scrollsToTop = NO;
        expressionScrollView.scrollIndicatorInsets = UIEdgeInsetsMake(0.0, 0.0, HTVC_ANS_HEIGHT + HTVC_BOTTOM_MARGIN, 0.0);
        
        HTVC_MathExpressionView *expressionView = [[HTVC_MathExpressionView alloc] initWithFrame:CGRectZero hostCell:self];
        expressionView.translatesAutoresizingMaskIntoConstraints = NO;
        
        UIImageView *expressionLeftFadingOut = [[UIImageView alloc] initWithImage:[[UIImage imageNamed:@"gradient-8"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate]];
        expressionLeftFadingOut.translatesAutoresizingMaskIntoConstraints = NO;
        expressionLeftFadingOut.tintColor = hostTableView.backgroundColor;
        [hostTableView addObserver:self forKeyPath:@"backgroundColor" options:0 context:NULL];
        expressionLeftFadingOut.hidden = YES;
        
        [expressionScrollView addSubview:(_expressionView = expressionView)];
        [expressionScrollView addSubview:(_expressionLeftFadingOut = expressionLeftFadingOut)];
        
        UILabel *equalSign = [[UILabel alloc] initWithFrame:CGRectZero];
        equalSign.translatesAutoresizingMaskIntoConstraints = NO;
        equalSign.text = @"= ";
        equalSign.font = [UIFont fontWithName:@"TimesNewRomanPS-BoldMT" size:24.0];
        
        MathExpressionView *answerExpressionView = [[MathExpressionView alloc] initWithFrame:CGRectZero];
        answerExpressionView.translatesAutoresizingMaskIntoConstraints = NO;
        answerExpressionView.backgroundColor = [UIColor clearColor];
        
        HTVC_Tag *myTag = [[HTVC_Tag alloc] initWithImage:[UIImage imageNamed:@"tag-background"]];
        FTAssert_DEBUG(CGRectGetHeight(myTag.bounds) == HTVC_TAG_HEIGHT);
        myTag.translatesAutoresizingMaskIntoConstraints = NO;
        myTag.label.font = [UIFont systemFontOfSize:17.0];
        
        HTVC_TagEditor *tagEditor = [[HTVC_TagEditor alloc] initWithImage:[UIImage imageNamed:@"tag-editor-background"]];
        FTAssert_DEBUG(CGRectGetHeight(tagEditor.bounds) == HTVC_TAG_EDITOR_HEIGHT);
        tagEditor.translatesAutoresizingMaskIntoConstraints = NO;
        tagEditor.alpha = 0.0;
        tagEditor.textField.tag = 1;
        tagEditor.textField.font = myTag.label.font;
        tagEditor.textField.delegate = self;
        [tagEditor.textField addObserver:self forKeyPath:@"text" options:0 context:NULL];
        [tagEditor.textField addTarget:self action:@selector(handleTextFieldEdit:) forControlEvents:UIControlEventEditingChanged];
        
        [contentView addSubview:(_expressionScrollView = expressionScrollView)];
        [contentView addSubview:(_answerExpressionView = answerExpressionView)];
        [contentView addSubview:equalSign];
        [contentView addSubview:(_myTag = myTag)];
        [contentView addSubview:(_tagEditor = tagEditor)];
        
        /**************************************************************************/
        NSDictionary *views = NSDictionaryOfVariableBindings(contentView, expressionScrollView, expressionView, equalSign, answerExpressionView);
        NSDictionary *metrics = @{@"horizMargin":  @(HTVC_HORIZ_MARGIN),
                                  @"bottomMargin": @(HTVC_BOTTOM_MARGIN)};
        NSLayoutConstraint *tmpConstraint;
        
        [NSLayoutConstraint activateConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|[expressionScrollView]|" options:0 metrics:nil views:views]];
        [NSLayoutConstraint activateConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[expressionScrollView]|" options:0 metrics:nil views:views]];
        
        [NSLayoutConstraint activateConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|[expressionView(>=expressionScrollView)]|" options:0 metrics:nil views:views]];
        [NSLayoutConstraint activateConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[expressionView(==expressionScrollView)]|" options:0 metrics:nil views:views]];
        
        [NSLayoutConstraint constraintWithItem:expressionLeftFadingOut attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:contentView attribute:NSLayoutAttributeLeft multiplier:1.0 constant:0.0].active = YES;
        [NSLayoutConstraint constraintWithItem:expressionLeftFadingOut attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:expressionScrollView attribute:NSLayoutAttributeTop multiplier:1.0 constant:0.0].active = YES;
        [NSLayoutConstraint constraintWithItem:expressionLeftFadingOut attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:expressionScrollView attribute:NSLayoutAttributeBottom multiplier:1.0 constant:0.0].active = YES;
        
        [equalSign setContentCompressionResistancePriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisHorizontal];
        [equalSign setContentHuggingPriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisHorizontal];
        
        [NSLayoutConstraint activateConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|-horizMargin-[equalSign][answerExpressionView]" options:NSLayoutFormatAlignAllBottom metrics:metrics views:views]];
        [NSLayoutConstraint activateConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[answerExpressionView]-bottomMargin-|" options:0 metrics:metrics views:views]];
        
        tmpConstraint = [NSLayoutConstraint constraintWithItem:myTag attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:contentView attribute:NSLayoutAttributeLeading multiplier:1.0 constant:HTVC_TAG_LEADING_MARGIN];
        (_tagLeadingMarginConstraint = tmpConstraint).active = YES;
        tmpConstraint = [NSLayoutConstraint constraintWithItem:contentView attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationGreaterThanOrEqual toItem:myTag attribute:NSLayoutAttributeTrailing multiplier:1.0 constant:HTVC_TAG_MINIMUM_TRAILING_MARGIN];
        (_tagMinimumTrailingMarginConstraint = tmpConstraint).active = YES;
        tmpConstraint = [NSLayoutConstraint constraintWithItem:myTag attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:contentView attribute:NSLayoutAttributeTop multiplier:1.0 constant:HTVC_TAG_TOP_MARGIN];
        (_tagTopMarginConstraint = tmpConstraint).active = YES;
        tmpConstraint = [NSLayoutConstraint constraintWithItem:myTag attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:0.0 constant:HTVC_TAG_HEIGHT];
        (_tagHeightConstraint = tmpConstraint).active = YES;

        tmpConstraint = [NSLayoutConstraint constraintWithItem:tagEditor attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:contentView attribute:NSLayoutAttributeLeading multiplier:1.0 constant:0.0];
        (_tagEditorLeadingMarginConstraint = tmpConstraint).active = YES;
        [NSLayoutConstraint constraintWithItem:contentView attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationGreaterThanOrEqual toItem:tagEditor attribute:NSLayoutAttributeTrailing multiplier:1.0 constant:0.0].active = YES;
        tmpConstraint = [NSLayoutConstraint constraintWithItem:tagEditor attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:contentView attribute:NSLayoutAttributeTop multiplier:1.0 constant:0.0];
        (_tagEditorTopMarginConstraint = tmpConstraint).active = YES;
        tmpConstraint = [NSLayoutConstraint constraintWithItem:tagEditor attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:0.0 constant:HTVC_TAG_EDITOR_HEIGHT];
        (_tagEditorHeightConstraint = tmpConstraint).active = YES;
    }
    return self;
}

- (void)dealloc
{
    [self.hostTableView removeObserver:self forKeyPath:@"backgroundColor" context:NULL];
    [self.tagEditor.textField removeObserver:self forKeyPath:@"text" context:NULL];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if (object == self.tagEditor.textField) {
        FTAssert_DEBUG([keyPath isEqualToString:@"text"]);
        [self updateTextFieldPlaceholder:object];
    }
    else if (object == self.hostTableView) {
        FTAssert_DEBUG([keyPath isEqualToString:@"backgroundColor"]);
        self.expressionLeftFadingOut.tintColor = ((UITableView *)object).backgroundColor;
    }
    else {
        FTAssert_DEBUG(NO);
    }
}

- (MathExpressionView *)expressionViewToHighlightByTouch:(UITouch *)touch
{
    CGPoint location = [touch locationInView:self];
    if (!CGRectContainsPoint(CGRectInset(self.bounds, 0.0, 8.0), location)) return nil;
    
    HTVC_Tag *tag = self.myTag;
    if (!tag.hidden && CGRectContainsPoint(CGRectInset([tag convertRect:tag.bounds toView:self], -10.0, -10.0), location)) return nil;
    
    MathResult *answer = [self.expressionView.expression evaluate];
    if (answer == nil || ({decQuad tmpDec = answer.value; !decQuadIsFinite(&tmpDec);})) return nil;
    
    return self.answerExpressionView;
}

- (void)updateTextFieldPlaceholder:(UITextField *)textField
{
    FTAssert_DEBUG(textField == self.tagEditor.textField);
    textField.placeholder = textField.text.length ? nil : NSLocalizedString(@"Add annotation here...", nil);
}

- (void)handleTextFieldEdit:(id)sender
{
    FTAssert_DEBUG(sender == self.tagEditor.textField);
    [self updateTextFieldPlaceholder:sender];
    [sender invalidateIntrinsicContentSize];
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    FTAssert_DEBUG(textField == self.tagEditor.textField);
    if (textField.alpha < 0.001) {
        FTAssert_DEBUG(NO);
        return NO;
    }
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    FTAssert_DEBUG(textField == self.tagEditor.textField);
    [textField resignFirstResponder];
    return YES;
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    FTAssert_DEBUG(textField == self.tagEditor.textField);
    HTVC_TagEditor *tagEditor = self.tagEditor;
    HistoryRecord *record = self.record;
    
    if (self.hostTableView.discardsChanges) {
        if ((tagEditor.textField.text = record.annotation).length) {
            tagEditor.colorIndex = record.tagColorIndex;
        }
    }
    else {
        uint32_t newColorIndex = tagEditor.colorIndex;
        NSString *newAnnotation = tagEditor.textField.text;
        if (newAnnotation.length) {
            if (![record.annotation isEqualToString:newAnnotation]) {
                record.annotation = newAnnotation;
            }
            if (record.tagColorIndex != newColorIndex) {
                record.tagColorIndex = newColorIndex;
            }
        }
        else {
            if (record.annotation) {
                record.annotation = nil;
            }
            if (record.tagColorIndex != 0) {
                record.tagColorIndex = 0;
            }
        }
        if ([record.managedObjectContext hasChanges]) {
            NSError *error;
            if (![record.managedObjectContext save:&error]) {
                FTAssert(NO, error);
            }
        }
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
    
    HTVC_Tag *tag = self.myTag;
    HTVC_TagEditor *tagEditor = self.tagEditor;
    if (self.hostTableView.mode == FTTableViewEditingInPlaceMode) {
        if (selected) {
            if (0.001 < tagEditor.alpha) return;
            
            HistoryRecord *record = self.record;
            if ((tagEditor.textField.text = record.annotation).length) {
                tagEditor.colorIndex = record.tagColorIndex;
            }
            else {
                tagEditor.colorIndex = (uint32_t)[[NSUserDefaults standardUserDefaults] integerForKey:@"DefaultTagColorIndex"];
            }
            
            if (animated) {
                if (tag.hidden) {
                    tag.alpha = 0.0;
                    tagEditor.alpha = 1.0;
                    
                    self.tagEditorHeightConstraint.constant = 0.0;
                    [self.contentView layoutIfNeeded];
                    
                    [UIView animateWithDuration:0.3 animations:^{
                        self.tagEditorHeightConstraint.constant = HTVC_TAG_EDITOR_HEIGHT;
                        [self.contentView layoutIfNeeded];
                    }];
                }
                else {
                    tagEditor.colorBlockLeadingMarginConstraint.constant = HTVC_TAG_COLOR_BLOCK_LEADING_MARGIN;
                    tagEditor.colorBlockWidthConstraint.constant = HTVC_TAG_COLOR_BLOCK_WIDTH;
                    tagEditor.textLeadingMarginConstraint.constant = HTVC_TAG_TEXT_LEADING_MARGIN;
                    tagEditor.textTrailingMarginConstraint.constant = HTVC_TAG_TEXT_TRAILING_MARGIN;
                    self.tagEditorLeadingMarginConstraint.constant = HTVC_TAG_LEADING_MARGIN;
                    self.tagEditorTopMarginConstraint.constant = HTVC_TAG_TOP_MARGIN;
                    self.tagEditorHeightConstraint.constant = HTVC_TAG_HEIGHT;
                    [self.contentView layoutIfNeeded];
                    
                    [UIView animateWithDuration:0.3 animations:^{
                        tag.alpha = 0.0;
                        tagEditor.alpha = 1.0;
                        
                        tag.colorBlockLeadingMarginConstraint.constant = HTVC_TAG_EDITOR_COLOR_BLOCK_LEADING_MARGIN;
                        tag.colorBlockWidthConstraint.constant = HTVC_TAG_EDITOR_COLOR_BLOCK_WIDTH;
                        tag.textLeadingMarginConstraint.constant = HTVC_TAG_EDITOR_TEXT_LEADING_MARGIN;
                        tag.textTrailingMarginConstraint.constant = HTVC_TAG_EDITOR_TEXT_TRAILING_MARGIN;
                        self.tagLeadingMarginConstraint.constant = 0.0;
                        self.tagTopMarginConstraint.constant = 0.0;
                        self.tagHeightConstraint.constant = HTVC_TAG_EDITOR_HEIGHT;
                        
                        tagEditor.colorBlockLeadingMarginConstraint.constant = HTVC_TAG_EDITOR_COLOR_BLOCK_LEADING_MARGIN;
                        tagEditor.colorBlockWidthConstraint.constant = HTVC_TAG_EDITOR_COLOR_BLOCK_WIDTH;
                        tagEditor.textLeadingMarginConstraint.constant = HTVC_TAG_EDITOR_TEXT_LEADING_MARGIN;
                        tagEditor.textTrailingMarginConstraint.constant = HTVC_TAG_EDITOR_TEXT_TRAILING_MARGIN;
                        self.tagEditorLeadingMarginConstraint.constant = 0.0;
                        self.tagEditorTopMarginConstraint.constant = 0.0;
                        self.tagEditorHeightConstraint.constant = HTVC_TAG_EDITOR_HEIGHT;
                        
                        [self.contentView layoutIfNeeded];
                    } completion:^(BOOL finished) {
                        tag.colorBlockLeadingMarginConstraint.constant = HTVC_TAG_COLOR_BLOCK_LEADING_MARGIN;
                        tag.colorBlockWidthConstraint.constant = HTVC_TAG_COLOR_BLOCK_WIDTH;
                        tag.textLeadingMarginConstraint.constant = HTVC_TAG_TEXT_LEADING_MARGIN;
                        tag.textTrailingMarginConstraint.constant = HTVC_TAG_TEXT_TRAILING_MARGIN;
                        self.tagLeadingMarginConstraint.constant = HTVC_TAG_LEADING_MARGIN;
                        self.tagTopMarginConstraint.constant = HTVC_TAG_TOP_MARGIN;
                        self.tagHeightConstraint.constant = HTVC_TAG_HEIGHT;
                    }];
                }
            }
            else {
                tag.alpha = 0.0;
                tagEditor.alpha = 1.0;
            }
        }
        else {
            if (tagEditor.alpha < 0.001) return;
            
            if ([tagEditor.textField isFirstResponder]) {
                [[FTTextFieldSurrogate surrogateForTextField:tagEditor.textField] becomeFirstResponder];
            }
            
            if (animated) {
                //! ASSUMPTION: the cell has been refreshed by some outside mechanism, such as NSFetchedResultsController.
                if (tag.hidden) {
                    [UIView animateWithDuration:0.3 animations:^{
                        self.tagEditorHeightConstraint.constant = 0.0;
                        [self.contentView layoutIfNeeded];
                    } completion:^(BOOL finished) {
                        tag.alpha = 1.0;
                        tagEditor.alpha = 0.0;
                        
                        self.tagEditorHeightConstraint.constant = HTVC_TAG_EDITOR_HEIGHT;
                    }];
                }
                else {
                    tag.colorBlockLeadingMarginConstraint.constant = HTVC_TAG_EDITOR_COLOR_BLOCK_LEADING_MARGIN;
                    tag.colorBlockWidthConstraint.constant = HTVC_TAG_EDITOR_COLOR_BLOCK_WIDTH;
                    tag.textLeadingMarginConstraint.constant = HTVC_TAG_EDITOR_TEXT_LEADING_MARGIN;
                    tag.textTrailingMarginConstraint.constant = HTVC_TAG_EDITOR_TEXT_TRAILING_MARGIN;
                    self.tagLeadingMarginConstraint.constant = 0.0;
                    self.tagTopMarginConstraint.constant = 0.0;
                    self.tagHeightConstraint.constant = HTVC_TAG_EDITOR_HEIGHT;
                    [self.contentView layoutIfNeeded];
                    
                    [UIView animateWithDuration:0.3 animations:^{
                        tag.alpha = 1.0;
                        tagEditor.alpha = 0.0;
                        
                        tag.colorBlockLeadingMarginConstraint.constant = HTVC_TAG_COLOR_BLOCK_LEADING_MARGIN;
                        tag.colorBlockWidthConstraint.constant = HTVC_TAG_COLOR_BLOCK_WIDTH;
                        tag.textLeadingMarginConstraint.constant = HTVC_TAG_TEXT_LEADING_MARGIN;
                        tag.textTrailingMarginConstraint.constant = HTVC_TAG_TEXT_TRAILING_MARGIN;
                        self.tagLeadingMarginConstraint.constant = HTVC_TAG_LEADING_MARGIN;
                        self.tagTopMarginConstraint.constant = HTVC_TAG_TOP_MARGIN;
                        self.tagHeightConstraint.constant = HTVC_TAG_HEIGHT;
                        
                        tagEditor.colorBlockLeadingMarginConstraint.constant = HTVC_TAG_COLOR_BLOCK_LEADING_MARGIN;
                        tagEditor.colorBlockWidthConstraint.constant = HTVC_TAG_COLOR_BLOCK_WIDTH;
                        tagEditor.textLeadingMarginConstraint.constant = HTVC_TAG_TEXT_LEADING_MARGIN;
                        tagEditor.textTrailingMarginConstraint.constant = HTVC_TAG_TEXT_TRAILING_MARGIN;
                        self.tagEditorLeadingMarginConstraint.constant = HTVC_TAG_LEADING_MARGIN;
                        self.tagEditorTopMarginConstraint.constant = HTVC_TAG_TOP_MARGIN;
                        self.tagEditorHeightConstraint.constant = HTVC_TAG_HEIGHT;
                        
                        [self.contentView layoutIfNeeded];
                    } completion:^(BOOL finished) {
                        tagEditor.colorBlockLeadingMarginConstraint.constant = HTVC_TAG_EDITOR_COLOR_BLOCK_LEADING_MARGIN;
                        tagEditor.colorBlockWidthConstraint.constant = HTVC_TAG_EDITOR_COLOR_BLOCK_WIDTH;
                        tagEditor.textLeadingMarginConstraint.constant = HTVC_TAG_EDITOR_TEXT_LEADING_MARGIN;
                        tagEditor.textTrailingMarginConstraint.constant = HTVC_TAG_EDITOR_TEXT_TRAILING_MARGIN;
                        self.tagEditorLeadingMarginConstraint.constant = 0.0;
                        self.tagEditorTopMarginConstraint.constant = 0.0;
                        self.tagEditorHeightConstraint.constant = HTVC_TAG_EDITOR_HEIGHT;
                    }];
                }
            }
            else {
                tag.alpha = 1.0;
                tagEditor.alpha = 0.0;
            }
        }
    }
    else {
        if (tagEditor.alpha < 0.001) return;
        
        if ([tagEditor.textField isFirstResponder]) {
            FTAssert_DEBUG(NO);
            [tagEditor.textField resignFirstResponder];
        }
        
        FTAssert_DEBUG(!animated);
        tag.alpha = 1.0;
        tagEditor.alpha = 0.0;
    }
}

- (void)setRecord:(HistoryRecord *)record
{
    _record = record;
    
    [self my_refresh];
}

- (void)setBackgroundColor:(UIColor *)backgroundColor
{
    if (self.backgroundColor != backgroundColor) {
        [super setBackgroundColor:backgroundColor];
        
        FTAssert_DEBUG(![self isSelected]);
        self.expressionScrollView.backgroundColor = backgroundColor;
        self.expressionView.backgroundColor = backgroundColor;
    }
}

- (void)my_refresh
{
    HistoryRecord *record = self.record;
    
    HTVC_Tag *tag = self.myTag;
    if ((tag.label.text = record.annotation).length) {
        tag.colorIndex = record.tagColorIndex;
        tag.hidden = NO;
        self.expressionView.insets = UIEdgeInsetsMake(HTVC_TAG_TOP_MARGIN + HTVC_TAG_HEIGHT + HTVC_EXPR_TOP_MARGIN, HTVC_HORIZ_MARGIN, HTVC_EXPR_ANS_GAP + HTVC_ANS_HEIGHT + HTVC_BOTTOM_MARGIN, HTVC_HORIZ_MARGIN);
    }
    else {
        tag.hidden = YES;
        self.expressionView.insets = UIEdgeInsetsMake(HTVC_EXPR_TOP_MARGIN, HTVC_HORIZ_MARGIN, HTVC_EXPR_ANS_GAP + HTVC_ANS_HEIGHT + HTVC_BOTTOM_MARGIN, HTVC_HORIZ_MARGIN);
    }
    
    self.expressionView.expression = record.expression;
    MathResult *answer = [record.expression evaluate];
    self.answerExpressionView.expression = answer ? [MathExpression expressionFromValue:answer.value inDegree:record.answerIsInDegree] : nil;
}

- (void)resetToNormalState
{
    self.contentView.userInteractionEnabled = YES;
    self.expressionLeftFadingOut.hidden = YES;
    self.tagMinimumTrailingMarginConstraint.constant = HTVC_TAG_MINIMUM_TRAILING_MARGIN;
}

- (void)prepareForReuse
{
    [super prepareForReuse];
    
    self.expressionScrollView.contentOffset = CGPointZero;
    if (g_osVersionMajor < 8) {
        [self resetToNormalState];
    }
}

- (void)willTransitionToState:(UITableViewCellStateMask)state
{
    [super willTransitionToState:state];
    
    if (state) {
        // Editing State
        if (state & UITableViewCellStateShowingEditControlMask) {
            self.expressionLeftFadingOut.hidden = NO;
            self.tagMinimumTrailingMarginConstraint.constant = 0.0;
        }
        
        //! WORKAROUND: It's strange that showingDeleteConfirmation reports YES only when swipe-to-revealing the delete confirmation button; reports NO once the finger is lifted.
        if (state & UITableViewCellStateShowingDeleteConfirmationMask) {
            self.contentView.userInteractionEnabled = NO;
        }
        else {
            self.contentView.userInteractionEnabled = YES;
        }
    }
    else {
        // Normal State
        [self resetToNormalState];
    }
}

@end
