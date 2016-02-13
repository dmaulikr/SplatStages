//
//  SSFSplatfest.m
//  SplatStages
//
//  Created by mac on 2016-01-16.
//  Copyright © 2016 OatmealDome. All rights reserved.
//

#import <SplatStagesFramework/SplatUtilities.h>

#import "SSFSplatfest.h"

@implementation SSFSplatfest

- (id) init {
	if (self = [super init]) {
		self.startTime = [NSDate dateWithTimeIntervalSince1970:0];
		self.endTime = [NSDate dateWithTimeIntervalSince1970:0];
		self.teamOneName = @"UNKNOWN_TEAM_ONE";
		self.teamOneColour = [UIColor blueColor];
		self.teamTwoName = @"UNKNOWN_TEAM_TWO";
		self.teamTwoColour = [UIColor orangeColor];
		self.stageOne = @"UNKNOWN_MAP";
		self.stageTwo = @"UNKNOWN_MAP";
		self.stageThree = @"UNKNOWN_MAP";
		self.teamOneResults = @[ @0, @0, @0 ];
		self.teamTwoResults = @[ @0, @0, @0 ];
	}
	return self;
}

- (id) initFromJson:(NSDictionary*) json {
	if (self = [super init]) {
		self.startTime = [NSDate dateWithTimeIntervalSince1970:[[json objectForKey:@"startTime"] longLongValue]];
		self.endTime = [NSDate dateWithTimeIntervalSince1970:[[json objectForKey:@"endTime"] longLongValue]];
		self.teamOneName = [[[json objectForKey:@"teams"] objectAtIndex:0] objectForKey:@"name"];
		self.teamOneColour = [SplatUtilities colorWithHexString:[[[json objectForKey:@"teams"] objectAtIndex:0] objectForKey:@"colour"]];
		self.teamTwoName = [[[json objectForKey:@"teams"] objectAtIndex:1] objectForKey:@"name"];
		self.teamTwoColour = [SplatUtilities colorWithHexString:[[[json objectForKey:@"teams"] objectAtIndex:1] objectForKey:@"colour"]];
		self.stageOne = [SplatUtilities toLocalizable:[[json objectForKey:@"maps"] objectAtIndex:0]];
		self.stageTwo = [SplatUtilities toLocalizable:[[json objectForKey:@"maps"] objectAtIndex:1]];
		self.stageThree = [SplatUtilities toLocalizable:[[json objectForKey:@"maps"] objectAtIndex:2]];
		
		NSArray* (^createResultsArray)(NSDictionary* resultsDict) = ^NSArray*(NSDictionary* resultsDict) {
			return @[
					 @([[resultsDict objectForKey:@"popularity"] integerValue]),
					 @([[resultsDict objectForKey:@"winPercentage"] integerValue]),
					 @([[resultsDict objectForKey:@"final"] integerValue])
					 ];
		};
		self.teamOneResults = createResultsArray([[json objectForKey:@"results"] objectAtIndex:0]);
		self.teamTwoResults = createResultsArray([[json objectForKey:@"results"] objectAtIndex:1]);
	}
	return self;
}

- (id) initWithCoder:(NSCoder*) decoder {
	if (self = [super init]) {
		self.startTime = [decoder decodeObjectForKey:@"startTime"];
		self.endTime = [decoder decodeObjectForKey:@"endTime"];
		self.teamOneName = [decoder decodeObjectForKey:@"teamOneName"];
		self.teamOneColour = [decoder decodeObjectForKey:@"teamOneColour"];
		self.teamTwoName = [decoder decodeObjectForKey:@"teamTwoName"];
		self.teamTwoColour = [decoder decodeObjectForKey:@"teamTwoColour"];
		self.stageOne = [decoder decodeObjectForKey:@"stageOne"];
		self.stageTwo = [decoder decodeObjectForKey:@"stageTwo"];
		self.stageThree = [decoder decodeObjectForKey:@"stageThree"];
		self.teamOneResults = [decoder decodeObjectForKey:@"teamOneResults"];
		self.teamTwoResults = [decoder decodeObjectForKey:@"teamTwoResults"];
	}
	return self;
}

- (void) encodeWithCoder:(NSCoder*) encoder {
	[encoder encodeObject:self.startTime forKey:@"startTime"];
	[encoder encodeObject:self.endTime forKey:@"endTime"];
	[encoder encodeObject:self.teamOneName forKey:@"teamOneName"];
	[encoder encodeObject:self.teamOneColour forKey:@"teamOneColour"];
	[encoder encodeObject:self.teamTwoName forKey:@"teamTwoName"];
	[encoder encodeObject:self.teamTwoColour forKey:@"teamTwoColour"];
	[encoder encodeObject:self.stageOne forKey:@"stageOne"];
	[encoder encodeObject:self.stageTwo forKey:@"stageTwo"];
	[encoder encodeObject:self.stageThree forKey:@"stageThree"];
	[encoder encodeObject:self.teamOneResults forKey:@"teamOneResults"];
	[encoder encodeObject:self.teamTwoResults forKey:@"teamTwoResults"];
}

@end
