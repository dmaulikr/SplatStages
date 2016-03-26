//
//  SettingsViewController.m
//  SplatStages
//
//  Created by mac on 2015-09-11.
//  Copyright © 2015 OatmealDome. All rights reserved.
//

#import <SplatStagesFramework/SplatUtilities.h>

#import "RegionViewController.h"
#import "SettingsViewController.h"
#import "TabViewController.h"

#import "AppDelegate.h"

@interface SettingsViewController ()

@end

@implementation SettingsViewController

- (void) viewDidLoad {
    [super viewDidLoad];
    
    // Setup the region label
    NSString* region = [[SplatUtilities getUserDefaults] objectForKey:@"regionUserFacing"];
    if (region == nil) {
        region = NSLocalizedString(@"REGION_UNKNOWN", nil);
    }
    [self.regionLabel setText:region];
    
    // Update status bar
    [self setNeedsStatusBarAppearanceUpdate];
}

- (IBAction) userSelectedRotation:(id) sender {
    TabViewController* rootController = (TabViewController*) [self tabBarController];
    [rootController setStages];
}

- (void) tableView:(UITableView*) tableView didSelectRowAtIndexPath:(NSIndexPath*) indexPath {
    if (indexPath.section == 1) {
        switch (indexPath.row) {
            case 0: { // Refresh Data cell
                TabViewController* rootController = (TabViewController*) [self tabBarController];
                [rootController refreshAllData];
                break;
            }
            case 1: { // Report an Issue cell
#ifdef DEBUG
				OneSignal* oneSignal = [(AppDelegate*) ([[UIApplication sharedApplication] delegate]) oneSignal];
				[oneSignal sendTag:@"ERRORS" value:@"1"]; // StageSignal errors
                //NSUserDefaults* defaults = [SplatUtilities getUserDefaults];
                //[defaults setObject:@"debug" forKey:@"region"];
                //[defaults synchronize];
#else
                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://github.com/OatmealDome/SplatStages/issues"]];
#endif
                break;
            }
            case 2: { // About cell
                NSString* displayName = [[[NSBundle mainBundle] localizedInfoDictionary] objectForKey:@"CFBundleDisplayName"];
                NSString* bundleVersion = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
                NSString* buildNumber = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"];
                NSString* aboutTitle = [NSString stringWithFormat:@"%@ (%@-%@)", displayName, bundleVersion, buildNumber];
                UIAlertView* aboutAlert = [[UIAlertView alloc] initWithTitle:aboutTitle message:NSLocalizedString(@"SETTINGS_ABOUT_TEXT", nil) delegate:nil cancelButtonTitle:NSLocalizedString(@"CONFIRM", nil) otherButtonTitles:nil, nil];
                [aboutAlert show];
                break;
            }
        }
    }
    [tableView deselectRowAtIndexPath:indexPath animated:true];
}

- (void) prepareForSegue:(UIStoryboardSegue*) segue sender:(id) sender {
    if ([[segue identifier] isEqualToString:@"regionSegue"]) {
        RegionViewController* regionVC = [segue destinationViewController];
        [regionVC setSettingsRegionLabel:self.regionLabel];
    }
}

- (UIStatusBarStyle) preferredStatusBarStyle {
    return UIStatusBarStyleDefault;
}

@end