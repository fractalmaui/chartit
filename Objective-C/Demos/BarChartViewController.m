//
//  BarChartViewController.m
//  ChartsDemo
//
//  Copyright 2015 Daniel Cohen Gindi & Philipp Jahoda
//  A port of MPAndroidChart for iOS
//  Licensed under Apache License 2.0
//
//  https://github.com/danielgindi/Charts
//
// 2/24 add percent

#import "BarChartViewController.h"
#import "Chartit-Swift.h"
#import "DayAxisValueFormatter.h"
#import "FiscalAxisValueFormatter.h"

@interface BarChartViewController () <ChartViewDelegate>

//DHS note these must match the swift file!!!
@property (nonatomic, strong) IBOutlet BarChartView *chartView;
@property (nonatomic, strong) IBOutlet UISlider *sliderX;
@property (nonatomic, strong) IBOutlet UISlider *sliderY;
@property (nonatomic, strong) IBOutlet UITextField *sliderTextX;
@property (nonatomic, strong) IBOutlet UITextField *sliderTextY;
@property (nonatomic, strong) IBOutlet UISwitch *percentSwitch;
@property (nonatomic, strong) IBOutlet UILabel *percentLabel;

@end

@implementation BarChartViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    //DHS CHANGES-------
    self.title = pTitle;
    needSliders  = FALSE;
 //   _chartView.backgroundColor = [UIColor redColor];
//    if (plotType == 99) //Special type w/ sliders  2/22
//    {
//        needSliders = TRUE;
//    }
    _sliderX.hidden       = !needSliders;
    _sliderY.hidden       = !needSliders;
    _sliderTextX.hidden   = !needSliders;
    _sliderTextY.hidden   = !needSliders;
    //END DHS CHANGES------
    self.options = @[
                     @{@"key": @"toggleValues", @"label": @"Toggle Values"},
                     @{@"key": @"toggleIcons", @"label": @"Toggle Icons"},
                     @{@"key": @"toggleHighlight", @"label": @"Toggle Highlight"},
                     @{@"key": @"animateX", @"label": @"Animate X"},
                     @{@"key": @"animateY", @"label": @"Animate Y"},
                     @{@"key": @"animateXY", @"label": @"Animate XY"},
                     @{@"key": @"saveToGallery", @"label": @"Save to Camera Roll"},
                     @{@"key": @"togglePinchZoom", @"label": @"Toggle PinchZoom"},
                     @{@"key": @"toggleAutoScaleMinMax", @"label": @"Toggle auto scale min/max"},
                     @{@"key": @"toggleData", @"label": @"Toggle Data"},
                     @{@"key": @"toggleBarBorders", @"label": @"Show Bar Borders"},
                     ];
    
    [self setupBarLineChartView:_chartView];
    
    _chartView.delegate = self;
    
    _chartView.drawBarShadowEnabled = NO;
    _chartView.drawValueAboveBarEnabled = YES;
    
    _chartView.maxVisibleCount = 60;
    
    ChartXAxis *xAxis = _chartView.xAxis;
    xAxis.labelPosition = XAxisLabelPositionBottom;
    xAxis.labelFont = [UIFont systemFontOfSize:10.f];
    xAxis.drawGridLinesEnabled = NO;
    xAxis.granularity = 1.0; // only intervals of 1 day
    xAxis.labelCount = 7;
//    xAxis.valueFormatter = [[DayAxisValueFormatter alloc] initForChart:_chartView];
    xAxis.valueFormatter = [[FiscalAxisValueFormatter alloc] initForChart:_chartView];


    ChartYAxis *leftAxis = _chartView.leftAxis;
    leftAxis.labelFont = [UIFont systemFontOfSize:10.f];
    leftAxis.labelCount = 8;
    leftAxis.labelPosition = YAxisLabelPositionOutsideChart;
    leftAxis.spaceTop = 0.15;
    leftAxis.axisMinimum = 0.0; // this replaces startAtZero = YES
    
    ChartYAxis *rightAxis = _chartView.rightAxis;
    rightAxis.enabled = NO;
    rightAxis.drawGridLinesEnabled = NO;
    rightAxis.labelFont = [UIFont systemFontOfSize:10.f];
    rightAxis.labelCount = 8;
    rightAxis.valueFormatter = leftAxis.valueFormatter;
    rightAxis.spaceTop = 0.15;
    rightAxis.axisMinimum = 0.0; // this replaces startAtZero = YES
    
    ChartLegend *l = _chartView.legend;
    l.horizontalAlignment = ChartLegendHorizontalAlignmentLeft;
    l.verticalAlignment = ChartLegendVerticalAlignmentBottom;
    l.orientation = ChartLegendOrientationHorizontal;
    l.drawInside = NO;
    l.form = ChartLegendFormSquare;
    l.formSize = 9.0;
    l.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:11.f];
    l.xEntrySpace = 4.0;
    
    XYMarkerView *marker = [[XYMarkerView alloc]
                                  initWithColor: [UIColor colorWithWhite:180/255. alpha:1.0]
                                  font: [UIFont systemFontOfSize:12.0]
                                  textColor: UIColor.whiteColor
                                  insets: UIEdgeInsetsMake(8.0, 8.0, 20.0, 8.0)
                                  xAxisValueFormatter: _chartView.xAxis.valueFormatter];
    marker.chartView = _chartView;
    marker.minimumSize = CGSizeMake(80.f, 40.f);
    _chartView.marker = marker;
    
    _sliderX.value = 12.0;
    _sliderY.value = 50.0;
    [self slidersValueChanged:nil];
}

//=====BarChartVC==================================================
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//=====BarChartVC==================================================
- (void)updateChartData
{
    if (self.shouldHideData)
    {
        _chartView.data = nil;
        return;
    }
    byPercent = _percentSwitch.isOn;
    //DHS     [self setDataCount:_sliderX.value + 1 range:_sliderY.value];
    int monthCount = [rpd getStatsMonthCount];
    int dataRange  = [rpd getStatsMaxForData : @"all"];  //2/22 need change?
    //Get handle to left axis...
    ChartYAxis *leftAxis = _chartView.leftAxis;
    //2/27 format varies by plot type
    NSString* fstr = @" $";
    if (byPercent)
    {
        fstr = @" %";
        leftAxis.axisMaximum = 100.0;
    }
    NSNumberFormatter *leftAxisFormatter = [[NSNumberFormatter alloc] init];
    leftAxisFormatter.minimumFractionDigits = 0;
    leftAxisFormatter.maximumFractionDigits = 1;
    leftAxisFormatter.negativeSuffix = fstr;
    leftAxisFormatter.positiveSuffix = fstr;
    leftAxis.valueFormatter = [[ChartDefaultAxisValueFormatter alloc] initWithFormatter:leftAxisFormatter];

    //DHS range is either auto-set or 100 by percent
    [self loadPlotData : monthCount ];
}

//=====BarChartVC==================================================
- (void)loadPlotData:(int)count
{
    double start = 1.0;
    
    NSMutableArray *totalVals  = [[NSMutableArray alloc] init];
    NSMutableArray *ltotalVals = [[NSMutableArray alloc] init];
    NSMutableArray *ptotalVals = [[NSMutableArray alloc] init];

    BOOL needTotals  = [plotType.lowercaseString containsString:@"total"];
    BOOL needLTotals = [plotType.lowercaseString containsString:@"local"];
    BOOL needPTotals = [plotType.lowercaseString containsString:@"processed"];
    
    //2/27
    _percentSwitch.hidden = !(needLTotals || needPTotals);
    _percentLabel.hidden  = !(needLTotals || needPTotals);

    for (int i = start; i < start + count + 1; i++)
    {
        double valTo,valLo,valPr;
        valTo = valLo = valPr = 0.0;
        if (needTotals)
        {
            valTo = [rpd getTotalByMonth:i-1];
            if (byPercent)
                [totalVals addObject:[[BarChartDataEntry alloc] initWithX:i y:100.0]];
            else
                [totalVals addObject:[[BarChartDataEntry alloc] initWithX:i y:valTo]];
        }
        if (needLTotals)
        {
            valLo = [rpd getLocalTotalByMonth:i-1];
            if (byPercent) valLo = 100.0 * (valLo/valTo);
            [ltotalVals addObject:[[BarChartDataEntry alloc] initWithX:i y:valLo]];
        }
        if (needPTotals)
        {
            valPr = [rpd getProcessedTotalByMonth:i-1];
            if (byPercent) valPr = 100.0 * (valPr/valTo);
            [ptotalVals addObject:[[BarChartDataEntry alloc] initWithX:i y:valPr]];
        }
        //HUH?            [totalVals addObject:[[BarChartDataEntry alloc] initWithX:i y:val icon: [UIImage imageNamed:@"icon"]]];
    } //end int i
    
    BarChartDataSet *set1 = nil;
    BarChartDataSet *set2 = nil;
    BarChartDataSet *set3 = nil;
    NSArray *blueColz  = @[ [UIColor colorWithRed:.6 green:.6 blue:.9 alpha:1] ];
    NSArray *greenColz = @[ [UIColor colorWithRed:.5 green:.9 blue:.5 alpha:1] ];
    NSArray *redColz   = @[ [UIColor colorWithRed:.9 green:.5 blue:.5 alpha:1] ];

    if (needTotals)
    {
        set1 = [[BarChartDataSet alloc] initWithValues:totalVals label:@"Totals"];
        [set1 setColors: blueColz];
        set1.drawIconsEnabled = NO;
        if (byPercent) set1.drawValuesEnabled = NO;
    }
    if (needLTotals)
    {
        set2 = [[BarChartDataSet alloc] initWithValues:ltotalVals label:@"Local"];
        [set2 setColors: greenColz];
        set2.drawIconsEnabled = NO;
    }
    if (needPTotals)
    {
        set3 = [[BarChartDataSet alloc] initWithValues:ptotalVals label:@"Processed"];
        [set3 setColors: redColz];
        set3.drawIconsEnabled = NO;
    }

    NSMutableArray *dataSets = [[NSMutableArray alloc] init];
    if (needTotals) [dataSets addObject:set1];
    if (needLTotals)[dataSets addObject:set2];
    if (needPTotals)[dataSets addObject:set3];

    BarChartData *data = [[BarChartData alloc] initWithDataSets:dataSets];
    [data setValueFont:[UIFont fontWithName:@"HelveticaNeue-Light" size:10.f]];
    
    data.barWidth = 0.9f;
    
    _chartView.data = data;
    //DHS 2/22 
    [_chartView animateWithYAxisDuration:3.0];

}

- (void)optionTapped:(NSString *)key
{
    [super handleOption:key forChartView:_chartView];
}

#pragma mark - Actions

- (IBAction)slidersValueChanged:(id)sender
{
    _sliderTextX.text = [@((int)_sliderX.value + 2) stringValue];
    _sliderTextY.text = [@((int)_sliderY.value) stringValue];
    
    [self updateChartData];
}

- (IBAction)switchChanged:(id)sender
{
    [self updateChartData];
}



#pragma mark - ChartViewDelegate

- (void)chartValueSelected:(ChartViewBase * __nonnull)chartView entry:(ChartDataEntry * __nonnull)entry highlight:(ChartHighlight * __nonnull)highlight
{
    NSLog(@"chartValueSelected");
}

- (void)chartValueNothingSelected:(ChartViewBase * __nonnull)chartView
{
    NSLog(@"chartValueNothingSelected");
}

@end
