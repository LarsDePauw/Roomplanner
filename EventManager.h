//
//  EventManager.h
//  Roomplanner02
//
//  Created by Tiele Declercq on 18/01/15.
//  Copyright (c) 2015 Tiele Declercq. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <EventKit/EventKit.h>

@interface EventManager : NSObject

@property (nonatomic, strong) EKCalendar *calendar;
@property (nonatomic, strong) EKEventStore *eventStore;
@property (nonatomic) BOOL eventsAccessGranted;

-(NSArray *)getEvents:(NSDate *)date;
-(NSArray *)getEventsOnTime:(NSDate *)date;
-(NSArray *)getEventsBetween:(NSDate *)startDate and:(NSDate *)endDate;

-(NSDate *)freeFrom:(NSDate *)date;
-(NSDate *)freeUntil:(NSDate *)date;

@end
