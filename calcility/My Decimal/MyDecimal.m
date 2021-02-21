//
//  MyDecimal.m
//  iCalculator
//
//  Created by curie on 4/28/14.
//  Copyright (c) 2014 Fish Tribe. All rights reserved.
//

#import "decNumber/decQuad.h"


decContext DQ_set;

decQuad DQ_posInf;
decQuad DQ_negInf;
decQuad DQ_NaN;

decQuad Dec_0p1;
decQuad Dec_1;
decQuad Dec_2;
decQuad Dec_3;
decQuad Dec_10;
decQuad Dec_100;
decQuad Dec_180;
decQuad Dec_1000;

decQuad Dec_e;
decQuad Dec_pi;
decQuad Dec_pi_2;
decQuad Dec_pi_180;

double IEEE754_dec2bin(const decQuad *d)
{
    char str[DECQUAD_String];
    decQuadToString(d, str);
    return strtod(str, NULL);
}

void IEEE754_bin2dec(double b, decQuad *d)
{
    char str[DECQUAD_String];
    sprintf(str, "%.17g", b);
    decQuadFromString(d, str, &DQ_set);
}

void Dec_init(void)
{
    FTAssert_DEBUG(decContextTestEndian(1) == 0);

    decContextDefault(&DQ_set, DEC_INIT_DECQUAD);
    
    decQuadFromString(&DQ_posInf, "+Inf", &DQ_set);
    decQuadFromString(&DQ_negInf, "-Inf", &DQ_set);
    decQuadFromString(&DQ_NaN, "NaN", &DQ_set);
    
    decQuadFromString(&Dec_0p1, "0.1", &DQ_set);
    decQuadFromUInt32(&Dec_1, 1);
    decQuadFromUInt32(&Dec_2, 2);
    decQuadFromUInt32(&Dec_3, 3);
    decQuadFromUInt32(&Dec_10, 10);
    decQuadFromUInt32(&Dec_100, 100);
    decQuadFromUInt32(&Dec_180, 180);
    decQuadFromUInt32(&Dec_1000, 1000);

    IEEE754_bin2dec(exp(1.0), &Dec_e);
    IEEE754_bin2dec(acos(-1.0), &Dec_pi);
    decQuadDivide(&Dec_pi_2, &Dec_pi, &Dec_2, &DQ_set);
    decQuadDivide(&Dec_pi_180, &Dec_pi, &Dec_180, &DQ_set);
    
#ifdef DEBUG
    decQuadShow(&Dec_pi, "π");
    decQuadShow(&Dec_e, "e");
#endif
}
