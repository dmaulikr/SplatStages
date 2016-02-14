//
//  SSFSubscription.m
//  SplatStages
//
//  Created by mac on 2016-02-13.
//  Copyright © 2016 OatmealDome. All rights reserved.
//

#import <SplatStagesFramework/SplatUtilities.h>

#import "SSFSubscription.h"

@implementation SSFSubscription

- (id) initWithType:(SubscriptionType) type rotationNumber:(RotationNumber) rotNum map:(NSString*) map gamemode:(NSString*) gamemode {
	if (self = [super init]) {
		self.subscriptionType = type;
		self.rotationNumber = rotNum;
		self.localizableMap = map;
		self.localizableGamemode = gamemode;
	}
	
	return self;
}

- (id) initFromTag:(NSString*) tag {
	if (self = [super init]) {
		NSArray* components = [tag componentsSeparatedByString:@":"];
		
		self.subscriptionType = [self typeFromComponent:[components objectAtIndex:0]];
		
		switch (self.subscriptionType) {
			case STAGE: {
				self.rotationNumber = [[components objectAtIndex:1] integerValue];
				self.localizableGamemode = [components objectAtIndex:2];
				self.localizableMap = [components objectAtIndex:3];
				break;
			}
			case GAMEMODE: {
				self.rotationNumber = [[components objectAtIndex:1] integerValue];
				self.localizableGamemode = [components objectAtIndex:2];
				break;
			}
			case SPLATFEST: {
				break;
			}
		}
	}
	
	return self;
}

- (NSString*) toTag {
	switch (self.subscriptionType) {
		case STAGE: {
			return [NSString stringWithFormat:@"S:%lu:%@:%@", (unsigned long) self.rotationNumber, self.localizableGamemode, self.localizableMap];
		}
		case GAMEMODE: {
			return [NSString stringWithFormat:@"G:%lu:%@", (unsigned long) self.rotationNumber, self.localizableGamemode];
		}
		case SPLATFEST: {
			return [NSString stringWithFormat:@"F"];
		}
	}
}

- (NSString*) toString {
	switch (self.subscriptionType) {
		case STAGE: {
			return [NSString stringWithFormat:@"%@ - %@: %@ rotation", [SplatUtilities localizeString:self.localizableGamemode], [SplatUtilities localizeString:self.localizableMap], [self stringFromRotationNumber:self.rotationNumber]];
		}
		case GAMEMODE: {
			return [NSString stringWithFormat:@"%@: %@ rotation", [SplatUtilities localizeString:self.localizableGamemode], [self stringFromRotationNumber:self.rotationNumber]];
		}
		case SPLATFEST: {
			return [NSString stringWithFormat:[SplatUtilities localizeString:@"SETTINGS_SPLATFEST_SUBSCRIPTION"], [[SplatUtilities getUserDefaults] objectForKey:@"regionUserFacing"]];
		}
	}
}

- (SubscriptionType) typeFromComponent:(NSString*) component {
	if ([component isEqualToString:@"S"]) {
		return STAGE;
	} else if ([component isEqualToString:@"G"]) {
		return GAMEMODE;
	} else if ([component isEqualToString:@"F"]) {
		return SPLATFEST;
	}
	
	// This should never happen.
	return STAGE;
}

- (NSString*) stringFromRotationNumber:(RotationNumber) rotationNumber {
	switch (rotationNumber) {
		case ZERO: {
			return [SplatUtilities localizeString:@"ROTATION_ZERO"];
		}
		case ONE: {
			return [SplatUtilities localizeString:@"ROTATION_ONE"];
		}
		case TWO: {
			return [SplatUtilities localizeString:@"ROTATION_TWO"];
		}
	}
}

@end
