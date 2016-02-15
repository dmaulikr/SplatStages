//
//  AddSubscriptionViewController.h
//  SplatStages
//
//  Created by mac on 2016-02-14.
//  Copyright © 2016 OatmealDome. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AddSubscriptionViewController : UITableViewController

@property (weak, nonatomic) IBOutlet UISegmentedControl *typeControl;
@property (weak, nonatomic) IBOutlet UISegmentedControl *rotationControl;
@property (weak, nonatomic) IBOutlet UILabel *rotationInfoLabel;
@property (weak, nonatomic) IBOutlet UILabel *gamemodeInfoLabel;
@property (weak, nonatomic) IBOutlet UILabel *stageInfoLabel;
@property (weak, nonatomic) IBOutlet UILabel *gamemodeLabel;
@property (weak, nonatomic) IBOutlet UILabel *stageLabel;

@property (strong, atomic) NSArray* gamemodes;
@property (strong, atomic) NSArray* stages;

@property (atomic) NSInteger selectedGamemode;
@property (atomic) NSInteger selectedStage;

@end
