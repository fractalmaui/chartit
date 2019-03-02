//
//  MainVC.h
//  ChartsDemo-iOS
//
//  Created by Dave Scruton on 2/17/19.
//  Copyright © 2019 Beyond Green Partners. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>
#import "NavButtons.h"
#import "EXPTable.h"
#import "spinnerView.h"
#import "LineChart1ViewController.h"
#import "BarChartViewController.h"
#import "PieChartViewController.h"
#import "RawPlotData.h"

#define NAV_HOME_BUTTON 0
#define NAV_DB_BUTTON 1
#define NAV_SETTINGS_BUTTON 2
#define NAV_BATCH_BUTTON 3


@interface MainVC : UIViewController <NavButtonsDelegate,RawPlotDataDelegate,
                            UITableViewDelegate,UITableViewDataSource>
{
    NavButtons *nav;
    UITableView *plotOptionsTable;
    int viewWid,viewHit,viewW2,viewH2;
    NSMutableArray *plotObjects;
    spinnerView *spv;
    BOOL dataLoaded;
    BOOL statsLoaded;
    LineChart1ViewController *lc1VC;
    RawPlotData *rpd;
    NSString *funcSelect;
    NSString *ptypeSelect;
    NSString *monthSelect;
    int monthNumber;
    NSArray *lineOptions;
    NSArray *barOptions;
    NSArray *pieOptions;
    NSArray *scatterOptions;
    NSArray *tableOptions;
}

@property (weak, nonatomic) IBOutlet UIButton *lineButton;
@property (weak, nonatomic) IBOutlet UIButton *barButton;
@property (weak, nonatomic) IBOutlet UIButton *donutButton;
@property (weak, nonatomic) IBOutlet UIButton *scatterButton;
@property (weak, nonatomic) IBOutlet UIView *buttonsView;
@property (weak, nonatomic) IBOutlet UIView *overlayView;
@property (weak, nonatomic) IBOutlet UIImageView *animImage;
- (IBAction)lineSelect:(id)sender;
- (IBAction)barSelect:(id)sender;
- (IBAction)donutSelect:(id)sender;
- (IBAction)scatterSelect:(id)sender;

@end


