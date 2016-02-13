//
//  SSFSplatfest.h
//  SplatStages
//
//  Created by mac on 2016-01-16.
//  Copyright © 2016 OatmealDome. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <UIKit/UIKit.h>

@interface SSFSplatfest : NSObject

@property (strong, atomic) NSDate* startTime;
@property (strong, atomic) NSDate* endTime;
@property (strong, atomic) NSString* teamOneName;
@property (strong, atomic) UIColor* teamOneColour;
@property (strong, atomic) NSString* teamTwoName;
@property (strong, atomic) UIColor* teamTwoColour;
@property (strong, atomic) NSString* stageOne;
@property (strong, atomic) NSString* stageTwo;
@property (strong, atomic) NSString* stageThree;
@property (strong, atomic) NSArray* teamOneResults;
@property (strong, atomic) NSArray* teamTwoResults;

@end
