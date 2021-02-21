//
//  UIGeometry+MyAdditions.h
//
//  Created by curie on 13-3-13.
//  Copyright (c) 2013年 Fish Tribe. All rights reserved.
//

#import <UIKit/UIGeometry.h>


UIKIT_STATIC_INLINE CGRect my_UIEdgeInsetsOutsetRect(CGRect rect, UIEdgeInsets insets) {
    rect.origin.x    -= insets.left;
    rect.origin.y    -= insets.top;
    rect.size.width  += (insets.left + insets.right);
    rect.size.height += (insets.top  + insets.bottom);
    return rect;
}
