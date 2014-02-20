//
//  FormatManager.m
//  Buddy
//
//  Created by curer on 2/20/14.
//  Copyright (c) 2014 curer. All rights reserved.
//

#import "FormatManager.h"

@implementation FormatManager

+ (NSString *)builtTime:(int)timeInSec
{
    NSString *totalTimeMessage;
    
    int timeInMin = timeInSec / 60;
    
    if (timeInSec < 60) {
        totalTimeMessage = [NSString stringWithFormat:@"YOU spent %d seconds on building", timeInSec];
    }
    else if (timeInMin == 1)
    {
        totalTimeMessage = [NSString stringWithFormat:@"YOU spent 1 minute %d seconds on building", timeInSec % 60];
    }
    else if (timeInMin <= 60 )
    {
        totalTimeMessage = [NSString stringWithFormat:@"YOU spent %d minutes on building", timeInMin];
    }
    else
    {
        totalTimeMessage = [NSString stringWithFormat:@"YOU spent %d h %d min on building",
                            timeInMin / 60, timeInMin % 60];
    }
    
    return totalTimeMessage;
}

+ (NSString *)codingTime:(int)timeInMin
{
    NSString *totalTimeMessage;
    
    if (timeInMin == 0) {
        totalTimeMessage = [NSString stringWithFormat:@"YOU spent less than 1 minute on coding"];
    }
    else if (timeInMin == 1)
    {
        totalTimeMessage = [NSString stringWithFormat:@"YOU spent 1 minute on coding"];
    }
    else if (timeInMin <= 60)
    {
        totalTimeMessage = [NSString stringWithFormat:@"YOU spent %d minutes on coding", timeInMin];
    }
    else
    {
        totalTimeMessage = [NSString stringWithFormat:@"YOU spent %d h %d min on coding",
                            timeInMin / 60, timeInMin % 60];
    }
    
    return totalTimeMessage;
}

@end
