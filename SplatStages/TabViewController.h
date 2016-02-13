//
//  ViewController.h
//  SplatStages
//
//  Created by mac on 2015-08-25.
//  Copyright © 2015 OatmealDome. All rights reserved.
//

#import <UIKit/UIKit.h>

#import <SplatStagesFramework/SplatStagesFramework.h>

#define REGULAR_CONTROLLER 0
#define RANKED_CONTROLLER 1
#define SPLATFEST_CONTROLLER 2
#define SETTINGS_CONTROLLER 3

@interface TabViewController : UITabBarController

// Stages
@property (nonatomic) BOOL viewsReady;
@property (strong, atomic) SSFRotationTimer* rotationTimer;
@property (strong, atomic) NSTimer* stageRequestTimer;

- (void) getStageData;
- (void) getSplatfestData;
- (void) refreshAllData;
- (void) setStages;
- (void) setupStageView:(NSString*) nameEN nameJP:(NSString*) nameJP label:(UILabel*) label imageView:(UIImageView*) imageView;
- (void) errorOccurred:(NSError*) error when:(NSString*) errorWhen;

@end

