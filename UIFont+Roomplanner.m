//
//  UIFont+Roomplanner.m
//  Roomplanner02
//
//  Created by Tiele Declercq on 15/01/15.
//  Copyright (c) 2015 Tiele Declercq. All rights reserved.
//
// Default Roomplanner fonts

#import "UIFont+Roomplanner.h"

@implementation UIFont (Roomplanner)

+(UIFont *)roomDefaultWithSize:(CGFloat)size {
    return [UIFont fontWithName:@"HelveticaNeue-Light" size:size];
}
+(UIFont *)roomLightWithSize:(CGFloat)size {
    return [UIFont fontWithName:@"HelveticaNeue-UltraLight" size:size];
}
+(UIFont *)roomBoldWithSize:(CGFloat)size {
    return [UIFont fontWithName:@"HelveticaNeue-Bold" size:size];
}

@end
