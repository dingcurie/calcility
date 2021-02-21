//
//  MathKeyboard_iPad.m
//  iCalculator
//
//  Created by curie on 13-9-10.
//  Copyright (c) 2013年 Fish Tribe. All rights reserved.
//

#import "MathKeyboard_iPad.h"
#import "MathConcreteOperators.h"
#import "MathNumber.h"


@interface MathKeyboard_iPad ()

@property (nonatomic, weak, readonly) UIView *mainPad;

@end


@implementation MathKeyboard_iPad

- (id)init
{
    self = [super initWithFrame:CGRectZero];
    if (self) {
        /****************** keypad ******************/
        MathKeypad *keypad = [[MathKeypad alloc] initWithFrame:CGRectZero keyboard:self];
        keypad.translatesAutoresizingMaskIntoConstraints = NO;
        [super addSubview:keypad];
        
        UIFont *  numberFont_Portrait = [UIFont fontWithName:@"TimesNewRomanPSMT"        size:30.0];
        UIFont *operatorFont_Portrait = [UIFont fontWithName:@"TimesNewRomanPS-BoldMT"   size:30.0];
        UIFont *  symbolFont_Portrait = [UIFont fontWithName:@"TimesNewRomanPSMT"        size:30.0];
        UIFont *variableFont_Portrait = [UIFont fontWithName:@"TimesNewRomanPS-ItalicMT" size:26.0];
        UIFont *functionFont_Portrait = [UIFont fontWithName:@"TimesNewRomanPSMT"        size:24.0];
        
        UIFont *  numberFont_Landscape = [UIFont fontWithName:@"TimesNewRomanPSMT"        size:36.0];
        UIFont *operatorFont_Landscape = [UIFont fontWithName:@"TimesNewRomanPS-BoldMT"   size:36.0];
        UIFont *  symbolFont_Landscape = [UIFont fontWithName:@"TimesNewRomanPSMT"        size:36.0];
        UIFont *variableFont_Landscape = [UIFont fontWithName:@"TimesNewRomanPS-ItalicMT" size:32.0];
        UIFont *functionFont_Landscape = [UIFont fontWithName:@"TimesNewRomanPSMT"        size:30.0];
        
        MathKey *__weak me;
        
        /************** mainPad **************/
        UIView *mainPad = [[UIView alloc] initWithFrame:CGRectZero];
        mainPad.translatesAutoresizingMaskIntoConstraints = NO;
        [keypad addSubview:(_mainPad = mainPad)];
        
        /* Column 1 */
        MathKey *arcsinKey = [[MathKey alloc] initWithStyle:MathKeyStyleDark tag:MATH_ARCSIN_KEY_TAG];
        [arcsinKey setTitle:@"arcsin" portraitFont:[functionFont_Portrait fontWithSize:22.0] landscapeFont:[functionFont_Landscape fontWithSize:28.0]];
        {
            MathKey *arcsinhKey = [[MathKey alloc] initWithStyle:MathKeyStyleFlyout tag:MATH_ARCSINH_KEY_TAG];
            [arcsinhKey setTitle:@"arcsinh" portraitFont:[functionFont_Portrait fontWithSize:21.0] landscapeFont:[functionFont_Landscape fontWithSize:27.0]];
            
            arcsinKey.flyoutKeys = @[arcsinhKey];
        }
        [mainPad addSubview:arcsinKey];
        
        MathKey *arccosKey = [[MathKey alloc] initWithStyle:MathKeyStyleDark tag:MATH_ARCCOS_KEY_TAG];
        [arccosKey setTitle:@"arccos" portraitFont:[functionFont_Portrait fontWithSize:22.0] landscapeFont:[functionFont_Landscape fontWithSize:28.0]];
        {
            MathKey *arccoshKey = [[MathKey alloc] initWithStyle:MathKeyStyleFlyout tag:MATH_ARCCOSH_KEY_TAG];
            [arccoshKey setTitle:@"arccosh" portraitFont:[functionFont_Portrait fontWithSize:21.0] landscapeFont:[functionFont_Landscape fontWithSize:27.0]];
            
            arccosKey.flyoutKeys = @[arccoshKey];
        }
        [mainPad addSubview:arccosKey];
        
        MathKey *arctanKey = [[MathKey alloc] initWithStyle:MathKeyStyleDark tag:MATH_ARCTAN_KEY_TAG];
        [arctanKey setTitle:@"arctan" portraitFont:[functionFont_Portrait fontWithSize:22.0] landscapeFont:[functionFont_Landscape fontWithSize:28.0]];
        {
            MathKey *arctanhKey = [[MathKey alloc] initWithStyle:MathKeyStyleFlyout tag:MATH_ARCTANH_KEY_TAG];
            [arctanhKey setTitle:@"arctanh" portraitFont:[functionFont_Portrait fontWithSize:21.0] landscapeFont:[functionFont_Landscape fontWithSize:27.0]];
            
            arctanKey.flyoutKeys = @[arctanhKey];
        }
        [mainPad addSubview:arctanKey];
        
        MathKey *degreeKey = [[MathKey alloc] initWithStyle:MathKeyStyleDark tag:MATH_DEGREE_KEY_TAG];
        [degreeKey setTitle:@"°" portraitFont:[symbolFont_Portrait fontWithSize:22.0] landscapeFont:[symbolFont_Landscape fontWithSize:28.0]];
        [mainPad addSubview:degreeKey];
        
        /* Column 2 */
        MathKey *sinKey = [[MathKey alloc] initWithStyle:MathKeyStyleDark tag:MATH_SIN_KEY_TAG];
        [sinKey setTitle:@"sin" portraitFont:functionFont_Portrait landscapeFont:functionFont_Landscape];
        {
            MathKey *sinhKey = [[MathKey alloc] initWithStyle:MathKeyStyleFlyout tag:MATH_SINH_KEY_TAG];
            [sinhKey setTitle:@"sinh" portraitFont:functionFont_Portrait landscapeFont:functionFont_Landscape];
            
            sinKey.flyoutKeys = @[sinhKey];
        }
        [mainPad addSubview:sinKey];
        
        MathKey *cosKey = [[MathKey alloc] initWithStyle:MathKeyStyleDark tag:MATH_COS_KEY_TAG];
        [cosKey setTitle:@"cos" portraitFont:functionFont_Portrait landscapeFont:functionFont_Landscape];
        {
            MathKey *coshKey = [[MathKey alloc] initWithStyle:MathKeyStyleFlyout tag:MATH_COSH_KEY_TAG];
            [coshKey setTitle:@"cosh" portraitFont:functionFont_Portrait landscapeFont:functionFont_Landscape];
            
            cosKey.flyoutKeys = @[coshKey];
        }
        [mainPad addSubview:cosKey];
        
        MathKey *tanKey = [[MathKey alloc] initWithStyle:MathKeyStyleDark tag:MATH_TAN_KEY_TAG];
        [tanKey setTitle:@"tan" portraitFont:functionFont_Portrait landscapeFont:functionFont_Landscape];
        {
            MathKey *tanhKey = [[MathKey alloc] initWithStyle:MathKeyStyleFlyout tag:MATH_TANH_KEY_TAG];
            [tanhKey setTitle:@"tanh" portraitFont:functionFont_Portrait landscapeFont:functionFont_Landscape];
            
            tanKey.flyoutKeys = @[tanhKey];
        }
        [mainPad addSubview:tanKey];
        
        MathKey *piKey = [[MathKey alloc] initWithStyle:MathKeyStyleDark tag:MATH_PI_KEY_TAG];
        [piKey setTitle:@"π" portraitFont:variableFont_Portrait landscapeFont:variableFont_Landscape];
        {
            MathKey *piOver2Key = [[MathKey alloc] initWithStyle:MathKeyStyleFlyout tag:MATH_PI_OVER_2_TAG];
            [piOver2Key setPortraitImage:[UIImage imageNamed:@"glyph-π_over_2-26"] landscapeImage:[UIImage imageNamed:@"glyph-π_over_2-26"]];
            [piOver2Key setPortraitHighlightedImage:[UIImage imageNamed:@"glyph-π_over_2-26-white"] landscapeHighlightedImage:[UIImage imageNamed:@"glyph-π_over_2-26-white"]];
            
            MathKey *piOver3Key = [[MathKey alloc] initWithStyle:MathKeyStyleFlyout tag:MATH_PI_OVER_3_TAG];
            [piOver3Key setPortraitImage:[UIImage imageNamed:@"glyph-π_over_3-26"] landscapeImage:[UIImage imageNamed:@"glyph-π_over_3-26"]];
            [piOver3Key setPortraitHighlightedImage:[UIImage imageNamed:@"glyph-π_over_3-26-white"] landscapeHighlightedImage:[UIImage imageNamed:@"glyph-π_over_3-26-white"]];
            
            MathKey *piOver4Key = [[MathKey alloc] initWithStyle:MathKeyStyleFlyout tag:MATH_PI_OVER_4_TAG];
            [piOver4Key setPortraitImage:[UIImage imageNamed:@"glyph-π_over_4-26"] landscapeImage:[UIImage imageNamed:@"glyph-π_over_4-26"]];
            [piOver4Key setPortraitHighlightedImage:[UIImage imageNamed:@"glyph-π_over_4-26-white"] landscapeHighlightedImage:[UIImage imageNamed:@"glyph-π_over_4-26-white"]];
            
            MathKey *piOver6Key = [[MathKey alloc] initWithStyle:MathKeyStyleFlyout tag:MATH_PI_OVER_6_TAG];
            [piOver6Key setPortraitImage:[UIImage imageNamed:@"glyph-π_over_6-26"] landscapeImage:[UIImage imageNamed:@"glyph-π_over_6-26"]];
            [piOver6Key setPortraitHighlightedImage:[UIImage imageNamed:@"glyph-π_over_6-26-white"] landscapeHighlightedImage:[UIImage imageNamed:@"glyph-π_over_6-26-white"]];
            
            MathKey *twoPiOver3Key = [[MathKey alloc] initWithStyle:MathKeyStyleFlyout tag:MATH_2PI_OVER_3_TAG];
            [twoPiOver3Key setPortraitImage:[UIImage imageNamed:@"glyph-2π_over_3-26"] landscapeImage:[UIImage imageNamed:@"glyph-2π_over_3-26"]];
            [twoPiOver3Key setPortraitHighlightedImage:[UIImage imageNamed:@"glyph-2π_over_3-26-white"] landscapeHighlightedImage:[UIImage imageNamed:@"glyph-2π_over_3-26-white"]];
            
            MathKey *fourPiOver3Key = [[MathKey alloc] initWithStyle:MathKeyStyleFlyout tag:MATH_4PI_OVER_3_TAG];
            [fourPiOver3Key setPortraitImage:[UIImage imageNamed:@"glyph-4π_over_3-26"] landscapeImage:[UIImage imageNamed:@"glyph-4π_over_3-26"]];
            [fourPiOver3Key setPortraitHighlightedImage:[UIImage imageNamed:@"glyph-4π_over_3-26-white"] landscapeHighlightedImage:[UIImage imageNamed:@"glyph-4π_over_3-26-white"]];
            
            piKey.flyoutKeys = @[piOver6Key, piOver4Key, piOver2Key, piOver3Key, twoPiOver3Key, fourPiOver3Key];
        }
        [mainPad addSubview:piKey];
        
        /* Column 3 */
        MathKey *log10Key = [[MathKey alloc] initWithStyle:MathKeyStyleDark tag:MATH_LOG10_KEY_TAG];
        [log10Key setTitle:@"log" portraitFont:functionFont_Portrait landscapeFont:functionFont_Landscape];
        [mainPad addSubview:log10Key];
        
        MathKey *lnKey = [[MathKey alloc] initWithStyle:MathKeyStyleDark tag:MATH_LN_KEY_TAG];
        [lnKey setTitle:@"ln" portraitFont:functionFont_Portrait landscapeFont:functionFont_Landscape];
        [mainPad addSubview:lnKey];
        
        MathKey *log2Key = [[MathKey alloc] initWithStyle:MathKeyStyleDark tag:MATH_LOG2_KEY_TAG];
        [log2Key setPortraitImage:[UIImage imageNamed:@"glyph-log2-24"] landscapeImage:[UIImage imageNamed:@"glyph-log2-30"]];
        [log2Key setPortraitHighlightedImage:[UIImage imageNamed:@"glyph-log2-24-white"] landscapeHighlightedImage:[UIImage imageNamed:@"glyph-log2-30-white"]];
        [log2Key setPortraitInsets:UIEdgeInsetsMake(5.0, 0.0, 0.0, 0.0) landscapeInsets:UIEdgeInsetsMake(5.0, 0.0, 0.0, 0.0)];
        {
            MathKey *logKey = [[MathKey alloc] initWithStyle:MathKeyStyleFlyout tag:MATH_LOG_KEY_TAG];
            [logKey setPortraitImage:[UIImage imageNamed:@"glyph-log[]-24"] landscapeImage:[UIImage imageNamed:@"glyph-log[]-30"]];
            [logKey setPortraitHighlightedImage:[UIImage imageNamed:@"glyph-log[]-24-white"] landscapeHighlightedImage:[UIImage imageNamed:@"glyph-log[]-30-white"]];
            [logKey setPortraitInsets:UIEdgeInsetsMake(5.0, 0.0, 0.0, 0.0) landscapeInsets:UIEdgeInsetsMake(5.0, 0.0, 0.0, 0.0)];
            
            log2Key.flyoutKeys = @[logKey];
        }
        [mainPad addSubview:log2Key];
        
        MathKey *eKey = [[MathKey alloc] initWithStyle:MathKeyStyleDark tag:MATH_E_KEY_TAG];
        [eKey setTitle:@"e" portraitFont:variableFont_Portrait landscapeFont:variableFont_Landscape];
        [mainPad addSubview:eKey];
        
        /* Column 4 */
        MathKey *sqrtKey = [[MathKey alloc] initWithStyle:MathKeyStyleDark tag:MATH_SQRT_KEY_TAG];
        [sqrtKey setPortraitImage:[UIImage imageNamed:@"glyph-sqrt-24"] landscapeImage:[UIImage imageNamed:@"glyph-sqrt-30"]];
        [sqrtKey setPortraitHighlightedImage:[UIImage imageNamed:@"glyph-sqrt-24-white"] landscapeHighlightedImage:[UIImage imageNamed:@"glyph-sqrt-30-white"]];
        me = sqrtKey;
        [sqrtKey setRefreshState:^(id<MathInput> inputtee) {
            FTAssert(inputtee);
            NSArray *selectedElements = [inputtee.expression elementsInRange:inputtee.selectedRange];
            me.takingOffMode = selectedElements.count == 1 && [selectedElements[0] isKindOfClass:[MathSqrt class]];
        }];
        {
            MathKey *cbrtKey = [[MathKey alloc] initWithStyle:MathKeyStyleFlyout tag:MATH_CBRT_KEY_TAG];
            [cbrtKey setPortraitImage:[UIImage imageNamed:@"glyph-cbrt-24"] landscapeImage:[UIImage imageNamed:@"glyph-cbrt-30"]];
            [cbrtKey setPortraitHighlightedImage:[UIImage imageNamed:@"glyph-cbrt-24-white"] landscapeHighlightedImage:[UIImage imageNamed:@"glyph-cbrt-30-white"]];
            me = cbrtKey;
            [cbrtKey setRefreshState:^(id<MathInput> inputtee) {
                FTAssert(inputtee);
                NSArray *selectedElements = [inputtee.expression elementsInRange:inputtee.selectedRange];
                MathRoot *theRoot;
                MathNumber *theIndex;
                me.takingOffMode = selectedElements.count == 1 && [(theRoot = selectedElements[0]) isKindOfClass:[MathRoot class]] && theRoot.index.elements.count == 1 && [(theIndex = theRoot.index.elements[0]) isKindOfClass:[MathNumber class]] && [theIndex.string isEqualToString:@"3"];
            }];
            
            MathKey *rootKey = [[MathKey alloc] initWithStyle:MathKeyStyleFlyout tag:MATH_ROOT_KEY_TAG];
            [rootKey setPortraitImage:[UIImage imageNamed:@"glyph-root-24"] landscapeImage:[UIImage imageNamed:@"glyph-root-30"]];
            [rootKey setPortraitHighlightedImage:[UIImage imageNamed:@"glyph-root-24-white"] landscapeHighlightedImage:[UIImage imageNamed:@"glyph-root-30-white"]];
            me = rootKey;
            [rootKey setRefreshState:^(id<MathInput> inputtee) {
                FTAssert(inputtee);
                NSArray *selectedElements = [inputtee.expression elementsInRange:inputtee.selectedRange];
                MathRoot *theRoot;
                MathNumber *theIndex;
                me.takingOffMode = selectedElements.count == 1 && [(theRoot = selectedElements[0]) isKindOfClass:[MathRoot class]] && !(theRoot.index.elements.count == 1 && [(theIndex = theRoot.index.elements[0]) isKindOfClass:[MathNumber class]] && [theIndex.string isEqualToString:@"3"]);
            }];
            
            sqrtKey.flyoutKeys = @[cbrtKey, rootKey];
        }
        [mainPad addSubview:sqrtKey];
        
        MathKey *squareKey = [[MathKey alloc] initWithStyle:MathKeyStyleDark tag:MATH_SQUARE_KEY_TAG];
        [squareKey setPortraitImage:[UIImage imageNamed:@"glyph-x^2-24"] landscapeImage:[UIImage imageNamed:@"glyph-x^2-30"]];
        [squareKey setPortraitHighlightedImage:[UIImage imageNamed:@"glyph-x^2-24-white"] landscapeHighlightedImage:[UIImage imageNamed:@"glyph-x^2-30-white"]];
        [squareKey setPortraitInsets:UIEdgeInsetsMake(0.0, 0.0, 2.0, 0.0) landscapeInsets:UIEdgeInsetsMake(0.0, 0.0, 2.0, 0.0)];
        [mainPad addSubview:squareKey];
        
        MathKey *cubicKey = [[MathKey alloc] initWithStyle:MathKeyStyleDark tag:MATH_CUBIC_KEY_TAG];
        [cubicKey setPortraitImage:[UIImage imageNamed:@"glyph-x^3-24"] landscapeImage:[UIImage imageNamed:@"glyph-x^3-30"]];
        [cubicKey setPortraitHighlightedImage:[UIImage imageNamed:@"glyph-x^3-24-white"] landscapeHighlightedImage:[UIImage imageNamed:@"glyph-x^3-30-white"]];
        [cubicKey setPortraitInsets:UIEdgeInsetsMake(0.0, 0.0, 2.0, 0.0) landscapeInsets:UIEdgeInsetsMake(0.0, 0.0, 2.0, 0.0)];
        [mainPad addSubview:cubicKey];
        
        MathKey *powKey = [[MathKey alloc] initWithStyle:MathKeyStyleDark tag:MATH_POW_KEY_TAG];
        [powKey setPortraitImage:[UIImage imageNamed:@"glyph-x^[]-24"] landscapeImage:[UIImage imageNamed:@"glyph-x^[]-30"]];
        [powKey setPortraitHighlightedImage:[UIImage imageNamed:@"glyph-x^[]-24-white"] landscapeHighlightedImage:[UIImage imageNamed:@"glyph-x^[]-30-white"]];
        [powKey setPortraitInsets:UIEdgeInsetsMake(0.0, 0.0, 2.0, 0.0) landscapeInsets:UIEdgeInsetsMake(0.0, 0.0, 2.0, 0.0)];
        [mainPad addSubview:powKey];
        
        /* Column 5 */
        MathKey *factorialKey = [[MathKey alloc] initWithStyle:MathKeyStyleDark tag:MATH_FACTORIAL_KEY_TAG];
        [factorialKey setTitle:@"!" portraitFont:symbolFont_Portrait landscapeFont:symbolFont_Landscape];
        [mainPad addSubview:factorialKey];
        
        MathKey *permutationKey = [[MathKey alloc] initWithStyle:MathKeyStyleDark tag:MATH_PERMUTATION_KEY_TAG];
        [permutationKey setTitle:@"P(n,k)" portraitFont:[functionFont_Portrait fontWithSize:21.0] landscapeFont:[functionFont_Landscape fontWithSize:27.0]];
        [mainPad addSubview:permutationKey];
        
        MathKey *combinationKey = [[MathKey alloc] initWithStyle:MathKeyStyleDark tag:MATH_COMBINATION_KEY_TAG];
        [combinationKey setTitle:@"C(n,k)" portraitFont:[functionFont_Portrait fontWithSize:21.0] landscapeFont:[functionFont_Landscape fontWithSize:27.0]];
        [mainPad addSubview:combinationKey];
        
        MathKey *randKey = [[MathKey alloc] initWithStyle:MathKeyStyleDark tag:MATH_RAND_KEY_TAG];
        NSString *title = NSLocalizedString(@"Rand", nil);
        BOOL isZh = [title isEqualToString:@"随机数"];
        [randKey setTitle:title portraitFont:[functionFont_Portrait fontWithSize:(21.0 - 3.0 * isZh)] landscapeFont:[functionFont_Landscape fontWithSize:(27.0 - 4.0 * isZh)]];
        [randKey setPortraitInsets:UIEdgeInsetsMake(3.0, 0.0, 0.0, 0.0) landscapeInsets:UIEdgeInsetsMake(3.0, 0.0, 0.0, 0.0)];
        [mainPad addSubview:randKey];
        
        /* Column 6 */
        MathKey *num7Key = [[MathKey alloc] initWithStyle:MathKeyStyleLight tag:MATH_NUM_KEY_TAG];
        [num7Key setTitle:@"7" portraitFont:numberFont_Portrait landscapeFont:numberFont_Landscape];
        [mainPad addSubview:num7Key];
        
        MathKey *num4Key = [[MathKey alloc] initWithStyle:MathKeyStyleLight tag:MATH_NUM_KEY_TAG];
        [num4Key setTitle:@"4" portraitFont:numberFont_Portrait landscapeFont:numberFont_Landscape];
        [mainPad addSubview:num4Key];
        
        MathKey *num1Key = [[MathKey alloc] initWithStyle:MathKeyStyleLight tag:MATH_NUM_KEY_TAG];
        [num1Key setTitle:@"1" portraitFont:numberFont_Portrait landscapeFont:numberFont_Landscape];
        [mainPad addSubview:num1Key];
        
        MathKey *num0Key = [[MathKey alloc] initWithStyle:MathKeyStyleLight tag:MATH_NUM_KEY_TAG];
        [num0Key setTitle:@"0" portraitFont:numberFont_Portrait landscapeFont:numberFont_Landscape];
        [mainPad addSubview:num0Key];
        
        /* Column 7 */
        MathKey *num8Key = [[MathKey alloc] initWithStyle:MathKeyStyleLight tag:MATH_NUM_KEY_TAG];
        [num8Key setTitle:@"8" portraitFont:numberFont_Portrait landscapeFont:numberFont_Landscape];
        [mainPad addSubview:num8Key];
        
        MathKey *num5Key = [[MathKey alloc] initWithStyle:MathKeyStyleLight tag:MATH_NUM_KEY_TAG];
        [num5Key setTitle:@"5" portraitFont:numberFont_Portrait landscapeFont:numberFont_Landscape];
        [mainPad addSubview:num5Key];
        
        MathKey *num2Key = [[MathKey alloc] initWithStyle:MathKeyStyleLight tag:MATH_NUM_KEY_TAG];
        [num2Key setTitle:@"2" portraitFont:numberFont_Portrait landscapeFont:numberFont_Landscape];
        [mainPad addSubview:num2Key];
        
        MathKey *dotKey = [[MathKey alloc] initWithStyle:MathKeyStyleLight tag:MATH_NUM_KEY_TAG];
        [dotKey setTitle:@"." portraitFont:numberFont_Portrait landscapeFont:numberFont_Landscape];
        [mainPad addSubview:dotKey];
        
        /* Column 8 */
        MathKey *num9Key = [[MathKey alloc] initWithStyle:MathKeyStyleLight tag:MATH_NUM_KEY_TAG];
        [num9Key setTitle:@"9" portraitFont:numberFont_Portrait landscapeFont:numberFont_Landscape];
        [mainPad addSubview:num9Key];
        
        MathKey *num6Key = [[MathKey alloc] initWithStyle:MathKeyStyleLight tag:MATH_NUM_KEY_TAG];
        [num6Key setTitle:@"6" portraitFont:numberFont_Portrait landscapeFont:numberFont_Landscape];
        [mainPad addSubview:num6Key];
        
        MathKey *num3Key = [[MathKey alloc] initWithStyle:MathKeyStyleLight tag:MATH_NUM_KEY_TAG];
        [num3Key setTitle:@"3" portraitFont:numberFont_Portrait landscapeFont:numberFont_Landscape];
        [mainPad addSubview:num3Key];
        
        MathKey *expKey = [[MathKey alloc] initWithStyle:MathKeyStyleLight tag:MATH_EXP_KEY_TAG];
        [expKey setPortraitImage:[UIImage imageNamed:@"glyph-x10^[]-24"] landscapeImage:[UIImage imageNamed:@"glyph-x10^[]-30"]];
        [expKey setPortraitHighlightedImage:[UIImage imageNamed:@"glyph-x10^[]-24-white"] landscapeHighlightedImage:[UIImage imageNamed:@"glyph-x10^[]-30-white"]];
        [mainPad addSubview:expKey];
        
        /* Column 9 */
        MathKey *parenthesesKey = [[MathKey alloc] initWithStyle:MathKeyStyleDark tag:MATH_PARENTHESES_KEY_TAG];
        [parenthesesKey setTitle:@"( )" portraitFont:symbolFont_Portrait landscapeFont:symbolFont_Landscape];
        [parenthesesKey setPortraitInsets:UIEdgeInsetsMake(0.0, 0.0, 4.0, 0.0) landscapeInsets:UIEdgeInsetsMake(0.0, 0.0, 5.0, 0.0)];
        me = parenthesesKey;
        [parenthesesKey setRefreshState:^(id<MathInput> inputtee) {
            FTAssert(inputtee);
            NSArray *selectedElements = [inputtee.expression elementsInRange:inputtee.selectedRange];
            me.takingOffMode = selectedElements.count == 1 && [selectedElements[0] isKindOfClass:[MathParentheses class]];
        }];
        {
            MathKey *absKey = [[MathKey alloc] initWithStyle:MathKeyStyleFlyout tag:MATH_ABS_KEY_TAG];
            [absKey setPortraitImage:[UIImage imageNamed:@"glyph-abs-30"] landscapeImage:[UIImage imageNamed:@"glyph-abs-36"]];
            [absKey setPortraitHighlightedImage:[UIImage imageNamed:@"glyph-abs-30-white"] landscapeHighlightedImage:[UIImage imageNamed:@"glyph-abs-36-white"]];
            me = absKey;
            [absKey setRefreshState:^(id<MathInput> inputtee) {
                FTAssert(inputtee);
                NSArray *selectedElements = [inputtee.expression elementsInRange:inputtee.selectedRange];
                me.takingOffMode = selectedElements.count == 1 && [selectedElements[0] isKindOfClass:[MathAbs class]];
            }];
            
            MathKey *floorKey = [[MathKey alloc] initWithStyle:MathKeyStyleFlyout tag:MATH_FLOOR_KEY_TAG];
#ifdef LITE_VERSION
            floorKey.locked = YES;
#endif
            [floorKey setPortraitImage:[UIImage imageNamed:@"glyph-floor-30"] landscapeImage:[UIImage imageNamed:@"glyph-floor-36"]];
            [floorKey setPortraitHighlightedImage:[UIImage imageNamed:@"glyph-floor-30-white"] landscapeHighlightedImage:[UIImage imageNamed:@"glyph-floor-36-white"]];
            me = floorKey;
            [floorKey setRefreshState:^(id<MathInput> inputtee) {
                FTAssert(inputtee);
                NSArray *selectedElements = [inputtee.expression elementsInRange:inputtee.selectedRange];
                me.takingOffMode = selectedElements.count == 1 && [selectedElements[0] isKindOfClass:[MathFloor class]];
            }];

            MathKey *ceilKey = [[MathKey alloc] initWithStyle:MathKeyStyleFlyout tag:MATH_CEIL_KEY_TAG];
#ifdef LITE_VERSION
            ceilKey.locked = YES;
#endif
            [ceilKey setPortraitImage:[UIImage imageNamed:@"glyph-ceil-30"] landscapeImage:[UIImage imageNamed:@"glyph-ceil-36"]];
            [ceilKey setPortraitHighlightedImage:[UIImage imageNamed:@"glyph-ceil-30-white"] landscapeHighlightedImage:[UIImage imageNamed:@"glyph-ceil-36-white"]];
            me = ceilKey;
            [ceilKey setRefreshState:^(id<MathInput> inputtee) {
                FTAssert(inputtee);
                NSArray *selectedElements = [inputtee.expression elementsInRange:inputtee.selectedRange];
                me.takingOffMode = selectedElements.count == 1 && [selectedElements[0] isKindOfClass:[MathCeil class]];
            }];

            parenthesesKey.flyoutKeys = @[absKey, floorKey, ceilKey];
        }
        [mainPad addSubview:parenthesesKey];
        
        MathKey *addKey = [[MathKey alloc] initWithStyle:MathKeyStyleDark tag:MATH_ADD_KEY_TAG];
        [addKey setTitle:@"+" portraitFont:operatorFont_Portrait landscapeFont:operatorFont_Landscape];
        [mainPad addSubview:addKey];
        
        MathKey *mulKey = [[MathKey alloc] initWithStyle:MathKeyStyleDark tag:MATH_MUL_KEY_TAG];
        [mulKey setTitle:@"×" portraitFont:[operatorFont_Portrait fontWithSize:32.0] landscapeFont:[operatorFont_Landscape fontWithSize:38.0]];
        [mainPad addSubview:mulKey];
        
        MathKey *percentKey = [[MathKey alloc] initWithStyle:MathKeyStyleDark tag:MATH_PERCENT_KEY_TAG];
        [percentKey setTitle:@"%" portraitFont:symbolFont_Portrait landscapeFont:symbolFont_Landscape];
        {
            MathKey *permilleKey = [[MathKey alloc] initWithStyle:MathKeyStyleFlyout tag:MATH_PERMILLE_KEY_TAG];
            [permilleKey setTitle:@"‰" portraitFont:symbolFont_Portrait landscapeFont:symbolFont_Landscape];
            
            percentKey.flyoutKeys = @[permilleKey];
        }
        [mainPad addSubview:percentKey];
        
        /* Column 10 */
        MathKey *deleteKey = [[MathKey alloc] initWithStyle:MathKeyStyleDark tag:MATH_DELETE_KEY_TAG];
        [deleteKey setPortraitImage:[UIImage imageNamed:@"glyph-delete-24"] landscapeImage:[UIImage imageNamed:@"glyph-delete-30"]];
        [deleteKey setPortraitHighlightedImage:[UIImage imageNamed:@"glyph-delete-24-highlighted"] landscapeHighlightedImage:[UIImage imageNamed:@"glyph-delete-30-highlighted"]];
        [mainPad addSubview:deleteKey];
        
        MathKey *subKey = [[MathKey alloc] initWithStyle:MathKeyStyleDark tag:MATH_SUB_KEY_TAG];
        [subKey setTitle:@"−" portraitFont:operatorFont_Portrait landscapeFont:operatorFont_Landscape];
        [mainPad addSubview:subKey];
        
        MathKey *divKey = [[MathKey alloc] initWithStyle:MathKeyStyleDark tag:MATH_DIV_KEY_TAG];
        [divKey setTitle:@"/" portraitFont:operatorFont_Portrait landscapeFont:operatorFont_Landscape];
        {
            MathKey *fractionKey = [[MathKey alloc] initWithStyle:MathKeyStyleFlyout tag:MATH_FRACTION_KEY_TAG];
            [fractionKey setPortraitImage:[UIImage imageNamed:@"glyph-1|[]-30"] landscapeImage:[UIImage imageNamed:@"glyph-1|[]-36"]];
            [fractionKey setPortraitHighlightedImage:[UIImage imageNamed:@"glyph-1|[]-30-white"] landscapeHighlightedImage:[UIImage imageNamed:@"glyph-1|[]-36-white"]];
            divKey.alternativeKey = fractionKey;

            MathKey *fraction1Key = [[MathKey alloc] initWithStyle:MathKeyStyleFlyout tag:MATH_FRACTION1_KEY_TAG];
            me = fraction1Key;
            [fraction1Key setRefreshState:^(id<MathInput> inputtee) {
                FTAssert(inputtee);
                if (inputtee.selectedRange.selectionLength) {
                    [me setPortraitImage:[UIImage imageNamed:@"glyph-[]|#-30"] landscapeImage:[UIImage imageNamed:@"glyph-[]|#-36"]];
                    [me setPortraitHighlightedImage:[UIImage imageNamed:@"glyph-[]|#-30-white"] landscapeHighlightedImage:[UIImage imageNamed:@"glyph-[]|#-36-white"]];
                }
                else {
                    [me setPortraitImage:[UIImage imageNamed:@"glyph-[]|[]-30"] landscapeImage:[UIImage imageNamed:@"glyph-[]|[]-36"]];
                    [me setPortraitHighlightedImage:[UIImage imageNamed:@"glyph-[]|[]-30-white"] landscapeHighlightedImage:[UIImage imageNamed:@"glyph-[]|[]-36-white"]];
                }
            }];

            MathKey *fraction2Key = [[MathKey alloc] initWithStyle:MathKeyStyleFlyout tag:MATH_FRACTION2_KEY_TAG];
            me = fraction2Key;
            [fraction2Key setRefreshState:^(id<MathInput> inputtee) {
                FTAssert(inputtee);
                if (inputtee.selectedRange.selectionLength) {
                    [me setPortraitImage:[UIImage imageNamed:@"glyph-#|[]-30"] landscapeImage:[UIImage imageNamed:@"glyph-#|[]-36"]];
                    [me setPortraitHighlightedImage:[UIImage imageNamed:@"glyph-#|[]-30-white"] landscapeHighlightedImage:[UIImage imageNamed:@"glyph-#|[]-36-white"]];
                }
                else {
                    [me setPortraitImage:[UIImage imageNamed:@"glyph-@|[]-30"] landscapeImage:[UIImage imageNamed:@"glyph-@|[]-36"]];
                    [me setPortraitHighlightedImage:[UIImage imageNamed:@"glyph-@|[]-30-white"] landscapeHighlightedImage:[UIImage imageNamed:@"glyph-@|[]-36-white"]];
                }
            }];

            MathKey *modKey = [[MathKey alloc] initWithStyle:MathKeyStyleFlyout tag:MATH_MOD_KEY_TAG];
            [modKey setTitle:@"mod" portraitFont:functionFont_Portrait landscapeFont:functionFont_Landscape];

            divKey.flyoutKeys = @[fraction2Key, fraction1Key, modKey];
        }
        [mainPad addSubview:divKey];
        
        MathKey *returnKey = [[MathKey alloc] initWithStyle:MathKeyStyleDark tag:MATH_RETURN_KEY_TAG];
        [returnKey setPortraitImage:[UIImage imageNamed:@"glyph-return-24"] landscapeImage:[UIImage imageNamed:@"glyph-return-30"]];
        [returnKey setPortraitHighlightedImage:[UIImage imageNamed:@"glyph-return-24-highlighted"] landscapeHighlightedImage:[UIImage imageNamed:@"glyph-return-30-highlighted"]];
        [returnKey setPortraitDisabledImage:[UIImage imageNamed:@"glyph-return-24-disabled"] landscapeDisabledImage:[UIImage imageNamed:@"glyph-return-30-disabled"]];
        me = returnKey;
        [returnKey setRefreshState:^(id<MathInput> inputtee) {
            FTAssert(inputtee);
            me.enabled = inputtee.expression.elements.count != 0;
        }];
        [mainPad addSubview:returnKey];
        
        /**************************************************************************/
        [super setStaticKeys:mainPad.subviews];
        
        NSDictionary *views = NSDictionaryOfVariableBindings(keypad, mainPad);
        [NSLayoutConstraint activateConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|[keypad]|" options:0 metrics:nil views:views]];
        [NSLayoutConstraint activateConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[keypad]|" options:0 metrics:nil views:views]];
        [NSLayoutConstraint activateConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|[mainPad]|" options:0 metrics:nil views:views]];
        [NSLayoutConstraint activateConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[mainPad]|" options:0 metrics:nil views:views]];
    }
    return self;
}

#define KEY_HEIGHT  77.0

- (CGSize)intrinsicContentSize
{
    CGFloat separatorThickness = [MathKeyboard separatorThickness];
    return CGSizeMake(UIViewNoIntrinsicMetric, (KEY_HEIGHT - separatorThickness) * 4.0);
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    static CGSize s_previousSize;
    CGSize size = CGRectStandardize(self.bounds).size;
    if (CGSizeEqualToSize(size, s_previousSize)) return;
    s_previousSize = size;
    
    CGFloat separatorThickness = [MathKeyboard separatorThickness];
    CGFloat keyWidth[10];
    CGFloat integralKeyWidth = floor((size.width - 9.0 * separatorThickness) / 10.0) + 2.0 * separatorThickness;
    FTAssert_DEBUG(integralKeyWidth == trunc(integralKeyWidth));  //! ASSUMPTION: display scale = 1.0.
    CGFloat remainderWidth = size.width - 10.0 * integralKeyWidth + 11.0 * separatorThickness;
    for (uint8_t i = 0; i < 10; i++) {
        keyWidth[i] = integralKeyWidth;
    }
    keyWidth[0] += remainderWidth;
    
    NSUInteger row = 0;
    NSUInteger col = 0;
    CGFloat originX = -separatorThickness;
    for (MathKey *key in self.mainPad.subviews) {
        key.frame = CGRectMake(originX, (KEY_HEIGHT - separatorThickness) * row, keyWidth[col], KEY_HEIGHT);
        if (++row == 4) {
            row = 0;
            originX += keyWidth[col] - separatorThickness;
            col++;
        }
        
        [key updateContent];
    }
}

- (NSInteger)colIndexOfKey:(MathKey *)key
{
    static const NSInteger colIndexes[10] = {0, 1, 2, 2, 2, -3, -3, -3, -2, -1};
    
    NSUInteger indexOfKey = 0;
    for (UIView *subview in key.superview.subviews) {
        if (subview == key) {
            break;
        }
        indexOfKey++;
    }
    return colIndexes[indexOfKey / 4];
}

@end
