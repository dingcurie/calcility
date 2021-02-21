//
//  ConstantRecord.h
//  iCalculator
//
//  Created by curie on 5/31/14.
//  Copyright (c) 2014 Fish Tribe. All rights reserved.
//

#import "Record.h"

@class ConstantSheet;


@interface ConstantRecord : Record

@property (nonatomic, strong) ConstantSheet *containingSheet;

@end
