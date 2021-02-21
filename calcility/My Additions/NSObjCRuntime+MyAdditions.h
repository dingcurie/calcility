//
//  NSObjCRuntime+MyAdditions.h
//
//  Created by curie on 7/31/14.
//  Copyright (c) 2014 Fish Tribe. All rights reserved.
//

#import <Foundation/NSObjCRuntime.h>


#ifdef DEBUG
#define NSLog_DEBUG(format, ...)  NSLog(format, ##__VA_ARGS__)
#else
#define NSLog_DEBUG(format, ...)  do {} while (0)
#endif
