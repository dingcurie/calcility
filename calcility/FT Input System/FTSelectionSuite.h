//
//  FTSelectionSuite.h
//
//  Created by curie on 13-1-27.
//  Copyright (c) 2013年 Fish Tribe. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FTSelectionHandle.h"


typedef NS_ENUM(NSUInteger, FTSelectionSuiteMode) {
    FTSelectionSuiteModeDefault = 0,
    
    FTSelectionSuiteModeLine = 1UL << 0
};


@interface FTSelectionSuite : NSObject

@property(nonatomic, getter=isHidden) BOOL hidden;

@property (nonatomic, readonly) FTSelectionSuiteMode mode;
@property (nonatomic, strong, readonly) UIView *marquee;
@property (nonatomic, strong, readonly) NSArray<FTSelectionHandle *> *selectionHandles;

- (void)addToSuperview:(UIView *)newSuperview;
- (void)removeFromSuperview;
- (void)my_refresh;

- (void)snapSelectionHandleOfType:(FTSelectionHandleType)type toPoint:(CGPoint)point inView:(UIView *)view;
- (void)unsnapSelectionHandleOfType:(FTSelectionHandleType)type;

@end
