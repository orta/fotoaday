//
//  fotoadayAppDelegate.m
//  fotoaday
//
//  Created by Ben Maslen on 19/09/2010.
//  Copyright wgrids 2010. All rights reserved.
//

#import "fotoadayAppDelegate.h"
#import "MainViewController.h"
#import "FlipsideViewController.h"

NSString *kStoredAuthTokenKeyName = @"FlickrAuthToken";
NSString *kGetAuthTokenStep = @"kGetAuthTokenStep";
NSString *kCheckTokenStep = @"kCheckTokenStep";

NSString *kGetUserInfoStep = @"kGetUserInfoStep";
NSString *kSetImagePropertiesStep = @"kSetImagePropertiesStep";
NSString *kUploadImageStep = @"kUploadImageStep";

@implementation fotoadayAppDelegate


@synthesize window;
@synthesize mainViewController, flipViewController;
@synthesize flickrContext, flickrUserName;


#pragma mark -
#pragma mark Application lifecycle

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {    
  [window addSubview:mainViewController.view];
  [window makeKeyAndVisible];
  [self performSelector:@selector(_applicationDidFinishLaunchingContinued) withObject:nil afterDelay:0.0];
  [mainViewController setStatus:@"loading"];
  return YES;
}

- (void)_applicationDidFinishLaunchingContinued {
	if ([self flickrRequest].sessionInfo) {
		// is getting auth token
		return;
	}
	
	if ([self.flickrContext.authToken length]) {

		[self flickrRequest].sessionInfo = kCheckTokenStep;
		[flickrRequest callAPIMethodWithGET:@"flickr.auth.checkToken" arguments:nil];
    [self callImagePicker];

	}else{

    FlipsideViewController *controller = [[FlipsideViewController alloc] initWithNibName:@"FlipsideView" bundle:nil];
    controller.delegate = self;    
    controller.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    [mainViewController presentModalViewController:controller animated:YES];
    
    [controller release];    
  }
}

-(void) applicationDidBecomeActive:(UIApplication *)application{
  [mainViewController setStatus:@"loading"];
  [self callImagePicker];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [mainViewController setStatus:@"no problem"];
  [mainViewController dismissModalViewControllerAnimated:YES];
}


- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingImage:(UIImage *)img editingInfo:(NSDictionary *)editInfo {
  [mainViewController dismissModalViewControllerAnimated:YES];
  [self performSelector:@selector(_startUpload:) withObject:img afterDelay:0.0];
}

- (void)_startUpload:(UIImage *)image {
  [mainViewController setStatus:@"uploading"];

  NSData *JPEGData = UIImageJPEGRepresentation(image, 1.0);
  self.flickrRequest.sessionInfo = kUploadImageStep;
  [self.flickrRequest uploadImageStream:[NSInputStream inputStreamWithData:JPEGData] suggestedFilename:@"" MIMEType:@"image/jpeg" arguments:[NSDictionary dictionaryWithObjectsAndKeys:@"0", @"is_public", nil]];
  
  [NotificationController createNextNotification];
}

- (void) callImagePicker{
  if ([mainViewController modalViewController]) {
    [mainViewController dismissModalViewControllerAnimated:YES];
  }
  
  if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera] == YES){
    [mainViewController setStatus:@"shooting"];
    UIImagePickerController * imagePicker = [[UIImagePickerController alloc] init];
    imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
    imagePicker.delegate = self;
    [mainViewController presentModalViewController:imagePicker animated:YES];     
    
  }else {
    
    [mainViewController setStatus:@"grabbing"];
    UIImagePickerController * imagePicker = [[UIImagePickerController alloc] init];
    imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    imagePicker.delegate = self;
    [mainViewController presentModalViewController:imagePicker animated:YES];      
  }  
}

- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url {
	// query has the form of "&frob=", the rest is the frob
	NSString *frob = [[url query] substringFromIndex:6];
	[self flickrRequest].sessionInfo = kGetAuthTokenStep;
	[flickrRequest callAPIMethodWithGET:@"flickr.auth.getToken" arguments:[NSDictionary dictionaryWithObjectsAndKeys:frob, @"frob", nil]];
		
  return YES;
}


#pragma mark FlipsideViewController delegate methods
- (void)flipsideViewControllerDidFinish:(FlipsideViewController *)controller {
  [mainViewController dismissModalViewControllerAnimated:YES];
}



#pragma mark OFFlickrAPIRequest delegate methods
- (void)flickrAPIRequest:(OFFlickrAPIRequest *)inRequest didCompleteWithResponse:(NSDictionary *)inResponseDictionary {
	
  // Token has been authed
  if (inRequest.sessionInfo == kGetAuthTokenStep) {
		[self setAndStoreFlickrAuthToken:[[inResponseDictionary valueForKeyPath:@"auth.token"] textContent]];
		self.flickrUserName = [inResponseDictionary valueForKeyPath:@"auth.user.username"];
    [mainViewController setStatus:[NSString stringWithFormat:@">_ %@", self.flickrUserName]];
    [self callImagePicker];

	}
  
  // Token has been checked on init
  else if (inRequest.sessionInfo == kCheckTokenStep) {
		self.flickrUserName = [inResponseDictionary valueForKeyPath:@"auth.user.username"];
	}
  
  // Image is uploaded, now set metadata
  if (inRequest.sessionInfo == kUploadImageStep) {    
    [mainViewController setStatus:@"almost there!"];    
    NSString *photoID = [[inResponseDictionary valueForKeyPath:@"photoid"] textContent];
    
    flickrRequest.sessionInfo = kSetImagePropertiesStep;
    
    NSMutableDictionary * attributes = [NSMutableDictionary dictionaryWithObject:photoID forKey:@"photo_id"];
    NSString *title = [NSString stringWithFormat:@"fotoaday %@", [NotificationController currentDayCount]];
    [attributes setObject:title forKey:@"title"];
    [flickrRequest callAPIMethodWithPOST:@"flickr.photos.setMeta" arguments:attributes];        		        
	}
  // Metadata set, app is done
  else if (inRequest.sessionInfo == kSetImagePropertiesStep) {
    [mainViewController setStatus:@"close me!"];
    
  }
  
  
}

- (void)flickrAPIRequest:(OFFlickrAPIRequest *)inRequest didFailWithError:(NSError *)inError {
	if (inRequest.sessionInfo == kGetAuthTokenStep) {
	}
	else if (inRequest.sessionInfo == kCheckTokenStep) {
		[self setAndStoreFlickrAuthToken:nil];
	}
	
	[[[[UIAlertView alloc] initWithTitle:@"API Failed" message:[inError description] delegate:nil cancelButtonTitle:@"Dismiss" otherButtonTitles:nil] autorelease] show];
}

- (void)setAndStoreFlickrAuthToken:(NSString *)inAuthToken {
  NSLog(@"storing token");
	if (![inAuthToken length]) {
		self.flickrContext.authToken = nil;
		[[NSUserDefaults standardUserDefaults] removeObjectForKey:kStoredAuthTokenKeyName];
	}
	else {
		self.flickrContext.authToken = inAuthToken;
		[[NSUserDefaults standardUserDefaults] setObject:inAuthToken forKey:kStoredAuthTokenKeyName];
	}
  [[NSUserDefaults standardUserDefaults] synchronize];

}


- (OFFlickrAPIContext *)flickrContext {
  if (!flickrContext) {
    flickrContext = [[OFFlickrAPIContext alloc] initWithAPIKey:@"c5b71af939768078d568e18fe8f504b4" sharedSecret:@"39fd6b8fa2b0aa30"];
    
    NSString *authToken;
    if (authToken = [[NSUserDefaults standardUserDefaults] objectForKey:kStoredAuthTokenKeyName]) {
      flickrContext.authToken = authToken;
      NSLog(@"Token found");
    }
  }
  
  return flickrContext;
}

- (OFFlickrAPIRequest *)flickrRequest {
	if (!flickrRequest) {
		flickrRequest = [[OFFlickrAPIRequest alloc] initWithAPIContext:self.flickrContext];
		flickrRequest.delegate = self;		
	}
	
	return flickrRequest;
}

+ (fotoadayAppDelegate *)sharedDelegate {
  return (fotoadayAppDelegate *)[[UIApplication sharedApplication] delegate];
}



- (void)applicationWillResignActive:(UIApplication *)application {
  /*
   Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
   Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
   */
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
  /*
   Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
   If your application supports background execution, called instead of applicationWillTerminate: when the user quits.
   */
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
  /*
   Called as part of  transition from the background to the inactive state: here you can undo many of the changes made on entering the background.
   */
}


- (void)applicationWillTerminate:(UIApplication *)application {
  /*
   Called when the application is about to terminate.
   See also applicationDidEnterBackground:.
   */
}


#pragma mark -
#pragma mark Memory management

- (void)applicationDidReceiveMemoryWarning:(UIApplication *)application {
  /*
   Free up as much memory as possible by purging cached data objects that can be recreated (or reloaded from disk) later.
   */
}


- (void)dealloc {
  [mainViewController release];
  [window release];
  
  [flickrContext release];
	[flickrRequest release];
	[flickrUserName release];
  
  [super dealloc];
}

@end
