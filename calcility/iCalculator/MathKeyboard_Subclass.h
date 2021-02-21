//
//  MathKeyboard_Subclass.h
//  iCalculator
//
//  Created by curie on 13-9-11.
//  Copyright (c) 2013年 Fish Tribe. All rights reserved.
//

#import "MathKeyboard.h"


typedef NS_ENUM(NSUInteger, MathKeyStyle) {
    MathKeyStyleCustom = 0,
    MathKeyStyleLight,
    MathKeyStyleDark,
    MathKeyStyleFlyout,
};


enum : NSInteger {
    MATH_NUM_KEY_TAG = 0,
    
    MATH_DELETE_KEY_TAG,
    MATH_RETURN_KEY_TAG,
    
    MATH_ADD_KEY_TAG,
    MATH_SUB_KEY_TAG,
    MATH_MUL_KEY_TAG,
    MATH_DIV_KEY_TAG,
    MATH_FRACTION_KEY_TAG,
    MATH_FRACTION1_KEY_TAG,
    MATH_FRACTION2_KEY_TAG,
    MATH_MOD_KEY_TAG,
    MATH_PERCENT_KEY_TAG,
    MATH_PERMILLE_KEY_TAG,
    MATH_EXP_KEY_TAG,
    MATH_PARENTHESES_KEY_TAG,
    MATH_FLOOR_KEY_TAG,
    MATH_CEIL_KEY_TAG,
    MATH_ABS_KEY_TAG,
    
    MATH_SIN_KEY_TAG,
    MATH_COS_KEY_TAG,
    MATH_TAN_KEY_TAG,
    MATH_ARCSIN_KEY_TAG,
    MATH_ARCCOS_KEY_TAG,
    MATH_ARCTAN_KEY_TAG,
    MATH_DEGREE_KEY_TAG,
    
    MATH_SINH_KEY_TAG,
    MATH_COSH_KEY_TAG,
    MATH_TANH_KEY_TAG,
    MATH_ARCSINH_KEY_TAG,
    MATH_ARCCOSH_KEY_TAG,
    MATH_ARCTANH_KEY_TAG,
    
    MATH_PI_KEY_TAG,
    MATH_PI_OVER_2_TAG,
    MATH_PI_OVER_3_TAG,
    MATH_PI_OVER_4_TAG,
    MATH_PI_OVER_6_TAG,
    MATH_2PI_OVER_3_TAG,
    MATH_4PI_OVER_3_TAG,
    MATH_E_KEY_TAG,
    
    MATH_LOG10_KEY_TAG,
    MATH_LN_KEY_TAG,
    MATH_LOG2_KEY_TAG,
    MATH_LOG_KEY_TAG,
    
    MATH_SQRT_KEY_TAG,
    MATH_CBRT_KEY_TAG,
    MATH_ROOT_KEY_TAG,
    MATH_SQUARE_KEY_TAG,
    MATH_CUBIC_KEY_TAG,
    MATH_POW_KEY_TAG,
    
    MATH_FACTORIAL_KEY_TAG,
    MATH_RAND_KEY_TAG,
    MATH_COMBINATION_KEY_TAG,
    MATH_PERMUTATION_KEY_TAG,
};


@interface MathKey : UIButton

- (id)initWithStyle:(MathKeyStyle)style tag:(NSInteger)tag;  //: Designated Initializer

@property (nonatomic, getter = isLocked) BOOL locked;
@property (nonatomic, getter = isTakingOffMode) BOOL takingOffMode;
@property (nonatomic, strong) MathKey *alternativeKey;
@property (nonatomic, strong) NSArray *flyoutKeys;
@property (nonatomic, copy) void (^refreshState)(id<MathInput> inputtee);

- (void)setTitle:(NSString *)title portraitFont:(UIFont *)portraitFont landscapeFont:(UIFont *)landscapeFont;
- (void)setPortraitImage:(UIImage *)portraitImage landscapeImage:(UIImage *)landscapeImage;
- (void)setPortraitHighlightedImage:(UIImage *)portraitHighlightedImage landscapeHighlightedImage:(UIImage *)landscapeHighlightedImage;
- (void)setPortraitDisabledImage:(UIImage *)portraitDisabledImage landscapeDisabledImage:(UIImage *)landscapeDisabledImage;
- (void)setPortraitInsets:(UIEdgeInsets)portraitInsets landscapeInsets:(UIEdgeInsets)landscapeInsets;

- (void)updateContent;

@end


#pragma mark -


@interface MathKeypad : UIView

- (id)initWithFrame:(CGRect)frame keyboard:(MathKeyboard *)keyboard;  //: Designated Initializer

@property (nonatomic, weak) MathKey *hitKey;
@property (nonatomic, getter = isDimmed) BOOL dimmed;

- (void)dismissFlyoutKeypad;

@end


#pragma mark -


@interface MathKeyboard ()

+ (CGFloat)separatorThickness;

@property (nonatomic, strong) MathKeypad *keypad;
@property (nonatomic, copy) NSArray *staticKeys;

- (NSInteger)colIndexOfKey:(MathKey *)key;  //: [0] [1] [2] ... [2] [-3] ... [-3] [-2] [-1]

@end
