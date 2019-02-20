//
//  FiscalAxisValueFormatter.m
//  Chartit
//
//  Created by Dave Scruton on 2/19/19.
//  Copyright © 2019 dcg. All rights reserved.
//

#import "FiscalAxisValueFormatter.h"

@interface FiscalAxisValueFormatter ()
{
    NSArray *fmonths;
    NSDateFormatter *_dateFormatter;
    __weak BarLineChartViewBase *_chart;
}
@end

@implementation FiscalAxisValueFormatter

- (id)initForChart:(BarLineChartViewBase *)chart
{
    self = [super init];
    if (self)
    {
        self->_chart = chart;
        
        fmonths = @[
                   @"Jul", @"Aug", @"Sep",
                   @"Oct", @"Nov", @"Dec",
                   @"Jan", @"Feb", @"Mar",
                   @"Apr", @"May", @"Jun"
                   ];
    }
    return self;
}

//-----(FiscalAxisValueFormatter)------------------------------------------
- (NSString *)stringForValue:(double)value
                        axis:(ChartAxisBase *)axis
{
    int fiscalMonth = (int)value;
    fiscalMonth     = MAX(fiscalMonth,0);
    int modMonth    = fiscalMonth % 12;
    return fmonths[modMonth];
}



@end
