//
//  AppDelegate.m
//  Roomplanner02
//
//  Created by Tiele Declercq on 15/01/15.
//  Copyright (c) 2015 Tiele Declercq. All rights reserved.
//

#import "AppDelegate.h"
#import "BaseSplitViewController.h"
#import "NSDate+Roomplanner.h"

@interface AppDelegate ()

@property (nonatomic, strong) NSCalendar *dateCalendar;
@property (nonatomic, strong) NSDateComponents *minuteComponent;
@property (nonatomic, strong) NSTimer *minuteTimer;

@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    // Initialize
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.backgroundColor = [UIColor whiteColor];
    [self.window makeKeyAndVisible];
    
    _dateCalendar = [NSCalendar currentCalendar];
    _minuteComponent = [[NSDateComponents alloc] init];
    _minuteComponent.minute = 1;

    // Set default settings
    NSDictionary *defaults = @{@"roomName": @"",
                               @"roomLogoURL": @"https://hb.willemengroep.eu/sign/logo/logo-willemen-groep.png",
                               @"roomSetFree": @YES,
                               @"roomTimeToConfirm": @900,
                               @"roomShouldSendMail": @YES,
                               @"roomNotifier": @"",
                               @"smtpHost": @"smtp.outlook.com",
                               @"smtpPort": @"587",
                               @"smtpAuth": @1,
                               @"smtpSender": @"",
                               @"smtpUser": @"",
                               @"smtpPass": @""};
    [[NSUserDefaults standardUserDefaults] registerDefaults:defaults];
    
    // Start initial screen.
    //self.window.rootViewController = [[BaseSplitViewController alloc] init];
    
    
    
    return YES;
}

- (void)applicationDidEnterBackground:(UIApplication *)application {

    // Stop timerjob
    [_minuteTimer invalidate];
    
    [self.window.rootViewController removeFromParentViewController];
    self.window.rootViewController = nil;
    
    self.eventManager = nil;
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // rebuild entire screen on re-open. There might be some setting (room name?) changed
    // This will redo a bunch that was just launched on first launch but will hide the ugly screen buildup.
    self.window.rootViewController = [[BaseSplitViewController alloc] init];
    
    // Start timerjob
    [self doEveryMinute];

    // Instantiate Calendar access
    self.eventManager = [[EventManager alloc] init];
    // Request calendar access in 0.5 seconds. It takes a while for the calendar to instantiate.
    [self performSelector:@selector(requestAccessToEvents) withObject:nil afterDelay:0.5];
    
}

// Timer job that will be executed at exactly every minute
-(void)doEveryMinute {
    // Tell everyone a minute has passed!
    [[NSNotificationCenter defaultCenter] postNotificationName:@"MinuteHasPassed" object:nil];
    NSLog(@"A minute has passed");
    
    // Shedule itself again to run at the next (flat) minute
    NSDate *flatMinute = [NSDate dateWithoutSeconds:[NSDate date]];
    flatMinute = [_dateCalendar dateByAddingComponents:_minuteComponent toDate:flatMinute options:0];
    
    _minuteTimer = [[NSTimer alloc]initWithFireDate:flatMinute
                                           interval:0
                                             target:self
                                           selector:@selector(doEveryMinute)
                                           userInfo:nil
                                            repeats:NO];
    [[NSRunLoop currentRunLoop]addTimer:_minuteTimer
                                forMode:NSDefaultRunLoopMode];
}

// Request access to the calendar
-(void)requestAccessToEvents {
    [_eventManager.eventStore requestAccessToEntityType:EKEntityTypeEvent completion:^(BOOL granted, NSError *error) {
        if (error == nil) {
            // Store the returned granted value.
            NSLog(@"Grant: %d", granted);
            _eventManager.eventsAccessGranted = granted;
        }
        else{
            // In case of error, just log its description to the debugger.
            NSLog(@"%@", [error localizedDescription]);
        }
    }];
}


@end
