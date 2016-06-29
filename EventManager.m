//
//  EventManager.m
//  Roomplanner02
//
//  Created by Tiele Declercq on 18/01/15.
//  Copyright (c) 2015 Tiele Declercq. All rights reserved.
//

#import "EventManager.h"
#import "NSDate+Roomplanner.h"

@interface EventManager ()


@end

@implementation EventManager

- (instancetype)init
{
    self = [super init];
    if (self) {
        _eventStore = [[EKEventStore alloc] init];
    }
    
    return self;
}

// Access to the calendar has been granted
-(void)setEventsAccessGranted:(BOOL)eventsAccessGranted{
    NSLog(@"Calendar status: %d", eventsAccessGranted);
    _eventsAccessGranted = eventsAccessGranted;
    if(_eventsAccessGranted) {
        @try {
            // Try fetching the default calendar will fail the first time after access was granted
            _calendar = [_eventStore defaultCalendarForNewEvents];
            NSLog(@"Calendar %@ is Accessible", _calendar.title);
            
            // Tell everyone that the calendar can be accessed
            [[NSNotificationCenter defaultCenter] postNotificationName:@"CalendarIsAccessible" object:_eventStore];
        }
        @catch (NSException *exception) {
            NSLog(@"Default calendar could not be fetched");
        }
    }    
    
}

// Get events of the default calendar of the entire day
-(NSArray *)getEvents:(NSDate *)date {
    NSArray *events;
    if(_eventsAccessGranted) {
        date = [NSDate dateWithoutTime:date];
        NSDateComponents *dateComponent = [[NSDateComponents alloc] init];
        NSCalendar *dateCalendar = [NSCalendar currentCalendar];
        dateComponent.day = 1;
        NSDate *dateAfter = [dateCalendar dateByAddingComponents:dateComponent toDate:date options:0];
        
        // Create a predicate value with start date a year before and end date a year after the current date.
        NSPredicate *predicate = [_eventStore predicateForEventsWithStartDate:date
                                                                      endDate:dateAfter
                                                                    calendars:@[_calendar]];
        // Get an array with all events.
        events = [_eventStore eventsMatchingPredicate:predicate];
    }
    //NSLog(@"Returned %lu events", (unsigned long)events.count);
    return events;
}

// Get events of the given minute.
-(NSArray *)getEventsOnTime:(NSDate *)date {
    NSArray *events;
    if(_eventsAccessGranted) {
        date = [NSDate dateWithoutSeconds:date];
        NSDateComponents *dateComponent = [[NSDateComponents alloc] init];
        NSCalendar *dateCalendar = [NSCalendar currentCalendar];
        dateComponent.minute = 1;
        NSDate *dateAfter = [dateCalendar dateByAddingComponents:dateComponent toDate:date options:0];
        
        // event searcher
        NSPredicate *predicate = [_eventStore predicateForEventsWithStartDate:date
                                                                      endDate:dateAfter
                                                                    calendars:@[_calendar]];
        // Get an array with all events.
        events = [_eventStore eventsMatchingPredicate:predicate];
    }
    //NSLog(@"Returned %lu events in this minute", (unsigned long)events.count);
    return events;
}

// Get events between 2 timeframes
-(NSArray *)getEventsBetween:(NSDate *)startDate and:(NSDate *)endDate {
    NSArray *events;
    if(_eventsAccessGranted) {
        // event searcher
        NSPredicate *predicate = [_eventStore predicateForEventsWithStartDate:startDate
                                                                      endDate:endDate
                                                                    calendars:@[_calendar]];
        // Get an array with all events.
        events = [_eventStore eventsMatchingPredicate:predicate];
    }
    return events;
}

// Get next available timeframe of 30 minutes
-(NSDate *)freeFrom:(NSDate *)date {
    if(_eventsAccessGranted) {
        NSCalendar *dateCalendar = [NSCalendar currentCalendar];
        NSDateComponents *dateComponent = [[NSDateComponents alloc] init];
        dateComponent.minute = 30;
        
        NSDate *dateFreeFrom;
        NSDate *dateCheckFrom = date;
        NSDate *dateCheckTill = [dateCalendar dateByAddingComponents:dateComponent toDate:dateCheckFrom options:0];
        
        do {
            //NSLog(@"check from %@, till %@", dateCheckFrom, dateCheckTill);
            // event searcher
            NSPredicate *predicate = [_eventStore predicateForEventsWithStartDate:dateCheckFrom
                                                                          endDate:dateCheckTill
                                                                        calendars:@[_calendar]];
            // Get an array with all events.
            NSArray *events = [_eventStore eventsMatchingPredicate:predicate];
            
            if(events.count > 0) {
                // Found events. Adjust 'from' date to end date of last meeting
                NSDate *dateLastEvent;
                for (EKEvent *event in events) {
                    if (dateLastEvent == nil || [dateLastEvent compare:event.endDate] == NSOrderedAscending) {
                        dateLastEvent = event.endDate;
                    }
                }
                
                if ([dateCheckFrom compare:dateLastEvent] == NSOrderedAscending) {
                    dateCheckFrom = dateLastEvent;
                    dateCheckTill = [dateCalendar dateByAddingComponents:dateComponent toDate:dateCheckFrom options:0];
                } else {
                    dateFreeFrom = dateLastEvent;
                }
                
            } else {
                // No events found. Found a free half hour!
                dateFreeFrom = dateCheckFrom;
            }
            
        } while (dateFreeFrom == nil);
        
        return dateFreeFrom;
        
    } else {
        return date;
    }
}

// Get date of the next event in the calendar within 1 month
// Returns nil if no events are found.
-(NSDate *)freeUntil:(NSDate *)date {
    if(_eventsAccessGranted) {
        NSCalendar *dateCalendar = [NSCalendar currentCalendar];
        NSDateComponents *dateComponent = [[NSDateComponents alloc] init];
        dateComponent.month = 1;
        
        NSDate *dateFreeUntil;
        NSDate *dateCheckFrom = date;
        NSDate *dateCheckTill = [dateCalendar dateByAddingComponents:dateComponent toDate:dateCheckFrom options:0];
        
        // event searcher
        NSPredicate *predicate = [_eventStore predicateForEventsWithStartDate:dateCheckFrom
                                                                      endDate:dateCheckTill
                                                                    calendars:@[_calendar]];
        // Get an array with all events.
        NSArray *events = [_eventStore eventsMatchingPredicate:predicate];
        
        if(events.count > 0) {
            // Found events. Adjust 'from' date to end date of last meeting
            //NSLog(@"Found events: %@", events);
            for (EKEvent *event in events) {
                if (dateFreeUntil == nil || [dateFreeUntil compare:event.startDate] == NSOrderedDescending) {
                    // NSLog(@"Until: %@, startDate: %@", dateFreeUntil, event.startDate);
                    if([event.endDate compare:dateCheckFrom] != NSOrderedSame) {
                        dateFreeUntil = event.startDate;
                    }
                }
            }
        }
        
        return dateFreeUntil;
        
    } else {
        return nil;
    }
}




@end
