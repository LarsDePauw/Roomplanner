//
//  AvailabilityNavViewController.h
//  Roomplanner02
//
//  Created by Tiele Declercq on 15/01/15.
//  Copyright (c) 2015 Tiele Declercq. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <EventKit/EventKit.h>

@interface AvailabilityNavViewController : UINavigationController

@property (nonatomic, strong) EKEvent *addedEvent;
@property (nonatomic, strong) EKEvent *activeEvent;

@end
