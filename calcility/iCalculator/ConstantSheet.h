//
//  ConstantSheet.h
//  iCalculator
//
//  Created by curie on 5/31/14.
//  Copyright (c) 2014 Fish Tribe. All rights reserved.
//

#import "Sheet.h"

@class ConstantRecord;


@interface ConstantSheet : Sheet

@property (nonatomic, strong) NSOrderedSet *records;

@end


@interface ConstantSheet (CoreDataGeneratedAccessors)

- (void)insertObject:(ConstantRecord *)value inRecordsAtIndex:(NSUInteger)idx;
- (void)removeObjectFromRecordsAtIndex:(NSUInteger)idx;
- (void)insertRecords:(NSArray *)value atIndexes:(NSIndexSet *)indexes;
- (void)removeRecordsAtIndexes:(NSIndexSet *)indexes;
- (void)replaceObjectInRecordsAtIndex:(NSUInteger)idx withObject:(ConstantRecord *)value;
- (void)replaceRecordsAtIndexes:(NSIndexSet *)indexes withRecords:(NSArray *)values;
- (void)addRecordsObject:(ConstantRecord *)value;
- (void)removeRecordsObject:(ConstantRecord *)value;
- (void)addRecords:(NSOrderedSet *)values;
- (void)removeRecords:(NSOrderedSet *)values;

@end
