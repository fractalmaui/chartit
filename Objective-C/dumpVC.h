//
//  dumpVC.h
//  Chartit
//
//  Created by Dave Scruton on 3/5/19.
//  Copyright © 2019 dcg. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RawPlotData.h"
#import "EXPStats.h"

NS_ASSUME_NONNULL_BEGIN

@interface dumpVC : UIViewController
{
    RawPlotData *rpd;
    EXPStats *estats;
    NSString *dumpString;

}
@property (weak, nonatomic) IBOutlet UITextView *dumpText;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
- (IBAction)backSelect:(id)sender;

@end

NS_ASSUME_NONNULL_END
