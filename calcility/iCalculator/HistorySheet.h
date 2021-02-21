//
//  HistorySheet.h
//  iCalculator
//
//  Created by curie on 7/21/14.
//  Copyright (c) 2014 Fish Tribe. All rights reserved.
//

#import "Sheet.h"

@class HistoryRecord;


@interface HistorySheet : Sheet

@property (nonatomic) int64_t ordinal;

@property (nonatomic, strong) NSSet *records;

@end


@interface HistorySheet (CoreDataGeneratedAccessors)

- (void)addRecordsObject:(HistoryRecord *)value;
- (void)removeRecordsObject:(HistoryRecord *)value;
- (void)addRecords:(NSSet *)values;
- (void)removeRecords:(NSSet *)values;

@end
