//
//  AddSubscriptionViewController.m
//  SplatStages
//
//  Created by mac on 2016-02-14.
//  Copyright © 2016 OatmealDome. All rights reserved.
//

#import <ActionSheetPicker-3.0/ActionSheetStringPicker.h>

#import <MBProgressHUD/MBProgressHUD.h>

#import <OneSignal/OneSignal.h>

#import <SplatStagesFramework/SSFSubscription.h>
#import <SplatStagesFramework/SplatDataFetcher.h>

#import "AddSubscriptionViewController.h"
#import "AppDelegate.h"
#import "TabViewController.h"

@interface AddSubscriptionViewController ()

@end

@implementation AddSubscriptionViewController

- (void) viewDidLoad {
    [super viewDidLoad];
	
	// Show our loading UI
	[self showLoadingUIWithText:@"LOADING"];
	
	// Fetch compatible gamemodes and stages
	[SplatDataFetcher downloadAndParseJson:@"https://oatmealdome.github.io/splatstages/compatible-push.json" completionHandler:^(NSDictionary* data, NSError* error) {
		if (error) {
			dispatch_async(dispatch_get_main_queue(), ^{
				[self errorOccurred:error when:@"ERROR_FETCHING_COMPATIBLE_DATA"];
				[self.navigationController popViewControllerAnimated:true];
			});
			return;
		}
		
		self.gamemodes = [data objectForKey:@"gamemodes"];
		self.stages = [data objectForKey:@"stages"];
		
		self.selectedGamemode = 255;
		self.selectedStage = 255;
		
		dispatch_async(dispatch_get_main_queue(), ^{
			[self resetUI];
		});
	}];
}

- (void) didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) tableView:(UITableView*) tableView didSelectRowAtIndexPath:(NSIndexPath*) indexPath {
	if (indexPath.section == 0) { // Save
		// Show our loading UI
		[self showLoadingUIWithText:@"SAVING"];
		
		// Verify that the required fields are set
		if ((self.selectedGamemode == 255 && self.typeControl.selectedSegmentIndex != 2) ||
			(self.selectedStage == 255 && self.typeControl.selectedSegmentIndex == 0) ||
			(self.rotationControl.selectedSegmentIndex == -1 && self.typeControl.selectedSegmentIndex != 2)) {
			UIAlertView* fillAllAlert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"SETTINGS_NOTIFICATIONS_FILL_ALL_TITLE", nil) message:NSLocalizedString(@"SETTINGS_NOTIFICATIONS_FILL_ALL_TEXT", nil) delegate:nil cancelButtonTitle:NSLocalizedString(@"CONFIRM", nil) otherButtonTitles:nil, nil];
			[fillAllAlert show];
			[self resetUI];
			[self.tableView deselectRowAtIndexPath:indexPath animated:true];
			return;
		}
		
		// Create a subscription object
		NSString* gamemode = (self.selectedGamemode > [self.gamemodes count]) ? nil : [self.gamemodes objectAtIndex:self.selectedGamemode];
		NSString* stage = (self.selectedStage > [self.stages count]) ? nil : [self.stages objectAtIndex:self.selectedStage];
		SSFSubscription* subscription = [[SSFSubscription alloc] initWithType:self.typeControl.selectedSegmentIndex rotationNumber:self.rotationControl.selectedSegmentIndex map:stage gamemode:gamemode];
		
		void (^tagSuccess)() = ^{
			dispatch_async(dispatch_get_main_queue(), ^{
				// Show a settings saved alert
				UIAlertView* finishAlert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"SETTINGS_SAVED_TITLE", nil) message:NSLocalizedString(@"SETTINGS_SAVED_TEXT", nil) delegate:nil cancelButtonTitle:NSLocalizedString(@"CONFIRM", nil) otherButtonTitles:nil, nil];
				[finishAlert show];
				
				// Reset the UI.
				[self resetUI];
				
				// Pop the view controller.
				[self.navigationController popViewControllerAnimated:true];
			});
		};
		
		void (^tagFailure)(NSError* error) = ^(NSError* error) {
			dispatch_async(dispatch_get_main_queue(), ^{
				[self errorOccurred:error when:@"ERROR_SENDING_SUBSCRIPTION"];
			});
		};
		
		// Send the subscription to OneSignal.
		OneSignal* oneSignal = [(AppDelegate*) ([[UIApplication sharedApplication] delegate]) oneSignal];
		[oneSignal sendTag:[subscription toTag] value:@"1" onSuccess:^(NSDictionary* result) {
			if (subscription.subscriptionType == SPLATFEST) {
				// Send a tag containing the user's region
				[oneSignal sendTag:@"region" value:[SplatUtilities getUserRegion] onSuccess:tagSuccess onFailure:tagFailure];
			} else {
				tagSuccess();
			}
		} onFailure:tagFailure];
	} else if (self.typeControl.selectedSegmentIndex != 2) {
		if (indexPath.row == 2) { // Gamemode
			NSMutableArray* localizedArray = [[NSMutableArray alloc] init];
			for (NSString* gamemode in self.gamemodes) {
				[localizedArray addObject:[SplatUtilities localizeString:gamemode]];
			}
			[ActionSheetStringPicker showPickerWithTitle:NSLocalizedString(@"SETTINGS_GAMEMODE_PICKER_TITLE", nil) rows:localizedArray initialSelection:0 doneBlock:^(ActionSheetStringPicker* picker, NSInteger selectedIndex, id selectedValue) {
				self.selectedGamemode = selectedIndex;
				[self.gamemodeLabel setText:selectedValue];
			} cancelBlock:^(ActionSheetStringPicker* picker) {
				// Do nothing.
			} origin:self.view];
		} else if (indexPath.row == 3 && self.typeControl.selectedSegmentIndex != 1) { // Stage
			NSMutableArray* localizedArray = [[NSMutableArray alloc] init];
			for (NSString* stage in self.stages) {
				[localizedArray addObject:[SplatUtilities localizeString:stage]];
			}
			[ActionSheetStringPicker showPickerWithTitle:NSLocalizedString(@"SETTINGS_STAGE_PICKER_TITLE", nil) rows:localizedArray initialSelection:0 doneBlock:^(ActionSheetStringPicker* picker, NSInteger selectedIndex, id selectedValue) {
				self.selectedStage = selectedIndex;
				[self.stageLabel setText:selectedValue];
			} cancelBlock:^(ActionSheetStringPicker* picker) {
				// Do nothing.
			} origin:self.view];
		}
	}
	
	[self.tableView deselectRowAtIndexPath:indexPath animated:true];
}

- (IBAction) typeChanged:(id) sender {
	switch (self.typeControl.selectedSegmentIndex) {
		case 0: {
			[self.rotationControl setEnabled:true];
			[self.rotationInfoLabel setTextColor:[UIColor blackColor]];
			[self.gamemodeInfoLabel setTextColor:[UIColor blackColor]];
			[self.stageInfoLabel setTextColor:[UIColor blackColor]];
			[self.gamemodeLabel setText:NSLocalizedString(@"SETTINGS_SELECT", nil)];
			[self.stageLabel setText:NSLocalizedString(@"SETTINGS_SELECT", nil)];
			break;
		}
		case 1: {
			[self.rotationControl setEnabled:true];
			[self.rotationInfoLabel setTextColor:[UIColor blackColor]];
			[self.gamemodeInfoLabel setTextColor:[UIColor blackColor]];
			[self.stageInfoLabel setTextColor:[UIColor lightGrayColor]];
			[self.gamemodeLabel setText:NSLocalizedString(@"SETTINGS_SELECT", nil)];
			[self.stageLabel setText:NSLocalizedString(@"SETTINGS_NOT_AVAILABLE", nil)];
			break;
		}
		case 2: {
			[self.rotationControl setEnabled:false];
			[self.rotationInfoLabel setTextColor:[UIColor lightGrayColor]];
			[self.gamemodeInfoLabel setTextColor:[UIColor lightGrayColor]];
			[self.stageInfoLabel setTextColor:[UIColor lightGrayColor]];
			[self.gamemodeLabel setText:NSLocalizedString(@"SETTINGS_NOT_AVAILABLE", nil)];
			[self.stageLabel setText:NSLocalizedString(@"SETTINGS_NOT_AVAILABLE", nil)];
			break;
		}
	}
	
	self.selectedGamemode = 255;
	self.selectedStage = 255;
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

- (void) errorOccurred:(NSError*) error when:(NSString*) when {
	TabViewController* rootController = (TabViewController*) [self tabBarController];
	[rootController errorOccurred:error when:when];
	
	[self resetUI];
}

@end
