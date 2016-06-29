//
//  NowView.m
//  Roomplanner02
//
//  Created by Tiele Declercq on 17/01/15.
//  Copyright (c) 2015 Tiele Declercq. All rights reserved.
//

#import "NowView.h"
#import "UIFont+Roomplanner.h"
#import "UIColor+Roomplanner.h"

@interface NowView ()

@property (nonatomic, strong) UILabel *lblNow;
@property (nonatomic, strong) NSDateFormatter *dateFormatter;

@end

@implementation NowView

-(instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    
    if(self) {
        
        // transparant gradient background after label
        CAGradientLayer *gradient = [CAGradientLayer layer];
        gradient.frame = CGRectMake(0, 0, 40, 30);
        gradient.colors = [NSArray arrayWithObjects:
                           (id)[[UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:0] CGColor],
                           (id)[[UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:1] CGColor],
                           (id)[[UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:0] CGColor],
                           nil];
        [self.layer addSublayer:gradient];

        // Current time
        _lblNow = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 40, 28)];
        _lblNow.textAlignment = NSTextAlignmentRight;
        _lblNow.font = [UIFont roomBoldWithSize:14];
        _lblNow.textColor = [UIColor redColor];
        [self addSubview:_lblNow];

        _dateFormatter = [[NSDateFormatter alloc] init];
        [_dateFormatter setDateFormat:@"HH:mm"];
        
        [self setTime:[NSDate date]];

        // Line indicating current time
        UIView *line = [[UIView alloc] initWithFrame:CGRectMake(50, 15, self.frame.size.width - 50, 1)];
        line.backgroundColor = [UIColor redColor];
        [self addSubview:line];

        // Circle indicating current time
        UIView *circle = [[UIView alloc] initWithFrame:CGRectMake(45, 8, 14, 14)];
        circle.backgroundColor = [UIColor redColor];
        circle.layer.cornerRadius = 7.0;
        circle.layer.masksToBounds = YES;
        circle.layer.borderWidth = 1.0;
        circle.layer.borderColor = [[UIColor whiteColor]CGColor];
        [self addSubview:circle];

    }
    
    return self;
}

// Adjust label text to current time
-(void)setTime:(NSDate *)date {
    _lblNow.text = [_dateFormatter stringFromDate:date];
}

@end
