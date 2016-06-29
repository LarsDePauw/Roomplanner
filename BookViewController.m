//
//  BookViewController.m
//  Roomplanner02
//
//  Created by Tiele Declercq on 20/01/15.
//  Copyright (c) 2015 Tiele Declercq. All rights reserved.
//

#import "BookViewController.h"
#import "AppDelegate.h"
#import "AvailabilityNavViewController.h"
#import "BusyViewController.h"
#import "UIColor+Roomplanner.h"
#import "UIFont+Roomplanner.h"
#import "NSDate+Roomplanner.h"
#import <TBMacros/Macros.h>
#import <EventKit/EventKit.h>

@interface BookViewController () <UIPickerViewDelegate, UITextFieldDelegate>

@property (nonatomic, strong) AppDelegate *app;

@property (nonatomic, retain) NSTimer *timer;

@property (nonatomic) int secondsToConfirm;

@property (nonatomic, strong) UITextField *txtSubject;
@property (nonatomic, strong) UIDatePicker *pickFrom;
@property (nonatomic, strong) UIPickerView *pickDuration;
@property (nonatomic, strong) UILabel *lblAutoclose;
@property (nonatomic, strong) UIButton *btnBook;

@property (nonatomic, strong) NSDate *date;
@property (nonatomic, strong) NSCalendar *dateCalendar;
@property (nonatomic, strong) NSDateComponents *secondComponent;

@property (nonatomic, strong) NSArray *durationFixed;
@property (nonatomic, strong) NSMutableArray *durationDynamic;
@end

@implementation BookViewController

-(instancetype)init {
    self = [super init];
    
    if(self) {
        _app = (AppDelegate *)[[UIApplication sharedApplication] delegate];

        _secondsToConfirm = 300;
        
        _date = [NSDate date];
        _dateCalendar = [NSCalendar currentCalendar];
        _secondComponent = [[NSDateComponents alloc]init];
        _secondComponent.second = 1;
        
        _durationFixed = @[@{@"text": NSLocalizedString(@"15 minuten", nil), @"minutes": [NSNumber numberWithInt:15]},
                           @{@"text": NSLocalizedString(@"30 minuten", nil), @"minutes": [NSNumber numberWithInt:30]},
                           @{@"text": NSLocalizedString(@"1 uur", nil), @"minutes": [NSNumber numberWithInt:60]},
                           @{@"text": NSLocalizedString(@"2 uren", nil), @"minutes": [NSNumber numberWithInt:120]},
                           @{@"text": NSLocalizedString(@"4 uren", nil), @"minutes": [NSNumber numberWithInt:240]},
                           @{@"text": NSLocalizedString(@"8 uren", nil), @"minutes": [NSNumber numberWithInt:480]}];
        
        _durationDynamic = [[NSMutableArray alloc]init];
        
    }
    
    return self;
}

-(instancetype)initWithDate:(NSDate *)date {
    self = [self init];
    
    if(self) {
        _date = date;
    }
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    self.view.backgroundColor = [UIColor whiteColor];

    UINavigationBar *navBar = [[UINavigationBar alloc]initWithFrame:CGRectMake(0, 0, WIDTH(self.view), 44)];
    UINavigationItem *navTitle = [[UINavigationItem alloc]initWithTitle:NSLocalizedString(@"Book room", nil)];
    navTitle.leftBarButtonItem = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:nil action:@selector(cancel)];
    navTitle.leftBarButtonItem.title = NSLocalizedString(@"Cancel", nil);
    navTitle.rightBarButtonItem = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:nil action:@selector(bookNow)];
    navTitle.rightBarButtonItem.title = NSLocalizedString(@"Book now", nil);
    navBar.items = @[navTitle];
    navBar.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    [self.view addSubview:navBar];

    _txtSubject = [[UITextField alloc]initWithFrame:CGRectMake(20, 45, WIDTH(self.view) - 40, 66)];
    _txtSubject.placeholder = NSLocalizedString(@"Your name", nil);
    _txtSubject.delegate = self;
    _txtSubject.font = [UIFont roomDefaultWithSize:30];
    _txtSubject.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    [self.view addSubview:_txtSubject];
    
    UIView *line1 = [[UIView alloc] initWithFrame:CGRectMake(0, 111, WIDTH(self.view), 1)];
    line1.backgroundColor = [UIColor roomLightGray];
    line1.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    [self.view addSubview:line1];
    
    _pickFrom = [[UIDatePicker alloc]initWithFrame:CGRectMake(0, 112, WIDTH(self.view), 44)];
    _pickFrom.minuteInterval = 5;
    _pickFrom.date = _date;
    _pickFrom.minimumDate=[NSDate date];
    _pickFrom.datePickerMode = UIDatePickerModeDateAndTime;
    _pickFrom.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    [_pickFrom addTarget:self action:@selector(pickFromChanged:) forControlEvents:UIControlEventValueChanged];
    [self.view addSubview:_pickFrom];
    
    UIView *line2 = [[UIView alloc] initWithFrame:CGRectMake(0, 112 + HEIGHT(_pickFrom), WIDTH(self.view), 1)];
    line2.backgroundColor = [UIColor roomLightGray];
    line2.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    [self.view addSubview:line2];
    
    _pickDuration = [[UIPickerView alloc]initWithFrame:CGRectMake(0, 113 + HEIGHT(_pickFrom), WIDTH(self.view), 44)];
    _pickDuration.delegate = self;
    _pickDuration.showsSelectionIndicator = YES;
    _pickDuration.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    [self.view addSubview:_pickDuration];
    
    UIView *line3 = [[UIView alloc] initWithFrame:CGRectMake(0, 112 + HEIGHT(_pickFrom) + HEIGHT(_pickDuration), WIDTH(self.view), 1)];
    line3.backgroundColor = [UIColor roomLightGray];
    line3.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    [self.view addSubview:line3];
    
    _btnBook = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    _btnBook.frame = CGRectMake(0, 113 + HEIGHT(_pickFrom) + HEIGHT(_pickDuration), WIDTH(self.view), (HEIGHT(self.view) - 44 - 113 - HEIGHT(_pickFrom) - HEIGHT(_pickDuration)) );
    _btnBook.titleLabel.font = [UIFont systemFontOfSize:50];
    _btnBook.titleLabel.textAlignment = NSTextAlignmentCenter;
    [_btnBook setTitle:NSLocalizedString(@"Book now", nil) forState:UIControlStateNormal];
    _btnBook.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self.view addSubview:_btnBook];
    [_btnBook addTarget:self
                action:@selector(bookNow)
      forControlEvents:UIControlEventTouchUpInside];

    _lblAutoclose = [[UILabel alloc]initWithFrame:CGRectMake(0, HEIGHT(self.view)-44, WIDTH(self.view), 44)];
    int minutes = (_secondsToConfirm % 3600) / 60;
    int seconds = (_secondsToConfirm % 3600) % 60;
    _lblAutoclose.text = [NSString stringWithFormat:NSLocalizedString(@"Close in %02d:%02d", nil), minutes, seconds];
    _lblAutoclose.textAlignment = NSTextAlignmentCenter;
    _lblAutoclose.backgroundColor = [UIColor roomLightGray];
    _lblAutoclose.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleWidth;
    [self.view addSubview:_lblAutoclose];

    
    
    //[self.view layoutSubviews];

    
}



-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];

    _timer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(countdown:) userInfo:nil repeats:YES];
    [self reloadDurations];
}

-(void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [_timer invalidate];
}

// returns the number of 'columns' to display.
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 1;
}

// returns the # of rows in each component..
- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    return _durationDynamic.count;
}

// tell the picker the title for a given component
- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    return _durationDynamic[row][@"text"];
}

// tell the picker the width of each row for a given component
//- (CGFloat)pickerView:(UIPickerView *)pickerView widthForComponent:(NSInteger)component {
//    int sectionWidth = 300;
//    
//    return sectionWidth;
//}

- (void) pickFromChanged:(id)sender{
    //NSLog(@"picked date: %@", _pickFrom.date);
    [self reloadDurations];

}

-(void)reloadDurations {
    
    NSDate *freeUntil = [_app.eventManager freeUntil:_pickFrom.date];
    [_durationDynamic removeAllObjects];
    
    if(freeUntil == nil) {
        // no events found. Everything goes..
        for (NSDictionary *duration in _durationFixed) {
            [_durationDynamic addObject:duration];
        }
        
    } else if([_pickFrom.date compare:freeUntil] != NSOrderedDescending) {
        NSNumber *minutesBetween = [NSNumber numberWithFloat:([freeUntil timeIntervalSinceDate:_pickFrom.date] / 60)];

        for (NSDictionary *duration in _durationFixed) {
            if([duration objectForKey:@"minutes"])
                //NSLog(@"%f > %d", [(NSNumber *)duration[@"minutes"] floatValue], [minutesBetween intValue]);
                if([(NSNumber *)duration[@"minutes"] floatValue] <= [minutesBetween intValue]) {
                    [_durationDynamic addObject:duration];
                }
        }
        
        if([minutesBetween doubleValue] >= 5 && [minutesBetween doubleValue] < 480) {
            if([_dateCalendar isDate:_pickFrom.date inSameDayAsDate:freeUntil]) {
                NSDateFormatter *dateFormatter = [[NSDateFormatter alloc]init];
                [dateFormatter setDateFormat:@"HH:mm"];

                [_durationDynamic addObject:@{@"text": [NSString stringWithFormat:@"tot %@", [dateFormatter stringFromDate:freeUntil]],
                                              @"minutes": minutesBetween}];

            }
        }
    }
    
    if(_durationDynamic.count == 0) {
        [_durationDynamic addObject:@{@"text": @"BEZET",
                                      @"minutes": [NSNumber numberWithInt:0]}];
        _btnBook.enabled = NO;
    } else {
        _btnBook.enabled = YES;
    }
    
    [_pickDuration reloadAllComponents];
    [_pickDuration selectRow:2 inComponent:0 animated:YES];
    
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return NO;
}

-(void)cancel {
    [self dismissViewControllerAnimated:YES completion:^{
    
        NSLog(@"Closed modal");
    }];
}

-(void)bookNow {
    NSLog(@"Book Now");
    
    if(_app.eventManager.eventsAccessGranted) {
        // Create a new event object.
        EKEvent *event = [EKEvent eventWithEventStore:_app.eventManager.eventStore];
        event.calendar = _app.eventManager.calendar;
        
        event.title = _txtSubject.text;
        if(event.title.length <= 1) {
            event.title = NSLocalizedString(@"Roomplanner booking", nil);
        }
        
        event.startDate = _pickFrom.date;

        NSCalendar *dateCalendar = [NSCalendar currentCalendar];
        NSDateComponents *dateComponent = [[NSDateComponents alloc] init];
        dateComponent.minute = [(NSNumber *)_durationDynamic[[_pickDuration selectedRowInComponent:0]][@"minutes"] intValue];

        event.endDate = [dateCalendar dateByAddingComponents:dateComponent toDate:event.startDate options:0];
        
        //[_app.eventManager getEventsBetween:event.startDate and:event.endDate];
        
        // Let the nav controller know of the added event so it can go directly to 'busy' when booked 'now'
        //[[NSNotificationCenter defaultCenter] postNotificationName:@"CreatedAnEvent" object:event];
        if([[NSDate date] timeIntervalSinceDate:event.startDate] >= 0) {
            _app.navController.addedEvent = event;
        }

        // Save and commit the event.
        NSError *error;
        if ([_app.eventManager.eventStore saveEvent:event span:EKSpanThisEvent commit:YES error:&error]) {
            //NSLog(@"Event was saved: %@", event);
            [self dismissViewControllerAnimated:YES completion:nil];

        }
        else{
            // An error occurred, so log the error description.
            NSLog(@"%@", [error localizedDescription]);
        }


    }
    
    
    
}

-(void)countdown:(NSTimer*)timer {
    _secondsToConfirm -= 1;
    
    if(_secondsToConfirm < 0) {
        [_timer invalidate];
        [self cancel];
        
    } else {
        int minutes = (_secondsToConfirm % 3600) / 60;
        int seconds = (_secondsToConfirm % 3600) % 60;
        _lblAutoclose.text = [NSString stringWithFormat:NSLocalizedString(@"Close in %02d:%02d", nil), minutes, seconds];
    }
    
}

@end
