//
//  AppDelegate.m
//  iCalculator
//
//  Created by curie on 12-10-1.
//  Copyright (c) 2012年 Fish Tribe. All rights reserved.
//

#import "AppDelegate.h"
#import "MyDecimal.h"
#import <CoreData/CoreData.h>


NSInteger g_osVersionMajor;

NSInteger g_dataVersion;

BOOL g_isPhone;
BOOL g_isClassic;

NSString * const g_appStdLink = @"https://itunes.apple.com/app/id686375771?mt=8";
NSString * const g_appLiteLink = @"https://itunes.apple.com/app/id647645099?mt=8";

NSString * const g_appStdName = @"Calcility";
NSString * const g_appLiteName = @"Calcility (Lite)";

NSDate *g_lastLeaveTime;

static NSURL *l_documentsDirectoryURL;
static NSURL *l_dataDirectoryURL;


@implementation AppDelegate

+ (NSURL *)documentsDirectoryURL
{
    if (l_documentsDirectoryURL == nil) {
        l_documentsDirectoryURL = [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] firstObject];
    }
    return l_documentsDirectoryURL;
}

+ (NSURL *)dataDirectoryURL
{
    if (l_dataDirectoryURL == nil) {
        l_dataDirectoryURL = [[[NSFileManager defaultManager] URLsForDirectory:NSLibraryDirectory inDomains:NSUserDomainMask] firstObject];
    }
    return l_dataDirectoryURL;
}

+ (NSPersistentStoreCoordinator *)sharedPersistentStoreCoordinator
{
    static NSPersistentStoreCoordinator *sharedPersistentStoreCoordinator;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"Model" withExtension:@"momd"];
        NSManagedObjectModel *model = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
        
        sharedPersistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:model];
        NSURL *storeURL = [self.documentsDirectoryURL URLByAppendingPathComponent:@"store.sqlite"];
        NSDictionary *options = @{NSMigratePersistentStoresAutomaticallyOption: @YES, NSInferMappingModelAutomaticallyOption: @YES};
        NSError *error;
        if (![sharedPersistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:options error:&error]) {
            FTRegisterError(error);
            sharedPersistentStoreCoordinator = nil;
        }
    });
    return sharedPersistentStoreCoordinator;
}

-(BOOL)application:(UIApplication *)application willFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    g_osVersionMajor = [[UIDevice currentDevice].systemVersion integerValue];
    
    g_isPhone = [UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone;
    g_isClassic = CGRectGetHeight([UIScreen mainScreen].nativeBounds) == (g_isPhone ? 480.0 : 1024.0);
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults registerDefaults:@{@"MathAngleUnitDefaultsToDegree"       : @YES,
                                     @"MathPrecedenceTextbookConvention"    : @YES,
                                     @"MathThousandsSeparatorLeftIsOn"      : @YES,
                                     @"MathThousandsSeparatorRightIsOn"     : @NO}];
    g_dataVersion = [userDefaults integerForKey:@"DataVersion"];
    
    return YES;
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    NSLog_DEBUG(@"Debuging...");
    Dec_init();
    
    if (g_dataVersion != DATA_VERSION) {
        NSLog_DEBUG(@"Data version is changed from %d to %d: ", (int)g_dataVersion, DATA_VERSION);
        [[NSUserDefaults standardUserDefaults] setInteger:DATA_VERSION forKey:@"DataVersion"];
    }

    return YES;
}
							
- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    
    g_lastLeaveTime = [NSDate date];
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
