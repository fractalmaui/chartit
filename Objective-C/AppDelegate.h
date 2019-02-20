//
//  AppDelegate.h
//  ChartsDemo
//
//  Copyright 2015 Daniel Cohen Gindi & Philipp Jahoda
//  A port of MPAndroidChart for iOS
//  Licensed under Apache License 2.0
//
//  https://github.com/danielgindi/Charts
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>
#import "Vendors.h"
@interface AppDelegate : UIResponder <UIApplicationDelegate>
{
    Vendors *vv;
}

@property (strong, nonatomic) UIWindow *window;
@property (nonatomic , assign) BOOL debugMode;

@end

