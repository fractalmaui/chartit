//
//   __  __       _    __     ______
//  |  \/  | __ _(_)_ _\ \   / / ___|
//  | |\/| |/ _` | | '_ \ \ / / |
//  | |  | | (_| | | | | \ V /| |___
//  |_|  |_|\__,_|_|_| |_|\_/  \____|
//
//  MainVC.m
//  ChartsDemo-iOS
//
//  Created by Dave Scruton on 2/17/19.
//  Copyright © 2019 Beyond Green Partners. All rights reserved.
//
//   ray wenderlich tutorial on swift charts:
//    https://medium.com/@skoli/using-realm-and-charts-with-swift-3-in-ios-10-40c42e3838c0
//  2/28 add switch back to BGPCloud app, (using RH navbar button for now)
//  5/17 add multi-customer support
#import "MainVC.h"

@interface MainVC ()

@end

@implementation MainVC

#define CELLHITE 40
    
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
// Since this comes from an XIB, we're handling inits in here...
- (void)viewDidLoad {
    [super viewDidLoad];
    
    mappDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];

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
  //  dataLoaded  = FALSE;
    statsLoaded = FALSE;
    dataSource  = @"builtin";
    [self startLoadingData];
    //ONLY need for parse load... [spv start : @"Read Plot Data..."];
    rpd = RawPlotData.sharedInstance;
    rpd.delegate = self;
    
    plotOptionsTable = [[UITableView alloc] init];
    plotOptionsTable.backgroundColor = [UIColor colorWithWhite:1.f alpha:0.4f];
    xs = 320;
    xi = viewW2 - xs/2;
//    yi = 100;
    ys = 300; // DHS 3/1  viewHit - yi - 80;
    yi = viewH2 - ys/2;
    plotOptionsTable.frame = CGRectMake(xi,yi,xs,ys);
    plotOptionsTable.delegate = self;
    plotOptionsTable.dataSource = self;
    [plotOptionsTable registerClass:[UITableViewCell class] forCellReuseIdentifier:@"Cell"];
    [self.view addSubview:plotOptionsTable];
    plotOptionsTable.backgroundColor = [UIColor colorWithRed:.7 green:.7 blue:.7 alpha:.3];
    plotOptionsTable.hidden = TRUE;

    monthSelect = @"01-JUL";
    monthNumber = 0;

    [self initOptions];
    tableOptions = lineOptions;
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(startLoadingData:)
//                                                name:@"vendorsLoaded" object:nil];
    
    [self resetOverlay];

} //end viewDidLoad

//=============OCR MainVC=====================================================
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    _customerLabel.text = mappDelegate.selectedCustomerFullName;
}

//=============MainVC=====================================================
-(void) viewDidAppear:(BOOL)animated
{
    
    [super viewDidAppear:animated];
    [self startLoadingData];  //use canned vendors, load data immediately
}


//=============MainVC=====================================================
- (IBAction)lineSelect:(id)sender
{
    if (!dataLoaded) [self errorMessage:@"Waiting to load Data..." :@"Please wait a few moments"];
    else {
        //NSLog(@" line plots...");
        funcSelect   = @"line";
        tableOptions = lineOptions; //Assign table choices
        [self animateOverlay:sender];
    }
} //end lineSelect

//=============MainVC=====================================================
- (IBAction)barSelect:(id)sender
{
    if (!dataLoaded) [self errorMessage:@"Waiting to load Data..." :@"Please wait a few moments"];
    else{
        //NSLog(@" bar plots...");
        funcSelect = @"bar";
        tableOptions = barOptions; //Assign table choices
        [self animateOverlay:sender];
    }
} // end barSelect

//=============MainVC=====================================================
- (IBAction)donutSelect:(id)sender
{
    if (!dataLoaded) [self errorMessage:@"Waiting to load Data..." :@"Please wait a few moments"];
    else{
        //NSLog(@" donut plots...");
        funcSelect = @"pie";
        tableOptions = pieOptions; //Assign table choices
        [self animateOverlay:sender];
    }
} //end donutSelect

//=============MainVC=====================================================
- (IBAction)scatterSelect:(id)sender
{
    [self errorMessage : @"Not Implemented" : @"There are no Scatter Plots set up Yet"];
}


//=============MainVC=====================================================
// 5/17
- (IBAction)customerSelect:(id)sender {
    [self customerMenu];

}

//=============MainVC=====================================================
//  Called when "vendors Loaded" notification comes in...
- (void)startLoadingData
{
    [spv start : @"Load Plot Data..."];
    NSLog(@" loading data...");
    if ([dataSource isEqualToString:@"builtin"])
    {
        [rpd loadDataFromBuiltinCSV: @"fy2018"];
        //Compute stats from EXP data...
        [rpd getStatsFromEXP];
        dataLoaded = TRUE;
        [spv stop];

    }
    else if ([dataSource isEqualToString:@"exp"])
    {
        //DHS 5/17 new table names EXP_GRAPH_CUSTOMERABBREVIATEDNAME
//        [rpd readFullEXPTable : @"EXP_Comparison" : 0 ];
        NSString *etName = [NSString stringWithFormat:@"EXP_GRAPH_%@",mappDelegate.selectedCustomer];
        [rpd readFullEXPTable : etName : 0];   //@"EXP_Comparison" : 0 ];
    }
} //end startLoadingData
    

//=============MainVC=====================================================
// Items to appear in the selection table based on plot type
-(void) initOptions
{
    lineOptions    = @[ @"Totals",@"Total vs Local",@"Total vs Processed",@"Back"];
    barOptions     = @[ @"Totals",@"Total vs Local",@"Total vs Processed",@"Back"];
    pieOptions     = @[ @"Total by Categories",
                        @"Processed by Categories",@"Non-Processed by Categories",
                        @"Local by Categories",@"Non-Local by Categories",
                        @"Local vs Total",@"Processed vs Total",@"FY Month",@"Back"];
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
// Keeps table centered no matter how many options there are
-(void) resetTableFrame
{
    int xi,yi,xs,ys;
    xs = 300;
    ys = CELLHITE * (int)tableOptions.count;
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
    [nav setHotNot         : NAV_HOME_BUTTON : [UIImage imageNamed:@"empty64"]  :
     [UIImage imageNamed:@"empty64"] ];
    [nav setLabelText      : NAV_HOME_BUTTON : NSLocalizedString(@"",nil)];
    [nav setLabelTextColor : NAV_HOME_BUTTON : [UIColor blackColor]];
    [nav setHidden         : NAV_HOME_BUTTON : FALSE];
    // DB access button...
    [nav setHotNot         : NAV_DB_BUTTON : [UIImage imageNamed:@"fileNOT"]  :
     [UIImage imageNamed:@"fileHOT"] ];
    //[nav setCropped        : NAV_DB_BUTTON : 0.01 * PORTRAIT_PERCENT];
    [nav setLabelText      : NAV_DB_BUTTON : NSLocalizedString(@"FILES",nil)];
    [nav setLabelTextColor : NAV_DB_BUTTON : [UIColor blackColor]];
    [nav setHidden         : NAV_DB_BUTTON : FALSE];
    // other button...
    [nav setHotNot         : NAV_SETTINGS_BUTTON : [UIImage imageNamed:@"cloudNOT"]  :
     [UIImage imageNamed:@"cloudHOT"] ];
    [nav setLabelText      : NAV_SETTINGS_BUTTON : NSLocalizedString(@"CLOUD",nil)];
    [nav setLabelTextColor : NAV_SETTINGS_BUTTON : [UIColor blackColor]];
    [nav setHidden         : NAV_SETTINGS_BUTTON : FALSE]; //10/16 show create even logged out...
    
    [nav setHotNot         : NAV_BATCH_BUTTON : [UIImage imageNamed:@"empty64"]  :
     [UIImage imageNamed:@"empty64"] ];
    [nav setLabelText      : NAV_BATCH_BUTTON : NSLocalizedString(@"",nil)];
    [nav setLabelTextColor : NAV_BATCH_BUTTON : [UIColor blackColor]];
    [nav setHidden         : NAV_BATCH_BUTTON : FALSE]; //10/16 show create even logged out...
    //Set color behind NAV buttpns...
    [nav setSolidBkgdColor:[UIColor colorWithRed:0.9 green:0.8 blue:0.7 alpha:1] :1];
    
    //REMOVE FOR FINAL DELIVERY
    //    vn = [[UIVersionNumber alloc] initWithPlacement:UI_VERSIONNUMBER_TOPRIGHT];
    //    [nav addSubview:vn];
    
}

//=============MainVC=====================================================
-(void) errorMessage : (NSString *) title :(NSString *) msg
{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:
                                NSLocalizedString(title,nil)  message:msg
                                                            preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"OK",nil)
                                              style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
                                              }]];
    [self presentViewController:alert animated:YES completion:nil];
    
} //end errorMessage


//=============MainVC=====================================================
// 2/27 choose fiscal month for pie chart
-(void) monthMenu
{
    NSArray *    fiscalMonths = @[ @"01-JUL", @"02-AUG", @"03-SEP", @"04-OCT",
                                   @"05-NOV", @"06-DEC", @"07-JAN", @"08-FEB",
                                   @"09-MAR", @"10-APR", @"11-MAY", @"12-JUN"
                                ];
    NSMutableAttributedString *tatString = [[NSMutableAttributedString alloc]initWithString:@"Choose Month"];
    [tatString addAttribute:NSFontAttributeName value:[UIFont boldSystemFontOfSize:30] range:NSMakeRange(0, tatString.length)];
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:
                                NSLocalizedString(@"Choose Month",nil)
                                                                   message:nil
                                                            preferredStyle:UIAlertControllerStyleActionSheet];
    [alert setValue:tatString forKey:@"attributedTitle"];
    int count = 0;
    for (NSString *month in fiscalMonths)
    {
        [alert addAction:[UIAlertAction actionWithTitle:NSLocalizedString(month,nil)
                                                  style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
                                                      self->monthSelect = month;
                                                      self->monthNumber = count;
                                                  }]];
        count++;
    }
    [alert addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel",nil)
                                              style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
                                              }]];
    [self presentViewController:alert animated:YES completion:nil];
} //end monthMenu

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
    
    //5/17 add customer selection
    [alert addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"Change Customer",nil)
                                              style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
                                                  [self customerMenu];
                                              }]];

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


//=============OCR MainVC=====================================================
// 5/17 New: multi-customer support
-(void) customerMenu
{
    

    NSString *cstr = [NSString stringWithFormat:@"Current Customer [%@]",mappDelegate.selectedCustomer];
    NSMutableAttributedString *tatString = [[NSMutableAttributedString alloc]initWithString:cstr];
    [tatString addAttribute:NSFontAttributeName value:[UIFont boldSystemFontOfSize:30] range:NSMakeRange(0, tatString.length)];
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:
                                NSLocalizedString(cstr,nil)
                                                                   message:nil
                                                            preferredStyle:UIAlertControllerStyleActionSheet];
    
    [alert setValue:tatString forKey:@"attributedTitle"];
    int i = 0;
    for (NSString *nextCust in mappDelegate.cust.customerNames)
    {
        NSString *cfull = mappDelegate.cust.fullNames[i];
        [alert addAction:[UIAlertAction actionWithTitle:NSLocalizedString(nextCust,nil)
                                                  style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
                                                      [mappDelegate updateCustomerDefaults:nextCust :cfull];
                                                      self->_customerLabel.text = cfull;
                                                  }]];
        i++;
    }
    [alert addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel",nil)
                                              style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
                                                 // [self makeCancelSound];
                                              }]];
    [self presentViewController:alert animated:YES completion:nil];
    
    
} //end customerMenu

//=============MainVC=====================================================
-(void) loadMenu
{
    NSMutableAttributedString *tatString = [[NSMutableAttributedString alloc]initWithString:@"Load From:"];
    [tatString addAttribute:NSFontAttributeName value:[UIFont boldSystemFontOfSize:30] range:NSMakeRange(0, tatString.length)];
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:
                                NSLocalizedString(@"Load From:",nil)
                                                                   message:nil
                                                            preferredStyle:UIAlertControllerStyleActionSheet];
    
    [alert setValue:tatString forKey:@"attributedTitle"];
    [alert addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"Builtin Fiscal Year",nil)
                                              style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
                                                  self->dataSource = @"builtin";
                                                  [self startLoadingData];
                                              }]];
    [alert addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"EXP Table",nil)
                                              style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
                                                  self->dataSource = @"exp";
                                                  [self startLoadingData];
                                              }]];
    [self presentViewController:alert animated:YES completion:nil];
    
    
} //end loadMmenu



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

//=============MainVC=====================================================
-(void) setupPieChart
{
    PieChartViewController *vc = [[PieChartViewController alloc] init];
    [vc setPlotType:ptypeSelect];  //selected plot type, total, total vs local, etc
    [vc setPlotTitle:ptypeSelect]; //this needs improvement
    [vc setMonth:monthSelect :monthNumber];
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
    return CELLHITE;
}

//=============MainVC=====================================================
// 2/22 hook up
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    ptypeSelect = cell.textLabel.text;
    if ([ptypeSelect.lowercaseString isEqualToString:@"back"])
    {
        [self resetOverlay];
    }
    else if ([ptypeSelect.lowercaseString containsString:@"month"])
    {
        [self monthMenu];
    }
    else //Go to a plot...
    {
        if ([funcSelect isEqualToString:@"line"]) [self setupLineChart];
        if ([funcSelect isEqualToString:@"bar"])  [self setupBarChart];
        if ([funcSelect isEqualToString:@"pie"])  [self setupPieChart];
    }
    [tableView deselectRowAtIndexPath:indexPath animated:NO];

    
} //end didSelectRowAtIndexPath



#pragma mark - NavButtonsDelegate
//=============<NavButtonsDelegate>=====================================================
-(void)  didSelectNavButton: (int) which
{
    NSLog(@"   didselectNavButton %d",which);
    // [_sfx makeTicSoundWithPitch : 8 : 50 + which];
    
    if (which == 0) //Stubbed for now...
    {
        if (statsLoaded)
        {
            [rpd dumpAllStats];
            dvc = [[dumpVC alloc] init];
            [self presentViewController:dvc animated:YES completion:nil];
        }
    }
    else if (which == 1) //Choose input source
    {
        [self loadMenu];
    }
    else if (which == 2) //Switch back to BGP Cloud
    {
        NSString *chartitAppURL = @"BGPCloud://";
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:chartitAppURL]];
    }
    else if (which == 3) //Stubbed for now...
    {

    }
    
} //end didSelectNavButton


#pragma mark - RawPlotDataDelegate

//=======<RawPlotDataDelegate>=======================================
-(void) didReadFullEXPTable
{
    NSLog(@" read data OK");
    dataLoaded = TRUE;
    dispatch_async(dispatch_get_main_queue(), ^{
        [self->spv stop];
        [self->rpd getStatsFromParse];
    });
}

//=======<RawPlotDataDelegate>=======================================
-(void) errorReadingFullEXPTable : (NSString *)errmsg
{
    NSLog(@" error reading EXP %@",errmsg);
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
