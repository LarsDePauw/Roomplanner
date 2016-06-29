//
//  CalendarViewController.m
//  Roomplanner02
//
//  Created by Tiele Declercq on 15/01/15.
//  Copyright (c) 2015 Tiele Declercq. All rights reserved.
//

#define DAYS_BEFORE 3
#define DAYS_AFTER 7
#define SECONDS_TO_SCROLL_BACK 5


#import "CalendarViewController.h"
#import "AppDelegate.h"
#import "BaseSplitViewController.h"
#import "DayView.h"
#import "Config.h"
#import "UIColor+Roomplanner.h"
#import "UIFont+Roomplanner.h"
#import "NSDate+Roomplanner.h"
#import "NowView.h"
#import "EventManager.h"
#import "BookViewController.h"

#import <TBMacros/Macros.h>


@interface CalendarViewController () <UITableViewDataSource, UITableViewDelegate, DayViewDelegate>

@property (nonatomic, strong) AppDelegate *app;

@property (nonatomic, strong) UITableView *uiScroller;
@property (nonatomic, strong) NSString *cellIdentifier;

@property (nonatomic, strong) UIImageView *imgLogoView;
@property (nonatomic, strong) UILabel *lblDate, *lblWeekday, *lblTime;
@property (nonatomic, strong) NowView *uiNow;

@property (nonatomic, strong) NSMutableArray *days;

@property (nonatomic, strong) NSDate *date;
@property (nonatomic, strong) NSDateComponents *dateComponent;
@property (nonatomic, strong) NSCalendar *dateCalendar;
@property (nonatomic, strong) NSDateFormatter *dateFormatter;

@property (nonatomic, strong) NSTimer *timerScrollBackToPosition;
@property (nonatomic, strong) NSDateComponents *minuteComponent;


@end

@implementation CalendarViewController

#pragma mark View methods

-(instancetype)init {
    
    self = [super init];
    
    if(self) {
        _app = (AppDelegate *)[[UIApplication sharedApplication] delegate];

        _days = [[NSMutableArray alloc] init];
        
        _date = [NSDate dateWithoutTime:nil];
        _dateComponent = [[NSDateComponents alloc] init];
        _dateCalendar = [NSCalendar currentCalendar];
        _dateFormatter = [[NSDateFormatter alloc] init];

        _minuteComponent = [[NSDateComponents alloc] init];
        _minuteComponent.minute = 1;

        for (int i = 0; i < (DAYS_BEFORE + DAYS_AFTER + 1); i++) {
            _dateComponent.day = i - DAYS_BEFORE;
            [_days addObject: [_dateCalendar dateByAddingComponents:_dateComponent toDate:_date options:0]];
        }
        
        _cellIdentifier = @"DayCell";
        
    }
    
    return self;
}

-(void)viewDidLoad {
    self.view.backgroundColor = [UIColor whiteColor];
    
    
    
    [self addLogo];
    
    
    [self addTime];
    
    [self addDate];
    
    [self addWeekday];
    
    [self updateLogo];

    [self setTopDate:[NSDate date]];
    
    [self addBorderBelowDate];
    
    
    [self addDayScroller];
    
    
    // Update clock and now-marker
    NSLog(@"Set updateEveryMinute to run at every MinuteHasPassed");
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(updateEveryMinute)
                                                 name:@"MinuteHasPassed"
                                               object:nil];
    
    // Update events when the calendar is accessible
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(eventsChanged:)
                                                 name:@"CalendarIsAccessible"
                                               object:nil];
    
    
    // Update events on visible cells when eventStore says 'something' changed
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(eventsChanged:)
                                                 name:EKEventStoreChangedNotification
                                               object:nil];
}

#pragma mark Add UI elements

- (void)addLogo {
    _imgLogoView = [[UIImageView alloc]initWithFrame:CGRectMake(20, 30, 100, 90)];
    _imgLogoView.contentMode = UIViewContentModeScaleAspectFit;
    [self.view addSubview: _imgLogoView];
    
    //[self updateLogo];
}

-(void)updateLogo {
    UIImage *imgLogo;
    if([[[NSUserDefaults standardUserDefaults] stringForKey:@"roomLogoURL"] isEqualToString:@""]) {
        // No logo has been set-up, use Roomplanner logo
        imgLogo = [UIImage imageNamed:@"Roomplanner"];
    } else {
        // A logo url has been set-up. Use stored logo if available. If empty, use roomplanner logo
        NSData *imgData = [[NSUserDefaults standardUserDefaults] objectForKey:@"roomStoredLogoData"];
        if(imgData == nil) {
            imgLogo = [UIImage imageNamed:@"Roomplanner"];
        } else {
            imgLogo = [UIImage imageWithData:imgData];
        }
        
        // Check if logo url has changed since last fetched
        NSString *imgCurrentURL = [[NSUserDefaults standardUserDefaults] stringForKey:@"roomLogoURL"];
        NSString *imgStoredURL = [[NSUserDefaults standardUserDefaults] stringForKey:@"roomStoredLogoURL"];
        if(![imgCurrentURL isEqualToString:imgStoredURL]) {
            // Logo URL has changed, fetch new image
            dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void){
                // Download image on background thread
                NSString *imgURL = [[NSUserDefaults standardUserDefaults] stringForKey:@"roomLogoURL"];
                NSData * imgData = [[NSData alloc] initWithContentsOfURL: [NSURL URLWithString:imgURL]];
                
                // Store the image in local settings (dirty!)
                [[NSUserDefaults standardUserDefaults] setValue:imgURL forKey:@"roomStoredLogoURL"];
                [[NSUserDefaults standardUserDefaults] setObject:imgData forKey:@"roomStoredLogoData"];
                
                // Update logo on UI thread
                dispatch_async(dispatch_get_main_queue(), ^(void){
                    [self updateLogo];
                });
            });
        }
    }
    
    CGRect imgFrame = _imgLogoView.frame;
    imgFrame.size.width = (imgFrame.size.height / imgLogo.size.height) * imgLogo.size.width;
    if(imgFrame.size.width > 180) imgFrame.size.width = 180;
    _imgLogoView.frame = imgFrame;
    _imgLogoView.image = imgLogo;
    
    if(_lblTime != nil) {
        CGRect frame = _lblTime.frame;
        frame.origin.x = imgFrame.origin.x + imgFrame.size.width;
        frame.size.width = [Config getWidthOfLeftFrame] - frame.origin.x;
        _lblTime.frame = frame;
    }
    
    if(_lblDate != nil) {
        CGRect frame = _lblDate.frame;
        frame.origin.x = imgFrame.origin.x + imgFrame.size.width;
        frame.size.width = [Config getWidthOfLeftFrame] - frame.origin.x;
        _lblDate.frame = frame;
    }
    
    if(_lblWeekday != nil) {
        CGRect frame = _lblWeekday.frame;
        frame.origin.x = imgFrame.origin.x + imgFrame.size.width;
        frame.size.width = [Config getWidthOfLeftFrame] - frame.origin.x;
        _lblWeekday.frame = frame;
    }
}

- (void)addTime {
    // Print day Monthname
    //_lblDate = [[UILabel alloc] initWithFrame: CGRectMake(130, 40, [Config getWidthOfLeftFrame] - 20, 50)];
    
    _lblTime = [[UILabel alloc] initWithFrame: CGRectMake(130, 30, [Config getWidthOfLeftFrame] - 150, 50)];
    _lblTime.font = [UIFont roomBoldWithSize:48];
    _lblTime.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview: _lblTime];
}

- (void)addDate {
    _lblDate = [[UILabel alloc] initWithFrame: CGRectMake(130, 80, [Config getWidthOfLeftFrame] - 150, 50)];
    _lblDate.font = [UIFont roomDefaultWithSize:28];
    _lblDate.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview: _lblDate];
}

- (void)addWeekday {
    _lblWeekday = [[UILabel alloc] initWithFrame: CGRectMake(130, 90, [Config getWidthOfLeftFrame] - 20, 40)];
    _lblWeekday.font = [UIFont roomLightWithSize:24];
    //[self.view addSubview: _lblWeekday];
}

- (void)addBorderBelowDate {
    // Border below weekday
    UIView *borderBelowWeekday = [[UIView alloc] initWithFrame: CGRectMake(20, 130, [Config getWidthOfLeftFrame] - 40, 4)];
    borderBelowWeekday.backgroundColor = [UIColor roomLightGray];
    [self.view addSubview:borderBelowWeekday];
}

- (void)addDayScroller {
    // Day scroller
    _uiScroller = [[UITableView alloc] initWithFrame:CGRectMake(20, 134, [Config getWidthOfLeftFrame] - 40, HEIGHT(self.view) - 134)];
    _uiScroller.dataSource = self;
    _uiScroller.delegate = self;
    _uiScroller.separatorColor = [UIColor clearColor];
    _uiScroller.allowsSelection = NO;
    [self.view addSubview:_uiScroller];
    
    [DayView setWidthOfCell:WIDTH(_uiScroller)];
    
    // 'Now' marker
    _uiNow = [[NowView alloc] initWithFrame:CGRectMake(0, 0, [Config getWidthOfLeftFrame] - 60, 20)];
    [_uiScroller addSubview:_uiNow];
    [self setNowMarker:[NSDate date]];
}

#pragma mark Day scroller implementation

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _days.count;
}

-(DayView *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    DayView *cell = [tableView dequeueReusableCellWithIdentifier:_cellIdentifier];
    if(cell == nil) {
        cell = [[DayView alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:_cellIdentifier];
        cell.delegate = self;
    }
    
    // Get date of cell
    NSDate *cellDate = _days[indexPath.row];
    [cell setDate:cellDate];
    
    // Get events of this cell
    NSArray *events = [_app.eventManager getEvents:cellDate];
    [cell setEvents:events];
    
    return cell;
}

-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    //NSLog(@"Display row %li, date %@", (long)indexPath.row, [(DayView *)cell getDate] );
    
//    if(indexPath.row > (_days.count - 5)) {
//        NSLog(@"Extend days!");
//        _dateComponent.day = 1;
//        [_days addObject: [_dateCalendar dateByAddingComponents:_dateComponent toDate:[(DayView *)cell getDate] options:0]];
//        [tableView reloadData];
//    }

    
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [DayView getHeightOfDay];
}


-(void)scrollViewDidScroll:(UIScrollView *)scrollView {
    [_timerScrollBackToPosition invalidate];
    _timerScrollBackToPosition = [NSTimer scheduledTimerWithTimeInterval:SECONDS_TO_SCROLL_BACK target:self selector:@selector(scrollToNow) userInfo:nil repeats:NO];
}

#pragma mark UI Updates

-(void)scrollToNow {
    [_uiScroller setContentOffset:CGPointMake(0, [self nowYposition] - 100) animated:YES];
}

-(CGFloat)nowYposition {
    NSUInteger dayIndex = [_days indexOfObjectIdenticalTo:[NSDate dateWithoutTime:[NSDate date]]];
    CGFloat yPos = ([DayView getHeightOfDay] * dayIndex);
    
    _dateComponent = [_dateCalendar components:(NSCalendarUnitHour | NSCalendarUnitMinute) fromDate:[NSDate date]];
    yPos += ([DayView getHeightOfHour] * _dateComponent.hour) + 15;
    yPos += ([DayView getHeightOfHour] / 60) * _dateComponent.minute;
    return yPos;
}

-(void)setTopDate:(NSDate *)date {
    [_dateFormatter setDateFormat:@"d MMMM YYYY"];
    _lblDate.text = [_dateFormatter stringFromDate:date];

    [_dateFormatter setDateFormat:@"HH:mm"];
    _lblTime.text = [_dateFormatter stringFromDate:date];
    
    [_dateFormatter setDateFormat:@"EEEE"];
    _lblWeekday.text = [_dateFormatter stringFromDate:date];
}

-(void)setNowMarker:(NSDate *)date {
    CGRect frame = _uiNow.frame;
    frame.origin.y = [self nowYposition] - 5;
    [_uiNow setFrame:frame];
    
    [_uiNow setTime:date];
    
    if(![_timerScrollBackToPosition isValid]) {
        [self scrollToNow];
    }
}


// Update clock and reset now-marker
-(void)updateEveryMinute {
    // Add a day at the end of the days array when the day has passed and reload the table
    NSDate *Today = [NSDate dateWithoutTime:nil];

    if(![Today isEqualToDate:_date]){
        NSLog(@"Shifted a day");
        _date = [NSDate dateWithoutTime:nil];
        [_days removeAllObjects];
        NSDateComponents *dayComponent = [[NSDateComponents alloc] init];
        for (int i = 0; i < (DAYS_BEFORE + DAYS_AFTER + 1); i++) {
            dayComponent.day = i - DAYS_BEFORE;
            [_days addObject: [_dateCalendar dateByAddingComponents:dayComponent toDate:_date options:0]];
        }
        [_uiScroller reloadData];
    }

    [self setTopDate:[NSDate date]];
    [self setNowMarker:[NSDate date]];
}

#pragma mark Listen for events

-(void)eventsChanged:(NSNotification *)notification {
    for (NSIndexPath *indexPath in [_uiScroller indexPathsForVisibleRows]) {
        // Get date of visible cell
        NSDate *cellDate = _days[indexPath.row];
        
        // Get events of this cell
        NSArray *events = [_app.eventManager getEvents:cellDate];
        
        DayView *cell = (DayView *)[_uiScroller cellForRowAtIndexPath:indexPath];
        
        if(cell.events != events) {
            [cell performSelectorOnMainThread:@selector(setEvents:)
                                   withObject:events
                                waitUntilDone:NO];
        }
        
    }
    
}

-(void)userTapped:(NSDate *)date {
    NSDate *tappedDate = [NSDate roundedAt30Minutes:date];
    NSDate *freeDate = [_app.eventManager freeFrom:tappedDate];
    
    if([date compare:[NSDate date]] == NSOrderedDescending) {
        BookViewController *modal = [[BookViewController alloc]initWithDate:freeDate];
        [modal setModalInPopover:YES];
        [modal setModalPresentationStyle:UIModalPresentationFormSheet];
        
        [self presentViewController:modal animated:YES completion:nil];
    }
}


@end
