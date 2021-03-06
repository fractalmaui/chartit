//
//     _                ____       _                  _
//    / \   _ __  _ __ |  _ \  ___| | ___  __ _  __ _| |_ ___
//   / _ \ | '_ \| '_ \| | | |/ _ \ |/ _ \/ _` |/ _` | __/ _ \
//  / ___ \| |_) | |_) | |_| |  __/ |  __/ (_| | (_| | ||  __/
// /_/   \_\ .__/| .__/|____/ \___|_|\___|\__, |\__,_|\__\___|
//         |_|   |_|                      |___/
//
//  AppDelegate.m
//  ChartsDemo
//
//  Copyright © 2019 Beyond Green Partners. All rights reserved.
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
    MainVC *mvc = [[MainVC alloc] init];
    // 2/17 skip nav for now, don't need it. plus the titlebar isn't accessible??
    UINavigationController *nvc = [[UINavigationController alloc] initWithRootViewController:mvc];
    
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
    
    _settings = [OCRSettings sharedInstance]; //DHS 3/2

    vv = [Vendors sharedInstance]; //Load vendors as early as possible!
    vv.delegate = self;
    
    //5/17 customers, saved to defaults...
    _cust = [Customers sharedInstance]; //DHS 3/13 new table
    [self getUserDefaults];

    
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


//====(TestOCR AppDelegate)==========================================
- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url {
    
    return NO;
}


-(void) didReadVendorsFromParse
{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"vendorsLoaded"
                                                        object:nil userInfo:nil];
}
-(void) errorReadingVendorsFromParse
{
    NSLog(@" error reading vendors...");

}


//====(TestOCR AppDelegate)==========================================
-(void) updateCustomerDefaults : (NSString *)customerString : (NSString *)customerFullString
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    _selectedCustomer            = customerString;
    _selectedCustomerFullName    = customerFullString;
    [userDefaults setObject:_selectedCustomer         forKey:@"customer"];
    [userDefaults setObject:_selectedCustomerFullName forKey:@"customerFull"];
    
} //end updateCustomerDefault

//====(TestOCR AppDelegate)==========================================
-(void) getUserDefaults
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    if ([userDefaults objectForKey:@"customer"] == nil  ) //No defaults yet?
    {
        NSLog(@" no defaults: reset");
        [userDefaults setObject:@"KCH" forKey:@"customer"];
        [userDefaults setObject:@"Kona Hospital" forKey:@"customerFull"];
    }
    else NSLog(@" found defaults...");
    _selectedCustomer         = [userDefaults objectForKey:@"customer"];
    _selectedCustomerFullName = [userDefaults objectForKey:@"customerFull"];
    
}



@end
