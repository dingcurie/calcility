//
//  HTVC_MathExpressionView.m
//  iCalculator
//
//  Created by curie on 11/20/14.
//  Copyright (c) 2014 Fish Tribe. All rights reserved.
//

#import "HTVC_MathExpressionView.h"
#import "HistoryTableViewCell.h"
#import "MathEditableExpressionView.h"


static UIView *__weak l_jumpView;
static UIResponder<FTInputting> *__weak l_previousFirstResponder;
static BOOL l_previousFirstResponderIsResigned;
static BOOL l_menuVisible;
static BOOL l_copied;


@implementation HTVC_MathExpressionView {
    CGPoint _beginLocation;
}

- (id)initWithFrame:(CGRect)frame hostCell:(HistoryTableViewCell *)hostCell
{
    FTAssert(hostCell);
    self = [super initWithFrame:frame];
    if (self) {
        [super setExclusiveTouch:YES];
        [super setUserInteractionEnabled:YES];
        
        _hostCell = hostCell;
        
        UILongPressGestureRecognizer *longPressGestureRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(respondToLongPressGesture:)];
        longPressGestureRecognizer.minimumPressDuration = 0.6;
        [super addGestureRecognizer:(_longPressGestureRecognizer = longPressGestureRecognizer)];
    }
    return self;
}

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer
{
    if (gestureRecognizer == self.longPressGestureRecognizer) {
        return self.hostCell.hostTableView.mode == FTTableViewNormalMode;
    }
    return YES;
}

- (void)respondToLongPressGesture:(UILongPressGestureRecognizer *)longPressGestureRecognizer
{
    if (longPressGestureRecognizer.state == UIGestureRecognizerStateBegan) {
        FTAssert_DEBUG(![self isFirstResponder]);
        l_previousFirstResponder = [FTInputSystem sharedInputSystem].firstResponder;
        l_previousFirstResponderIsResigned = [FTInputSystem sharedInputSystem].firstResponderIsResigned;
        [self my_becomeFirstResponderIfNotAlready];
        
        UIMenuController *menuController = [UIMenuController sharedMenuController];
        menuController.menuItems = @[[[UIMenuItem alloc] initWithTitle:NSLocalizedString(@"Annotate", nil) action:@selector(annotate:)]];
        [self my_showEditingMenu];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(respondToMenuControllerWillHideMenuNotification:) name:UIMenuControllerWillHideMenuNotification object:nil];
        
        l_menuVisible = YES;
        l_copied = NO;
    }
}

//: Avoid triggering answer jumping when pop-up menu is visible.
- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event
{
    return l_menuVisible ? NO : [super pointInside:point withEvent:event];
}

- (void)copy:(id)sender
{
    [super copy:sender];
    
    l_copied = YES;
}

- (void)annotate:(id)sender
{
    l_previousFirstResponderIsResigned = YES;
    
    HistoryTableViewCell *cell = self.hostCell;
    FTTableView *tableView = cell.hostTableView;
    NSIndexPath *indexPath = [tableView indexPathForCell:cell];
    FTAssert_DEBUG(indexPath);
    
    [tableView setMode:FTTableViewEditingInPlaceMode animated:YES];
    [tableView my_interactivelySelectRowAtIndexPath:indexPath animated:YES scrollPosition:UITableViewScrollPositionNone];
}

- (void)respondToMenuControllerWillHideMenuNotification:(NSNotification *)notification
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIMenuControllerWillHideMenuNotification object:nil];
    l_menuVisible = NO;
    
    if (l_previousFirstResponder) {
        if (l_copied) {
            [l_previousFirstResponder my_becomeFirstResponderIfNotAlready];
            [l_previousFirstResponder performSelector:@selector(my_showEditingMenu) withObject:nil afterDelay:(l_previousFirstResponderIsResigned ? 0.25 : 0.0)];
        }
        else {
            if (l_previousFirstResponderIsResigned) {
                [self my_resignFirstResponderIfNotAlready];
                [l_previousFirstResponder my_becomeResignedFirstResponder];
            }
            else {
                [l_previousFirstResponder my_becomeFirstResponderIfNotAlready];
            }
        }
        
        l_previousFirstResponder = nil;
    }
}

#pragma mark -

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [touches anyObject];
    _beginLocation = [touch locationInView:nil];
    
    HistoryTableViewCell *cell = self.hostCell;
    FTTableView *tableView = cell.hostTableView;
    
    switch (tableView.mode) {
        case FTTableViewNormalMode: {
            UIResponder *jumpingTarget = [FTInputSystem sharedInputSystem].firstResponder;
            if (jumpingTarget == nil || ![jumpingTarget isKindOfClass:[MathEditableExpressionView class]]) return;
            MathEditableExpressionView *editableExpressionView = (MathEditableExpressionView *)jumpingTarget;
            [NSObject cancelPreviousPerformRequestsWithTarget:editableExpressionView selector:@selector(my_showEditingMenu) object:nil];
            [[UIMenuController sharedMenuController] setMenuVisible:NO animated:YES];
            
            MathExpressionView *expressionViewToHighlight = [cell expressionViewToHighlightByTouch:touch];
            if (expressionViewToHighlight == nil) return;
            FTAssert_DEBUG(expressionViewToHighlight.expression);
            
            if (l_jumpView) {
                [l_jumpView removeFromSuperview];
            }
            UIView *jumpView = [[UIView alloc] initWithFrame:expressionViewToHighlight.frame];
            jumpView.layer.backgroundColor = [UIColor colorWithRed:1.0 green:1.0 blue:0.2 alpha:1.0].CGColor;
            jumpView.layer.opaque = NO;
            jumpView.layer.cornerRadius = 2.0;
            jumpView.layer.shadowOpacity = 0.1;
            jumpView.layer.shadowRadius = 2.0;
            jumpView.layer.shadowOffset = CGSizeMake(0.0, 0.0);
            [expressionViewToHighlight.superview addSubview:(l_jumpView = jumpView)];
            
            MathExpressionView *jumpingExpressionView = [[MathExpressionView alloc] init];
            jumpingExpressionView.layer.anchorPoint = CGPointZero;
            jumpingExpressionView.frame = l_jumpView.bounds;
            jumpingExpressionView.backgroundColor = [UIColor clearColor];
            jumpingExpressionView.expression = expressionViewToHighlight.expression;
            jumpingExpressionView.fontSize = expressionViewToHighlight.fontSize;
            [l_jumpView addSubview:jumpingExpressionView];
            break;
        }
        case FTTableViewBatchEditingMode: {
            [cell setHighlighted:YES animated:NO];
            break;
        }
        case FTTableViewEditingInPlaceMode: {
            [cell setHighlighted:YES animated:NO];
            break;
        }
    }
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [touches anyObject];
    CGPoint location = [touch locationInView:nil];
    
    HistoryTableViewCell *cell = self.hostCell;
    FTTableView *tableView = cell.hostTableView;
    
    switch (tableView.mode) {
        case FTTableViewNormalMode: {
            if (hypot(location.x - _beginLocation.x, location.y - _beginLocation.y) > 10.0) {
                [l_jumpView removeFromSuperview];
            }
            break;
        }
        case FTTableViewBatchEditingMode: {
            break;
        }
        case FTTableViewEditingInPlaceMode: {
            break;
        }
    }
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
    HistoryTableViewCell *cell = self.hostCell;
    FTTableView *tableView = cell.hostTableView;

    switch (tableView.mode) {
        case FTTableViewNormalMode: {
            [l_jumpView removeFromSuperview];
            break;
        }
        case FTTableViewBatchEditingMode: {
            [cell setHighlighted:NO animated:NO];
            break;
        }
        case FTTableViewEditingInPlaceMode: {
            [cell setHighlighted:NO animated:NO];
            break;
        }
    }
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    HistoryTableViewCell *cell = self.hostCell;
    FTTableView *tableView = cell.hostTableView;
    NSIndexPath *indexPath = [tableView indexPathForCell:cell];
    FTAssert_DEBUG(indexPath);
    
    switch (tableView.mode) {
        case FTTableViewNormalMode: {
            if (l_jumpView == nil) return;
            
            UIResponder *jumpingTarget = [FTInputSystem sharedInputSystem].firstResponder;
            if (jumpingTarget == nil || ![jumpingTarget isKindOfClass:[MathEditableExpressionView class]]) {
                FTAssert_DEBUG(NO);
                l_jumpView = nil;
                return;
            }
            MathEditableExpressionView *editableExpressionView = (MathEditableExpressionView *)jumpingTarget;
            
            [[UIApplication sharedApplication] beginIgnoringInteractionEvents];  // 🔒
            
            UIView *rootView = self.my_viewController.view;
            l_jumpView.center = [rootView convertPoint:l_jumpView.center fromView:l_jumpView.superview];
            [rootView addSubview:l_jumpView];
            MathExpressionView *jumpingExpressionView = l_jumpView.subviews.firstObject;
            
            MathExpression *editableExpressionCopy = [editableExpressionView.expression copy];
            NSArray *elementsToInsert = [[NSArray alloc] initWithArray:jumpingExpressionView.expression.elements copyItems:YES];
            MathRange *insertionRange = [editableExpressionCopy replaceElementsInRange:editableExpressionView.selectedRange withElements:elementsToInsert localSelectedRange:MathLocalSelectedRangeSelectAll];
            CGRect entireRect = [editableExpressionCopy rectWhenDrawAtPoint:CGPointZero withFontSize:editableExpressionView.fontSize];
            CGRect insertionRect = [editableExpressionCopy selectionRectForRange:insertionRange whenDrawAtPoint:CGPointZero withFontSize:editableExpressionView.fontSize];
            CGRect insertionBounds = CGRectMake(0.0, 0.0, CGRectGetWidth(insertionRect), CGRectGetHeight(insertionRect));
            CGPoint insertionCenter = CGPointMake(CGRectGetMidX(insertionRect), CGRectGetMidY(insertionRect));
            CGFloat scaleX = insertionBounds.size.width / CGRectGetWidth(l_jumpView.bounds);
            CGFloat scaleY = insertionBounds.size.height / CGRectGetHeight(l_jumpView.bounds);
            
            MathExpressionView *jumpedExpressionView = [[MathExpressionView alloc] init];
            jumpedExpressionView.layer.anchorPoint = CGPointZero;
            jumpedExpressionView.frame = insertionBounds;
            jumpedExpressionView.transform = CGAffineTransformMakeScale(1.0 / scaleX, 1.0 / scaleY);
            jumpedExpressionView.backgroundColor = [UIColor clearColor];
            jumpedExpressionView.alpha = 0.0;
            jumpedExpressionView.expression = editableExpressionCopy;
            jumpedExpressionView.fontSize = editableExpressionView.fontSize;
            jumpedExpressionView.insets = UIEdgeInsetsMake(CGRectGetMinY(entireRect) - CGRectGetMinY(insertionRect),
                                                           CGRectGetMinX(entireRect) - CGRectGetMinX(insertionRect),
                                                           CGRectGetMaxY(insertionRect) - CGRectGetMaxY(entireRect),
                                                           CGRectGetMaxX(insertionRect) - CGRectGetMaxX(entireRect));
            [l_jumpView addSubview:jumpedExpressionView];
            
            CALayer *jumpViewLayer = l_jumpView.layer;
            CGPoint startPoint = jumpViewLayer.position;
            CGPoint endPoint = [rootView convertPoint:insertionCenter fromView:editableExpressionView];
            CGFloat y0 = MIN(startPoint.y, endPoint.y) - (20.0 + ABS(endPoint.x - startPoint.x) * 10.0 / 320.0);
            CGFloat sqrtNormStartY = sqrt(startPoint.y - y0);
            CGFloat sqrtNormEndY = sqrt(endPoint.y - y0);
            CGPoint controlPoint = CGPointMake((startPoint.x + endPoint.x) / 2.0, y0 - sqrtNormStartY * sqrtNormEndY);
            CGMutablePathRef parabola = CGPathCreateMutable();
            CGPathMoveToPoint(parabola, NULL, startPoint.x, startPoint.y);
            CGPathAddQuadCurveToPoint(parabola, NULL, controlPoint.x, controlPoint.y, endPoint.x, endPoint.y);
            CAKeyframeAnimation *jumpAnimation = [CAKeyframeAnimation animationWithKeyPath:@"position"];
            jumpAnimation.path = parabola;
            jumpAnimation.duration = MIN(0.5, 0.02 * (sqrtNormStartY + sqrtNormEndY));
            CGPathRelease(parabola);
            [jumpViewLayer addAnimation:jumpAnimation forKey:@"position"];
            jumpViewLayer.position = endPoint;
            [UIView animateWithDuration:jumpAnimation.duration animations:^{
                l_jumpView.bounds = insertionBounds;
                jumpingExpressionView.transform = CGAffineTransformMakeScale(scaleX, scaleY);
                jumpingExpressionView.alpha = 0.0;
                jumpedExpressionView.transform = CGAffineTransformIdentity;
                jumpedExpressionView.alpha = 1.0;
            } completion:^(BOOL finished) {
                l_jumpView.center = insertionCenter;
                editableExpressionView.highlightView = l_jumpView;
                l_jumpView = nil;
                
                [editableExpressionView setUndoCheckpoint];
                [editableExpressionView replaceElementsInRange:editableExpressionView.selectedRange withElements:elementsToInsert localSelectedRange:nil];
                
                [[UIApplication sharedApplication] endIgnoringInteractionEvents];  // 🔓
                
                CALayer *highlightViewLayer = editableExpressionView.highlightView.layer;
                CFTimeInterval currentLocalLayerTime = [highlightViewLayer convertTime:CACurrentMediaTime() fromLayer:nil];
                
                CABasicAnimation *shadowFadeOutAnimation = [CABasicAnimation animationWithKeyPath:@"shadowOpacity"];
                shadowFadeOutAnimation.beginTime = currentLocalLayerTime + 0.25;
                shadowFadeOutAnimation.duration = 0.25;
                shadowFadeOutAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
                shadowFadeOutAnimation.fillMode = kCAFillModeBackwards;
                shadowFadeOutAnimation.fromValue = @(highlightViewLayer.shadowOpacity);
                highlightViewLayer.shadowOpacity = 0.0;
                [highlightViewLayer addAnimation:shadowFadeOutAnimation forKey:@"shadowOpacity"];
                
                [UIView animateWithDuration:0.25 delay:0.25 options:UIViewAnimationOptionCurveEaseOut animations:^{
                    highlightViewLayer.backgroundColor = editableExpressionView.backgroundColor.CGColor;
                } completion:^(BOOL finished) {
                    editableExpressionView.highlightView = nil;
                }];
            }];
            break;
        }
        case FTTableViewBatchEditingMode: {
            [cell setHighlighted:NO animated:NO];
            if ([cell isSelected]) {
                [tableView my_interactivelyDeselectRowAtIndexPath:indexPath animated:NO];
            }
            else {
                [tableView my_interactivelySelectRowAtIndexPath:indexPath animated:NO scrollPosition:UITableViewScrollPositionNone];
            }
            break;
        }
        case FTTableViewEditingInPlaceMode: {
            [cell setHighlighted:NO animated:NO];
            [tableView my_interactivelySelectRowAtIndexPath:indexPath animated:YES scrollPosition:UITableViewScrollPositionNone];
            break;
        }
    }
}

@end
