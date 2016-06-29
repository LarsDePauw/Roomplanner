//
//  AvailabilityNavViewController.m
//  Roomplanner02
//
//  Created by Tiele Declercq on 15/01/15.
//  Copyright (c) 2015 Tiele Declercq. All rights reserved.
//

#import "AvailabilityNavViewController.h"
#import "AppDelegate.h"
#import "AvailableViewController.h"
#import "PendingViewController.h"
#import "BusyViewController.h"


@interface AvailabilityNavViewController ()

@property (nonatomic, strong) AppDelegate *app;

@end

@implementation AvailabilityNavViewController

-(instancetype)init {
    self = [super initWithRootViewController: [[AvailableViewController alloc] init]];
    
    if(self) {
        _app = (AppDelegate *)[[UIApplication sharedApplication] delegate];
        _app.navController = self;
        
        self.navigationBarHidden = YES;
        
    }
    
    return self;
}

-(void)viewDidLoad {
    // Set status on startup
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(checkActiveEvents:)
                                                 name:@"CalendarIsAccessible"
                                               object:nil];
    
    // Set status on event changes
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(checkActiveEvents:)
                                                 name:EKEventStoreChangedNotification
                                               object:nil];
    
    // Check events every minute
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(checkActiveEvents:)
                                                 name:@"MinuteHasPassed"
                                               object:nil];


}

-(void)checkActiveEvents:(NSNotification *)notification {
    //NSLog(@"Availability received notification: %@", notification.name);
    
    NSArray *events = [_app.eventManager getEventsOnTime:[NSDate date]];
    EKEvent *activeEvent;
    for(EKEvent *event in events) {
        if(activeEvent || event.endDate > activeEvent.endDate) {
            activeEvent = event;
        }
    }
    
    if((_activeEvent == nil && activeEvent != nil)
       || (_activeEvent != nil && activeEvent == nil)
       || (_activeEvent != nil && activeEvent == nil && _activeEvent != activeEvent)) {
        [self performSelectorOnMainThread:@selector(setActiveEvent:) withObject:activeEvent waitUntilDone:NO];
    }
}

-(void)setActiveEvent:(EKEvent *)activeEvent {
    _activeEvent = activeEvent;
    
    //[[NSUserDefaults standardUserDefaults] boolForKey:@"roomSetFree"]
    
    
    if(activeEvent == nil) {
        NSLog(@"Pop to root view controller.");
        [self popToRootViewControllerAnimated:YES];
    } else if(![[NSUserDefaults standardUserDefaults] boolForKey:@"roomSetFree"] || (_addedEvent != nil && _addedEvent.startDate == activeEvent.startDate && _addedEvent.title == activeEvent.title)) {
        NSLog(@"Shift to busy.");
        [self pushViewController:[[BusyViewController alloc]init] animated:YES];
    } else {
        NSLog(@"Shift to pending.");
        [self pushViewController:[[PendingViewController alloc]init] animated:YES];
    }
}


@end
