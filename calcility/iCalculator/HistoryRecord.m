//
//  HistoryRecord.m
//  iCalculator
//
//  Created by curie on 5/31/14.
//  Copyright (c) 2014 Fish Tribe. All rights reserved.
//

#import "HistoryRecord.h"


@interface HistoryRecord (CoreDataPrimitiveProperties)

@property (nonatomic, strong) NSDate *primitiveCreationDate;
@property (nonatomic, strong) NSString *primitiveSectionID;

@end


@implementation HistoryRecord

@dynamic creationDate;
@dynamic sectionID;
@dynamic answerIsInDegree;
@dynamic tagColorIndex;

@dynamic containingSheet;

#pragma mark -

- (NSString *)sectionID
{
    [self willAccessValueForKey:@"sectionID"];
    NSString *sectionID = self.primitiveSectionID;
    [self didAccessValueForKey:@"sectionID"];
    
    if (sectionID == nil) {
        NSDateComponents *components = [[NSCalendar currentCalendar] components:(NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay) fromDate:self.creationDate];
        sectionID = [NSString stringWithFormat:@"%lld", (components.year * 1000LL + components.month) * 1000LL + components.day];
        self.primitiveSectionID = sectionID;
    }
    return sectionID;
}

- (void)setCreationDate:(NSDate *)creationDate
{
    [self willChangeValueForKey:@"creationDate"];
    self.primitiveCreationDate = creationDate;
    [self didChangeValueForKey:@"creationDate"];
    
    self.primitiveSectionID = nil;
}

+ (NSSet *)keyPathsForValuesAffectingSectionID
{
    return [NSSet setWithObject:@"creationDate"];
}

@end
