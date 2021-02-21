//
//  MyDecimal.h
//  iCalculator
//
//  Created by curie on 4/28/14.
//  Copyright (c) 2014 Fish Tribe. All rights reserved.
//

#import "decNumber/decQuad.h"


extern decContext DQ_set;

extern const decQuad DQ_posInf;
extern const decQuad DQ_negInf;
extern const decQuad DQ_NaN;

extern const decQuad Dec_0p1;
extern const decQuad Dec_1;
extern const decQuad Dec_2;
extern const decQuad Dec_3;
extern const decQuad Dec_10;
extern const decQuad Dec_100;
extern const decQuad Dec_180;
extern const decQuad Dec_1000;

extern const decQuad Dec_e;
extern const decQuad Dec_pi;
extern const decQuad Dec_pi_2;
extern const decQuad Dec_pi_180;

double IEEE754_dec2bin(const decQuad *);
void IEEE754_bin2dec(double, decQuad *);

void Dec_init(void);
