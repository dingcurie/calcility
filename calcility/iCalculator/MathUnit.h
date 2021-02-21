//
//  MathUnit.h
//  iCalculator
//
//  Created by curie on 9/10/14.
//  Copyright (c) 2014 Fish Tribe. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MyDecimal.h"


@interface MathUnit : NSObject

+ (instancetype)unit;

- (id)initWithOrder:(decQuad)order;  //: Designated Initializer

@property (nonatomic, readonly) decQuad order;

@end
