//
//  FiscalAxisValueFormatter.h
//  Chartit
//
//  Created by Dave Scruton on 2/19/19.
//  Copyright © 2019 dcg. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Chartit-Swift.h"

@interface FiscalAxisValueFormatter : NSObject <IChartAxisValueFormatter>

- (id)initForChart:(BarLineChartViewBase *)chart;
@end
