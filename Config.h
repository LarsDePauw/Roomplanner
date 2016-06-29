//
//  Config.h
//  Roomplanner02
//
//  Created by Tiele Declercq on 15/01/15.
//  Copyright (c) 2015 Tiele Declercq. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <MailCore/MailCore.h>

@interface Config : NSObject


+(CGFloat)getWidthOfLeftFrame;
+(void)setWidthOfLeftFrame:(CGFloat)frame;
+(CGFloat)getWidthOfRightFrame;
+(void)setWidthOfRightFrame:(CGFloat)frame;

+(MCOSMTPSession *)SMTPSession;

@end
