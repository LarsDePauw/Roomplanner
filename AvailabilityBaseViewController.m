//
//  AvailabilityBaseViewController.m
//  Roomplanner02
//
//  Created by Tiele Declercq on 15/01/15.
//  Copyright (c) 2015 Tiele Declercq. All rights reserved.
//

#import "AvailabilityBaseViewController.h"
#import "Config.h"
#import "UIColor+Roomplanner.h"
#import "UIFont+Roomplanner.h"
#import <TBMacros/Macros.h>

@interface AvailabilityBaseViewController ()

@property (nonatomic, strong) UIColor *bgColor, *borderColor;

@property (nonatomic, strong) UIView *borderVertical;
@property (nonatomic, strong) UILabel *lblStatus;


@end

@implementation AvailabilityBaseViewController

-(instancetype)initWithBgColor:(UIColor *)bgColor andBorderColor:(UIColor *)borderColor {
    self = [super init];
    if (self) {
        self.bgColor = bgColor;
        self.borderColor = borderColor;
        self.statusText = @"Default status";
    }
    return self;
}

-(void)viewDidLoad {
    
    self.view.backgroundColor = self.bgColor;
    
    // Vertical border on the right
    _borderVertical = [[UIView alloc] initWithFrame: CGRectMake(0, 0, 7, HEIGHT(self.view))];
    _borderVertical.backgroundColor = self.borderColor;
    [self.view addSubview:_borderVertical];
    
    
    // Room name
    UILabel *lblName = [[UILabel alloc] initWithFrame: CGRectMake(60, 50, [Config getWidthOfRightFrame] - 120, 40)];
    lblName.text = [[NSUserDefaults standardUserDefaults]stringForKey:@"roomName"];
    lblName.textAlignment = NSTextAlignmentCenter;
    lblName.textColor = [UIColor whiteColor];;
    lblName.font = [UIFont roomDefaultWithSize:26];
    [self.view addSubview:lblName];
    
    
    // Status label
    _lblStatus = [[UILabel alloc] initWithFrame: CGRectMake(60, 100, [Config getWidthOfRightFrame] - 120, 80)];
    _lblStatus.text = self.statusText;
    _lblStatus.textAlignment = NSTextAlignmentCenter;
//    _lblStatus.backgroundColor = [UIColor whiteColor];
    _lblStatus.layer.cornerRadius = 15;
    _lblStatus.layer.masksToBounds = YES;
//    _lblStatus.textColor = _borderColor;
    _lblStatus.textColor = [UIColor whiteColor];
//    _lblStatus.font = [UIFont roomDefaultWithSize:36];
    _lblStatus.font = [UIFont roomBoldWithSize:48];
    [self.view addSubview:_lblStatus];
    
}

-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
//    
//    NSLog(@"Viewcontrollers START: %lu", (unsigned long)self.navigationController.viewControllers.count);
//    
//    self.navigationController.viewControllers = @[[self.navigationController.viewControllers lastObject]];
//    
//    NSLog(@"Viewcontrollers END: %lu", (unsigned long)self.navigationController.viewControllers.count);

    
}

-(void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    //NSLog(@"Viewcontrollers START: %lu", (unsigned long)self.navigationController.viewControllers.count);
    //[self removeFromParentViewController];
    //NSLog(@"Viewcontrollers END: %lu", (unsigned long)self.navigationController.viewControllers.count);
}

-(void)setStatusText:(NSString *)statusText {
    _statusText = statusText;
    _lblStatus.text = statusText;
}


@end
