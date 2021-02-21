//
//  MathConstant.h
//  iCalculator
//
//  Created by curie on 13-4-9.
//  Copyright (c) 2013年 Fish Tribe. All rights reserved.
//

#import "MathOperator.h"


@interface MathConstant : MathOperator

+ (instancetype)posInf;
+ (instancetype)negInf;
+ (instancetype)nan;

+ (instancetype)pi;
+ (instancetype)e;

- (id)initWithSymbol:(NSString *)symbol value:(decQuad)value;  //: Designated Initializer

@property (nonatomic, copy, readonly) NSString *symbol;
@property (nonatomic, readonly) decQuad value;

- (MathResult *)operate;

@end
