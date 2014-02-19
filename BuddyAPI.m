//
//  BuddyAPI.m
//  Buddy
//
//  Created by curer on 2/19/14.
//  Copyright (c) 2014 curer. All rights reserved.
//

#import "BuddyAPI.h"


@implementation BuddyAPI

+ (NSURL *)online
{
    return [NSURL URLWithString:[MAIN_PATH stringByAppendingString:ONLINE]];
}

+ (NSURL *)offline
{
    return [NSURL URLWithString:[MAIN_PATH stringByAppendingString:ONLINE]];
}

+ (NSURL *)rank
{
    return [NSURL URLWithString:[MAIN_PATH stringByAppendingString:RANK]];
}

@end
