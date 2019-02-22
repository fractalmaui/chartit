//
//  MainVC.m
//  ChartsDemo-iOS
//
//  Created by Dave Scruton on 2/17/19.
//  Copyright © 2019 Beyond Green Partners. All rights reserved.
//
//   ray wenderlich tutorial on swift charts:
//    https://medium.com/@skoli/using-realm-and-charts-with-swift-3-in-ios-10-40c42e3838c0

#import "MainVC.h"

@interface MainVC ()

@end

@implementation MainVC


//=============MainVC=====================================================
- (id)initWithCoder:(NSCoder *)aDecoder {
    if ((self = [super initWithCoder:aDecoder])) {

    }
    return self;
}

- (void)encodeWithCoder:(nonnull NSCoder *)aCoder {
    
}



//=============MainVC=====================================================
- (void)viewDidLayoutSubviews
{

}

//=============MainVC=====================================================
- (void)viewDidLoad {
    [super viewDidLoad];
    CGSize csz   = [UIScreen mainScreen].bounds.size;
    viewWid = (int)csz.width;
    viewHit = (int)csz.height;
    viewW2  = viewWid/2;
    viewH2  = viewHit/2;
    
    // Do any additional setup after loading the view.
    int xi,yi,xs,ys;
    //CLUGEY! makes sure landscape òrientation doesn't set up NAVbar wrong`
    int tallestXY  = viewHit;
    int shortestXY = viewWid;
    if (shortestXY > tallestXY)
    {
        tallestXY  = viewWid;
        shortestXY = viewHit;
    }
    xs = shortestXY;
    ys = 80;
    xi = 0;
    yi = tallestXY - ys;
    nav = [[NavButtons alloc] initWithFrameAndCount: CGRectMake(xi, yi, xs, ys) : 4];
    nav.delegate = self;
    [self.view addSubview: nav];
    [self setupNavBar];
    
    // Add spinner busy indicator...
    spv = [[spinnerView alloc] initWithFrame:CGRectMake(0, 0, (int)csz.width, (int)csz.height)];
    [self.view addSubview:spv];
    
    
    //NOTE: this is a singleton, so there should be ONLY ONE Delegate!!!
    //  what if a child window needs to load data???
    //  may want to switch to NSNotification?
    dataLoaded  = FALSE;
    statsLoaded = FALSE;
    
    //ONLY need for parse load... [spv start : @"Read Plot Data..."];
    rpd = RawPlotData.sharedInstance;
    rpd.delegate = self;
    
    plotOptionsTable = [[UITableView alloc] init];
    plotOptionsTable.backgroundColor = [UIColor colorWithWhite:1.f alpha:0.4f];
    xs = 320;
    xi = viewW2 - xs/2;
    yi = 100;
    ys = viewHit - yi - 80;
    plotOptionsTable.frame = CGRectMake(xi,yi,xs,ys);
    plotOptionsTable.delegate = self;
    plotOptionsTable.dataSource = self;
    [plotOptionsTable registerClass:[UITableViewCell class] forCellReuseIdentifier:@"Cell"];
    [self.view addSubview:plotOptionsTable];
    plotOptionsTable.hidden = TRUE;


    [self initOptions];
    tableOptions = lineOptions;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(startLoadingData:)
                                                 name:@"vendorsLoaded" object:nil];
    
    [self resetOverlay];

} //end viewDidLoad

//=============MainVC=====================================================
-(void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

//=============MainVC=====================================================
- (IBAction)lineSelect:(id)sender
{
    NSLog(@" line plots...");
    funcSelect   = @"line";
    tableOptions = lineOptions; //Assign table choices
    [self animateOverlay:sender];
}

//=============MainVC=====================================================
- (IBAction)barSelect:(id)sender
{
    NSLog(@" bar plots...");
    funcSelect = @"bar";
    tableOptions = barOptions; //Assign table choices
    [self animateOverlay:sender];
}

//=============MainVC=====================================================
- (IBAction)donutSelect:(id)sender
{
    NSLog(@" donut plots...");
    funcSelect = @"pie";
    tableOptions = pieOptions; //Assign table choices
    [self animateOverlay:sender];
}

//=============MainVC=====================================================
- (IBAction)scatterSelect:(id)sender
{
    NSLog(@" scatter plots...");
    funcSelect = @"scatter";
    tableOptions = scatterOptions; //Assign table choices
    [self animateOverlay:sender];
}

//=============MainVC=====================================================
// Items to appear in the selection table based on plot type
-(void) initOptions
{
    lineOptions    = @[ @"Totals",@"Total vs Local",@"Total vs Processed",@"Back"];
    barOptions     = @[ @"Totals",@"Total vs Local",@"Total vs Processed",@"Back"];
    pieOptions     = @[ @"PIETotals",@"Total vs Local",@"Total vs Processed",@"Back"];
    scatterOptions = @[ @"STotals",@"Total vs Local",@"Total vs Processed",@"Back"];
}

//=============MainVC=====================================================
-(void) resetOverlay
{
    _overlayView.hidden = TRUE;
    _buttonsView.alpha  = 1.0;
    plotOptionsTable.hidden = TRUE;
    
}

//=============MainVC=====================================================
-(void) resetTableFrame
{
    int xi,yi,xs,ys;
    xs = 300;
    ys = 60 * (int)tableOptions.count;
    xi = viewW2 - xs/2;
    yi = viewH2 - ys/2;
    plotOptionsTable.frame = CGRectMake(xi,yi,xs,ys);

}

//=============MainVC=====================================================
-(void) animateOverlay : (id) sender
{
    UIButton *bbb        = (UIButton *)sender;
    _animImage.frame     = bbb.frame;
    _buttonsView.alpha   = 0.3;
    float adur           = 1.0;
    _animImage.image     = bbb.currentBackgroundImage;
    _overlayView.hidden  = FALSE;
    CGRect rr2 = _overlayView.frame;
    rr2.origin.x = 0;
    rr2.origin.y = 0;
    [UIView animateWithDuration:adur
                          delay:0
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         self.animImage.frame = rr2; //Anim Image up to full frame
                     }
                     completion:^(BOOL finished){
                         [self resetTableFrame];
                         [self->plotOptionsTable reloadData];
                         self->plotOptionsTable.hidden = FALSE;
                     }
     ];
} //end animateOverlay

//=============MainVC=====================================================
-(void) setupNavBar
{
    nav.backgroundColor = [UIColor redColor];
    //    [nav setSolidBkgdColor:[UIColor colorWithRed:0.9 green:0.8 blue:0.7 alpha:1] :0.5];
    //
    //
    //     -(void) setSolidBkgdColor : (UIColor*) color : (float) alpha
    //]
    //    nav.backgroundColor = [UIColor colorWithRed:0.9 green:0.8 blue:0.7 alpha:1];
    // Menu Button...
    [nav setHotNot         : NAV_HOME_BUTTON : [UIImage imageNamed:@"HamburgerHOT"]  :
     [UIImage imageNamed:@"HamburgerNOT"] ];
    [nav setLabelText      : NAV_HOME_BUTTON : NSLocalizedString(@"MENU",nil)];
    [nav setLabelTextColor : NAV_HOME_BUTTON : [UIColor blackColor]];
    [nav setHidden         : NAV_HOME_BUTTON : FALSE];
    // DB access button...
    [nav setHotNot         : NAV_DB_BUTTON : [UIImage imageNamed:@"dbNOT"]  :
     [UIImage imageNamed:@"dbHOT"] ];
    //[nav setCropped        : NAV_DB_BUTTON : 0.01 * PORTRAIT_PERCENT];
    [nav setLabelText      : NAV_DB_BUTTON : NSLocalizedString(@"DB",nil)];
    [nav setLabelTextColor : NAV_DB_BUTTON : [UIColor blackColor]];
    [nav setHidden         : NAV_DB_BUTTON : FALSE];
    // other button...
    [nav setHotNot         : NAV_SETTINGS_BUTTON : [UIImage imageNamed:@"grafHOT"]  :
     [UIImage imageNamed:@"grafNOT"] ];
    [nav setLabelText      : NAV_SETTINGS_BUTTON : NSLocalizedString(@"Outputs",nil)];
    [nav setLabelTextColor : NAV_SETTINGS_BUTTON : [UIColor blackColor]];
    [nav setHidden         : NAV_SETTINGS_BUTTON : FALSE]; //10/16 show create even logged out...
    
    [nav setHotNot         : NAV_BATCH_BUTTON : [UIImage imageNamed:@"multiNOT"]  :
     [UIImage imageNamed:@"multiHOT"] ];
    [nav setLabelText      : NAV_BATCH_BUTTON : NSLocalizedString(@"Batch",nil)];
    [nav setLabelTextColor : NAV_BATCH_BUTTON : [UIColor blackColor]];
    [nav setHidden         : NAV_BATCH_BUTTON : FALSE]; //10/16 show create even logged out...
    //Set color behind NAV buttpns...
    [nav setSolidBkgdColor:[UIColor colorWithRed:0.9 green:0.8 blue:0.7 alpha:1] :1];
    
    //REMOVE FOR FINAL DELIVERY
    //    vn = [[UIVersionNumber alloc] initWithPlacement:UI_VERSIONNUMBER_TOPRIGHT];
    //    [nav addSubview:vn];
    
}

//=============MainVC=====================================================
-(void) menu
{
    NSMutableAttributedString *tatString = [[NSMutableAttributedString alloc]initWithString:@"Plot Functions"];
    [tatString addAttribute:NSFontAttributeName value:[UIFont boldSystemFontOfSize:30] range:NSMakeRange(0, tatString.length)];
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:
                                NSLocalizedString(@"Plot Functions",nil)
                                                                   message:nil
                                                            preferredStyle:UIAlertControllerStyleActionSheet];
    [alert setValue:tatString forKey:@"attributedTitle"];
    
    //Only have plot options if there is something to plot!
    if (statsLoaded)
    {
        [alert addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"Bar Chart",nil)
                                                  style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
                                                      [self setupBarChart];
                                                  }]];
        
    }
    [alert addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel",nil)
                                              style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
                                              }]];
    [self presentViewController:alert animated:YES completion:nil];
    
    
} //end menu

//=============MainVC=====================================================
//  Called when "vendors Loaded" notification comes in...
- (void)startLoadingData:(NSNotification *)notification
{
    NSLog(@" loading data...");
    [rpd loadDataFromBuiltinCSV: @"fy2018"];
    //Compute stats from EXP data...
    [rpd getStatsFromEXP];
} //end startLoadingData



//=============MainVC=====================================================
// 2/22 use string for plot type
-(void) setupBarChart
{
    BarChartViewController *vc = [[BarChartViewController alloc] init];
    [vc setPlotType:ptypeSelect];  //selected plot type, total, total vs local, etc
    [vc setPlotTitle:ptypeSelect]; //this needs improvement
    [vc setPlotXYRanges:12 :50000];
    [self.navigationController pushViewController:vc animated:YES];
    
}

//=============MainVC=====================================================
-(void) setupLineChart
{
    LineChart1ViewController *vc = [[LineChart1ViewController alloc] init];
    [vc setPlotType:ptypeSelect];  //selected plot type, total, total vs local, etc
    [vc setPlotTitle:ptypeSelect]; //this needs improvement
    [vc setPlotXYRanges:12 :50000];
    [self.navigationController pushViewController:vc animated:YES];
    
}

#pragma mark - UITableViewDelegate


//=============MainVC=====================================================
- (UITableViewCell *)tableView:(nonnull UITableView *)tableView cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"Cell";
    int row = (int)indexPath.row;
    //NSLog(@" cell row %d",row);
    UITableViewCell *cell = (UITableViewCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    cell.textLabel.text = tableOptions[row];
    cell.backgroundColor = [UIColor clearColor];
    return cell;
} //end cellForRowAtIndexPath


//=============MainVC=====================================================
- (NSInteger)tableView:(nonnull UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return tableOptions.count;
}




//=============MainVC=====================================================
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 60;
}

//=============MainVC=====================================================
// 2/22 hook up
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    ptypeSelect = cell.textLabel.text;
    NSLog(@" duh %@",ptypeSelect);
    if ([ptypeSelect.lowercaseString isEqualToString:@"back"])
    {
        [self resetOverlay];
    }
    else //Go to a plot...
    {
        if ([funcSelect isEqualToString:@"line"]) [self setupLineChart];
        if ([funcSelect isEqualToString:@"bar"])  [self setupBarChart];
    }
    [tableView deselectRowAtIndexPath:indexPath animated:NO];

    
} //end didSelectRowAtIndexPath



#pragma mark - NavButtonsDelegate
//=============<NavButtonsDelegate>=====================================================
-(void)  didSelectNavButton: (int) which
{
    NSLog(@"   didselectNavButton %d",which);
    // [_sfx makeTicSoundWithPitch : 8 : 50 + which];
    
    if (which == 0) //THis is now a multi-function popup...
    {
        [self menu];
    }
    else if (which == 1) //THis is now a multi-function popup...
    {
        
        //Load canned data to an internal EXP table
        [rpd loadDataFromBuiltinCSV: @"fy2018"];
        //Compute stats from EXP data...
        [rpd getStatsFromEXP];
        
        //[rpd getStats];
        
        //        [self dbmenu];
    }
    else if (which == 2) //Templates / settings?
    {
        [self resetOverlay];
    }
    //    if (which == 3 && vv.loaded) //batch? (2/5 make sure vendors are there first!)
    //    {
    //        [self performSegueWithIdentifier:@"batchSegue" sender:@"mainVC"];
    //    }
    
} //end didSelectNavButton


#pragma mark - RawPlotDataDelegate

//=======<RawPlotDataDelegate>=======================================
-(void) didReadFullComparisonTable
{
    NSLog(@" read data OK");
    dataLoaded = TRUE;
    dispatch_async(dispatch_get_main_queue(), ^{
        [self->spv stop];
        [self->rpd getStatsFromParse];
    });
}

//=======<RawPlotDataDelegate>=======================================
-(void) didGetStats
{
    statsLoaded = TRUE;
}


//=======<RawPlotDataDelegate>=======================================
-(void) errorReadingFullComparisonTable : (NSString *)errmsg
{
    NSLog(@" error reading data:%@",errmsg);
    dispatch_async(dispatch_get_main_queue(), ^{
        [self->spv stop];
    });
    
}




@end
