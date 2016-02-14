//
//  SplatNetLoginViewController.m
//  SplatStages
//
//  Created by mac on 2016-02-13.
//  Copyright © 2016 OatmealDome. All rights reserved.
//

#import <MBProgressHUD/MBProgressHUD.h>

#import <SplatStagesFramework/SplatSquidRingHelper.h>
#import <SplatStagesFramework/SplatUtilities.h>

#import "SplatNetLoginViewController.h"
#import "TabViewController.h"

@interface SplatNetLoginViewController ()

@end

@implementation SplatNetLoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Set the contents of the text fields.
	VALValet* valet = [SplatUtilities getValet];
	if (![valet canAccessKeychain]) {
		NSString* alertText = [NSString stringWithFormat:@"%@\n\n%@%@\n\n%@", [SplatUtilities localizeString:@"ERROR_SPLATNET_LOG_IN"], [SplatUtilities localizeString:@"ERROR_INTERNAL_DESCRIPTION"], [SplatUtilities localizeString:@"ERROR_KEYCHAIN_ACCESS_DESCRIPTION"], NSLocalizedString(@"ERROR_SETTINGS_NOT_SAVED", nil)];
		UIAlertView* errorAlert = [[UIAlertView alloc] initWithTitle:[SplatUtilities localizeString:@"ERROR_TITLE"] message:alertText delegate:nil cancelButtonTitle:NSLocalizedString(@"CONFIRM", nil) otherButtonTitles:nil, nil];
		[errorAlert show];
	}
	
	[self.usernameField setText:[valet stringForKey:@"username"]];
	[self.passwordField setText:[valet stringForKey:@"password"]];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) tableView:(UITableView*) tableView didSelectRowAtIndexPath:(NSIndexPath*) indexPath {
	if (indexPath.section == 1) {
		// Create a new MBProgressHUD attached to the view.
		[MBProgressHUD hideAllHUDsForView:self.view.superview animated:true];
		MBProgressHUD* loadingHud = [MBProgressHUD showHUDAddedTo:self.view.superview animated:YES];
		loadingHud.mode = MBProgressHUDModeIndeterminate;
		loadingHud.labelText = NSLocalizedString(@"LOGGING_IN", nil);
		
		// Temporarily disable the back button.
		[self.navigationItem setHidesBackButton:true animated:true];
		
		// Save the user's credentials.
		VALValet* valet = [SplatUtilities getValet];
		if (![valet canAccessKeychain]) {
			NSString* alertText = [NSString stringWithFormat:@"%@\n\n%@%@\n\n%@", [SplatUtilities localizeString:@"ERROR_SPLATNET_LOG_IN"], [SplatUtilities localizeString:@"ERROR_INTERNAL_DESCRIPTION"], [SplatUtilities localizeString:@"ERROR_KEYCHAIN_ACCESS_DESCRIPTION"], NSLocalizedString(@"ERROR_SETTINGS_NOT_SAVED", nil)];
			UIAlertView* errorAlert = [[UIAlertView alloc] initWithTitle:[SplatUtilities localizeString:@"ERROR_TITLE"] message:alertText delegate:nil cancelButtonTitle:NSLocalizedString(@"CONFIRM", nil) otherButtonTitles:nil, nil];
			[errorAlert show];
			
			[self resetUI];
		}
		
		[valet setString:self.usernameField.text forKey:@"username"];
		[valet setString:self.passwordField.text forKey:@"password"];
		
		// Attempt to log in!
		[SplatSquidRingHelper loginToSplatNet:^{
			// Show a settings saved alert
			dispatch_async(dispatch_get_main_queue(), ^{
				UIAlertView* finishAlert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"SETTINGS_SAVED_TITLE", nil) message:NSLocalizedString(@"SETTINGS_SAVED_TEXT", nil) delegate:nil cancelButtonTitle:NSLocalizedString(@"CONFIRM", nil) otherButtonTitles:nil, nil];
				[finishAlert show];
			
				[self resetUI];
			});
		} errorHandler:^(NSError* error, NSString* when) {
			dispatch_async(dispatch_get_main_queue(), ^{
				TabViewController* rootController = (TabViewController*) [self tabBarController];
				[rootController errorOccurred:error when:when];
			
				[self resetUI];
			});

		}];
	}
	
	[self.tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (void) resetUI {
	// Undo temporary changes to the UI.
	[MBProgressHUD hideAllHUDsForView:self.view.superview animated:true];
	[self.navigationItem setHidesBackButton:false animated:true];
}

@end
