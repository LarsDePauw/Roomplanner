//
//  PendingViewController.m
//  Roomplanner02
//
//  Created by Tiele Declercq on 19/01/15.
//  Copyright (c) 2015 Tiele Declercq. All rights reserved.
//

#import "PendingViewController.h"
#import "AppDelegate.h"
#import "Config.h"
#import "UIColor+Roomplanner.h"
#import "UIFont+Roomplanner.h"
#import "BusyViewController.h"

#import <TBMacros/Macros.h>
#import <MailCore/MailCore.h>

@interface PendingViewController ()
@property (nonatomic, strong) AppDelegate *app;
@property (nonatomic) int secondsToConfirm;
@property (nonatomic, strong) UILabel *lblTimeLeft;

@property (nonatomic, strong) NSCalendar *dateCalendar;
@property (nonatomic, strong) NSDateComponents *secondComponent;


@end

@implementation PendingViewController

-(instancetype)init {
    self = [super initWithBgColor:[UIColor roomPendingColor] andBorderColor:[UIColor roomPendingDarkColor]];
    
    if(self) {
        _app = (AppDelegate *)[[UIApplication sharedApplication] delegate];
        
        self.statusText = NSLocalizedString(@"To be confirmed", nil);
        
        _secondsToConfirm = [[NSUserDefaults standardUserDefaults] stringForKey:@"roomTimeToConfirm"].intValue;
        
        _dateCalendar = [NSCalendar currentCalendar];
        _secondComponent = [[NSDateComponents alloc]init];
        _secondComponent.second = 1;
        

        
    }
    
    return self;
}

-(void)viewDidLoad {
    [super viewDidLoad];
    CGFloat heightRoundedFrame = 350;
    
    UIView *counterView = [[UIView alloc]initWithFrame:CGRectMake(60, HEIGHT(self.view) - heightRoundedFrame - 160, [Config getWidthOfRightFrame] - 120, heightRoundedFrame)];
    counterView.backgroundColor = [UIColor whiteColor];
    counterView.layer.cornerRadius = 15;
    counterView.layer.masksToBounds = YES;
    [self.view addSubview:counterView];
    
    _lblTimeLeft = [[UILabel alloc]initWithFrame:CGRectMake(10, 50, WIDTH(counterView) - 20, 100)];
    int minutes = (_secondsToConfirm % 3600) / 60;
    int seconds = (_secondsToConfirm % 3600) % 60;
    _lblTimeLeft.text = [NSString stringWithFormat:@"%02d:%02d", minutes, seconds];
    _lblTimeLeft.textAlignment = NSTextAlignmentCenter;
    _lblTimeLeft.font = [UIFont roomBoldWithSize:100];
    [counterView addSubview:_lblTimeLeft];

    UIButton *btnConfirm = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    btnConfirm.frame = CGRectMake(10, 200, WIDTH(counterView) - 20, 120);
//    btnConfirm.titleLabel.font = [UIFont systemFontOfSize:50];
    btnConfirm.titleLabel.font = [UIFont roomDefaultWithSize:48];
    [btnConfirm setTitleColor:[UIColor roomPendingDarkColor] forState:UIControlStateNormal];

    btnConfirm.titleLabel.textAlignment = NSTextAlignmentCenter;
    btnConfirm.titleLabel.numberOfLines = 2;
    [btnConfirm setTitle:NSLocalizedString(@"Confirm\r\npresence", nil) forState:UIControlStateNormal];
    [counterView addSubview:btnConfirm];
    [btnConfirm addTarget:self
                   action:@selector(presenceConfirmed)
         forControlEvents:UIControlEventTouchUpInside];
 
    
    UILabel *lblBottom = [[UILabel alloc]initWithFrame:CGRectMake(60, HEIGHT(self.view) - 150, [Config getWidthOfRightFrame] - 120, 140)];
    lblBottom.text = [NSString stringWithFormat:NSLocalizedString(@"Confirm within %d minutes", nil), ([[NSUserDefaults standardUserDefaults] stringForKey:@"roomTimeToConfirm"].intValue / 60)];
    lblBottom.textAlignment = NSTextAlignmentCenter;
    lblBottom.font = [UIFont roomLightWithSize:26];
    lblBottom.numberOfLines = 3;
    [self.view addSubview:lblBottom];
}

-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    _timer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(countdown:) userInfo:nil repeats:YES];
}

-(void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [_timer invalidate];
}

-(void)presenceConfirmed {
    NSLog(@"Presence confirmed!");
    [_timer invalidate];
    
    [self.navigationController pushViewController:[[BusyViewController alloc]init] animated:YES];
}

-(void)doSomething:(NSTimer*)timer {
    NSLog(@"Something!");
}

-(void)countdown:(NSTimer*)timer {
    _secondsToConfirm -= 1;
    
    if(_secondsToConfirm < 0) {
        [_timer invalidate];
        
        [self sendMailDeletedEvent:_app.navController.activeEvent];
        
        // Delete event from store
        NSError* error = nil;
        [_app.eventManager.eventStore removeEvent:_app.navController.activeEvent span:EKSpanThisEvent error:&error];
        
    } else {
        int hours = _secondsToConfirm / 3600;
        int minutes = (_secondsToConfirm % 3600) / 60;
        int seconds = (_secondsToConfirm % 3600) % 60;
        if(hours > 0) {
            _lblTimeLeft.text = [NSString stringWithFormat:@"%02d:%02d:%02d",hours, minutes, seconds];
        } else {
            _lblTimeLeft.text = [NSString stringWithFormat:@"%02d:%02d", minutes, seconds];
        }
    }
    
}

-(void)sendMailDeletedEvent:(EKEvent *)event {

    if(event.organizer != nil && [event.organizer.URL.description hasPrefix:@"mailto:"]) {
        NSString *address = [event.organizer.URL.description substringFromIndex:7];
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"HH:mm"];
        
        MCOSMTPSession *smtpSession = [Config SMTPSession];
        NSLog(@"Session: %@", smtpSession);
        if(smtpSession) {
            MCOMessageBuilder * builder = [[MCOMessageBuilder alloc] init];
            [[builder header] setFrom:[MCOAddress addressWithDisplayName:[[NSUserDefaults standardUserDefaults] stringForKey:@"roomName"]
                                                                 mailbox:[[NSUserDefaults standardUserDefaults] stringForKey:@"smtpEmail"]]];
            [[builder header] setTo:@[[MCOAddress addressWithDisplayName:event.organizer.name mailbox:address]]];
            
            if(![[[NSUserDefaults standardUserDefaults] stringForKey:@"roomNotifier"] isEqualToString:@""]) {
                [[builder header] setCc:@[[MCOAddress addressWithMailbox:[[NSUserDefaults standardUserDefaults] stringForKey:@"roomNotifier"]]]];
            }

            [[builder header] setSubject:NSLocalizedString(@"Reservation deleted", nil)];
            [builder setTextBody:[NSString stringWithFormat:NSLocalizedString(@"%@, reservation %@ at %@ in %@ was cancelled.", nil),
                                  event.organizer.name,
                                  event.title,
                                  [dateFormatter stringFromDate:event.startDate],
                                  [[NSUserDefaults standardUserDefaults] stringForKey:@"roomName"]]];
            
            NSError *error;
            NSString *html = [NSString stringWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"Cancellation" ofType:@"html"]
                                                       encoding:NSUTF8StringEncoding
                                                          error:&error];
            html = [html stringByReplacingOccurrencesOfString:@"{{roomName}}"
                                                   withString:[[NSUserDefaults standardUserDefaults] stringForKey:@"roomName"]];
            html = [html stringByReplacingOccurrencesOfString:@"{{time}}"
                                                   withString:[dateFormatter stringFromDate:event.startDate]];
            html = [html stringByReplacingOccurrencesOfString:@"{{subject}}"
                                                   withString:event.title];

            [builder setHTMLBody:html];
            NSData * rfc822Data = [builder data];
            
            MCOSMTPSendOperation *sendOperation = [smtpSession sendOperationWithData:rfc822Data];
            [sendOperation start:^(NSError *error) {
                if(error) {
                    NSLog(@"Error sending email:%@", error);
                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:[NSString stringWithFormat:@"Mail could not be sent: %@", error] delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
                    [alert show];
                } else {
                    NSLog(@"Cancellation mail sent to %@", address);
                }
            }];
            
        }
        
        
    }


}



@end
