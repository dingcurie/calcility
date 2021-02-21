//
//  FTTimeProfiler.m
//
//  Created by curie on 13-9-26.
//  Copyright (c) 2013年 Fish Tribe. All rights reserved.
//

#import "FTTimeProfiler.h"
#import <mach/mach_time.h>
#import <inttypes.h>


static uint64_t l_timestamps[256];
static const char *l_msgs[256];
static int l_i;
static int l_indent;


static
void report(void)
{
    static struct mach_timebase_info tbi;
    if (tbi.denom == 0) {
        mach_timebase_info(&tbi);
        tbi.denom *= 1000;
    }
    
    NSLog(@"--------------------------------------------------");
    uint64_t beginTimestampStack[128];
    for (int level = 0, i = 0; i < l_i; i++) {
        if (l_msgs[i] == NULL) {
            // a Begin
            beginTimestampStack[level] = l_timestamps[i];
            NSLog(@"%*s", level * 2 + 1, "^");
            level++;
        }
        else {
            // an End
            level--;
            uint64_t timeElapsed = l_timestamps[i] - beginTimestampStack[level];  //! SUPPRESS: The right operand of '-' is a garbage value
            NSLog(@"%*s %"PRIu64"us [%s]", level * 2 + 1, "~", timeElapsed * tbi.numer / tbi.denom, l_msgs[i]);
        }
    }
    
    memset(l_msgs, 0, sizeof(l_msgs[0]) * l_i);
    l_i = 0;
}

void FTTimeProfiler_begin(void)
{
    l_timestamps[l_i] = mach_absolute_time();
    l_i++;
    l_indent++;
}

void FTTimeProfiler_end(const char *msg)
{
    l_timestamps[l_i] = mach_absolute_time();
    l_msgs[l_i] = msg;
    l_i++;
    if (--l_indent == 0) {
        report();
    }
}
