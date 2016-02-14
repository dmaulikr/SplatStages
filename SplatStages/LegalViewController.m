//
//  LegalViewController.m
//  SplatStages
//
//  Created by mac on 2016-02-14.
//  Copyright © 2016 OatmealDome. All rights reserved.
//

#import "LegalViewController.h"

@interface LegalViewController ()

@end

@implementation LegalViewController

- (void) viewDidLoad {
    [super viewDidLoad];
	
	// Load the text.
	NSString* path = [[NSBundle mainBundle] pathForResource:@"LICENSES" ofType:@"txt"];
	NSString* content = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:NULL];
	//NSLog(@"%@", content);
	
	// Add legal text to the UITextView.
	UITextView* textView = (UITextView*) self.view;
	[textView setText:content];
}

- (void) didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
