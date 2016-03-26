//
//  SettingsViewController.h
//  SplatStages
//
//  Created by mac on 2015-09-11.
//  Copyright © 2015 OatmealDome. All rights reserved.
//

#ifdef DEBUG
#warning Debug build detected; the Report an Issue button will behave as a debug button.
#endif

#import <UIKit/UIKit.h>

@interface SettingsViewController : UITableViewController <UIAlertViewDelegate>

@property (weak, nonatomic) IBOutlet UILabel* regionLabel;
@property (weak, nonatomic) IBOutlet UISegmentedControl* rotationSelector;

@end

