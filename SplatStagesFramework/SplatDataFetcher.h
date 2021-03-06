//
//  SplatDataFetcher.h
//  SplatStages
//
//  Created by mac on 2015-09-25.
//  Copyright © 2015 OatmealDome. All rights reserved.
//

@interface SplatDataFetcher : NSObject

//! Downloads a file and returns an NSData instance of the file to the completionHandler.
+ (void) downloadFile:(NSString *) urlString completionHandler:(void (^)(NSData* data, NSError* error)) completionHandler;

//! Downloads and attempts to parse some JSON data. An NSDictionary instance is returned to the completionHandler.
+ (void) downloadAndParseJson:(NSString*) urlString completionHandler:(void (^)(id parsedJson, NSError* error)) completionHandler;

//! [DEPRECATED] Requests stage data from splatoon.ink.
+ (void) requestStageDataWithCallback:(void (^)(NSNumber* mode)) updateCallback errorHandler:(void (^)(NSError* error, NSString* when)) errorHandler;

//! Requests schedule data.
+ (void) getSchedule:(void (^)()) completionHandler errorHandler:(void (^)(NSError* error, NSString* when)) errorHandler;

//! Requests Splatfest data from oatmealdome.github.io.
+ (void) requestFestivalDataWithCallback:(void (^)()) updateCallback errorHandler:(void (^)(NSError* error, NSString* when)) errorHandler;

//! Returns a configured NSURLSession instance.
+ (NSURLSession*) dataSession;

@end