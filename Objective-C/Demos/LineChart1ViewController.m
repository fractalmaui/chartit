//
//  LineChart1ViewController.m
//  ChartsDemo
//
//  Copyright 2015 Daniel Cohen Gindi & Philipp Jahoda
//  A port of MPAndroidChart for iOS
//  Licensed under Apache License 2.0
//
//  https://github.com/danielgindi/Charts
//

#import "LineChart1ViewController.h"
#import "Chartit-Swift.h"
#import "FiscalAxisValueFormatter.h"

@interface LineChart1ViewController () <ChartViewDelegate>

@property (nonatomic, strong) IBOutlet LineChartView *chartView;
@property (nonatomic, strong) IBOutlet UISlider *sliderX;
@property (nonatomic, strong) IBOutlet UISlider *sliderY;
@property (nonatomic, strong) IBOutlet UITextField *sliderTextX;
@property (nonatomic, strong) IBOutlet UITextField *sliderTextY;
@property (weak, nonatomic) IBOutlet UISwitch *percentSwitch;
@property (nonatomic, strong) IBOutlet UILabel *percentLabel;

@end

@implementation LineChart1ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //DHS CHANGES-------
    self.title = pTitle;
    needSliders = FALSE;
    needTotals  = [plotType.lowercaseString containsString:@"total"];
    needLTotals = [plotType.lowercaseString containsString:@"local"];
    needPTotals = [plotType.lowercaseString containsString:@"processed"];
    

    //    if (plotType == 99) //Special type w/ sliders
    //    {
    //        needSliders = TRUE;
    //    }
    _sliderX.hidden = !needSliders;
    _sliderY.hidden = !needSliders;
    _sliderTextX.hidden = !needSliders;
    _sliderTextY.hidden = !needSliders;
    
    //END DHS CHANGES-------

    self.options = @[
                     @{@"key": @"toggleValues", @"label": @"Toggle Values"},
                     @{@"key": @"toggleFilled", @"label": @"Toggle Filled"},
                     @{@"key": @"toggleCircles", @"label": @"Toggle Circles"},
                     @{@"key": @"toggleCubic", @"label": @"Toggle Cubic"},
                     @{@"key": @"toggleHorizontalCubic", @"label": @"Toggle Horizontal Cubic"},
                     @{@"key": @"toggleIcons", @"label": @"Toggle Icons"},
                     @{@"key": @"toggleStepped", @"label": @"Toggle Stepped"},
                     @{@"key": @"toggleHighlight", @"label": @"Toggle Highlight"},
                     @{@"key": @"animateX", @"label": @"Animate X"},
                     @{@"key": @"animateY", @"label": @"Animate Y"},
                     @{@"key": @"animateXY", @"label": @"Animate XY"},
                     @{@"key": @"saveToGallery", @"label": @"Save to Camera Roll"},
                     @{@"key": @"togglePinchZoom", @"label": @"Toggle PinchZoom"},
                     @{@"key": @"toggleAutoScaleMinMax", @"label": @"Toggle auto scale min/max"},
                     @{@"key": @"toggleData", @"label": @"Toggle Data"},
                     ];
    
    _chartView.delegate = self;
    
    _chartView.chartDescription.enabled = NO;
    
    _chartView.dragEnabled = YES;
    [_chartView setScaleEnabled:YES];
    _chartView.pinchZoomEnabled = YES;
    _chartView.drawGridBackgroundEnabled = NO;

    // x-axis limit line
    ChartLimitLine *llXAxis = [[ChartLimitLine alloc] initWithLimit:10.0 label:@"Index 10"];
    llXAxis.lineWidth = 4.0;
    llXAxis.lineDashLengths = @[@(10.f), @(10.f), @(0.f)];
    llXAxis.labelPosition = ChartLimitLabelPositionRightBottom;
    llXAxis.valueFont = [UIFont systemFontOfSize:10.f];
    
    //[_chartView.xAxis addLimitLine:llXAxis];
#ifdef ORIGINAL_CODE
    
    _chartView.xAxis.gridLineDashLengths = @[@10.0, @10.0];
    _chartView.xAxis.gridLineDashPhase = 0.f;
#else
    ChartXAxis *xAxis = _chartView.xAxis;
    xAxis.labelPosition = XAxisLabelPositionBottom;
    xAxis.labelFont = [UIFont systemFontOfSize:10.f];
    xAxis.drawGridLinesEnabled = NO;
    xAxis.granularity = 1.0;
    xAxis.labelCount = 7;
    xAxis.valueFormatter = [[FiscalAxisValueFormatter alloc] initForChart:_chartView];
    
#endif

    ChartYAxis *leftAxis = _chartView.leftAxis;
    [leftAxis removeAllLimitLines];
//    [leftAxis addLimitLine:ll1];
//    [leftAxis addLimitLine:ll2];
//2/27    leftAxis.axisMaximum = (double)yRange;
    leftAxis.axisMinimum = 0.0;            //DHS
    leftAxis.gridLineDashLengths = @[@1.f, @1000.f]; //DHS $1000 increments, this needs to vary by plot type!
    leftAxis.drawZeroLineEnabled = YES;
    leftAxis.drawLimitLinesBehindDataEnabled = YES;

    _chartView.rightAxis.enabled = NO;
    
    //[_chartView.viewPortHandler setMaximumScaleY: 2.f];
    //[_chartView.viewPortHandler setMaximumScaleX: 2.f];
    
    BalloonMarker *marker = [[BalloonMarker alloc]
                             initWithColor: [UIColor colorWithWhite:180/255. alpha:1.0]
                             font: [UIFont systemFontOfSize:12.0]
                             textColor: UIColor.whiteColor
                             insets: UIEdgeInsetsMake(8.0, 8.0, 20.0, 8.0)];
    marker.chartView = _chartView;
    marker.minimumSize = CGSizeMake(80.f, 40.f);
    _chartView.marker = marker;
    
    _chartView.legend.form = ChartLegendFormLine;
    
    _sliderX.value = 45.0;
    _sliderY.value = 100.0;
    [self slidersValueChanged:nil];
    
    [_chartView animateWithXAxisDuration:2.5];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//=====LineChartVC==================================================
- (void)updateChartData
{
    if (self.shouldHideData)
    {
        _chartView.data = nil;
        return;
    }
    byPercent = _percentSwitch.isOn;
    NSLog(@" bp %d",byPercent);
    int monthCount = [rpd getStatsMonthCount];
    int dataRange  = [rpd getStatsMaxForData : @"all"];  //2/22 need change?
    NSLog(@" datarange %d",dataRange);
    // 2/27
    ChartYAxis *leftAxis = _chartView.leftAxis;
// 2/27 auto scaling on axis?
//    if (byPercent && (needLTotals || needPTotals))
//        leftAxis.axisMaximum = 100.0;
//    else
//        leftAxis.axisMaximum = (double)yRange;

    [self loadPlotData:monthCount range:(double)dataRange];
}

//=====LineChartVC==================================================
- (void)loadPlotData:(int)count range:(double)range
{
    NSMutableArray *totalVals  = [[NSMutableArray alloc] init];
    NSMutableArray *ltotalVals = [[NSMutableArray alloc] init];
    NSMutableArray *ptotalVals = [[NSMutableArray alloc] init];
    
    //2/27
    _percentSwitch.hidden = !(needLTotals || needPTotals);
    _percentLabel.hidden  = !(needLTotals || needPTotals);

    double start = 1.0;
    
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
            if (byPercent) valLo = 100.0 * (valLo / valTo);
            [ltotalVals addObject:[[BarChartDataEntry alloc] initWithX:i y:valLo]];
        }
        if (needPTotals)
        {
            valPr = [rpd getProcessedTotalByMonth:i-1];
            if (byPercent) valPr = 100.0 * (valPr / valTo);
            [ptotalVals addObject:[[BarChartDataEntry alloc] initWithX:i y:valPr]];
        }
        //HUH?            [totalVals addObject:[[BarChartDataEntry alloc] initWithX:i y:val icon: [UIImage imageNamed:@"icon"]]];
    } //end int i
    
    LineChartDataSet *set1 = nil;
    LineChartDataSet *set2 = nil;
    LineChartDataSet *set3 = nil;
    
    if (needTotals)
    {
        set1 = [[LineChartDataSet alloc] initWithValues:totalVals label:@"Totals"];
        set1.drawIconsEnabled = NO;
    }
    if (needLTotals)
    {
        set2 = [[LineChartDataSet alloc] initWithValues:ltotalVals label:@"Local"];
        set2.drawIconsEnabled = NO;
    }
    if (needPTotals)
    {
        set3 = [[LineChartDataSet alloc] initWithValues:ptotalVals label:@"Processed"];
        set3.drawIconsEnabled = NO;
    }
    
    //    set1 = [[LineChartDataSet alloc] initWithValues:values label:@"DataSet 1"];
    //        set1.drawIconsEnabled = NO;
    NSMutableArray *dataSets = [[NSMutableArray alloc] init];
    //Note colors are AARRBBGG!
    NSArray *colorz = @[@"#ff5555ee",@"#ff55ee55",@"#ffee5555"];
    NSArray *dashlens1 = @[@6.0f,@7.0f,@8.0f];
    NSArray *dashlens2 = @[@3.0f,@2.0f,@1.0f];
    
    for (int scount = 0;scount<3;scount++)
    {
        LineChartDataSet *nextSet;
        switch(scount)
        {
            case 0: nextSet = set1;break;
            case 1: nextSet = set2;break;
            case 2: nextSet = set3;break;
        }
        if (nextSet != nil)
        {
            //            nextSet.lineDashLengths = @[@5.f, @2.5f];
            nextSet.lineDashLengths = @[dashlens1[scount], dashlens2[scount]];
            nextSet.highlightLineDashLengths = @[dashlens1[scount], dashlens2[scount]];
            [nextSet setColor:UIColor.blackColor];
            [nextSet setCircleColor:UIColor.blackColor];
            nextSet.lineWidth = 1.0;
            nextSet.circleRadius = 3.0;
            nextSet.drawCircleHoleEnabled = NO;
            nextSet.valueFont = [UIFont systemFontOfSize:9.f];
            nextSet.formLineDashLengths = @[dashlens1[scount], dashlens2[scount]];
            nextSet.formLineWidth = 1.0;
            nextSet.formSize = 15.0;
            
            NSString *cstr = colorz[scount];
            NSArray *gradientColors = @[
                                        (id)[ChartColorTemplates colorFromString:@"#ffffffff"].CGColor, //Bottom
                                        (id)[ChartColorTemplates colorFromString:cstr].CGColor //Top
                                        ];
            CGGradientRef gradient = CGGradientCreateWithColors(nil, (CFArrayRef)gradientColors, nil);
            
            nextSet.fillAlpha = 1.f;
            nextSet.fill = [ChartFill fillWithLinearGradient:gradient angle:90.f];
            nextSet.drawFilledEnabled = YES;
            
            CGGradientRelease(gradient);
            
            [dataSets addObject:nextSet];
        } //end for nextset
    }
    LineChartData *data = [[LineChartData alloc] initWithDataSets:dataSets];
    
    _chartView.data = data;
} //end loadPlotData

- (void)optionTapped:(NSString *)key
{
    if ([key isEqualToString:@"toggleFilled"])
    {
        for (id<ILineChartDataSet> set in _chartView.data.dataSets)
        {
            set.drawFilledEnabled = !set.isDrawFilledEnabled;
        }
        
        [_chartView setNeedsDisplay];
        return;
    }
    
    if ([key isEqualToString:@"toggleCircles"])
    {
        for (id<ILineChartDataSet> set in _chartView.data.dataSets)
        {
            set.drawCirclesEnabled = !set.isDrawCirclesEnabled;
        }
        
        [_chartView setNeedsDisplay];
        return;
    }
    
    if ([key isEqualToString:@"toggleCubic"])
    {
        for (id<ILineChartDataSet> set in _chartView.data.dataSets)
        {
            set.mode = set.mode == LineChartModeCubicBezier ? LineChartModeLinear : LineChartModeCubicBezier;
        }
        
        [_chartView setNeedsDisplay];
        return;
    }

    if ([key isEqualToString:@"toggleStepped"])
    {
        for (id<ILineChartDataSet> set in _chartView.data.dataSets)
        {
            switch (set.mode) {
                case LineChartModeLinear:
                case LineChartModeCubicBezier:
                case LineChartModeHorizontalBezier:
                    set.mode = LineChartModeStepped;
                    break;
                case LineChartModeStepped: set.mode = LineChartModeLinear;
            }
        }

        [_chartView setNeedsDisplay];
    }
    
    if ([key isEqualToString:@"toggleHorizontalCubic"])
    {
        for (id<ILineChartDataSet> set in _chartView.data.dataSets)
        {
            set.mode = set.mode == LineChartModeHorizontalBezier ? LineChartModeCubicBezier : LineChartModeHorizontalBezier;
        }
        
        [_chartView setNeedsDisplay];
        return;
    }
    
    [super handleOption:key forChartView:_chartView];
}

#pragma mark - Actions

- (IBAction)slidersValueChanged:(id)sender
{
    _sliderTextX.text = [@((int)_sliderX.value) stringValue];
    _sliderTextY.text = [@((int)_sliderY.value) stringValue];
    
    [self updateChartData];
}

- (IBAction)percentChanged:(id)sender
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
