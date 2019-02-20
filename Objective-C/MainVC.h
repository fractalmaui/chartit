//
//  MainVC.h
//  ChartsDemo-iOS
//
//  Created by Dave Scruton on 2/17/19.
//  Copyright © 2019 dcg. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>
#import "NavButtons.h"
#import "EXPTable.h"
#import "spinnerView.h"
#import "LineChart1ViewController.h"
#import "BarChartViewController.h"
#import "RawPlotData.h"

#define NAV_HOME_BUTTON 0
#define NAV_DB_BUTTON 1
#define NAV_SETTINGS_BUTTON 2
#define NAV_BATCH_BUTTON 3


@interface MainVC : UIViewController <NavButtonsDelegate,RawPlotDataDelegate>
{
    NavButtons *nav;
    int viewWid,viewHit,viewW2,viewH2;
    NSMutableArray *plotObjects;
    spinnerView *spv;
    BOOL dataLoaded;
    BOOL statsLoaded;
    LineChart1ViewController *lc1VC;
    RawPlotData *rpd;
}



@end


