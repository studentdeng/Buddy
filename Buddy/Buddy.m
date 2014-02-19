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

#define TIME_INTERVAL_MIN 30

static Buddy *sharedPlugin;

@interface Buddy()

@property (nonatomic, strong) NSBundle *bundle;
@property (nonatomic, strong) NSTimer *onLineTimer;

@property (nonatomic, assign) int timeInMin;

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
    
    [self goToOnline];
    
    [self.onLineTimer invalidate];
    self.onLineTimer = [NSTimer scheduledTimerWithTimeInterval:TIME_INTERVAL_MIN * 60 target:self selector:@selector(onLineTimerProc) userInfo:nil repeats:YES];
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
        self.onLineTimer = [NSTimer scheduledTimerWithTimeInterval:TIME_INTERVAL_MIN target:self selector:@selector(onLineTimerProc) userInfo:nil repeats:YES];
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
                                           
                                           NSString *totalTimeMessage = [NSString stringWithFormat:@"Now YOU have been coding for %d h", self.timeInMin / 60];
                                           
                                           NSAlert *alert = [NSAlert alertWithMessageText:totalTimeMessage
                                                                            defaultButton:nil
                                                                          alternateButton:nil
                                                                              otherButton:nil
                                                                informativeTextWithFormat:message, nil];
                                           [alert runModal];
                                       }
                                   }
                               }];
}

- (void)showMessage:(NSString *)text
{
    NSAlert *alert = [NSAlert alertWithMessageText:@"message" defaultButton:nil alternateButton:nil otherButton:nil informativeTextWithFormat:text, nil];
    [alert runModal];
}

@end
