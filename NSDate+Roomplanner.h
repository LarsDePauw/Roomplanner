//
//  NSDate+Roomplanner.h
//  Roomplanner02
//
//  Created by Tiele Declercq on 17/01/15.
//  Copyright (c) 2015 Tiele Declercq. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDate (Roomplanner)

+(NSDate *)dateWithoutTime:(NSDate *)date;
+(NSDate *)dateWithoutSeconds:(NSDate *)date;
+(NSDate *)roundedAt30Minutes:(NSDate *)date;

@end
