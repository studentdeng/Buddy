//
//  Buddy.m
//  Buddy
//
//  Created by curer on 2/19/14.
//    Copyright (c) 2014 curer. All rights reserved.
//

#import "Buddy.h"
#import "BuddyAPI.h"
#import "APIManager.h"
#import "UserManager.h"
#import "FormatManager.h"

#define TIME_INTERVAL_MIN 1
#define BUILT_TOTAL_TIME_KEY    @"curer.built_total_time"
#define CODING_TOTAL_TIME_KEY   @"curer.code_total_time"

static Buddy *sharedPlugin;

@interface Buddy()

@property (nonatomic, strong) NSBundle *bundle;
@property (nonatomic, strong) NSTimer *onLineTimer;

@property (nonatomic, assign) int timeInMin;

@property (nonatomic, assign) double builtTimeInSec;
@property (nonatomic, strong) NSDate *buildDate;

@end

@implementation Buddy

+ (void)pluginDidLoad:(NSBundle *)plugin
{
    static id sharedPlugin = nil;
    static dispatch_once_t onceToken;
    NSString *currentApplicationName = [[NSBundle mainBundle] infoDictionary][@"CFBundleName"];
    if ([currentApplicationName isEqual:@"Xcode"]) {
        dispatch_once(&onceToken, ^{
            sharedPlugin = [[self alloc] initWithBundle:plugin];
        });
    }
}

- (id)initWithBundle:(NSBundle *)plugin
{
    if (self = [super init]) {
        // reference to plugin's bundle, for resource acccess
        
        self.bundle = plugin;
        [self setup];
    }
    
    return self;
}

#pragma mark - setup

- (void)setup
{
    self.builtTimeInSec = [[[NSUserDefaults standardUserDefaults] objectForKey:BUILT_TOTAL_TIME_KEY] doubleValue];
    self.timeInMin = [[[NSUserDefaults standardUserDefaults] objectForKey:CODING_TOTAL_TIME_KEY] intValue];
    
    NSMenuItem *menuItem = [[NSApp mainMenu] itemWithTitle:@"View"];
    if (menuItem) {
        [[menuItem submenu] addItem:[NSMenuItem separatorItem]];
        NSMenuItem *actionMenuItem = [[NSMenuItem alloc] initWithTitle:@"Buddy" action:@selector(doMenuAction) keyEquivalent:@""];
        [actionMenuItem setTarget:self];
        [[menuItem submenu] addItem:actionMenuItem];
    }
    
    //notification
    [[[NSWorkspace sharedWorkspace] notificationCenter] addObserver:self
                                                           selector:@selector(notificationActive:)
                                                               name:NSWorkspaceDidActivateApplicationNotification
                                                             object:nil];
    
    [[[NSWorkspace sharedWorkspace] notificationCenter] addObserver:self
                                                           selector:@selector(notificationDeactive:)
                                                               name:NSWorkspaceDidDeactivateApplicationNotification
                                                             object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(IDEBuildOperationWillStartNotificationFunc:) name:@"IDEBuildOperationWillStartNotification" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(IDEBuildOperationDidStopNotificationFunc:) name:@"IDEBuildOperationDidStopNotification" object:nil];
    
    [self goToOnline];
    
    [self.onLineTimer invalidate];
    self.onLineTimer = [NSTimer scheduledTimerWithTimeInterval:TIME_INTERVAL_MIN * 60 target:self selector:@selector(onLineTimerProc) userInfo:nil repeats:YES];
}

- (void)IDEBuildOperationWillStartNotificationFunc:(NSNotification *)notify
{
    self.buildDate = [NSDate date];
}

- (void)IDEBuildOperationDidStopNotificationFunc:(NSNotification *)notify
{
    NSDate *now = [NSDate date];
    
    NSTimeInterval sec = [now timeIntervalSinceDate:self.buildDate];
    
    self.builtTimeInSec += sec;
    
    [self saveToDisk];
}

#pragma mark - time proc

- (void)onLineTimerProc
{
    self.timeInMin += TIME_INTERVAL_MIN;
    
    [self goToOnline];
}

#pragma mark - notification

- (void)notificationActive:(NSNotification *)notify
{
    NSRunningApplication *app = notify.userInfo[NSWorkspaceApplicationKey];
    if ([app.localizedName isEqualToString:@"Xcode"]) {
        [self goToOnline];
        
        [self.onLineTimer invalidate];
        self.onLineTimer = [NSTimer scheduledTimerWithTimeInterval:TIME_INTERVAL_MIN * 60 target:self selector:@selector(onLineTimerProc) userInfo:nil repeats:YES];
    }
}

- (void)notificationDeactive:(NSNotification *)notify
{
    NSRunningApplication *app = notify.userInfo[NSWorkspaceApplicationKey];
    if ([app.localizedName isEqualToString:@"Xcode"]) {
        [self goToOffline];
        
        [self.onLineTimer invalidate];
    }
}

#pragma mark - Menu

// Sample Action, for menu item:
- (void)doMenuAction
{
    [self fetchRank];
}

#pragma mark - Network

- (void)goToOnline
{
    NSString *userId = [UserManager userId];
    
    [[APIManager sharedInstance] GET:ONLINE
                               param:@{@"user_id": userId}
                               block:^(BOOL bSucceed, NSDictionary *data) {
                                   if (bSucceed) {
                                       //[self showMessage:data];
                                   }
                               }];
}

- (void)goToOffline
{
    NSString *userId = [UserManager userId];
    
    [[APIManager sharedInstance] GET:OFFLINE
                               param:@{@"user_id": userId}
                               block:^(BOOL bSucceed, NSDictionary *data) {
                                   if (bSucceed) {
                                       //[self showMessage:data];
                                   }
                               }];
}

- (void)fetchRank
{
    NSString *userId = [UserManager userId];
    
    [[APIManager sharedInstance] GET:RANK
                               param:@{@"user_id": userId}
                               block:^(BOOL bSucceed, NSDictionary *data) {
                                   if (bSucceed) {
                                       
                                       NSNumber *number = data[@"data"][@"number"];
                                       if (number != 0) {
                                           
                                           NSString *message;
                                           
                                           if ([number intValue] != 1) {
                                               message = [NSString stringWithFormat:@"There're %d coders working at this moment !!", [number intValue]];
                                           }
                                           else
                                           {
                                               message = [NSString stringWithFormat:@"Only YOU working at this moment !!"];
                                           }
                                           
                                           NSString *totalTimeMessage = [FormatManager codingTime:self.timeInMin];
                                           NSString *totalBuiltMessage = [FormatManager builtTime:(int)self.builtTimeInSec];
                                           
                                           NSString *text = [NSString stringWithFormat:@"%@\n%@", totalTimeMessage, totalBuiltMessage];
                                           
                                           NSAlert *alert = [NSAlert alertWithMessageText:message
                                                                            defaultButton:nil
                                                                          alternateButton:nil
                                                                              otherButton:nil
                                                                informativeTextWithFormat:text, nil];
                                           [alert runModal];
                                       }
                                   }
                               }];
}

- (void)saveToDisk
{
    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithDouble:self.builtTimeInSec] forKey:BUILT_TOTAL_TIME_KEY];
    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithDouble:self.timeInMin] forKey:CODING_TOTAL_TIME_KEY];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)showMessage:(NSString *)text
{
    NSAlert *alert = [NSAlert alertWithMessageText:@"message" defaultButton:nil alternateButton:nil otherButton:nil informativeTextWithFormat:text, nil];
    [alert runModal];
}

@end
