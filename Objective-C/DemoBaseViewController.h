//
//  DemoBaseViewController.h
//  ChartsDemo
//
//  Copyright © 2019 Beyond Green Partners. All rights reserved.
//
//  https://github.com/danielgindi/Charts
//

#import <UIKit/UIKit.h>
#import "Chartit-Swift.h"
#import "RawPlotData.h"

@interface DemoBaseViewController : UIViewController
{
    BOOL needLimits;
    RawPlotData *rpd;
    NSString* plotType;
    NSString* pTitle;
    int xRange,yRange;
@protected
    NSArray *parties;
}

@property (nonatomic, strong) IBOutlet UIButton *optionsButton;
@property (nonatomic, strong) IBOutlet NSArray *options;

@property (nonatomic, assign) BOOL shouldHideData;

- (void)handleOption:(NSString *)key forChartView:(ChartViewBase *)chartView;
- (void) setPlotType : (NSString *)ptype;
- (void) setPlotTitle : (NSString *)tstr;
- (void) setPlotXYRanges : (int) xr : (int) yr;
- (void)updateChartData;

- (void)setupPieChartView:(PieChartView *)chartView;
- (void)setupRadarChartView:(RadarChartView *)chartView;
- (void)setupBarLineChartView:(BarLineChartViewBase *)chartView;

@end
