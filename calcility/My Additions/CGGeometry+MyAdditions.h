//
//  CGGeometry+MyAdditions.h
//
//  Created by curie on 13-4-18.
//  Copyright (c) 2013年 Fish Tribe. All rights reserved.
//

#ifndef CGGEOMETRY_MY_ADDITIONS_H_
#define CGGEOMETRY_MY_ADDITIONS_H_

#include <CoreGraphics/CGGeometry.h>


CG_INLINE CGPoint
my_CGPointOffset(CGPoint p, CGFloat dx, CGFloat dy)
{
    p.x += dx;
    p.y += dy;
    return p;
}

#endif /* CGGEOMETRY_MY_ADDITIONS_H_ */
