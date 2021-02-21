//
//  AppDelegate.h
//  iCalculator
//
//  Created by curie on 12-10-1.
//  Copyright (c) 2012年 Fish Tribe. All rights reserved.
//

#import <UIKit/UIKit.h>


extern NSInteger g_osVersionMajor;

#define DATA_VERSION  1
extern NSInteger g_dataVersion;

extern BOOL g_isPhone;
extern BOOL g_isClassic;

extern NSString * const g_appStdLink;
extern NSString * const g_appLiteLink;

extern NSString * const g_appStdName;
extern NSString * const g_appLiteName;

#ifdef LITE_VERSION
#define g_appLink g_appLiteLink
#define g_appName g_appLiteName
#else
#define g_appLink g_appStdLink
#define g_appName g_appStdName
#endif

extern NSDate *g_lastLeaveTime;


#pragma mark -


@interface AppDelegate : UIResponder <UIApplicationDelegate>

+ (NSURL *)documentsDirectoryURL;
+ (NSURL *)dataDirectoryURL;
+ (NSPersistentStoreCoordinator *)sharedPersistentStoreCoordinator;

@property (nonatomic, strong) UIWindow *window;

@end
