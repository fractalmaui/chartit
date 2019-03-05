//
//     _                ____       _                  _
//    / \   _ __  _ __ |  _ \  ___| | ___  __ _  __ _| |_ ___
//   / _ \ | '_ \| '_ \| | | |/ _ \ |/ _ \/ _` |/ _` | __/ _ \
//  / ___ \| |_) | |_) | |_| |  __/ |  __/ (_| | (_| | ||  __/
// /_/   \_\ .__/| .__/|____/ \___|_|\___|\__, |\__,_|\__\___|
//         |_|   |_|                      |___/
//
//  AppDelegate.h
//  ChartsDemo
//
//  Copyright © 2019 Beyond Green Partners. All rights reserved.
//
//  https://github.com/danielgindi/Charts
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>
#import "OCRSettings.h"
#import "Vendors.h"
@interface AppDelegate : UIResponder <UIApplicationDelegate, VendorsDelegate>
{
    Vendors *vv;
}

@property (strong, nonatomic) OCRSettings* settings;

@property (strong, nonatomic) UIWindow *window;
@property (nonatomic , assign) BOOL debugMode;

@end

