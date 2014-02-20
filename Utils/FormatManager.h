//
//  FormatManager.h
//  Buddy
//
//  Created by curer on 2/20/14.
//  Copyright (c) 2014 curer. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FormatManager : NSObject

+ (NSString *)codingTime:(int)timeInMin;
+ (NSString *)builtTime:(int)timeInSec;

@end
