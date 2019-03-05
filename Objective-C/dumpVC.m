//
//  dumpVC.m
//  Chartit
//
//  Created by Dave Scruton on 3/5/19.
//  Copyright © 2019 dcg. All rights reserved.
//

#import "dumpVC.h"

@interface dumpVC ()

@end

@implementation dumpVC

//=============dumpVC=====================================================
- (void)viewDidLoad {
    [super viewDidLoad];
    rpd = RawPlotData.sharedInstance;
}

//=============MainVC=====================================================
-(void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    dumpString = [rpd getDumpStringOfAllStats];
    _dumpText.text = dumpString;
}



//=============dumpVC=====================================================
-(void) dismiss
{
    //[_sfx makeTicSoundWithPitch : 8 : 52];
    [self dismissViewControllerAnimated : YES completion:nil];
    
}


- (IBAction)backSelect:(id)sender
{
    [self dismiss];
}
@end
