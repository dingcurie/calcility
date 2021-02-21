//
//  MathImplicitMul.m
//  iCalculator
//
//  Created by curie on 12-12-21.
//  Copyright (c) 2012年 Fish Tribe. All rights reserved.
//

#import "MathImplicitMul.h"


@interface MathImplicitMul ()

- (id)init;  //: Designated Initializer

@end


@implementation MathImplicitMul

+ (instancetype)implicitMul
{
    static MathImplicitMul *__weak s_weakRef;
    MathImplicitMul *strongRef = s_weakRef;
    if (strongRef == nil) {
        s_weakRef = strongRef = [[MathImplicitMul alloc] init];
    }
    return strongRef;
}

- (id)init
{
    self = [super initWithLeftAffinity:MathImplicitMultiplyLeftAffinity rightAffinity:MathImplicitMultiplyRightAffinity];
    return self;
}

- (id)initWithCoder:(NSCoder *)decoder
{
    self = [MathImplicitMul implicitMul];
    return self;
}

- (void)encodeWithCoder:(NSCoder *)encoder
{
    return;
}

- (MathResult *)operateOnLeftOperand:(MathResult *)leftOperand rightOperand:(MathResult *)rightOperand
{
    FTAssert(leftOperand && rightOperand);
    decQuad leftOperandValue = leftOperand.value;
    decQuad rightOperandValue = rightOperand.value;
    decQuad resultValue;
    decQuadMultiply(&resultValue, &leftOperandValue, &rightOperandValue, &DQ_set);
    return [[MathResult alloc] initWithValue:resultValue unitSet:[leftOperand.unitSet unitSetByMultiplyingBy:rightOperand.unitSet]];
}

@end
