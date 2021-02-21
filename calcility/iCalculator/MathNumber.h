//
//  MathNumber.h
//  iCalculator
//
//  Created by  on 12-6-11.
//  Copyright (c) 2012年 Fish Tribe. All rights reserved.
//

#import "MathElement.h"
#import "MyDecimal.h"


@interface MathNumber : MathElement

- (id)initWithString:(NSString *)aString;  //: Designated Initializer

@property (nonatomic, copy) NSMutableString *string;
@property (nonatomic, copy, readonly) NSString *formattedString;
@property (nonatomic, readonly) decQuad value;

- (void)setMutated;

- (NSUInteger)closestIndexToPoint:(CGPoint)hitPoint whenDrawWithContext:(MathDrawingContext *)context;
- (CGFloat)offsetForIndex:(NSUInteger)index whenDrawWithFontSize:(CGFloat)fontSize;

@end
