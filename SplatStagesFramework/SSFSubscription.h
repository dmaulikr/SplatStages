//
//  SSFSubscription.h
//  SplatStages
//
//  Created by mac on 2016-02-13.
//  Copyright © 2016 OatmealDome. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, SubscriptionType) {
	STAGE,
	GAMEMODE,
	SPLATFEST,
	UNKNOWN
};

typedef NS_ENUM(NSUInteger, RotationNumber) {
	ZERO,
	ONE,
	TWO
};

@interface SSFSubscription : NSObject

@property (atomic) SubscriptionType subscriptionType;
@property (atomic) RotationNumber rotationNumber;
@property (strong, atomic) NSString* localizableMap;
@property (strong, atomic) NSString* localizableGamemode;
@property (strong, atomic) NSString* internalRegion;

- (id) initWithType:(SubscriptionType) type rotationNumber:(RotationNumber) rotNum map:(NSString*) map gamemode:(NSString*) gamemode;

- (id) initFromTag:(NSString*) tag;

- (NSString*) toTag;

- (NSString*) toString;

@end
