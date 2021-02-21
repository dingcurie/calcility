//
//  MathUnitSet.h
//  iCalculator
//
//  Created by curie on 9/10/14.
//  Copyright (c) 2014 Fish Tribe. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MathUnit.h"


@interface MathUnitSet : NSObject

+ (MathUnitSet *)none;

- (id)initWithUnits:(NSArray *)units;

@property (nonatomic, copy, readonly) NSArray *units;

- (MathUnit *)unitForClass:(Class)unitClass;

- (MathUnitSet *)unitSetByMultiplyingBy:(MathUnitSet *)anotherUnitSet;
- (MathUnitSet *)unitSetByDividingBy:(MathUnitSet *)anotherUnitSet;
- (MathUnitSet *)unitSetByRaisingToPower:(decQuad)power;
- (MathUnitSet *)unitSetByRaisingToPowerReciprocal:(decQuad)powerReciprocal;
- (MathUnitSet *)unitSetByReconcilingWith:(MathUnitSet *)anotherUnitSet;

@end


#import "MathAngleUnitDegree.h"
#import "MathAngleUnitUserDefault.h"
