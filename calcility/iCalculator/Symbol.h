//
//  Symbol.h
//  iCalculator
//
//  Created by curie on 5/31/14.
//  Copyright (c) 2014 Fish Tribe. All rights reserved.
//

#import <CoreData/CoreData.h>

@class Record;


@interface Symbol : NSManagedObject

@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *subscript;

@property (nonatomic, strong) Record *record;

@end
