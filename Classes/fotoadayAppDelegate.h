//
//  fotoadayAppDelegate.h
//  fotoaday
//
//  Created by Ben Maslen on 19/09/2010.
//  Copyright wgrids 2010. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MainViewController;

@interface fotoadayAppDelegate : NSObject <UIApplicationDelegate> {
    UIWindow *window;
    MainViewController *mainViewController;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet MainViewController *mainViewController;

@end

