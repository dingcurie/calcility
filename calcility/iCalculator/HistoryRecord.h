//
//  HistoryRecord.h
//  iCalculator
//
//  Created by curie on 5/31/14.
//  Copyright (c) 2014 Fish Tribe. All rights reserved.
//

#import "Record.h"

@class HistorySheet;


@interface HistoryRecord : Record

@property (nonatomic, strong) NSDate *creationDate;
@property (nonatomic, strong, readonly) NSString *sectionID;
@property (nonatomic) BOOL answerIsInDegree;
@property (nonatomic) int32_t tagColorIndex;

@property (nonatomic, strong) HistorySheet *containingSheet;

@end
