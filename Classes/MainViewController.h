//
//  MainViewController.h
//  fotoaday
//
//  Created by Ben Maslen on 19/09/2010.
//  Copyright wgrids 2010. All rights reserved.
//

#import "FlipsideViewController.h"

@interface MainViewController : UIViewController <FlipsideViewControllerDelegate> {
  IBOutlet UILabel *infoLabel;

}
- (void) setStatus:(NSString*) status;

- (IBAction)showInfo:(id)sender;

@end
