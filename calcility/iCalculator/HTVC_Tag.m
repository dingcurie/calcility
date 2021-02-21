//
//  HTVC_Tag.m
//  iCalculator
//
//  Created by curie on 11/20/14.
//  Copyright (c) 2014 Fish Tribe. All rights reserved.
//

#import "HTVC_Tag.h"
#import "HTVC_ColorPallete.h"
#import "MathElement.h"


@interface HTVC_Tag ()

@property (nonatomic, weak, readonly) UIImageView *colorBlock;

@end


@implementation HTVC_Tag

- (instancetype)initWithImage:(UIImage *)image
{
    self = [super initWithImage:image];
    if (self) {
        [super setUserInteractionEnabled:NO];
        
        UIImageView *colorBlock = [[UIImageView alloc] initWithImage:[[UIImage imageNamed:@"opaque-point"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate]];
        colorBlock.translatesAutoresizingMaskIntoConstraints = NO;
        
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectZero];
        label.translatesAutoresizingMaskIntoConstraints = NO;
        label.textColor = [MathDrawingContext dullColor];
        label.lineBreakMode = NSLineBreakByTruncatingMiddle;
        
        [super addSubview:(_label = label)];
        [super addSubview:(_colorBlock = colorBlock)];
        
        NSLayoutConstraint *tmpConstraint;
        tmpConstraint = [NSLayoutConstraint constraintWithItem:colorBlock attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeLeading multiplier:1.0 constant:HTVC_TAG_COLOR_BLOCK_LEADING_MARGIN];
        (_colorBlockLeadingMarginConstraint = tmpConstraint).active = YES;
        tmpConstraint = [NSLayoutConstraint constraintWithItem:colorBlock attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:0.0 constant:HTVC_TAG_COLOR_BLOCK_WIDTH];
        (_colorBlockWidthConstraint = tmpConstraint).active = YES;
        tmpConstraint = [NSLayoutConstraint constraintWithItem:label attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:colorBlock attribute:NSLayoutAttributeTrailing multiplier:1.0 constant:HTVC_TAG_TEXT_LEADING_MARGIN];
        (_textLeadingMarginConstraint = tmpConstraint).active = YES;
        tmpConstraint = [NSLayoutConstraint constraintWithItem:self attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:label attribute:NSLayoutAttributeTrailing multiplier:1.0 constant:HTVC_TAG_TEXT_TRAILING_MARGIN];
        (_textTrailingMarginConstraint = tmpConstraint).active = YES;
        
        [NSLayoutConstraint constraintWithItem:label attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:0.0 constant:HTVC_TAG_HEIGHT].active = YES;
        [NSLayoutConstraint constraintWithItem:label attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterY multiplier:1.0 constant:0.0].active = YES;
        [NSLayoutConstraint constraintWithItem:colorBlock attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:label attribute:NSLayoutAttributeTop multiplier:1.0 constant:0.0].active = YES;
        [NSLayoutConstraint constraintWithItem:colorBlock attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:label attribute:NSLayoutAttributeBottom multiplier:1.0 constant:0.0].active = YES;
    }
    return self;
}

- (void)setColorIndex:(uint32_t)colorIndex
{
    _colorIndex = colorIndex;
    
    self.tintColor = [HTVC_ColorPallete colorAtIndex:colorIndex];
}

@end
