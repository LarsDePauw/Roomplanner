//
//  BusyViewController.m
//  Roomplanner02
//
//  Created by Tiele Declercq on 19/01/15.
//  Copyright (c) 2015 Tiele Declercq. All rights reserved.
//

#import "BusyViewController.h"
#import "AppDelegate.h"
#import "Config.h"
#import "UIColor+Roomplanner.h"
#import "UIFont+Roomplanner.h"
#import "NSDate+Roomplanner.h"

#import <TBMacros/Macros.h>
#import <EventKit/EventKit.h>


@interface BusyViewController ()

@property (nonatomic, strong) AppDelegate *app;

@end

@implementation BusyViewController

-(instancetype)init {
    self = [super initWithBgColor:[UIColor roomBusyColor] andBorderColor:[UIColor roomBusyDarkColor]];
    
    if(self) {
        _app = (AppDelegate *)[[UIApplication sharedApplication] delegate];

        self.statusText = NSLocalizedString(@"Occupied", nil);

    }
    
    return self;
}

-(void)viewDidLoad {
    [super viewDidLoad];
    
    CGFloat heightRoundedFrame = 120;
    
    UIView *roundedView = [[UIView alloc]initWithFrame:CGRectMake(60, HEIGHT(self.view) - heightRoundedFrame - 160, [Config getWidthOfRightFrame] - 120, heightRoundedFrame)];
    roundedView.backgroundColor = [UIColor whiteColor];
    roundedView.layer.cornerRadius = 15;
    roundedView.layer.masksToBounds = YES;
    [self.view addSubview:roundedView];
    
    UIButton *btnFree = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    btnFree.frame = CGRectMake(10, 0, WIDTH(roundedView) - 20, 120);
    //btnFree.titleLabel.font = [UIFont systemFontOfSize:50];
    btnFree.titleLabel.font = [UIFont roomDefaultWithSize:48];
    [btnFree setTitleColor:[UIColor roomBusyDarkColor] forState:UIControlStateNormal];

    btnFree.titleLabel.textAlignment = NSTextAlignmentCenter;
    [btnFree setTitle:NSLocalizedString(@"Release", nil) forState:UIControlStateNormal];
    [roundedView addSubview:btnFree];
    [btnFree addTarget:self
                action:@selector(freeNow)
      forControlEvents:UIControlEventTouchUpInside];
    
    
    UILabel *lblBottom = [[UILabel alloc]initWithFrame:CGRectMake(60, HEIGHT(self.view) - 150, [Config getWidthOfRightFrame] - 120, 140)];
    lblBottom.text = NSLocalizedString(@"Release when finished", nil);
    lblBottom.textAlignment = NSTextAlignmentCenter;
    lblBottom.font = [UIFont roomLightWithSize:26];
    lblBottom.textColor = [UIColor whiteColor];
    lblBottom.numberOfLines = 3;
    [self.view addSubview:lblBottom];
    
}




-(void)freeNow {
    NSLog(@"Free room");
    
    NSCalendar *dateCalendar = [NSCalendar currentCalendar];
    NSDateComponents *dateComponent = [[NSDateComponents alloc] init];
    dateComponent.minute = -1;
    
    NSDate *endDate = [dateCalendar dateByAddingComponents:dateComponent
                                                    toDate:[NSDate dateWithoutSeconds:[NSDate date]]
                                                   options:0];
    
    NSError *error;
    if([endDate timeIntervalSinceDate:_app.navController.activeEvent.startDate] < 120.0) {
        // Meeting less then 2 minutes > delete event from calendar
        if(![_app.eventManager.eventStore removeEvent:_app.navController.activeEvent span:EKSpanThisEvent error:&error]) {
            NSLog(@"%@", [error localizedDescription]);
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:[NSString stringWithFormat:@"Event could not be deleted: %@", error] delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alert show];
        }
    } else {
        
        if(_app.navController.activeEvent.organizer) {
            // Cannot alter an organized event. Remove and add event
            if([_app.eventManager.eventStore removeEvent:_app.navController.activeEvent span:EKSpanThisEvent error:&error]) {
                // Re-create local event
                EKEvent *event = [EKEvent eventWithEventStore:_app.eventManager.eventStore];
                event.calendar = _app.eventManager.calendar;
                event.title = _app.navController.activeEvent.title;
                event.startDate = _app.navController.activeEvent.startDate;
                event.endDate = endDate;
                if (![_app.eventManager.eventStore saveEvent:event span:EKSpanThisEvent commit:YES error:&error]) {
                    NSLog(@"%@", [error localizedDescription]);
                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:[NSString stringWithFormat:@"Event could not be created: %@", error] delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
                    [alert show];
                }
            } else {
                NSLog(@"%@", [error localizedDescription]);
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:[NSString stringWithFormat:@"Event could not be deleted: %@", error] delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
                [alert show];
            }
        } else {
            // Alter event
            // Shorten meeting till 'now' - 1 minute
            _app.navController.activeEvent.endDate = endDate;
            if (![_app.eventManager.eventStore saveEvent:_app.navController.activeEvent span:EKSpanThisEvent commit:YES error:&error]) {
                NSLog(@"%@", [error localizedDescription]);
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:[NSString stringWithFormat:@"Event could not be altered: %@", error] delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
                [alert show];
            }
        }

        
    }
    


    
}

@end
