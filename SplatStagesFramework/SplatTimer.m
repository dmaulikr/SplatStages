//
//  SplatTimer.m
//  SplatStages
//
//  Created by mac on 2015-09-25.
//  Copyright © 2015 OatmealDome. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "NSAttributedString+CCLFormat.h"

#import "SplatTimer.h"

@implementation SplatTimer

/*- (id) initRotationTimerWithDate:(NSDate*) date labelOne:(UILabel*) labelOne labelTwo:(UILabel*) labelTwo textString:(NSString*) textString timerFinishedHandler:(void (^)()) timerFinishedHandler {
    if (self = [super init]) {
        // Initialize variables
        self.countdownDate = date;
        self.labelOne = labelOne;
        self.labelTwo = labelTwo;
        self.textString = textString;
        self.timerFinishedHandler = timerFinishedHandler;
        
        // Setup internals
        self.calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
        self.calendarUnits = NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond;
        self.selector = @selector(runRotationTimer);
        self.internalTimer = [self createTimer];
    }
    return self;
}

- (id) initFestivalTimerWithDate:(NSDate*) date label:(UILabel*) label textString:(NSString*) textString timeString:(NSString*) timeString teamA:(NSAttributedString*) teamA teamB:(NSAttributedString*) teamB useThreeNumbers:(BOOL) useThreeNumbers timerFinishedHandler:(void (^)(NSAttributedString* teamA, NSAttributedString* teamB)) timerFinishedHandler {
    if (self = [super init]) {
        // Initialize variables
        self.countdownDate = date;
        self.labelOne = label;
        self.textString = textString;
        self.timeString = timeString;
        self.teamA = teamA;
        self.teamB = teamB;
        self.useThreeNumbers = useThreeNumbers;
        self.festivalTimerFinishedHandler = timerFinishedHandler;
        
        // Setup internals
        self.calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
        self.calendarUnits = NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond;
        if (!useThreeNumbers) {
            self.calendarUnits = self.calendarUnits | NSCalendarUnitDay;
        }
        self.selector = @selector(runFestivalTimer);
        self.internalTimer = [self createTimer];
    }
    return self;
}

- (void) runRotationTimer {
    if ([self.countdownDate timeIntervalSinceNow] <= 0.0) {
        [self invalidate];
        self.timerFinishedHandler();
    } else {
        NSDateComponents* components = [self.calendar components:self.calendarUnits fromDate:[NSDate date] toDate:self.countdownDate options:0];
        NSString* rotationCountdownText = [NSString stringWithFormat:self.textString, [components hour], [components minute], [components second]];;
        [self.labelOne setText:rotationCountdownText];
        if (self.labelTwo) {
            [self.labelTwo setText:rotationCountdownText];
        }
    }
}

- (void) runFestivalTimer {
    if ([self.countdownDate timeIntervalSinceNow] <= 0.0) {
        [self invalidate];
        self.festivalTimerFinishedHandler(self.teamA, self.teamB);
    } else {
        NSDateComponents* components = [self.calendar components:self.calendarUnits fromDate:[NSDate date] toDate:self.countdownDate options:0];
        NSString* countdownTime;
        if (self.useThreeNumbers) {
            countdownTime = [NSString stringWithFormat:self.timeString, [components hour], [components minute], [components second]];
        } else {
            countdownTime = [NSString stringWithFormat:self.timeString, [components day], [components hour], [components minute], [components second]];
        }
        NSAttributedString* countdownText = [NSAttributedString attributedStringWithFormat:self.textString, self.teamA, self.teamB, countdownTime];
        [self.labelOne setAttributedText:countdownText];
    }
}*/

- (id) initWithDate:(NSDate*) date {
    if (self = [super init]) {
        [self setCalendar:[[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian]];
        [self setCalendarUnits:NSCalendarUnitDay | NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond];
        [self setCountdownDate:date];
    }
    return self;
}

- (void) start {
    if (!self.internalTimer) {
        self.internalTimer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(timerTick) userInfo:nil repeats:true];
    }
}

- (void) stop {
    if (self.internalTimer) {
        [self.internalTimer invalidate];
        self.internalTimer = nil;
    }
}

- (void) timerTick {
    if ([self.countdownDate timeIntervalSinceNow] > 0) {
        NSDateComponents* components = [self.calendar components:self.calendarUnits fromDate:[NSDate date] toDate:self.countdownDate options:0];
        [self timerTickWithComponents:components];
    } else {
        [self timerFinished];
        [self stop];
    }
}

- (void) timerTickWithComponents:(NSDateComponents*) components {
    // Do nothing, this should be overrided by a subclass.
}

- (void) timerFinished {
    // Do nothing, this should be ovverided by a subclass.
}

@end
