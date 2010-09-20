//
//  NotificationController.h
//  fotoaday
//
//  Created by Ben Maslen on 20/09/2010.
//  Copyright 2010 wgrids. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface NotificationController : NSObject {}

+ (void) createNextNotification;
+ (NSString *) currentDayCount;

@end
