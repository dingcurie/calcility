//
//  CALayer+MyAdditions.h
//
//  Created by curie on 12/18/14.
//  Copyright (c) 2014 Fish Tribe. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>


@interface CALayer (MyAdditions)

- (void)my_removeAnimationForKeyPath:(NSString *)keyPath;

@end
