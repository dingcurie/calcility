//
//  Record.h
//  iCalculator
//
//  Created by curie on 5/31/14.
//  Copyright (c) 2014 Fish Tribe. All rights reserved.
//

#import <CoreData/CoreData.h>

@class Symbol, MathExpression;


@interface Record : NSManagedObject

@property (nonatomic, strong) MathExpression *expression;
@property (nonatomic, strong) NSString *annotation;

@property (nonatomic, strong) Symbol *symbol;

@end
