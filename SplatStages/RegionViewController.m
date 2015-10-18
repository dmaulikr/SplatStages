//
//  RegionViewController.m
//  SplatStages
//
//  Created by mac on 2015-10-09.
//  Copyright © 2015 OatmealDome. All rights reserved.
//

#import "SplatStagesFramework/SplatUtilities.h"

#import "RegionViewController.h"
#import "TabViewController.h"

@interface RegionViewController ()

@end

@implementation RegionViewController

- (void) viewDidLoad {
    [super viewDidLoad];
    
    self.userFacingRegionStrings = @[
                           NSLocalizedString(@"REGION_NORTH_AMERICA", nil),
                           NSLocalizedString(@"REGION_EUROPE", nil),
                           NSLocalizedString(@"REGION_JAPAN", nil),
#ifdef DEBUG
                           NSLocalizedString(@"REGION_DEBUG", nil),
#endif
                           ];
    self.internalRegionStrings = @[ @"na", @"eu", @"jp", @"debug" ];
    
    [self selectRowWithRegion:[SplatUtilities getUserRegion]];
}

- (void) didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

// Thanks to Zyphrax at StackOverflow!
// http://stackoverflow.com/questions/2797165/uitableviewcell-checkmark-change-on-select
- (NSIndexPath*) tableView:(UITableView*) tableView willSelectRowAtIndexPath:(NSIndexPath*) indexPath {
    if (indexPath.section == 0) {
        [self.tableView cellForRowAtIndexPath:self.oldIndex].accessoryType = UITableViewCellAccessoryNone;
        [self.tableView cellForRowAtIndexPath:indexPath].accessoryType = UITableViewCellAccessoryCheckmark;
        self.oldIndex = indexPath;
    }
    
    return indexPath;
}

- (void) tableView:(UITableView*) tableView didSelectRowAtIndexPath:(NSIndexPath*) indexPath {
    if ((long) indexPath.section == 1) {
        // User tapped on Save, so let's do just that!
        NSLog(@"saving");
        NSString* chosenRegionInternal = [self.internalRegionStrings objectAtIndex:self.oldIndex.row];
        NSString* chosenRegionUser = [self.userFacingRegionStrings objectAtIndex:self.oldIndex.row];
        NSMutableString* finishText = [NSMutableString stringWithFormat:NSLocalizedString(@"SETTINGS_REGION_SET_TEXT", nil), chosenRegionUser];
        
        // Add the outdated message to the text if the user is not in the NA region
        if (![chosenRegionInternal isEqualToString:@"na"]) {
            [finishText appendString:[NSString stringWithFormat:@"\n\n%@", NSLocalizedString(@"SETTINGS_REGION_SET_TEXT_OUTDATED", nil)]];
        }
        
        // Show the region set alert
        UIAlertView* finishAlert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"SETTINGS_REGION_SET_TITLE", nil) message:finishText delegate:self cancelButtonTitle:NSLocalizedString(@"CONFIRM", nil) otherButtonTitles:nil, nil];
        [finishAlert show];
        
        // Update region label
        [self.settingsRegionLabel setText:chosenRegionUser];
        
        // Save this setting.
        NSUserDefaults* userDefaults = [SplatUtilities getUserDefaults];
        [userDefaults setObject:@1 forKey:@"setupFinished"];
        [userDefaults setObject:chosenRegionInternal forKey:@"region"];
        [userDefaults setObject:chosenRegionUser forKey:@"regionUserFacing"];
        [userDefaults synchronize];
        
        // Tell the TabViewController that it's okay to let the user out.
        TabViewController* rootController = (TabViewController*) self.tabBarController;
        rootController.needsInitialSetup = false;
        
        // Force a refresh of all the data.
        [rootController refreshAllData];
    }
    
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (void) selectRowWithRegion:(NSString*) region {
    NSIndexPath* index;
    if ([region isEqualToString:@"na"]) {
        index = [NSIndexPath indexPathForRow:0 inSection:0];
    } else if ([region isEqualToString:@"eu"]) {
        index = [NSIndexPath indexPathForRow:1 inSection:0];
    } else if ([region isEqualToString:@"jp"]) {
        index = [NSIndexPath indexPathForRow:2 inSection:0];
    } else {
        // This should *never* happen.
        index = nil;
    }
    
    [self.tableView selectRowAtIndexPath:index animated:false scrollPosition:UITableViewScrollPositionTop];

}

@end
