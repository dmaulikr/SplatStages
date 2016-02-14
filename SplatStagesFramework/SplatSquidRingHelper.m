//
//  SplatOAuthHelper.m
//  SplatStages
//
//  Created by mac on 2015-11-21.
//  Copyright © 2015 OatmealDome. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <SplatStagesFramework/SplatDataFetcher.h>
#import <SplatStagesFramework/SSFRotation.h>
#import <SplatStagesFramework/SplatSquidRingHelper.h>
#import <SplatStagesFramework/SplatUtilities.h>

@interface SplatSquidRingHelper ()

@end

@implementation SplatSquidRingHelper

// url: https://id.nintendo.net/oauth/authorize
// client_id: 12af3d0a3a1f441eb900411bb50a835a
// redirect_uri: https://splatoon.nintendo.net/users/auth/nintendo/callback
// response_type: code
// https://id.nintendo.net/oauth/authorize?client_id=12af3d0a3a1f441eb900411bb50a835a&redirect_uri=https%3A%2F%2Fsplatoon.nintendo.net%2Fusers%2Fauth%2Fnintendo%2Fcallback&response_type=code&state=affc0e17abc5b5af65b9c6a592e5151081771b405be9530e

+ (void) loginToSplatNet:(void (^)()) completionHandler errorHandler:(void (^)(NSError* error, NSString* when)) errorHandler {
    // Check if we're logged in first
    [self checkIfLoggedIn:^(BOOL loggedIn) {
        
        // We're already logged in, so let's not log in again.
        if (loggedIn) {
            NSLog(@"logged in already");
            completionHandler();
            return;
        }
        
        // Get a Valet instance and check if it can access the keychain
        VALValet* valet = [SplatUtilities getValet];
        if (![valet canAccessKeychain]) {
            NSDictionary* userInfo = @{
                                       NSLocalizedDescriptionKey : [SplatUtilities localizeString:@"ERROR_KEYCHAIN_ACCESS_DESCRIPTION"]
                                       };
            NSError* error = [[NSError alloc] initWithDomain:@"me.oatmealdome.ios.SplatStages" code:1 userInfo:userInfo];
            errorHandler(error, [SplatUtilities localizeString:@"ERROR_SPLATNET_LOG_IN"]);
            return;
        }
        
        // Check if the user has an NNID set
        if ([valet stringForKey:@"username"] == nil || [valet stringForKey:@"password"] == nil) {
            NSDictionary* userInfo = @{
                                       NSLocalizedDescriptionKey : [SplatUtilities localizeString:@"ERROR_CREDENTIALS_NOT_SET"]
                                       };
            NSError* error = [[NSError alloc] initWithDomain:@"me.oatmealdome.ios.SplatStages" code:3 userInfo:userInfo];
            errorHandler(error, [SplatUtilities localizeString:@"ERROR_SPLATNET_LOG_IN"]);
            return;
        }
        
        NSURL* url = [NSURL URLWithString:@"https://id.nintendo.net/oauth/authorize"];
        NSMutableURLRequest* request = [[NSMutableURLRequest alloc] initWithURL:url];
        NSString* requestParameters = [NSString stringWithFormat:@"client_id=12af3d0a3a1f441eb900411bb50a835a&redirect_uri=https://splatoon.nintendo.net/users/auth/nintendo/callback&response_type=code&username=%@&password=%@", [valet stringForKey:@"username"], [valet stringForKey:@"password"]];
        
        [request setHTTPMethod:@"POST"];
        [request setHTTPBody:[requestParameters dataUsingEncoding:NSUTF8StringEncoding]];
        
        NSURLSession* session = [SplatDataFetcher dataSession];
        [[session dataTaskWithRequest:request completionHandler:^(NSData* data, NSURLResponse* response, NSError* taskError) {
            // Check for an error first
            if (taskError) {
                errorHandler(taskError, @"ERROR_SPLATNET_LOG_IN");
                return;
            }
            
            // Check if the log in was successful by looking for "ika_swim" in the page contents
            NSString* pageContents = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            NSRange range = [pageContents rangeOfString:@"ika_swim" options:NSCaseInsensitiveSearch];
            
            if (range.location == NSNotFound) {
                NSDictionary* userInfo = @{
                                           NSLocalizedDescriptionKey : [SplatUtilities localizeString:@"ERROR_LOG_IN_FAILED"]
                                           };
                NSError* error = [[NSError alloc] initWithDomain:@"me.oatmealdome.ios.SplatStages" code:2 userInfo:userInfo];
                errorHandler(error, [SplatUtilities localizeString:@"ERROR_SPLATNET_LOG_IN"]);
                return;
            }
            
            // Log in successful.
            completionHandler();
        }] resume];
        
    } errorHandler:^(NSError* error, NSString* when) {
        errorHandler(error, when);
    }];
}

+ (void) getSchedule:(void (^)(NSMutableArray* schedule)) completionHandler errorHandler:(void (^)(NSError* error, NSString* when)) errorHandler {
    [self checkIfLoggedIn:^(BOOL loggedIn) {
        if (loggedIn) {
            // We need the stage names in English, so signal to the server that we want the locale to be "en"
            [SplatDataFetcher downloadAndParseJson:@"https://splatoon.nintendo.net/schedule/index.json?locale=en" completionHandler:^(NSDictionary* json, NSError* error) {
                if (error) {
                    errorHandler(error, @"ERROR_LOADING_SPLATNET_SCHEDULES");
                    return;
                }
                
                // Check if there is an error object in the dictionary
                if ([json objectForKey:@"error"] != nil) {
                    NSDictionary* userInfo = @{
											   NSLocalizedDescriptionKey : [json objectForKey:@"error"]
                                               };
                    NSError* error = [[NSError alloc] initWithDomain:@"me.oatmealdome.ios.SplatStages" code:4 userInfo:userInfo];
                    errorHandler(error, [SplatUtilities localizeString:@"ERROR_LOADING_SPLATNET_SCHEDULES"]);
                    return;
                }
                
                // We're good! Start parsing the schedule data.
                NSMutableArray* schedules = [[NSMutableArray alloc] init];
                BOOL splatfest = [[json objectForKey:@"festival"] boolValue];
                
                if (!splatfest) {
                    for (NSDictionary* rotation in [json objectForKey:@"schedule"]) {
                        NSDate* startTime = [self parseDate:[rotation objectForKey:@"datetime_begin"]];
                        NSDate* endTime = [self parseDate:[rotation objectForKey:@"datetime_end"]];
                        NSString* rankedMode = [rotation objectForKey:@"gachi_rule"];
                        NSArray* regular = [[rotation objectForKey:@"stages"] objectForKey:@"regular"];
                        NSArray* ranked = [[rotation objectForKey:@"stages"] objectForKey:@"gachi"];
                        NSArray* stages = @[
                                            [[regular objectAtIndex:0] objectForKey:@"name"],
                                            [[regular objectAtIndex:1] objectForKey:@"name"],
                                            [[ranked objectAtIndex:0] objectForKey:@"name"],
                                            [[ranked objectAtIndex:1] objectForKey:@"name"]
                                            ];
                        
                        [schedules addObject:[[SSFRotation alloc] initWithStages:stages rankedMode:rankedMode startTime:startTime endTime:endTime]];
                    }
                    
                    if ([schedules count] < 3) {
                        while ([schedules count] < 3) {
                            [schedules addObject:[NSNull null]];
                        }
                        
                        [SplatUtilities mergeScheduleArray:schedules withArray:[SplatUtilities createUnknownSchedule]];
                    }
                    
                    completionHandler(schedules);
                } else {
                    // TODO handle Splatfest
                    
                    // Return an unknown schedule
                    completionHandler([SplatUtilities createUnknownSchedule]);
                }
            }];
        } else {
            [self loginToSplatNet:^{
                // Call this method again!
                [self getSchedule:completionHandler errorHandler:errorHandler];
            } errorHandler:^(NSError* error, NSString* when) {
                errorHandler(error, when);
            }];
        }
        
    } errorHandler:^(NSError* error, NSString* when) {
        errorHandler(error, when);
    }];
}

+ (void) getOnlineFriends:(void (^)(NSDictionary* onlineFriends)) completionHandler errorHandler:(void (^)(NSError* error, NSString* when)) errorHandler {
    [SplatDataFetcher downloadAndParseJson:@"https://splatoon.nintendo.net/friend_list/index.json" completionHandler:^(id onlineFriends, NSError* error) {
        if (error) {
            errorHandler(error, @"ERROR_LOADING_FRIENDS_LIST");
            return;
        }
        
        completionHandler(onlineFriends);
    }];
}

+ (void) logout:(void (^)()) completionHandler errorHandler:(void (^)(NSError* error, NSString* when)) errorHandler {
	NSURLSession* session = [SplatDataFetcher dataSession];
	NSURL* url = [NSURL URLWithString:@"https://splatoon.nintendo.net/sign_out"];
	
	[[session dataTaskWithURL:url completionHandler:^(NSData* data, NSURLResponse* response, NSError* taskError) {
		// Check for an error first
		if (taskError) {
			errorHandler(taskError, @"ERROR_SPLATNET_LOG_OUT");
			return;
		}
		
		// No data is returned for me after this request finishes, so let's just assume
		// that the logout was OK if there was no error raised by NSURLSession.
		completionHandler();
	}] resume];
}

+ (void) checkIfLoggedIn:(void (^)(BOOL)) completionHandler errorHandler:(void (^)(NSError* error, NSString* when)) errorHandler {
    [SplatDataFetcher downloadAndParseJson:@"https://splatoon.nintendo.net/friend_list/index.json" completionHandler:^(id json, NSError* error) {
        if (error) {
            errorHandler(error, @"ERROR_CHECKING_IF_LOGGED_IN");
            return;
        }
        
        // If an error is encountered, the server returns a dictionary
        completionHandler([json isKindOfClass:[NSArray class]]);
    }];
    
}

+ (BOOL) splatNetCredentialsSet {
    VALValet* valet = [SplatUtilities getValet];
    return ([valet stringForKey:@"username"] != nil && [valet stringForKey:@"password"] != nil);
}

+ (NSDate*) parseDate:(NSString*) string {
    static NSDateFormatter* dateFormatter = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setLocale:[NSLocale localeWithLocaleIdentifier:@"en_US_POSIX"]];
        // '.000' is a terrible hack, but I couldn't get it to work any other way
        [dateFormatter setDateFormat:@"yyyy'-'MM'-'dd'T'HH':'mm':'ss'.000'ZZZZZ"];
    });
    return [dateFormatter dateFromString:string];
}

@end