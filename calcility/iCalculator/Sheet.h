//
//  Sheet.h
//  iCalculator
//
//  Created by curie on 6/4/14.
//  Copyright (c) 2014 Fish Tribe. All rights reserved.
//

#import <CoreData/CoreData.h>


@interface Sheet : NSManagedObject

@property (nonatomic, strong) NSDate *lastOpenedDate;
@property (nonatomic, strong) NSString *title;

@end
