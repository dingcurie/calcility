//
//  MathKeyboard_iPhone.m
//  iCalculator
//
//  Created by curie on 13-9-10.
//  Copyright (c) 2013年 Fish Tribe. All rights reserved.
//

#import "MathKeyboard_iPhone.h"
#import "MathConcreteOperators.h"
#import "MathNumber.h"
#import <UIKit/UIGestureRecognizerSubclass.h>


@interface MyThresholdGestureRecognizer : UIGestureRecognizer

@end


@implementation MyThresholdGestureRecognizer {
    CGPoint _beginLocation;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesBegan:touches withEvent:event];
    
    _beginLocation = [[touches anyObject] locationInView:nil];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesMoved:touches withEvent:event];
    
    if (self.state == UIGestureRecognizerStateFailed) return;
    
    CGPoint location = [[touches anyObject] locationInView:nil];
    if ((((UIScrollView *)self.view).contentOffset.x > 320.0 / 2 ? location.x - _beginLocation.x : _beginLocation.x - location.x) > 44.0) {
        self.state = UIGestureRecognizerStateFailed;
    }
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesCancelled:touches withEvent:event];
    
    self.state = UIGestureRecognizerStateRecognized;
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesEnded:touches withEvent:event];
    
    if (self.state == UIGestureRecognizerStateFailed) return;
    
    self.state = UIGestureRecognizerStateRecognized;
}

@end


#pragma mark -


@interface MathKeypadScrollView : UIScrollView <UIGestureRecognizerDelegate>

@property (nonatomic, weak, readonly) MyThresholdGestureRecognizer *thresholdGestureRecognizer;

@end


@implementation MathKeypadScrollView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        MyThresholdGestureRecognizer *thresholdGestureRecognizer = [[MyThresholdGestureRecognizer alloc] init];
        thresholdGestureRecognizer.cancelsTouchesInView = NO;
        thresholdGestureRecognizer.delegate = self;
        [super addGestureRecognizer:(_thresholdGestureRecognizer = thresholdGestureRecognizer)];
    }
    return self;
}

- (BOOL)touchesShouldCancelInContentView:(UIView *)view
{
    return YES;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldBeRequiredToFailByGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    if (gestureRecognizer == self.thresholdGestureRecognizer && otherGestureRecognizer == self.panGestureRecognizer) {
        return YES;
    }
    return NO;
}

@end


#pragma mark -


@interface MathKeyboard_iPhone () <UIScrollViewDelegate>

@property (nonatomic, weak, readonly) MathKeypadScrollView *scrollView;
@property (nonatomic, weak, readonly) UIPageControl *pageControl;
@property (nonatomic, weak, readonly) UIView *numPad;
@property (nonatomic, weak, readonly) UIView *fxPad;

@end


@implementation MathKeyboard_iPhone

- (id)init
{
    self = [super initWithFrame:CGRectZero];
    if (self) {
        MathKeypadScrollView *scrollView = [[MathKeypadScrollView alloc] initWithFrame:CGRectZero];
        scrollView.translatesAutoresizingMaskIntoConstraints = NO;
        scrollView.scrollsToTop = NO;
        scrollView.delaysContentTouches = NO;
        scrollView.pagingEnabled = YES;
        scrollView.showsHorizontalScrollIndicator = NO;
        scrollView.bounces = NO;
        scrollView.delegate = self;
        [super addSubview:(_scrollView = scrollView)];
        
        /****************** keypad ******************/
        MathKeypad *keypad = [[MathKeypad alloc] initWithFrame:CGRectZero keyboard:self];
        [scrollView addSubview:keypad];
        
        UIFont *  numberFont_Portrait = [UIFont fontWithName:@"TimesNewRomanPSMT"        size:30.0];
        UIFont *operatorFont_Portrait = [UIFont fontWithName:@"TimesNewRomanPS-BoldMT"   size:30.0];
        UIFont *  symbolFont_Portrait = [UIFont fontWithName:@"TimesNewRomanPSMT"        size:30.0];
        UIFont *variableFont_Portrait = [UIFont fontWithName:@"TimesNewRomanPS-ItalicMT" size:26.0];
        UIFont *functionFont_Portrait = [UIFont fontWithName:@"TimesNewRomanPSMT"        size:24.0];
        
        UIFont *  numberFont_Landscape = [UIFont fontWithName:@"TimesNewRomanPSMT"        size:20.0];
        UIFont *operatorFont_Landscape = [UIFont fontWithName:@"TimesNewRomanPS-BoldMT"   size:20.0];
        UIFont *  symbolFont_Landscape = [UIFont fontWithName:@"TimesNewRomanPSMT"        size:20.0];
        UIFont *variableFont_Landscape = [UIFont fontWithName:@"TimesNewRomanPS-ItalicMT" size:20.0];
        UIFont *functionFont_Landscape = [UIFont fontWithName:@"TimesNewRomanPSMT"        size:18.0];
        
        MathKey *__weak me;
        
        /************** numPad **************/
        UIView *numPad = [[UIView alloc] initWithFrame:CGRectZero];
        numPad.clipsToBounds = YES;
        [keypad addSubview:(_numPad = numPad)];
        
        /* Column 1 */
        MathKey *num7Key = [[MathKey alloc] initWithStyle:MathKeyStyleLight tag:MATH_NUM_KEY_TAG];
        [num7Key setTitle:@"7" portraitFont:numberFont_Portrait landscapeFont:numberFont_Landscape];
        [numPad addSubview:num7Key];
        
        MathKey *num4Key = [[MathKey alloc] initWithStyle:MathKeyStyleLight tag:MATH_NUM_KEY_TAG];
        [num4Key setTitle:@"4" portraitFont:numberFont_Portrait landscapeFont:numberFont_Landscape];
        [numPad addSubview:num4Key];
        
        MathKey *num1Key = [[MathKey alloc] initWithStyle:MathKeyStyleLight tag:MATH_NUM_KEY_TAG];
        [num1Key setTitle:@"1" portraitFont:numberFont_Portrait landscapeFont:numberFont_Landscape];
        [numPad addSubview:num1Key];
        
        MathKey *num0Key = [[MathKey alloc] initWithStyle:MathKeyStyleLight tag:MATH_NUM_KEY_TAG];
        [num0Key setTitle:@"0" portraitFont:numberFont_Portrait landscapeFont:numberFont_Landscape];
        [numPad addSubview:num0Key];
        
        /* Column 2 */
        MathKey *num8Key = [[MathKey alloc] initWithStyle:MathKeyStyleLight tag:MATH_NUM_KEY_TAG];
        [num8Key setTitle:@"8" portraitFont:numberFont_Portrait landscapeFont:numberFont_Landscape];
        [numPad addSubview:num8Key];
        
        MathKey *num5Key = [[MathKey alloc] initWithStyle:MathKeyStyleLight tag:MATH_NUM_KEY_TAG];
        [num5Key setTitle:@"5" portraitFont:numberFont_Portrait landscapeFont:numberFont_Landscape];
        [numPad addSubview:num5Key];
        
        MathKey *num2Key = [[MathKey alloc] initWithStyle:MathKeyStyleLight tag:MATH_NUM_KEY_TAG];
        [num2Key setTitle:@"2" portraitFont:numberFont_Portrait landscapeFont:numberFont_Landscape];
        [numPad addSubview:num2Key];
        
        MathKey *dotKey = [[MathKey alloc] initWithStyle:MathKeyStyleLight tag:MATH_NUM_KEY_TAG];
        [dotKey setTitle:@"." portraitFont:numberFont_Portrait landscapeFont:numberFont_Landscape];
        [numPad addSubview:dotKey];
        
        /* Column 3 */
        MathKey *num9Key = [[MathKey alloc] initWithStyle:MathKeyStyleLight tag:MATH_NUM_KEY_TAG];
        [num9Key setTitle:@"9" portraitFont:numberFont_Portrait landscapeFont:numberFont_Landscape];
        [numPad addSubview:num9Key];
        
        MathKey *num6Key = [[MathKey alloc] initWithStyle:MathKeyStyleLight tag:MATH_NUM_KEY_TAG];
        [num6Key setTitle:@"6" portraitFont:numberFont_Portrait landscapeFont:numberFont_Landscape];
        [numPad addSubview:num6Key];
        
        MathKey *num3Key = [[MathKey alloc] initWithStyle:MathKeyStyleLight tag:MATH_NUM_KEY_TAG];
        [num3Key setTitle:@"3" portraitFont:numberFont_Portrait landscapeFont:numberFont_Landscape];
        [numPad addSubview:num3Key];
        
        MathKey *expKey = [[MathKey alloc] initWithStyle:MathKeyStyleLight tag:MATH_EXP_KEY_TAG];
        [expKey setPortraitImage:[UIImage imageNamed:@"glyph-x10^[]-24"] landscapeImage:[UIImage imageNamed:@"glyph-x10^[]-18"]];
        [expKey setPortraitHighlightedImage:[UIImage imageNamed:@"glyph-x10^[]-24-white"] landscapeHighlightedImage:[UIImage imageNamed:@"glyph-x10^[]-18-white"]];
        [numPad addSubview:expKey];
        
        /* Column 4 */
        MathKey *parenthesesKey = [[MathKey alloc] initWithStyle:MathKeyStyleDark tag:MATH_PARENTHESES_KEY_TAG];
        [parenthesesKey setTitle:@"( )" portraitFont:symbolFont_Portrait landscapeFont:symbolFont_Landscape];
        [parenthesesKey setPortraitInsets:UIEdgeInsetsMake(0.0, 0.0, 4.0, 0.0) landscapeInsets:UIEdgeInsetsMake(0.0, 0.0, 2.0, 0.0)];
        me = parenthesesKey;
        [parenthesesKey setRefreshState:^(id<MathInput> inputtee) {
            FTAssert(inputtee);
            NSArray *selectedElements = [inputtee.expression elementsInRange:inputtee.selectedRange];
            me.takingOffMode = selectedElements.count == 1 && [selectedElements[0] isKindOfClass:[MathParentheses class]];
        }];
        {
            MathKey *absKey = [[MathKey alloc] initWithStyle:MathKeyStyleFlyout tag:MATH_ABS_KEY_TAG];
            [absKey setPortraitImage:[UIImage imageNamed:@"glyph-abs-30"] landscapeImage:[UIImage imageNamed:@"glyph-abs-20"]];
            [absKey setPortraitHighlightedImage:[UIImage imageNamed:@"glyph-abs-30-white"] landscapeHighlightedImage:[UIImage imageNamed:@"glyph-abs-20-white"]];
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
            [floorKey setPortraitImage:[UIImage imageNamed:@"glyph-floor-30"] landscapeImage:[UIImage imageNamed:@"glyph-floor-20"]];
            [floorKey setPortraitHighlightedImage:[UIImage imageNamed:@"glyph-floor-30-white"] landscapeHighlightedImage:[UIImage imageNamed:@"glyph-floor-20-white"]];
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
            [ceilKey setPortraitImage:[UIImage imageNamed:@"glyph-ceil-30"] landscapeImage:[UIImage imageNamed:@"glyph-ceil-20"]];
            [ceilKey setPortraitHighlightedImage:[UIImage imageNamed:@"glyph-ceil-30-white"] landscapeHighlightedImage:[UIImage imageNamed:@"glyph-ceil-20-white"]];
            me = ceilKey;
            [ceilKey setRefreshState:^(id<MathInput> inputtee) {
                FTAssert(inputtee);
                NSArray *selectedElements = [inputtee.expression elementsInRange:inputtee.selectedRange];
                me.takingOffMode = selectedElements.count == 1 && [selectedElements[0] isKindOfClass:[MathCeil class]];
            }];
            
            parenthesesKey.flyoutKeys = @[absKey, floorKey, ceilKey];
        }
        [numPad addSubview:parenthesesKey];
        
        MathKey *addKey = [[MathKey alloc] initWithStyle:MathKeyStyleDark tag:MATH_ADD_KEY_TAG];
        [addKey setTitle:@"+" portraitFont:operatorFont_Portrait landscapeFont:operatorFont_Landscape];
        [numPad addSubview:addKey];
        
        MathKey *mulKey = [[MathKey alloc] initWithStyle:MathKeyStyleDark tag:MATH_MUL_KEY_TAG];
        [mulKey setTitle:@"×" portraitFont:[operatorFont_Portrait fontWithSize:32.0] landscapeFont:[operatorFont_Landscape fontWithSize:22.0]];
        [numPad addSubview:mulKey];
        
        MathKey *percentKey = [[MathKey alloc] initWithStyle:MathKeyStyleDark tag:MATH_PERCENT_KEY_TAG];
        [percentKey setTitle:@"%" portraitFont:symbolFont_Portrait landscapeFont:symbolFont_Landscape];
        {
            MathKey *permilleKey = [[MathKey alloc] initWithStyle:MathKeyStyleFlyout tag:MATH_PERMILLE_KEY_TAG];
            [permilleKey setTitle:@"‰" portraitFont:symbolFont_Portrait landscapeFont:symbolFont_Landscape];
            
            percentKey.flyoutKeys = @[permilleKey];
        }
        [numPad addSubview:percentKey];
        
        /* Column 5 */
        MathKey *deleteKey = [[MathKey alloc] initWithStyle:MathKeyStyleDark tag:MATH_DELETE_KEY_TAG];
        [deleteKey setPortraitImage:[UIImage imageNamed:@"glyph-delete-24"] landscapeImage:[UIImage imageNamed:@"glyph-delete-18"]];
        [deleteKey setPortraitHighlightedImage:[UIImage imageNamed:@"glyph-delete-24-highlighted"] landscapeHighlightedImage:[UIImage imageNamed:@"glyph-delete-18-highlighted"]];
        [numPad addSubview:deleteKey];
        
        MathKey *subKey = [[MathKey alloc] initWithStyle:MathKeyStyleDark tag:MATH_SUB_KEY_TAG];
        [subKey setTitle:@"−" portraitFont:operatorFont_Portrait landscapeFont:operatorFont_Landscape];
        [numPad addSubview:subKey];
        
        MathKey *divKey = [[MathKey alloc] initWithStyle:MathKeyStyleDark tag:MATH_DIV_KEY_TAG];
        [divKey setTitle:@"/" portraitFont:operatorFont_Portrait landscapeFont:operatorFont_Landscape];
        {
            MathKey *fractionKey = [[MathKey alloc] initWithStyle:MathKeyStyleFlyout tag:MATH_FRACTION_KEY_TAG];
            [fractionKey setPortraitImage:[UIImage imageNamed:@"glyph-1|[]-30"] landscapeImage:[UIImage imageNamed:@"glyph-1|[]-20"]];
            [fractionKey setPortraitHighlightedImage:[UIImage imageNamed:@"glyph-1|[]-30-white"] landscapeHighlightedImage:[UIImage imageNamed:@"glyph-1|[]-20-white"]];
            divKey.alternativeKey = fractionKey;
            
            MathKey *fraction1Key = [[MathKey alloc] initWithStyle:MathKeyStyleFlyout tag:MATH_FRACTION1_KEY_TAG];
            me = fraction1Key;
            [fraction1Key setRefreshState:^(id<MathInput> inputtee) {
                FTAssert(inputtee);
                if (inputtee.selectedRange.selectionLength) {
                    [me setPortraitImage:[UIImage imageNamed:@"glyph-[]|#-30"] landscapeImage:[UIImage imageNamed:@"glyph-[]|#-20"]];
                    [me setPortraitHighlightedImage:[UIImage imageNamed:@"glyph-[]|#-30-white"] landscapeHighlightedImage:[UIImage imageNamed:@"glyph-[]|#-20-white"]];
                }
                else {
                    [me setPortraitImage:[UIImage imageNamed:@"glyph-[]|[]-30"] landscapeImage:[UIImage imageNamed:@"glyph-[]|[]-20"]];
                    [me setPortraitHighlightedImage:[UIImage imageNamed:@"glyph-[]|[]-30-white"] landscapeHighlightedImage:[UIImage imageNamed:@"glyph-[]|[]-20-white"]];
                }
            }];
            
            MathKey *fraction2Key = [[MathKey alloc] initWithStyle:MathKeyStyleFlyout tag:MATH_FRACTION2_KEY_TAG];
            me = fraction2Key;
            [fraction2Key setRefreshState:^(id<MathInput> inputtee) {
                FTAssert(inputtee);
                if (inputtee.selectedRange.selectionLength) {
                    [me setPortraitImage:[UIImage imageNamed:@"glyph-#|[]-30"] landscapeImage:[UIImage imageNamed:@"glyph-#|[]-20"]];
                    [me setPortraitHighlightedImage:[UIImage imageNamed:@"glyph-#|[]-30-white"] landscapeHighlightedImage:[UIImage imageNamed:@"glyph-#|[]-20-white"]];
                }
                else {
                    [me setPortraitImage:[UIImage imageNamed:@"glyph-@|[]-30"] landscapeImage:[UIImage imageNamed:@"glyph-@|[]-20"]];
                    [me setPortraitHighlightedImage:[UIImage imageNamed:@"glyph-@|[]-30-white"] landscapeHighlightedImage:[UIImage imageNamed:@"glyph-@|[]-20-white"]];
                }
            }];
            
            MathKey *modKey = [[MathKey alloc] initWithStyle:MathKeyStyleFlyout tag:MATH_MOD_KEY_TAG];
            [modKey setTitle:@"mod" portraitFont:functionFont_Portrait landscapeFont:functionFont_Landscape];
            
            divKey.flyoutKeys = @[fraction2Key, fraction1Key, modKey];
        }
        [numPad addSubview:divKey];
        
        MathKey *returnKey = [[MathKey alloc] initWithStyle:MathKeyStyleDark tag:MATH_RETURN_KEY_TAG];
        [returnKey setPortraitImage:[UIImage imageNamed:@"glyph-return-24"] landscapeImage:[UIImage imageNamed:@"glyph-return-18"]];
        [returnKey setPortraitHighlightedImage:[UIImage imageNamed:@"glyph-return-24-highlighted"] landscapeHighlightedImage:[UIImage imageNamed:@"glyph-return-18-highlighted"]];
        [returnKey setPortraitDisabledImage:[UIImage imageNamed:@"glyph-return-24-disabled"] landscapeDisabledImage:[UIImage imageNamed:@"glyph-return-18-disabled"]];
        me = returnKey;
        [returnKey setRefreshState:^(id<MathInput> inputtee) {
            FTAssert(inputtee);
            me.enabled = inputtee.expression.elements.count != 0;
        }];
        [numPad addSubview:returnKey];
        
        /************** fxPad **************/
        UIView *fxPad = [[UIView alloc] initWithFrame:CGRectZero];
        fxPad.clipsToBounds = YES;
        [keypad addSubview:(_fxPad = fxPad)];
        
        /* Column 1 */
        MathKey *arcsinKey = [[MathKey alloc] initWithStyle:MathKeyStyleDark tag:MATH_ARCSIN_KEY_TAG];
        [arcsinKey setTitle:@"arcsin" portraitFont:[functionFont_Portrait fontWithSize:20.0] landscapeFont:[functionFont_Landscape fontWithSize:(g_isClassic ? 15.0 : 18.0)]];
        {
            MathKey *arcsinhKey = [[MathKey alloc] initWithStyle:MathKeyStyleFlyout tag:MATH_ARCSINH_KEY_TAG];
            [arcsinhKey setTitle:@"arcsinh" portraitFont:[functionFont_Portrait fontWithSize:19.0] landscapeFont:[functionFont_Landscape fontWithSize:(g_isClassic ? 14.0 : 17.0)]];
            
            arcsinKey.flyoutKeys = @[arcsinhKey];
        }
        [fxPad addSubview:arcsinKey];
        
        MathKey *arccosKey = [[MathKey alloc] initWithStyle:MathKeyStyleDark tag:MATH_ARCCOS_KEY_TAG];
        [arccosKey setTitle:@"arccos" portraitFont:[functionFont_Portrait fontWithSize:20.0] landscapeFont:[functionFont_Landscape fontWithSize:(g_isClassic ? 15.0 : 18.0)]];
        {
            MathKey *arccoshKey = [[MathKey alloc] initWithStyle:MathKeyStyleFlyout tag:MATH_ARCCOSH_KEY_TAG];
            [arccoshKey setTitle:@"arccosh" portraitFont:[functionFont_Portrait fontWithSize:19.0] landscapeFont:[functionFont_Landscape fontWithSize:(g_isClassic ? 14.0 : 17.0)]];
            
            arccosKey.flyoutKeys = @[arccoshKey];
        }
        [fxPad addSubview:arccosKey];
        
        MathKey *arctanKey = [[MathKey alloc] initWithStyle:MathKeyStyleDark tag:MATH_ARCTAN_KEY_TAG];
        [arctanKey setTitle:@"arctan" portraitFont:[functionFont_Portrait fontWithSize:20.0] landscapeFont:[functionFont_Landscape fontWithSize:(g_isClassic ? 15.0 : 18.0)]];
        {
            MathKey *arctanhKey = [[MathKey alloc] initWithStyle:MathKeyStyleFlyout tag:MATH_ARCTANH_KEY_TAG];
            [arctanhKey setTitle:@"arctanh" portraitFont:[functionFont_Portrait fontWithSize:19.0] landscapeFont:[functionFont_Landscape fontWithSize:(g_isClassic ? 14.0 : 17.0)]];
            
            arctanKey.flyoutKeys = @[arctanhKey];
        }
        [fxPad addSubview:arctanKey];
        
        MathKey *degreeKey = [[MathKey alloc] initWithStyle:MathKeyStyleDark tag:MATH_DEGREE_KEY_TAG];
        [degreeKey setTitle:@"°" portraitFont:[symbolFont_Portrait fontWithSize:22.0] landscapeFont:[symbolFont_Landscape fontWithSize:16.0]];
        [fxPad addSubview:degreeKey];
        
        /* Column 2 */
        MathKey *sinKey = [[MathKey alloc] initWithStyle:MathKeyStyleDark tag:MATH_SIN_KEY_TAG];
        [sinKey setTitle:@"sin" portraitFont:functionFont_Portrait landscapeFont:functionFont_Landscape];
        {
            MathKey *sinhKey = [[MathKey alloc] initWithStyle:MathKeyStyleFlyout tag:MATH_SINH_KEY_TAG];
            [sinhKey setTitle:@"sinh" portraitFont:functionFont_Portrait landscapeFont:functionFont_Landscape];
            
            sinKey.flyoutKeys = @[sinhKey];
        }
        [fxPad addSubview:sinKey];
        
        MathKey *cosKey = [[MathKey alloc] initWithStyle:MathKeyStyleDark tag:MATH_COS_KEY_TAG];
        [cosKey setTitle:@"cos" portraitFont:functionFont_Portrait landscapeFont:functionFont_Landscape];
        {
            MathKey *coshKey = [[MathKey alloc] initWithStyle:MathKeyStyleFlyout tag:MATH_COSH_KEY_TAG];
            [coshKey setTitle:@"cosh" portraitFont:functionFont_Portrait landscapeFont:functionFont_Landscape];
            
            cosKey.flyoutKeys = @[coshKey];
        }
        [fxPad addSubview:cosKey];
        
        MathKey *tanKey = [[MathKey alloc] initWithStyle:MathKeyStyleDark tag:MATH_TAN_KEY_TAG];
        [tanKey setTitle:@"tan" portraitFont:functionFont_Portrait landscapeFont:functionFont_Landscape];
        {
            MathKey *tanhKey = [[MathKey alloc] initWithStyle:MathKeyStyleFlyout tag:MATH_TANH_KEY_TAG];
            [tanhKey setTitle:@"tanh" portraitFont:functionFont_Portrait landscapeFont:functionFont_Landscape];
            
            tanKey.flyoutKeys = @[tanhKey];
        }
        [fxPad addSubview:tanKey];
        
        MathKey *piKey = [[MathKey alloc] initWithStyle:MathKeyStyleDark tag:MATH_PI_KEY_TAG];
        [piKey setTitle:@"π" portraitFont:variableFont_Portrait landscapeFont:variableFont_Landscape];
        {
            MathKey *piOver2Key = [[MathKey alloc] initWithStyle:MathKeyStyleFlyout tag:MATH_PI_OVER_2_TAG];
            [piOver2Key setPortraitImage:[UIImage imageNamed:@"glyph-π_over_2-20"] landscapeImage:[UIImage imageNamed:@"glyph-π_over_2-14"]];
            [piOver2Key setPortraitHighlightedImage:[UIImage imageNamed:@"glyph-π_over_2-20-white"] landscapeHighlightedImage:[UIImage imageNamed:@"glyph-π_over_2-14-white"]];
            
            MathKey *piOver3Key = [[MathKey alloc] initWithStyle:MathKeyStyleFlyout tag:MATH_PI_OVER_3_TAG];
            [piOver3Key setPortraitImage:[UIImage imageNamed:@"glyph-π_over_3-20"] landscapeImage:[UIImage imageNamed:@"glyph-π_over_3-14"]];
            [piOver3Key setPortraitHighlightedImage:[UIImage imageNamed:@"glyph-π_over_3-20-white"] landscapeHighlightedImage:[UIImage imageNamed:@"glyph-π_over_3-14-white"]];
            
            MathKey *piOver4Key = [[MathKey alloc] initWithStyle:MathKeyStyleFlyout tag:MATH_PI_OVER_4_TAG];
            [piOver4Key setPortraitImage:[UIImage imageNamed:@"glyph-π_over_4-20"] landscapeImage:[UIImage imageNamed:@"glyph-π_over_4-14"]];
            [piOver4Key setPortraitHighlightedImage:[UIImage imageNamed:@"glyph-π_over_4-20-white"] landscapeHighlightedImage:[UIImage imageNamed:@"glyph-π_over_4-14-white"]];
            
            MathKey *piOver6Key = [[MathKey alloc] initWithStyle:MathKeyStyleFlyout tag:MATH_PI_OVER_6_TAG];
            [piOver6Key setPortraitImage:[UIImage imageNamed:@"glyph-π_over_6-20"] landscapeImage:[UIImage imageNamed:@"glyph-π_over_6-14"]];
            [piOver6Key setPortraitHighlightedImage:[UIImage imageNamed:@"glyph-π_over_6-20-white"] landscapeHighlightedImage:[UIImage imageNamed:@"glyph-π_over_6-14-white"]];
            
            MathKey *twoPiOver3Key = [[MathKey alloc] initWithStyle:MathKeyStyleFlyout tag:MATH_2PI_OVER_3_TAG];
            [twoPiOver3Key setPortraitImage:[UIImage imageNamed:@"glyph-2π_over_3-20"] landscapeImage:[UIImage imageNamed:@"glyph-2π_over_3-14"]];
            [twoPiOver3Key setPortraitHighlightedImage:[UIImage imageNamed:@"glyph-2π_over_3-20-white"] landscapeHighlightedImage:[UIImage imageNamed:@"glyph-2π_over_3-14-white"]];
            
            MathKey *fourPiOver3Key = [[MathKey alloc] initWithStyle:MathKeyStyleFlyout tag:MATH_4PI_OVER_3_TAG];
            [fourPiOver3Key setPortraitImage:[UIImage imageNamed:@"glyph-4π_over_3-20"] landscapeImage:[UIImage imageNamed:@"glyph-4π_over_3-14"]];
            [fourPiOver3Key setPortraitHighlightedImage:[UIImage imageNamed:@"glyph-4π_over_3-20-white"] landscapeHighlightedImage:[UIImage imageNamed:@"glyph-4π_over_3-14-white"]];
            
            piKey.flyoutKeys = @[piOver6Key, piOver4Key, piOver2Key, piOver3Key, twoPiOver3Key, fourPiOver3Key];
        }
        [fxPad addSubview:piKey];
        
        /* Column 3 */
        MathKey *log10Key = [[MathKey alloc] initWithStyle:MathKeyStyleDark tag:MATH_LOG10_KEY_TAG];
        [log10Key setTitle:@"log" portraitFont:functionFont_Portrait landscapeFont:functionFont_Landscape];
        [fxPad addSubview:log10Key];
        
        MathKey *lnKey = [[MathKey alloc] initWithStyle:MathKeyStyleDark tag:MATH_LN_KEY_TAG];
        [lnKey setTitle:@"ln" portraitFont:functionFont_Portrait landscapeFont:functionFont_Landscape];
        [fxPad addSubview:lnKey];
        
        MathKey *log2Key = [[MathKey alloc] initWithStyle:MathKeyStyleDark tag:MATH_LOG2_KEY_TAG];
        [log2Key setPortraitImage:[UIImage imageNamed:@"glyph-log2-24"] landscapeImage:[UIImage imageNamed:@"glyph-log2-18"]];
        [log2Key setPortraitHighlightedImage:[UIImage imageNamed:@"glyph-log2-24-white"] landscapeHighlightedImage:[UIImage imageNamed:@"glyph-log2-18-white"]];
        [log2Key setPortraitInsets:UIEdgeInsetsMake(4.0, 0.0, 0.0, 0.0) landscapeInsets:UIEdgeInsetsMake(2.0, 0.0, 0.0, 0.0)];
        {
            MathKey *logKey = [[MathKey alloc] initWithStyle:MathKeyStyleFlyout tag:MATH_LOG_KEY_TAG];
            [logKey setPortraitImage:[UIImage imageNamed:@"glyph-log[]-24"] landscapeImage:[UIImage imageNamed:@"glyph-log[]-18"]];
            [logKey setPortraitHighlightedImage:[UIImage imageNamed:@"glyph-log[]-24-white"] landscapeHighlightedImage:[UIImage imageNamed:@"glyph-log[]-18-white"]];
            [logKey setPortraitInsets:UIEdgeInsetsMake(4.0, 0.0, 0.0, 0.0) landscapeInsets:UIEdgeInsetsMake(2.0, 0.0, 0.0, 0.0)];
            
            log2Key.flyoutKeys = @[logKey];
        }
        [fxPad addSubview:log2Key];
        
        MathKey *eKey = [[MathKey alloc] initWithStyle:MathKeyStyleDark tag:MATH_E_KEY_TAG];
        [eKey setTitle:@"e" portraitFont:variableFont_Portrait landscapeFont:variableFont_Landscape];
        [fxPad addSubview:eKey];
        
        /* Column 4 */
        MathKey *sqrtKey = [[MathKey alloc] initWithStyle:MathKeyStyleDark tag:MATH_SQRT_KEY_TAG];
        [sqrtKey setPortraitImage:[UIImage imageNamed:@"glyph-sqrt-24"] landscapeImage:[UIImage imageNamed:@"glyph-sqrt-18"]];
        [sqrtKey setPortraitHighlightedImage:[UIImage imageNamed:@"glyph-sqrt-24-white"] landscapeHighlightedImage:[UIImage imageNamed:@"glyph-sqrt-18-white"]];
        me = sqrtKey;
        [sqrtKey setRefreshState:^(id<MathInput> inputtee) {
            FTAssert(inputtee);
            NSArray *selectedElements = [inputtee.expression elementsInRange:inputtee.selectedRange];
            me.takingOffMode = selectedElements.count == 1 && [selectedElements[0] isKindOfClass:[MathSqrt class]];
        }];
        {
            MathKey *cbrtKey = [[MathKey alloc] initWithStyle:MathKeyStyleFlyout tag:MATH_CBRT_KEY_TAG];
            [cbrtKey setPortraitImage:[UIImage imageNamed:@"glyph-cbrt-24"] landscapeImage:[UIImage imageNamed:@"glyph-cbrt-18"]];
            [cbrtKey setPortraitHighlightedImage:[UIImage imageNamed:@"glyph-cbrt-24-white"] landscapeHighlightedImage:[UIImage imageNamed:@"glyph-cbrt-18-white"]];
            me = cbrtKey;
            [cbrtKey setRefreshState:^(id<MathInput> inputtee) {
                FTAssert(inputtee);
                NSArray *selectedElements = [inputtee.expression elementsInRange:inputtee.selectedRange];
                MathRoot *theRoot;
                MathNumber *theIndex;
                me.takingOffMode = selectedElements.count == 1 && [(theRoot = selectedElements[0]) isKindOfClass:[MathRoot class]] && theRoot.index.elements.count == 1 && [(theIndex = theRoot.index.elements[0]) isKindOfClass:[MathNumber class]] && [theIndex.string isEqualToString:@"3"];
            }];
            
            MathKey *rootKey = [[MathKey alloc] initWithStyle:MathKeyStyleFlyout tag:MATH_ROOT_KEY_TAG];
            [rootKey setPortraitImage:[UIImage imageNamed:@"glyph-root-24"] landscapeImage:[UIImage imageNamed:@"glyph-root-18"]];
            [rootKey setPortraitHighlightedImage:[UIImage imageNamed:@"glyph-root-24-white"] landscapeHighlightedImage:[UIImage imageNamed:@"glyph-root-18-white"]];
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
        [fxPad addSubview:sqrtKey];
        
        MathKey *squareKey = [[MathKey alloc] initWithStyle:MathKeyStyleDark tag:MATH_SQUARE_KEY_TAG];
        [squareKey setPortraitImage:[UIImage imageNamed:@"glyph-x^2-24"] landscapeImage:[UIImage imageNamed:@"glyph-x^2-18"]];
        [squareKey setPortraitHighlightedImage:[UIImage imageNamed:@"glyph-x^2-24-white"] landscapeHighlightedImage:[UIImage imageNamed:@"glyph-x^2-18-white"]];
        [squareKey setPortraitInsets:UIEdgeInsetsMake(0.0, 0.0, 3.0, 0.0) landscapeInsets:UIEdgeInsetsMake(0.0, 0.0, 2.0, 0.0)];
        [fxPad addSubview:squareKey];
        
        MathKey *cubicKey = [[MathKey alloc] initWithStyle:MathKeyStyleDark tag:MATH_CUBIC_KEY_TAG];
        [cubicKey setPortraitImage:[UIImage imageNamed:@"glyph-x^3-24"] landscapeImage:[UIImage imageNamed:@"glyph-x^3-18"]];
        [cubicKey setPortraitHighlightedImage:[UIImage imageNamed:@"glyph-x^3-24-white"] landscapeHighlightedImage:[UIImage imageNamed:@"glyph-x^3-18-white"]];
        [cubicKey setPortraitInsets:UIEdgeInsetsMake(0.0, 0.0, 3.0, 0.0) landscapeInsets:UIEdgeInsetsMake(0.0, 0.0, 2.0, 0.0)];
        [fxPad addSubview:cubicKey];
        
        MathKey *powKey = [[MathKey alloc] initWithStyle:MathKeyStyleDark tag:MATH_POW_KEY_TAG];
        [powKey setPortraitImage:[UIImage imageNamed:@"glyph-x^[]-24"] landscapeImage:[UIImage imageNamed:@"glyph-x^[]-18"]];
        [powKey setPortraitHighlightedImage:[UIImage imageNamed:@"glyph-x^[]-24-white"] landscapeHighlightedImage:[UIImage imageNamed:@"glyph-x^[]-18-white"]];
        [powKey setPortraitInsets:UIEdgeInsetsMake(0.0, 0.0, 3.0, 0.0) landscapeInsets:UIEdgeInsetsMake(0.0, 0.0, 2.0, 0.0)];
        [fxPad addSubview:powKey];
        
        /* Column 5 */
        MathKey *factorialKey = [[MathKey alloc] initWithStyle:MathKeyStyleDark tag:MATH_FACTORIAL_KEY_TAG];
        [factorialKey setTitle:@"!" portraitFont:symbolFont_Portrait landscapeFont:symbolFont_Landscape];
        [fxPad addSubview:factorialKey];
        
        MathKey *permutationKey = [[MathKey alloc] initWithStyle:MathKeyStyleDark tag:MATH_PERMUTATION_KEY_TAG];
        [permutationKey setTitle:@"P(n,k)" portraitFont:[functionFont_Portrait fontWithSize:19.0] landscapeFont:[functionFont_Landscape fontWithSize:(g_isClassic ? 14.0 : 16.0)]];
        [fxPad addSubview:permutationKey];
        
        MathKey *combinationKey = [[MathKey alloc] initWithStyle:MathKeyStyleDark tag:MATH_COMBINATION_KEY_TAG];
        [combinationKey setTitle:@"C(n,k)" portraitFont:[functionFont_Portrait fontWithSize:19.0] landscapeFont:[functionFont_Landscape fontWithSize:(g_isClassic ? 14.0 : 16.0)]];
        [fxPad addSubview:combinationKey];
        
        MathKey *randKey = [[MathKey alloc] initWithStyle:MathKeyStyleDark tag:MATH_RAND_KEY_TAG];
        NSString *title = NSLocalizedString(@"Rand", nil);
        BOOL isZh = [title isEqualToString:@"随机数"];
        [randKey setTitle:title portraitFont:[functionFont_Portrait fontWithSize:(19.0 - 3.0 * isZh)] landscapeFont:[functionFont_Landscape fontWithSize:(g_isClassic ? 14.0 - 2.0 * isZh : 16.0 - 2.0 * isZh)]];
        [randKey setPortraitInsets:UIEdgeInsetsMake(3.0, 0.0, 0.0, 0.0) landscapeInsets:UIEdgeInsetsMake(3.0, 0.0, 0.0, 0.0)];
        [fxPad addSubview:randKey];
        
        /**************************************************************************/
        [super setStaticKeys:[numPad.subviews arrayByAddingObjectsFromArray:fxPad.subviews]];
        
        UIPageControl *pageControl = [[UIPageControl alloc] initWithFrame:CGRectZero];
        pageControl.translatesAutoresizingMaskIntoConstraints = NO;
        pageControl.userInteractionEnabled = NO;
        pageControl.pageIndicatorTintColor = [UIColor colorWithWhite:0.0 alpha:0.3];
        pageControl.currentPageIndicatorTintColor = [UIColor blackColor];
        pageControl.numberOfPages = 2;
        [self addSubview:(_pageControl = pageControl)];
        
        NSDictionary *views = NSDictionaryOfVariableBindings(scrollView, pageControl);
        [NSLayoutConstraint activateConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|[scrollView]|" options:0 metrics:nil views:views]];
        [NSLayoutConstraint activateConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[scrollView]|" options:0 metrics:nil views:views]];
        [NSLayoutConstraint activateConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|[pageControl]|" options:0 metrics:nil views:views]];
        [NSLayoutConstraint activateConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[pageControl(==8.0)]-(-5.0)-|" options:0 metrics:nil views:views]];
    }
    return self;
}

- (void)traitCollectionDidChange:(UITraitCollection *)previousTraitCollection
{
    [super traitCollectionDidChange:previousTraitCollection];
    
    [self invalidateIntrinsicContentSize];
}

- (CGSize)intrinsicContentSize
{
    CGSize windowSize = CGRectStandardize(self.window.bounds).size;
    CGFloat height;
    if (self.traitCollection.verticalSizeClass == UIUserInterfaceSizeClassRegular) {
        /* Portrait */
        height = 224.0 + (windowSize.width - 320.0) / 2.0;
    }
    else {
        /* Landscape */
        height = 170.0 + (windowSize.height - 320.0) / 4.0;
    }
    height = trunc(height / 2.0) * 2.0;  // Make it even.
    return CGSizeMake(UIViewNoIntrinsicMetric, height);
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    static CGSize s_previousSize;
    CGSize size = CGRectStandardize(self.bounds).size;
    if (CGSizeEqualToSize(size, s_previousSize)) return;
    s_previousSize = size;
    
    CGFloat separatorThickness = [MathKeyboard separatorThickness];
    CGFloat keyHeight = size.height / 4.0 + separatorThickness;
    FTAssert_DEBUG(keyHeight * 2.0 == trunc(keyHeight * 2.0));  //! ASSUMPTION: display scale = 2.0.
    CGFloat numKeyWidth[5];
    CGFloat fxKeyWidth[5];
    
    if (self.traitCollection.verticalSizeClass == UIUserInterfaceSizeClassRegular) {
        /* Portrait */
        CGFloat integralKeyWidth = floor((size.width - 4.0 * separatorThickness) * 2.0 / 5.0) / 2.0 + 2.0 * separatorThickness;
        FTAssert_DEBUG(integralKeyWidth * 2.0 == trunc(integralKeyWidth * 2.0));  //! ASSUMPTION: display scale = 2.0.
        for (uint8_t i = 0; i < 5; i++) {
            fxKeyWidth[i] = integralKeyWidth;
            numKeyWidth[i] = integralKeyWidth;
        }
        CGFloat remainderWidth = size.width - 5.0 * integralKeyWidth + 6.0 * separatorThickness;
        fxKeyWidth[0] += remainderWidth;
        switch ((int)(remainderWidth * 2.0)) {
            case 0: {
                break;
            }
            case 1: {
                numKeyWidth[0] += 0.5;
                break;
            }
            case 2: {
                numKeyWidth[0] += 0.5;
                numKeyWidth[4] += 0.5;
                break;
            }
            case 3: {
                numKeyWidth[0] += 0.5;
                numKeyWidth[1] += 0.5;
                numKeyWidth[2] += 0.5;
                break;
            }
            case 4: {
                numKeyWidth[0] += 0.5;
                numKeyWidth[1] += 0.5;
                numKeyWidth[2] += 0.5;
                numKeyWidth[4] += 0.5;
                break;
            }
            default: {
                FTAssert_DEBUG(NO);
                break;
            }
        }
        
        self.keypad.frame = CGRectMake(0.0, 0.0, 2.0 * size.width, size.height);
        self.fxPad.frame = CGRectMake(0.0, 0.0, size.width, size.height);
        self.numPad.frame = CGRectMake(size.width, 0.0, size.width, size.height);
        self.scrollView.contentSize = CGRectStandardize(self.keypad.frame).size;
        self.scrollView.contentOffset = CGRectStandardize(self.numPad.frame).origin;
        self.scrollView.scrollEnabled = YES;
        self.pageControl.hidden = NO;
    }
    else {
        /* Landscape */
        CGFloat integralKeyWidth = floor((size.width - 9.0 * separatorThickness) * 2.0 / 10.0) / 2.0 + 2.0 * separatorThickness;
        FTAssert_DEBUG(integralKeyWidth * 2.0 == trunc(integralKeyWidth * 2.0));  //! ASSUMPTION: display scale = 2.0.
        CGFloat remainderWidth = size.width - 10.0 * integralKeyWidth + 11.0 * separatorThickness;
        while (!g_isClassic && integralKeyWidth + remainderWidth < 64.0/* Minimum width for 'arccos' key */) {
            integralKeyWidth -= 0.5;  //! ASSUMPTION: display scale = 2.0.
            remainderWidth += 9.0 * 0.5;
        }
        for (uint8_t i = 0; i < 5; i++) {
            fxKeyWidth[i] = integralKeyWidth;
            numKeyWidth[i] = integralKeyWidth;
        }
        fxKeyWidth[0] += remainderWidth;
        
        self.keypad.frame = CGRectMake(0.0, 0.0, size.width, size.height);
        CGFloat fxPadWidth = fxKeyWidth[0] + fxKeyWidth[1] + fxKeyWidth[2] + fxKeyWidth[3] + fxKeyWidth[4] - 5.0 * separatorThickness;
        self.fxPad.frame = CGRectMake(0.0, 0.0, fxPadWidth, size.height);
        self.numPad.frame = CGRectMake(fxPadWidth, 0.0, size.width - fxPadWidth, size.height);
        self.scrollView.contentSize = size;
        self.scrollView.contentOffset = CGPointZero;
        self.scrollView.scrollEnabled = NO;
        self.pageControl.hidden = YES;
    }
    
    NSUInteger row = 0;
    NSUInteger col = 0;
    CGFloat originX = -separatorThickness;
    for (MathKey *key in [self.numPad subviews]) {
        key.frame = CGRectMake(originX, (keyHeight - separatorThickness) * row, numKeyWidth[col], keyHeight);
        if (++row == 4) {
            row = 0;
            originX += numKeyWidth[col] - separatorThickness;
            col++;
        }
        
        [key updateContent];
    }
    
    row = 0;
    col = 0;
    originX = -separatorThickness;
    for (MathKey *key in [self.fxPad subviews]) {
        key.frame = CGRectMake(originX, (keyHeight - separatorThickness) * row, fxKeyWidth[col], keyHeight);
        if (++row == 4) {
            row = 0;
            originX += fxKeyWidth[col] - separatorThickness;
            col++;
        }
        
        [key updateContent];
    }
}

- (void)scrollToNumPad
{
    if (![self.pageControl isHidden]) {
        //! WORKAROUND: [UIScrollView setContentOffset:animated:] behaves erratic since iOS 7.1, which sometimes stops scrolling to the destination, but scrolls back to the start.
        [UIView animateWithDuration:0.25 animations:^{
            self.scrollView.contentOffset = CGRectStandardize(self.numPad.frame).origin;
        }];
    }
}

#pragma mark -

- (void)scrollViewDidScroll:(MathKeypadScrollView *)scrollView
{
    CGFloat pageWidth = CGRectGetWidth(scrollView.bounds);
    NSUInteger page = floor((scrollView.contentOffset.x - pageWidth / 2) / pageWidth) + 1;
    self.pageControl.currentPage = page;
}

- (NSInteger)colIndexOfKey:(MathKey *)key
{
    static const NSInteger colIndexes_Portrait[5] = {0, 1, 2, -2, -1};
    static const NSInteger colIndexes_Landscape[10] = {0, 1, 2, 2, 2, -3, -3, -3, -2, -1};

    BOOL isLandscape = UIInterfaceOrientationIsLandscape([UIApplication sharedApplication].statusBarOrientation);
    
    NSUInteger indexOfKey = 0;
    for (UIView *subview in key.superview.subviews) {
        if (subview == key) {
            break;
        }
        indexOfKey++;
    }
    
    if (isLandscape) {
        if (key.superview == self.numPad) {
            indexOfKey += 4 * 5;
        }
        return colIndexes_Landscape[indexOfKey / 4];
    }
    else {
        return colIndexes_Portrait[indexOfKey / 4];
    }
}

@end
