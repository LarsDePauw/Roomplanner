//
//  AvailableViewController.m
//  Roomplanner02
//
//  Created by Tiele Declercq on 15/01/15.
//  Copyright (c) 2015 Tiele Declercq. All rights reserved.
//

#import "AvailableViewController.h"
#import "AppDelegate.h"

#import "UIColor+Roomplanner.h"
#import "UIFont+Roomplanner.h"
#import "Config.h"
#import "BookViewController.h"
#import <TBMacros/Macros.h>

@interface AvailableViewController ()

@property (nonatomic, strong) AppDelegate *app;

@end

@implementation AvailableViewController

-(instancetype)init {
    self = [super initWithBgColor:[UIColor roomAvailableColor] andBorderColor:[UIColor roomAvailableDarkColor]];
    
    if(self) {
        _app = (AppDelegate *)[[UIApplication sharedApplication] delegate];

        self.statusText = NSLocalizedString(@"Available", nil);
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
    
    UIButton *btnBook = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    btnBook.frame = CGRectMake(10, 0, WIDTH(roundedView) - 20, 120);
//    btnBook.titleLabel.font = [UIFont systemFontOfSize:50];
    btnBook.titleLabel.font = [UIFont roomDefaultWithSize:48];
    [btnBook setTitleColor:[UIColor roomAvailableDarkColor] forState:UIControlStateNormal];
    btnBook.titleLabel.textAlignment = NSTextAlignmentCenter;
//    btnBook.titleLabel.textColor = [UIColor roomAvailableDarkColor];
    [btnBook setTitle:NSLocalizedString(@"Book now", nil) forState:UIControlStateNormal];
    [roundedView addSubview:btnBook];
    [btnBook addTarget:self
                   action:@selector(bookNow)
         forControlEvents:UIControlEventTouchUpInside];
    
//    
//    UILabel *lblBottom = [[UILabel alloc]initWithFrame:CGRectMake(60, HEIGHT(self.view) - 150, [Config getWidthOfRightFrame] - 120, 140)];
//    lblBottom.text = @"";
//    lblBottom.textAlignment = NSTextAlignmentCenter;
//    lblBottom.font = [UIFont roomLightWithSize:26];
//    lblBottom.numberOfLines = 3;
//    [self.view addSubview:lblBottom];
    
    
}

-(void)bookNow {
    NSLog(@"Book Now");
    
    if(_app.eventManager.eventsAccessGranted) {
        BookViewController *modal = [[BookViewController alloc]init];
        [modal setModalInPopover:YES];
        [modal setModalPresentationStyle:UIModalPresentationFormSheet];
        
        
        [self presentViewController:modal animated:YES completion:nil];
    } else {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Roomplanner" message:NSLocalizedString(@"No access to calendar", nil) delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
    }
}

@end
