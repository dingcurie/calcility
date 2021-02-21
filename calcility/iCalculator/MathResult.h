//
//  MathResult.h
//  iCalculator
//
//  Created by curie on 9/9/14.
//  Copyright (c) 2014 Fish Tribe. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MyDecimal.h"
#import "MathUnitSet.h"


@interface MathResult : NSObject

- (id)initWithValue:(decQuad)value unitSet:(MathUnitSet *)unitSet;

@property (nonatomic, readonly) decQuad value;
@property (nonatomic, strong, readonly) MathUnitSet *unitSet;

@end
