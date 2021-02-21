//
//  MathUnitSet.m
//  iCalculator
//
//  Created by curie on 9/10/14.
//  Copyright (c) 2014 Fish Tribe. All rights reserved.
//

#import "MathUnitSet.h"


@interface MathUnitSet ()

- (id)initWithUnitDictionary:(NSDictionary *)unitDictionary;  //: Designated Initializer

@property (nonatomic, copy, readonly) NSDictionary *unitDictionary;

@end


static
void roundToIntegralQuasiExact(decQuad *value)
{
    if (value == NULL || !decQuadIsFinite(value)) {
        FTAssert_DEBUG(NO);
        return;
    }
    
    decQuad integralValue;
    decContextZeroStatus(&DQ_set);
    decQuadToIntegralExact(&integralValue, value, &DQ_set);
    if (decContextTestStatus(&DQ_set, DEC_Inexact)) {
        decQuad error;
        decQuadSubtract(&error, &integralValue, value, &DQ_set);
        FTAssert_DEBUG(decQuadGetExponent(&integralValue) == 0);
        int msd_place_diff = decQuadDigits(&integralValue) - decQuadDigits(&error) - decQuadGetExponent(&error);
        if (msd_place_diff > DBL_DIG - 1) {
            *value = integralValue;
        }
    }
}


static MathUnitSet *l_none;


@implementation MathUnitSet

+ (MathUnitSet *)none
{
    if (l_none == nil) {
        l_none = [[MathUnitSet alloc] initWithUnits:@[]];
    }
    return l_none;
}

- (id)initWithUnitDictionary:(NSDictionary *)unitDictionary
{
    FTAssert(unitDictionary);
    self = [super init];
    if (self) {
        _unitDictionary = [unitDictionary copy];
    }
    return self;
}

- (id)initWithUnits:(NSArray *)units
{
    FTAssert(units);
    NSMutableDictionary *unitDictionary = [NSMutableDictionary dictionaryWithCapacity:0];
    for (MathUnit *unit in units) {
        unitDictionary[NSStringFromClass([unit class])] = unit;
    }
    return [self initWithUnitDictionary:unitDictionary];
}

- (NSArray *)units
{
    return [self.unitDictionary allValues];
}

- (MathUnit *)unitForClass:(Class)unitClass
{
    return self.unitDictionary[NSStringFromClass(unitClass)];
}

- (MathUnitSet *)unitSetByMultiplyingBy:(MathUnitSet *)anotherUnitSet
{
    if (anotherUnitSet == nil) return nil;
    if (self.unitDictionary.count == 0) return anotherUnitSet;
    if (anotherUnitSet.unitDictionary.count == 0) return self;
    
    NSMutableDictionary *unitDictionary = [self.unitDictionary mutableCopy];
    [anotherUnitSet.unitDictionary enumerateKeysAndObjectsUsingBlock:^(NSString *key, MathUnit *thatUnit, BOOL *stop) {
        MathUnit *thisUnit = unitDictionary[key];
        if (thisUnit) {
            decQuad thisOrder = thisUnit.order;
            decQuad thatOrder = thatUnit.order;
            decQuad resultOrder;
            decQuadAdd(&resultOrder, &thisOrder, &thatOrder, &DQ_set);
            if (decQuadIsZero(&resultOrder)) {
                [unitDictionary removeObjectForKey:key];
            }
            else {
                unitDictionary[key] = [[MathUnit alloc] initWithOrder:resultOrder];
            }
        }
        else {
            unitDictionary[key] = thatUnit;
        }
    }];
    return [[MathUnitSet alloc] initWithUnitDictionary:unitDictionary];
}

- (MathUnitSet *)unitSetByDividingBy:(MathUnitSet *)anotherUnitSet
{
    if (anotherUnitSet == nil) return nil;
    if (self.unitDictionary.count == 0) return anotherUnitSet;
    if (anotherUnitSet.unitDictionary.count == 0) return self;
    
    NSMutableDictionary *unitDictionary = [self.unitDictionary mutableCopy];
    [anotherUnitSet.unitDictionary enumerateKeysAndObjectsUsingBlock:^(NSString *key, MathUnit *thatUnit, BOOL *stop) {
        decQuad thatOrder = thatUnit.order;
        decQuad resultOrder;
        MathUnit *thisUnit = unitDictionary[key];
        if (thisUnit) {
            decQuad thisOrder = thisUnit.order;
            decQuadSubtract(&resultOrder, &thisOrder, &thatOrder, &DQ_set);
        }
        else {
            decQuadMinus(&resultOrder, &thatOrder, &DQ_set);
        }
        if (decQuadIsZero(&resultOrder)) {
            [unitDictionary removeObjectForKey:key];
        }
        else {
            unitDictionary[key] = [[MathUnit alloc] initWithOrder:resultOrder];
        }
    }];
    return [[MathUnitSet alloc] initWithUnitDictionary:unitDictionary];
}

- (MathUnitSet *)unitSetByRaisingToPower:(decQuad)power
{
    if (self.unitDictionary.count == 0) return self;
    
    NSMutableDictionary *__block unitDictionary = [self.unitDictionary mutableCopy];
    [self.unitDictionary enumerateKeysAndObjectsUsingBlock:^(NSString *key, MathUnit *unit, BOOL *stop) {
        decQuad order = unit.order;
        decQuad resultOrder;
        decQuadMultiply(&resultOrder, &order, &power, &DQ_set);
        if (!decQuadIsFinite(&resultOrder)) {
            unitDictionary = nil;
            *stop = YES;
        }
        roundToIntegralQuasiExact(&resultOrder);
        if (decQuadIsZero(&resultOrder)) {
            [unitDictionary removeObjectForKey:key];
        }
        else {
            unitDictionary[key] = [[MathUnit alloc] initWithOrder:resultOrder];
        }
    }];
    return unitDictionary ? [[MathUnitSet alloc] initWithUnitDictionary:unitDictionary] : nil;
}

- (MathUnitSet *)unitSetByRaisingToPowerReciprocal:(decQuad)powerReciprocal
{
    if (self.unitDictionary.count == 0) return self;

    NSMutableDictionary *__block unitDictionary = [self.unitDictionary mutableCopy];
    [self.unitDictionary enumerateKeysAndObjectsUsingBlock:^(NSString *key, MathUnit *unit, BOOL *stop) {
        decQuad order = unit.order;
        decQuad resultOrder;
        decQuadDivide(&resultOrder, &order, &powerReciprocal, &DQ_set);
        if (!decQuadIsFinite(&resultOrder)) {
            unitDictionary = nil;
            *stop = YES;
        }
        roundToIntegralQuasiExact(&resultOrder);
        if (decQuadIsZero(&resultOrder)) {
            [unitDictionary removeObjectForKey:key];
        }
        else {
            unitDictionary[key] = [[MathUnit alloc] initWithOrder:resultOrder];
        }
    }];
    return unitDictionary ? [[MathUnitSet alloc] initWithUnitDictionary:unitDictionary] : nil;
}

- (MathUnitSet *)unitSetByReconcilingWith:(MathUnitSet *)anotherUnitSet
{
    if (anotherUnitSet == nil) return nil;
    if (self.unitDictionary.count == 0 && anotherUnitSet.unitDictionary.count == 0) return self;  // or anotherUnitSet
    
    NSMutableDictionary *deltaUnitDictionary = [self.unitDictionary mutableCopy];
    [anotherUnitSet.unitDictionary enumerateKeysAndObjectsUsingBlock:^(NSString *key, MathUnit *thatUnit, BOOL *stop) {
        decQuad thatOrder = thatUnit.order;
        decQuad deltaOrder;
        MathUnit *thisUnit = deltaUnitDictionary[key];
        if (thisUnit) {
            decQuad thisOrder = thisUnit.order;
            decQuadSubtract(&deltaOrder, &thisOrder, &thatOrder, &DQ_set);
        }
        else {
            decQuadMinus(&deltaOrder, &thatOrder, &DQ_set);
        }
        if (decQuadIsZero(&deltaOrder)) {
            [deltaUnitDictionary removeObjectForKey:key];
        }
        else {
            deltaUnitDictionary[key] = [[MathUnit alloc] initWithOrder:deltaOrder];
        }
    }];
    
    MathUnit *angleUnitUserDefault = deltaUnitDictionary[NSStringFromClass([MathAngleUnitUserDefault class])];
    MathUnit *angleUnitDegree = deltaUnitDictionary[NSStringFromClass([MathAngleUnitDegree class])];
    if (angleUnitUserDefault) {
        decQuad userDefaultOrder = angleUnitUserDefault.order;
        FTAssert_DEBUG(!decQuadIsZero(&userDefaultOrder));
        if (angleUnitDegree == nil || ({decQuad tmpDec = angleUnitDegree.order; decQuadAdd(&tmpDec, &userDefaultOrder, &tmpDec, &DQ_set); decQuadIsZero(&tmpDec);})) {
            return decQuadIsPositive(&userDefaultOrder) ? anotherUnitSet : self;
        }
        else {
            return nil;
        }
    }
    else {
        if (angleUnitDegree) {
            FTAssert_DEBUG(({decQuad tmpDec = angleUnitDegree.order; !decQuadIsZero(&tmpDec);}));
            return nil;
        }
        else {
            FTAssert_DEBUG(deltaUnitDictionary.count == 0);
            return self;  //: or anotherUnitSet
        }
    }
}

@end
