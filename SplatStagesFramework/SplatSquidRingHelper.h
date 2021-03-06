//
//  SplatOAuthHelper.h
//  SplatStages
//
//  Created by mac on 2015-11-21.
//  Copyright © 2015 OatmealDome. All rights reserved.
//

@interface SplatSquidRingHelper : NSObject

+ (void) loginToSplatNet:(void (^)()) completionHandler errorHandler:(void (^)(NSError* error, NSString* when)) errorHandler;

+ (void) getOnlineFriends:(void (^)(NSDictionary* onlineFriends)) completionHandler errorHandler:(void (^)(NSError* error, NSString* when)) errorHandler;

+ (void) getSchedule:(void (^)(NSMutableArray* schedule)) completionHandler errorHandler:(void (^)(NSError* error, NSString* when)) errorHandler;

+ (void) logout:(void (^)()) completionHandler errorHandler:(void (^)(NSError* error, NSString* when)) errorHandler;

+ (void) checkIfLoggedIn:(void (^)(BOOL)) completionHandler errorHandler:(void (^)(NSError* error, NSString* when)) errorHandler;

+ (BOOL) splatNetCredentialsSet;

@end