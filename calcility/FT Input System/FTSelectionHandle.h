//
//  FTSelectionHandle.h
//
//  Created by curie on 13-4-24.
//  Copyright (c) 2013年 Fish Tribe. All rights reserved.
//

#import <UIKit/UIKit.h>


typedef NS_ENUM(NSUInteger, FTSelectionHandleType) {
    FTSelectionHandleTypeStart,
    FTSelectionHandleTypeEnd,
    FTSelectionHandleTypeNum
};


@interface FTSelectionHandle : UIView

- (id)initWithType:(FTSelectionHandleType)type;  //: Designated Initializer

@property (nonatomic, readonly) FTSelectionHandleType type;
@property (nonatomic, weak, readonly) UIView *knob;
@property (nonatomic, weak, readonly) UIView *pole;

@property (nonatomic, weak) FTSelectionHandle *pairingSelectionHandle;

@end
