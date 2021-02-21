//
//  MathCloak.m
//  iCalculator
//
//  Created by curie on 13-4-30.
//  Copyright (c) 2013年 Fish Tribe. All rights reserved.
//

#import "MathCloak.h"


@interface MathCloak ()

@property (nonatomic, strong, readonly) MathElement *element;

@end


@implementation MathCloak

- (id)initWithElement:(MathElement *)element
{
    NSParameterAssert(element);
    self = [super initWithLeftAffinity:element.leftAffinity rightAffinity:element.rightAffinity];
    if (self) {
        _element = element;
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)decoder
{
    self = [super initWithCoder:decoder];
    if (self) {
        _element = [decoder decodeObjectForKey:@"element"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)encoder
{
    [super encodeWithCoder:encoder];
    [encoder encodeObject:_element forKey:@"element"];
}

- (BOOL)isGraphical
{
    return [self.element isGraphical];
}

- (CGRect)rectWhenDrawWithContext:(MathDrawingContext *)context
{
    CGRect rect = CGRectStandardize([self.element rectWhenDrawWithContext:context]);
    rect.size.width = 0.0;
    return rect;
}

- (CGRect)drawWithContext:(MathDrawingContext *)context
{
    return [self rectWhenDrawWithContext:context];
}

- (NSNumber *)operate
{
    return nil;
}

@end
