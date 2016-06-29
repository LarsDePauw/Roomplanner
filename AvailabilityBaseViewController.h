//
//  AvailabilityBaseViewController.h
//  Roomplanner02
//
//  Created by Tiele Declercq on 15/01/15.
//  Copyright (c) 2015 Tiele Declercq. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AvailabilityBaseViewController : UIViewController

@property (nonatomic, strong) NSString *statusText;

-(instancetype)initWithBgColor:(UIColor *)bgColor andBorderColor:(UIColor *)borderColor;

@end
