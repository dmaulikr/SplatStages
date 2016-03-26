//
//  SubscriptionsViewController.m
//  SplatStages
//
//  Created by mac on 2015-10-18.
//  Copyright © 2015 OatmealDome. All rights reserved.
//

#import <MBProgressHUD/MBProgressHUD.h>

#import <SplatStagesFramework/SSFSubscription.h>

#import "AppDelegate.h"
#import "SubscriptionCell.h"
#import "SubscriptionsViewController.h"
#import "TabViewController.h"

@interface SubscriptionsViewController ()

@end

@implementation SubscriptionsViewController

- (void) viewDidLoad {
    [super viewDidLoad];
	
	self.subscriptions = nil;
}

- (void) viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];
	
#ifdef ONESIGNAL_APPLICATION_KEY
	// Check if notifications are enabled
	if (![[UIApplication sharedApplication] isRegisteredForRemoteNotifications]) {
		// Turn away the user.
		UIAlertView* disabledAlert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"SETTINGS_NOTIFICATIONS_DISABLED_TITLE", nil) message:NSLocalizedString(@"SETTINGS_NOTIFICATIONS_DISABLED_TEXT", nil) delegate:nil cancelButtonTitle:NSLocalizedString(@"CONFIRM", nil) otherButtonTitles:nil, nil];
		[disabledAlert show];
		[self.navigationController popViewControllerAnimated:true];
	}
	
	// Temporarily set this to nil so we can load it in the background
	self.subscriptions = nil;
	
	// Show a loading UI and hide the back button
	[self showLoadingUIWithText:@"LOADING"];
	
	// Load the tags.
	[[self getOneSignal] getTags:^(NSDictionary* tags) {
		self.subscriptions = [[NSMutableArray alloc] init];
		for (NSString* tag in [tags allKeys]) {
			if ([tag isEqualToString:@"region"]) {
				// Don't show the region tag
				continue;
			}
			[self.subscriptions addObject:[[SSFSubscription alloc] initFromTag:tag]];
		}
		dispatch_async(dispatch_get_main_queue(), ^{
			[self.tableView reloadData];
			[self resetUI];
		});
	} onFailure:^(NSError* error) {
		dispatch_async(dispatch_get_main_queue(), ^{
			TabViewController* rootController = (TabViewController*) [self tabBarController];
			[rootController errorOccurred:error when:@"ERROR_LOADING_NOTIFICATION_SUBSCRIPTIONS"];
			[self resetUI];
			[self.navigationController popViewControllerAnimated:true];
		});
	}];
#else
	// ONESIGNAL_APPLICATION_KEY is not available... Turn away the user.
	self.subscriptions = nil;
	
	// Show an alert.
	UIAlertView* disabledAlert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"ERROR_ONESIGNAL_KEY_MISSING_TITLE", nil) message:NSLocalizedString(@"ERROR_ONESIGNAL_KEY_MISSING_TEXT", nil) delegate:nil cancelButtonTitle:NSLocalizedString(@"CONFIRM", nil) otherButtonTitles:nil, nil];
	[disabledAlert show];
	
	// Pop the view controller.
	[self.navigationController popViewControllerAnimated:true];
#endif
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSInteger) numberOfSectionsInTableView:(UITableView*) tableView {
    return 2;
}

- (NSInteger) tableView:(UITableView*) tableView numberOfRowsInSection:(NSInteger) section {
    if (section == 0) { // Add Subscription section
        return 1;
    } else {
		return (self.subscriptions == nil) ? 1 : self.subscriptions.count;
    }
}

- (UITableViewCell*) tableView:(UITableView*) tableView cellForRowAtIndexPath:(NSIndexPath*) indexPath {
	if (indexPath.section == 0) {
		UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:@"addCell" forIndexPath:indexPath];
		return cell;
	} else {
		SubscriptionCell* cell = (SubscriptionCell*) [tableView dequeueReusableCellWithIdentifier:@"subscriptionCell" forIndexPath:indexPath];
		
		if (self.subscriptions == nil) {
			[cell.label setText:NSLocalizedString(@"LOADING", nil)];
		} else {
			SSFSubscription* subscription = [self.subscriptions objectAtIndex:indexPath.row];
			[cell.label setText:[subscription toString]];
		}
		
		return cell;
	}
}

- (BOOL) tableView:(UITableView*) tableView canEditRowAtIndexPath:(NSIndexPath*) indexPath {
	return (indexPath.section != 0);
}

- (void) tableView:(UITableView*) tableView commitEditingStyle:(UITableViewCellEditingStyle) editingStyle forRowAtIndexPath:(NSIndexPath*) indexPath {
	if (editingStyle == UITableViewCellEditingStyleDelete) {
		// Show our loading UI
		[self showLoadingUIWithText:@"SAVING"];
		
		SSFSubscription* subscription = [self.subscriptions objectAtIndex:indexPath.row];
		[[self getOneSignal] deleteTag:[subscription toTag] onSuccess:^(NSDictionary* result) {
			dispatch_async(dispatch_get_main_queue(), ^{
				[self.subscriptions removeObjectAtIndex:indexPath.row];
				[tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationLeft];
				[self resetUI];
			});
		} onFailure:^(NSError* error) {
			dispatch_async(dispatch_get_main_queue(), ^{
				TabViewController* rootController = (TabViewController*) [self tabBarController];
				[rootController errorOccurred:error when:@"ERROR_SAVING_SUBSCRIPTION_UPDATE"];
				[self resetUI];
			});
		}];
	}
}

- (OneSignal*) getOneSignal {
	return [(AppDelegate*) ([[UIApplication sharedApplication] delegate]) oneSignal];
}

- (void) showLoadingUIWithText:(NSString*) text {
	// Create a new MBProgressHUD attached to the view.
	[MBProgressHUD hideAllHUDsForView:self.navigationController.view animated:true];
	MBProgressHUD* loadingHud = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
	loadingHud.mode = MBProgressHUDModeIndeterminate;
	loadingHud.labelText = NSLocalizedString(text, nil);
	
	// Hide the back button.
	[self.navigationItem setHidesBackButton:true animated:true];
}

- (void) resetUI {
	// Undo temporary changes to the UI.
	[MBProgressHUD hideAllHUDsForView:self.navigationController.view animated:true];
	[self.navigationItem setHidesBackButton:false animated:true];
}


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
