//
//  DayView.m
//  Roomplanner02
//
//  Created by Tiele Declercq on 15/01/15.
//  Copyright (c) 2015 Tiele Declercq. All rights reserved.
//
// DayView is 1 cell in the DayScroller.
// It draws a line for every hour and aligned the events of that day.
// This object is re-used in the scroller so all data needs to be dynamic

#import "DayView.h"
#import "UIColor+Roomplanner.h"
#import "UIFont+Roomplanner.h"
#import "NSDate+Roomplanner.h"
#import "BookViewController.h"
#import <TBMacros/Macros.h>
#import <EventKitUI/EventKitUI.h>


@interface DayView () <UIGestureRecognizerDelegate>

@property (nonatomic, strong) UILabel *lblDate;;

@property (nonatomic, strong) NSDate *date;
@property (nonatomic, strong) NSDateFormatter *dateFormatter;
@property (nonatomic, strong) NSDateComponents *dateComponents;
@property (nonatomic, strong) NSCalendar *dateCalendar;

@property (nonatomic, strong) NSMutableArray *eventViews;

@end

@implementation DayView

// Width of DayView is set-up when the scroller's frame has been drawn.
static CGFloat widthOfCell = 100;

-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    
    if(self) {
        // Use current date by default. It will be changed before it's displayed
        _date = [NSDate date];
        _dateCalendar = [NSCalendar currentCalendar];
        _dateFormatter = [[NSDateFormatter alloc] init];
        
        // Use current locale to write full date
        NSString *deviceLanguage = [[NSLocale preferredLanguages] objectAtIndex:0];
        NSLocale *locale = [[NSLocale alloc] initWithLocaleIdentifier:deviceLanguage];
        [_dateFormatter setLocale:locale];
        
        [self addDateOnTop];
        
        for (int i=1; i < 24; i++) {
            [self addHourOfDay:i];
            
        }

        // Views on events of that day.
        _eventViews = [[NSMutableArray alloc]init];
        
        // Register a tap to register a new event
        UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTap:)];
        [self addGestureRecognizer:singleTap];
    }
    
    return self;
}

// Date label on top of day
- (void)addDateOnTop {
    _lblDate = [[UILabel alloc] initWithFrame: CGRectMake(0, 0, widthOfCell, [DayView getHourOffset])];
    _lblDate.text = [_dateFormatter stringFromDate:_date];
    _lblDate.textAlignment = NSTextAlignmentCenter;
    _lblDate.font = [UIFont roomDefaultWithSize:16];
    _lblDate.backgroundColor = [UIColor roomLightGray];
    [self addSubview:_lblDate];
}

// Hour and line for each hour of the day
- (void)addHourOfDay:(int)i {
    UILabel *lblHour = [[UILabel alloc] initWithFrame:CGRectMake(0, (i * [DayView getHeightOfHour]) + [DayView getHourOffset] - 10, 40, 20)];
    lblHour.text = [NSString stringWithFormat:@"%i:00", i];
    lblHour.textAlignment = NSTextAlignmentRight;
    lblHour.font = [UIFont roomDefaultWithSize:12];
    lblHour.textColor = [UIColor roomGray];
    [self addSubview:lblHour];
    
    UIView *line = [[UIView alloc] initWithFrame:CGRectMake(50, ((i * [DayView getHeightOfHour]) + [DayView getHourOffset]), widthOfCell - 70, 1)];
    line.backgroundColor = [UIColor roomLightGray];
    [self addSubview:line];
}

// Which day does this dayview represent?
-(NSDate *)getDate {
    return _date;
}

// Set full date on top
-(void)setDate:(NSDate *)date {
    _date = date;
    [_dateFormatter setDateFormat:@"EEEE d MMMM YYYY"];
    _lblDate.text = [_dateFormatter stringFromDate:_date];
}

// 
-(void)setEvents:(NSArray *)events {
    if(events != _events) {
        for (UIView *eventView in _eventViews) {
            [eventView removeFromSuperview];
        }
        
        [_eventViews removeAllObjects];
        
        for (EKEvent *event in events) {
            NSDateComponents *comp;
            CGFloat yStart, yEnd;
            
            if([NSDate dateWithoutTime:_date] == [NSDate dateWithoutTime:event.startDate]) {
                comp = [_dateCalendar components:(NSCalendarUnitHour|NSCalendarUnitMinute) fromDate:event.startDate];
                yStart = (comp.hour * [DayView getHeightOfHour]);
                yStart += ([DayView getHeightOfHour] / 60) * comp.minute;
                yStart += [DayView getHourOffset];
            } else {
                yStart = [DayView getHourOffset];
            }

            if([NSDate dateWithoutTime:_date] == [NSDate dateWithoutTime:event.endDate]) {
                comp = [_dateCalendar components:(NSCalendarUnitHour|NSCalendarUnitMinute) fromDate:event.endDate];
                yEnd = (comp.hour * [DayView getHeightOfHour]);
                yEnd += ([DayView getHeightOfHour] / 60) * comp.minute;
                yEnd += [DayView getHourOffset];
            } else {
                yEnd = [DayView getHeightOfDay];
            }
            
            CGFloat height = yEnd - yStart;
            
            UIView *eventView = [[UIView alloc] initWithFrame:CGRectMake(50, yStart, widthOfCell - 70, height)];
            eventView.backgroundColor = [UIColor roomEventBg];
            [self addSubview:eventView];
            
            UIView *eventBorderLeft = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 4, HEIGHT(eventView))];
            eventBorderLeft.backgroundColor = [UIColor roomEventBorder];
            [eventView addSubview:eventBorderLeft];
            
            UIView *eventBorderTop = [[UIView alloc] initWithFrame:CGRectMake(0, 0, WIDTH(eventView), 0.5)];
            eventBorderTop.backgroundColor = [UIColor roomEventBorderTransparant];
            [eventView addSubview:eventBorderTop];
            
            UILabel *eventTime = [[UILabel alloc] init];
            [_dateFormatter setDateFormat:@"HH:mm"];
            eventTime.text = [_dateFormatter stringFromDate:event.startDate];
            eventTime.font = [UIFont roomDefaultWithSize:16];
            eventTime.textColor = [UIColor roomEventText];

            UILabel *eventTitle = [[UILabel alloc] init];
            eventTitle.text = event.title;
            eventTitle.font = [UIFont roomBoldWithSize:16];
            eventTitle.textColor = [UIColor roomEventText];
            
            if(height >= 55) {
                [eventTime setFrame:CGRectMake(12, 8, WIDTH(eventView) - 24, 20)];
                [eventTime sizeToFit];
                [eventView addSubview:eventTime];
                
                [eventTitle setFrame:CGRectMake(12, 30, WIDTH(eventView) - 24, height - 30)];
                [eventTitle sizeToFit];
                [eventView addSubview:eventTitle];
            } else if(height >= 15) {
                [eventTitle setFrame:CGRectMake(12, 0, WIDTH(eventView) - 24, height)];
                if(height < 24) {
                    eventTitle.font = [UIFont roomBoldWithSize:(height / 1.5)];
                }
                [eventView addSubview:eventTitle];
            }
            
            [_eventViews addObject:eventView];
            
            //NSLog(@"Added event %@", event.title);
        }
    }
    
    _events = events;
}

+(int)getHeightOfHour {
    return 60;
}

+(int)getHourOffset {
    return 25;
}

+(int)getHeightOfDay {
    return ([self getHeightOfHour] * 24) + 24;
}

+(void)setWidthOfCell:(CGFloat)width {
    widthOfCell = width;
}

- (void)handleTap:(UITapGestureRecognizer *)tap {
    CGPoint pos = [tap locationInView:self];
    NSNumber *posY = [[NSNumber alloc]initWithFloat:(pos.y - [DayView getHourOffset])];

    if(pos.y > 0 && [_delegate respondsToSelector:@selector(userTapped:)]) {
        NSDateComponents* dateComponents = [[NSCalendar currentCalendar] components:NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay fromDate:_date];
        dateComponents.hour = ([posY intValue] / 60);
        dateComponents.minute = ([posY intValue] % 60) * ([DayView getHeightOfHour] / 60);
        //NSLog(@"tap: %@", [[NSCalendar currentCalendar] dateFromComponents:dateComponents]);
        
        [_delegate userTapped:[[NSCalendar currentCalendar] dateFromComponents:dateComponents]];
    }
    
}

@end
