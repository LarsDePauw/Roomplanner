//
//  UIColor+Roomplanner.h
//  Roomplanner02
//
//  Created by Tiele Declercq on 15/01/15.
//  Copyright (c) 2015 Tiele Declercq. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIColor (Roomplanner)

+(UIColor *)roomLightGray;
+(UIColor *)roomGray;

+(UIColor *)roomAvailableColor;
+(UIColor *)roomAvailableDarkColor;
+(UIColor *)roomPendingColor;
+(UIColor *)roomPendingDarkColor;
+(UIColor *)roomBusyColor;
+(UIColor *)roomBusyDarkColor;

+(UIColor *)roomEventBorder;
+(UIColor *)roomEventBorderTransparant;
+(UIColor *)roomEventBg;
+(UIColor *)roomEventText;

@end

