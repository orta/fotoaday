//
//  NotificationController.m
//  fotoaday
//
//  Created by Ben Maslen on 20/09/2010.
//  Copyright 2010 wgrids. All rights reserved.
//

#import "NotificationController.h"


@implementation NotificationController

+ (void) createNextNotification{
  UILocalNotification *localNote = [[UILocalNotification alloc] init];
  NSDate * currentDate = [NSDate date];

  NSDateComponents * components = [[[NSDateComponents alloc] init] autorelease];
  [components setSecond:10];
  
  NSCalendar *gregorian = [[[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar] autorelease];
  NSDate *date = [gregorian dateByAddingComponents:components toDate:currentDate options:0];
  
  localNote.fireDate = date;
  localNote.alertBody = [NSString stringWithFormat:@"Hey buddy it's day %@", [self currentDayCount]];
  [[UIApplication sharedApplication] scheduleLocalNotification:localNote];
  
  NSLog(@"scheduledLocalNotifications are %@", [[UIApplication sharedApplication] scheduledLocalNotifications]);
 
  int count = [[NSUserDefaults standardUserDefaults] integerForKey:@"number_of_days"];
  if (!count) {
    count = 0;
  }
  count++;
  [[NSUserDefaults standardUserDefaults] setInteger:count forKey:@"number_of_days"];

  NSLog(@"DEATH?");
  
}

+ (NSString *) currentDayCount{
  return [NSString stringWithFormat: @"%i",  [[NSUserDefaults standardUserDefaults] integerForKey:@"number_of_days"]];
}
@end
