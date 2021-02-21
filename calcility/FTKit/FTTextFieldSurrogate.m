//
//  FTTextFieldSurrogate.m
//  iCalculator
//
//  Created by curie on 2/11/15.
//  Copyright (c) 2015 Fish Tribe. All rights reserved.
//

#import "FTTextFieldSurrogate.h"


@implementation FTTextFieldSurrogate

+ (instancetype)surrogateForTextField:(UITextField *)aTextField
{
    FTTextFieldSurrogate *surrogate = [[self alloc] initWithFrame:aTextField.bounds];  //! WORKAROUND: If init with CGRectZero, the textField becoming first responder next will NOT scroll to the end if it has a lengthy text.
    surrogate.hidden = YES;
    surrogate.inputAccessoryView = aTextField.inputAccessoryView;
    surrogate.enablesReturnKeyAutomatically =aTextField.enablesReturnKeyAutomatically;
    surrogate.returnKeyType = aTextField.returnKeyType;
    surrogate.keyboardAppearance = aTextField.keyboardAppearance;
    surrogate.keyboardType = aTextField.keyboardType;
    return surrogate;
}

- (BOOL)becomeFirstResponder
{
    [[UIApplication sharedApplication].keyWindow addSubview:self];
    
    if (![super becomeFirstResponder]) {
        [self removeFromSuperview];
        return NO;
    }
    return YES;
}

- (BOOL)resignFirstResponder
{
    if ([super resignFirstResponder]) {
        [self performSelector:@selector(removeFromSuperview) withObject:nil afterDelay:0.0];
        return YES;
    }
    return NO;
}

@end
