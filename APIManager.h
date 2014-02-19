//
//  APIManager.h
//  Buddy
//
//  Created by curer on 2/19/14.
//  Copyright (c) 2014 curer. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "macro.h"

@interface APIManager : NSObject

+ (instancetype)sharedInstance;

- (void)GET:(NSString *)path param:(NSDictionary *)dic block:(CUNetBlockHandler)handler;
- (void)POST:(NSString *)path param:(NSDictionary *)dic block:(CUNetBlockHandler)handler;

@end
