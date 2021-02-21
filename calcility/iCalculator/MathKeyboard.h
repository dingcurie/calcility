//
//  MathKeyboard.h
//  iCalculator
//
//  Created by curie on 12-11-11.
//  Copyright (c) 2012年 Fish Tribe. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MathExpression+Editing.h"


@protocol MathInput <NSObject>

@property (nonatomic, strong, readonly) MathExpression *expression;
@property (nonatomic, strong, readonly) MathRange *selectedRange;

- (void)insertNumericString:(NSString *)aNumericString;
- (void)replaceElementsInRange:(MathRange *)range withElements:(NSArray *)elements localSelectedRange:(MathRange *)localSelectedRange;
- (MathExpressionDeletionResult)deleteBackwardAggressively:(BOOL)aggressively;
- (void)commitReturn;

- (void)setUndoCheckpoint;

@end


#pragma mark -


@interface MathKeyboard : UIView

+ (MathKeyboard *)sharedKeyboard;

- (void)cancelKeyHit;

@end
