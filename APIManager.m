//
//  APIManager.m
//  Buddy
//
//  Created by curer on 2/19/14.
//  Copyright (c) 2014 curer. All rights reserved.
//

#import "APIManager.h"
#import "BuddyAPI.h"

@implementation NSString (APIManager)

- (NSString *)URLEncodedString
{
	return [self URLEncodedStringWithCFStringEncoding:kCFStringEncodingUTF8];
}

- (NSString *)URLEncodedStringWithCFStringEncoding:(CFStringEncoding)encoding
{
	return (__bridge_transfer NSString *) CFURLCreateStringByAddingPercentEscapes(NULL, (CFStringRef)[self mutableCopy], NULL, CFSTR("￼=,!$&'()*+;@?\n\"<>#\t :/"), encoding);
}

@end

@implementation APIManager

+ (instancetype)sharedInstance {
    static APIManager *_sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedInstance = [APIManager new];
    });
    
    return _sharedInstance;
}

- (void)GET:(NSString *)path param:(NSDictionary *)parameters block:(CUNetBlockHandler)handler
{
    NSString *urlString = [APIManager serializeBaseURL:MAIN_PATH
                                                  path:path
                                                params:parameters];
    
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:urlString]];
    
    [NSURLConnection sendAsynchronousRequest:request
                                       queue:[NSOperationQueue mainQueue]
                           completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
                               if (error == nil) {
                                   
                                   NSError *error = nil;
                                   id jsonObject = [NSJSONSerialization JSONObjectWithData:data
                                                                                   options:kNilOptions
                                                                                     error:&error];
                                   handler(TRUE, jsonObject);
                               }
                               else
                               {
                                   handler(FALSE, nil);
                               }
                           }];
}

- (void)POST:(NSString *)path param:(NSDictionary *)dic block:(CUNetBlockHandler)handler
{
}

#pragma mark - method

+ (NSString *)serializeBaseURL:(NSString *)baseURL path:(NSString *)path params:(NSDictionary *)params
{
    NSURL *parsedURL = [NSURL URLWithString:baseURL];
	NSString *queryPrefix = parsedURL.query ? @"&" : @"?";
	NSString *query = [self stringFromDictionary:params];
	
	return [NSString stringWithFormat:@"%@%@%@%@", baseURL, path, queryPrefix, query];
}

+ (NSString *)stringFromDictionary:(NSDictionary *)dict
{
    NSMutableArray *pairs = [NSMutableArray array];
	for (NSString *key in [dict keyEnumerator])
	{
        NSString *param = [dict objectForKey:key];
		if (!([param isKindOfClass:[NSString class]]))
		{
            param = [NSString stringWithFormat:@"%@", param];
		}
        
		[pairs addObject:[NSString stringWithFormat:@"%@=%@", key, [param URLEncodedString]]];
	}
	
	return [pairs componentsJoinedByString:@"&"];
}

@end
