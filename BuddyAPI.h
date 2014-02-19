//
//  BuddyAPI.h
//  Buddy
//
//  Created by curer on 2/19/14.
//  Copyright (c) 2014 curer. All rights reserved.
//

#import <Foundation/Foundation.h>

#define MAIN_PATH @"http://112.124.107.63/buddy_server/index.php/api/"

#define ONLINE      @"presence/online"
#define OFFLINE     @"presence/offline"
#define RANK        @"presence/rank"

@interface BuddyAPI : NSObject

+ (NSURL *)online;
+ (NSURL *)offline;
+ (NSURL *)rank;

@end
