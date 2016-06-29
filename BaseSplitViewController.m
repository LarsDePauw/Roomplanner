//
//  BaseSplitViewController.m
//  Roomplanner02
//
//  Created by Tiele Declercq on 15/01/15.
//  Copyright (c) 2015 Tiele Declercq. All rights reserved.
//

#import "BaseSplitViewController.h"
#import "CalendarViewController.h"
#import "AvailabilityNavViewController.h"
#import "Config.h"
#import <TBMacros/Macros.h>

@implementation BaseSplitViewController

-(instancetype)init {
    self = [super init];
    
    if (self) {
        
        CGFloat screenWidth = [[UIScreen mainScreen] bounds].size.width;
        [Config setWidthOfLeftFrame:(screenWidth / 2) - 50];
        [Config setWidthOfRightFrame:(screenWidth - [Config getWidthOfLeftFrame])];
        
        self.viewControllers = @[[[CalendarViewController alloc] init],
                                 [[AvailabilityNavViewController alloc] init]];
        
        self.maximumPrimaryColumnWidth = [Config getWidthOfLeftFrame];
        self.minimumPrimaryColumnWidth = [Config getWidthOfLeftFrame];
        
    }
    
    return self;
}


@end
