//
//  FTUtils.h
//
//  Created by curie on 6/11/14.
//  Copyright (c) 2014 Fish Tribe. All rights reserved.
//


#define FTAssert(condition, ...)  do { \
    if (!(condition)) {	\
        id objs[] = {__VA_ARGS__}; \
        for (NSUInteger i = 0; i < sizeof(objs) / sizeof(*objs); i++) { \
            NSLog(@"%@", objs[i]); \
        } \
        abort(); \
    } \
} while (0)


#ifdef DEBUG
#define FTAssert_DEBUG(condition, ...)  FTAssert(condition, ##__VA_ARGS__)
#else
#define FTAssert_DEBUG(condition, ...)  do {} while (0)
#endif


extern NSMutableDictionary *g_errors;

#define FTRegisterError(error)  do { \
    if (g_errors == nil) g_errors = [NSMutableDictionary dictionaryWithCapacity:0]; \
    g_errors[[NSString stringWithFormat:@"%s:%d", __PRETTY_FUNCTION__, __LINE__]] = (error) ? (error) : [NSNull null]; \
} while (0)
