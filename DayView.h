//
//  DayView.h
//  Roomplanner02
//
//  Created by Tiele Declercq on 15/01/15.
//  Copyright (c) 2015 Tiele Declercq. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol DayViewDelegate <NSObject>

@optional
-(void)userTapped:(NSDate *)date;

@end


@interface DayView : UITableViewCell

-(NSDate *)getDate;
-(void)setDate:(NSDate *)date;
-(void)setEvents:(NSArray *)events;

+(int)getHeightOfHour;
+(int)getHourOffset;
+(int)getHeightOfDay;
+(void)setWidthOfCell:(CGFloat)width;

@property (nonatomic, strong) NSArray *events;
@property (nonatomic, strong) id delegate;

@end
