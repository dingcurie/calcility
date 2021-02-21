//
//  FTInputSystem.h
//
//  Created by curie on 13-4-24.
//  Copyright (c) 2013年 Fish Tribe. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FTCaret.h"
#import "FTSelectionSuite.h"


@protocol FTInputting <NSObject>

@property (nonatomic, weak, readonly) UIView *contentView;
@property (nonatomic, readonly) CGRect caretFrame;
@property (nonatomic, readonly) CGRect marqueeFrame;
@property (nonatomic, readonly) FTSelectionSuiteMode selectionSuiteMode;
@property (nonatomic, readonly) BOOL shouldPreservedWhenUnregistered;

@optional

- (void)selectionHandle:(FTSelectionHandle *)selectionHandle respondToPressGesture:(UILongPressGestureRecognizer *)longPressGestureRecognizer;

@end


#pragma mark -


@interface FTInputSystem : NSObject

+ (FTInputSystem *)sharedInputSystem;

@property (nonatomic, strong, readonly) FTCaret *caret;
@property (nonatomic, strong, readonly) FTSelectionSuite *selectionSuite;

@property (nonatomic, strong, readonly) UIResponder<FTInputting> *firstResponder;
@property (nonatomic, readonly) BOOL firstResponderIsResigned;

- (void)registerFirstResponder:(UIResponder<FTInputting> *)firstResponder;
- (void)unregisterFirstResponder;
- (void)registerResignedFirstResponder:(UIResponder<FTInputting> *)resignedFirstResponder;

- (void)refresh;

@end


#pragma mark -


@interface UIResponder (FTInputSystem)

- (void)my_becomeResignedFirstResponder;

@end
