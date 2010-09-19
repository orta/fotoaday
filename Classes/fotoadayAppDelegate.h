//
//  fotoadayAppDelegate.h
//  fotoaday
//
//  Created by Ben Maslen on 19/09/2010.
//  Copyright wgrids 2010. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ObjectiveFlickr.h"
#import "FlipsideViewController.h"

@class MainViewController;
@class FlipsideViewController;

@interface fotoadayAppDelegate : NSObject <UIApplicationDelegate, OFFlickrAPIRequestDelegate, FlipsideViewControllerDelegate> {
  UIWindow *window;
  MainViewController *mainViewController;
  FlipsideViewController *flipViewController;
  
  NSString *flickrUserName;

  OFFlickrAPIContext *flickrContext;
	OFFlickrAPIRequest *flickrRequest;

}

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet MainViewController *mainViewController;
@property (nonatomic, retain) IBOutlet FlipsideViewController 
*flipViewController;

@property (nonatomic, readonly) OFFlickrAPIContext *flickrContext;
@property (nonatomic, retain) NSString *flickrUserName;

- (OFFlickrAPIContext *)flickrContext;
- (OFFlickrAPIRequest *)flickrRequest;

+ (fotoadayAppDelegate *)sharedDelegate;

- (void)setAndStoreFlickrAuthToken:(NSString *)inAuthToken;

@end