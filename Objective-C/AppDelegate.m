//
//  AppDelegate.m
//  ChartsDemo
//
//  Copyright 2015 Daniel Cohen Gindi & Philipp Jahoda
//  A port of MPAndroidChart for iOS
//  Licensed under Apache License 2.0
//
//  https://github.com/danielgindi/Charts
//

#import "AppDelegate.h"
#import "MainVC.h"

@interface AppDelegate ()

@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    MainVC *vc = [[MainVC alloc] init];
    // 2/17 skip nav for now, don't need it. plus the titlebar isn't accessible??
    UINavigationController *nvc = [[UINavigationController alloc] initWithRootViewController:vc];
    
    _window.rootViewController = nvc;
    [_window makeKeyAndVisible];
    
    [Parse initializeWithConfiguration:[ParseClientConfiguration configurationWithBlock:^(id<ParseMutableClientConfiguration> configuration) {
        //This is the AWS -> Mongo configuration...
        configuration.applicationId = @"jT8oJdg7ySCQrHazHQml6JHEnCoKAiYh5ON5leQk";
        configuration.clientKey     = @"hxSXfyhuz3xik85xRZlmC2XrhQ5URkOlLNAioGeY";
        configuration.server        = @"https://pg-app-jhg70nkxzqetipfyic66ks9q3kq41y.scalabl.cloud/1/";
        NSLog(@" parse DB at sashido.io connected");
        //Load Vendors from parse db,
        // ...force a load also, since object may already have been created before DB is ready!
    }]];
    vv = [Vendors sharedInstance]; //Load vendors as early as possible!
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
