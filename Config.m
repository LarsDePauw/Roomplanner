//
//  Config.m
//  Roomplanner02
//
//  Created by Tiele Declercq on 15/01/15.
//  Copyright (c) 2015 Tiele Declercq. All rights reserved.
//

#import "Config.h"


@interface Config ()


@end

@implementation Config

// Static width values for easy passing across controllers
static CGFloat widthOfLeftFrame, widthOfRightFrame;

+(CGFloat)getWidthOfLeftFrame {
    return widthOfLeftFrame;
}

+(void)setWidthOfLeftFrame:(CGFloat)frame {
    widthOfLeftFrame = frame;
}

+(CGFloat)getWidthOfRightFrame {
    return widthOfRightFrame;
}

+(void)setWidthOfRightFrame:(CGFloat)frame {
    widthOfRightFrame = frame;
}

// Start SMTP session using user settings
+(MCOSMTPSession *)SMTPSession {
    // Start session if enabled in settings
    if([[NSUserDefaults standardUserDefaults] boolForKey:@"roomShouldSendMail"]) {
        MCOSMTPSession *smtpSession;
        smtpSession = [[MCOSMTPSession alloc] init];
        
//        smtpSession.connectionLogger = ^(void * connectionID, MCOConnectionLogType type, NSData * data) {
//            NSLog(@"data: %@", [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
//        };
        
        smtpSession.hostname = [[NSUserDefaults standardUserDefaults] stringForKey:@"smtpHost"];
        
        NSNumber *port = [[NSNumberFormatter alloc] numberFromString:[[NSUserDefaults standardUserDefaults] stringForKey:@"smtpPort"]];
        smtpSession.port = [port unsignedIntValue];
        
        switch ([[NSUserDefaults standardUserDefaults] integerForKey:@"smtpAuth"]) {
            case 0:
                smtpSession.connectionType = MCOConnectionTypeClear;
                break;
            case 1:
                smtpSession.connectionType = MCOConnectionTypeStartTLS;
                break;
            case 2:
                smtpSession.connectionType = MCOConnectionTypeTLS;
                break;
            default:
                smtpSession.connectionType = MCOConnectionTypeClear;
                break;
        }
        
        // Apply user & pass if given. Should only be the case when connection is clear.
        // I.e. smtp.telenet.be when on a telenet connection. No authentication is required
        if(![[[NSUserDefaults standardUserDefaults] stringForKey:@"smtpUser"] isEqualToString:@""]) {
            smtpSession.username = [[NSUserDefaults standardUserDefaults] stringForKey:@"smtpUser"];
            smtpSession.password = [[NSUserDefaults standardUserDefaults] stringForKey:@"smtpPassword"];
        }
        
        if(smtpSession.hostname.length < 2 || smtpSession.port < 1 || (smtpSession.connectionType != MCOConnectionTypeClear && (smtpSession.username.length < 1 || smtpSession.password.length < 1))) {
            // Insufficient data to start this an smtp session
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Missing SMTP information in settings!" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alert show];
            return nil;
        }
        return smtpSession;
    } else {
        return nil;
    }
}

@end
