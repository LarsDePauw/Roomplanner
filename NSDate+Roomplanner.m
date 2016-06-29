//
//  NSDate+Roomplanner.m
//  Roomplanner02
//
//  Created by Tiele Declercq on 17/01/15.
//  Copyright (c) 2015 Tiele Declercq. All rights reserved.
//

#import "NSDate+Roomplanner.h"

@implementation NSDate (Roomplanner)

// Get date with YEAR, MONTH and DAY. Lose time parts
+(NSDate *)dateWithoutTime:(NSDate *)date {
    if( date == nil ) {
        date = [NSDate date];
    }
    NSDateComponents* dateComponents = [[NSCalendar currentCalendar] components:NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay fromDate:date];
    return [[NSCalendar currentCalendar] dateFromComponents:dateComponents];
}

// Get date with flattend minutes. 1:34:47 => 1:34:00
+(NSDate *)dateWithoutSeconds:(NSDate *)date {
    if( date == nil ) {
        date = [NSDate date];
    }
    NSDateComponents* dateComponents = [[NSCalendar currentCalendar] components:NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay|NSCalendarUnitHour|NSCalendarUnitMinute fromDate:date];
    return [[NSCalendar currentCalendar] dateFromComponents:dateComponents];
}

// Round date at 30 minutes. 1:34:47 => 1:30:00  /  1:24:47 => 1:00:00
+(NSDate *)roundedAt30Minutes:(NSDate *)date {
    if( date == nil ) {
        date = [NSDate date];
    }
    NSDateComponents* dateComponents = [[NSCalendar currentCalendar] components:NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay|NSCalendarUnitHour|NSCalendarUnitMinute fromDate:date];
    if(dateComponents.minute > 30) dateComponents.minute = 30;
    else dateComponents.minute = 0;
    return [[NSCalendar currentCalendar] dateFromComponents:dateComponents];
    
}

@end
