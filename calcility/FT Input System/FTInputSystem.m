//
//  FTInputSystem.m
//
//  Created by curie on 13-4-24.
//  Copyright (c) 2013年 Fish Tribe. All rights reserved.
//

#import "FTInputSystem.h"


@interface FTInputSystem ()

@property (nonatomic, strong) UIResponder<FTInputting> *firstResponder;
@property (nonatomic) BOOL firstResponderIsResigned;

@end


@implementation FTInputSystem

@synthesize caret = _caret;
@synthesize selectionSuite = _selectionSuite;

+ (FTInputSystem *)sharedInputSystem
{
    static FTInputSystem *sharedInputSystem;
    if (sharedInputSystem == nil) {
        sharedInputSystem = [[FTInputSystem alloc] init];
    }
    return sharedInputSystem;
}

- (FTCaret *)caret
{
    if (_caret == nil) {
        _caret = [[FTCaret alloc] init];
    }
    return _caret;
}

- (FTSelectionSuite *)selectionSuite
{
    if (_selectionSuite == nil) {
        _selectionSuite = [[FTSelectionSuite alloc] init];
    }
    return _selectionSuite;
}

- (void)registerFirstResponder:(UIResponder<FTInputting> *)firstResponder
{
    FTAssert(firstResponder);
    if (self.firstResponder == firstResponder && !self.firstResponderIsResigned) return;
    
    if (self.firstResponder) {
        [self.caret removeFromSuperview];
        [self.selectionSuite removeFromSuperview];
    }
    
    self.firstResponder = firstResponder;
    self.firstResponderIsResigned = NO;
    
    UIView *contentView = firstResponder.contentView;
    [self.caret addToSuperview:contentView];
    [self.selectionSuite addToSuperview:contentView];
    [self refresh];
}

- (void)unregisterFirstResponder
{
    if (self.firstResponder == nil) return;
    
    if (self.firstResponder.shouldPreservedWhenUnregistered) {
        if (self.firstResponderIsResigned) return;
        
        self.firstResponderIsResigned = YES;
        
        [self refresh];
    }
    else {
        self.firstResponder = nil;
        
        [self.caret removeFromSuperview];
        [self.selectionSuite removeFromSuperview];
    }
}

- (void)registerResignedFirstResponder:(UIResponder<FTInputting> *)resignedFirstResponder
{
    [self registerFirstResponder:resignedFirstResponder];
    [self unregisterFirstResponder];
}

- (void)refresh
{
    [self.firstResponder.contentView layoutIfNeeded];
    
    [self.caret my_refresh];
    [self.selectionSuite my_refresh];
}

@end


#pragma mark -


@implementation UIResponder (FTInputSystem)

- (void)my_becomeResignedFirstResponder
{
    FTAssert_DEBUG(![self isFirstResponder]);  //: Call -resignFirstResponder instead!
    FTAssert([self conformsToProtocol:@protocol(FTInputting)]);
    [[FTInputSystem sharedInputSystem] registerResignedFirstResponder:(UIResponder<FTInputting> *)self];
}

@end
