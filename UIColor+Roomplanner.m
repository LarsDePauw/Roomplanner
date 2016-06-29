//
//  UIColor+Roomplanner.m
//  Roomplanner02
//
//  Created by Tiele Declercq on 15/01/15.
//  Copyright (c) 2015 Tiele Declercq. All rights reserved.
//
//  Default Roomplanner colors

#import "UIColor+Roomplanner.h"

#import <TBMacros/Macros.h>

@implementation UIColor (Roomplanner)


+(UIColor *)roomLightGray {
    return UIColorFromRGB(220, 222, 224);
}

+(UIColor *)roomGray {
    return [UIColor grayColor];
}

// Available
+(UIColor *)roomAvailableColor {
    return UIColorFromRGB(112, 191, 65);
}

+(UIColor *)roomAvailableDarkColor {
    return UIColorFromRGB(0, 136, 43);
}

+(UIColor *)roomPendingColor {
    return UIColorFromRGB(245, 211, 40);
}

+(UIColor *)roomPendingDarkColor {
    return UIColorFromRGB(195, 151, 26);
}

+(UIColor *)roomBusyColor {
    return UIColorFromRGB(200, 37, 6);
}

+(UIColor *)roomBusyDarkColor {
    return UIColorFromRGB(134, 16, 1);
}

+(UIColor *)roomEventBorder {
    return UIColorFromRGB(81, 167, 249);
}

+(UIColor *)roomEventBorderTransparant {
    return UIColorFromRGBA(81, 167, 249, 0.5);
}

+(UIColor *)roomEventBg {
    return UIColorFromRGBA(180, 214, 255, 0.5);
}

+(UIColor *)roomEventText {
    return UIColorFromRGB(3, 101, 192);
}


@end
