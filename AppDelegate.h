//
//  AppDelegate.h
//  Roomplanner02
//
//  Created by Tiele Declercq on 15/01/15.
//  Copyright (c) 2015 Tiele Declercq. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EventManager.h"
#import "AvailabilityNavViewController.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (nonatomic, strong) EventManager *eventManager;
@property (nonatomic, strong) AvailabilityNavViewController *navController;

@end

