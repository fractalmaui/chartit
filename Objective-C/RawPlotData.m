//
//   ____                ____  _       _   ____        _
//  |  _ \ __ ___      _|  _ \| | ___ | |_|  _ \  __ _| |_ __ _
//  | |_) / _` \ \ /\ / / |_) | |/ _ \| __| | | |/ _` | __/ _` |
//  |  _ < (_| |\ V  V /|  __/| | (_) | |_| |_| | (_| | || (_| |
//  |_| \_\__,_| \_/\_/ |_|   |_|\___/ \__|____/ \__,_|\__\__,_|
//
//  RawPlotData.m
//  Chartit
//
//  Created by Dave Scruton on 2/18/19.
//  Copyright © 2019 Beyond Green Partners. All rights reserved.
//
//  3/5 add dumpallstats and getDumpStringOfAllStats

#import "RawPlotData.h"

@implementation RawPlotData
static RawPlotData *sharedInstance = nil;


//=============(RawPlotData)=====================================================
// Get the shared instance and create it if necessary.
+ (RawPlotData *)sharedInstance {
    if (sharedInstance == nil) {
        sharedInstance = [[super allocWithZone:NULL] init];
    }
    
    return sharedInstance;
}

//=============(RawPlotData)=====================================================
-(instancetype) init
{
    if (self = [super init])
    {
        plotObjects  = [[NSMutableArray alloc] init];
        monthlyStats = [[NSMutableArray alloc] init];
        _dataLoaded = FALSE;
        //vv = [Vendors sharedInstance];
        //[self readFullComparisonTable:0];
        columnKeys  = [[NSMutableArray alloc] init];
        et = [[EXPTable alloc] init];
        pamHeaders = nil;
        pamKeywords = nil;
        _categoryCount = 8; //Canned, need better way to set this
        
        vnames = @[
                   @"Adaptations",
                   @"Cal Kona",
                   @"Coca Cola",
                   @"Gordon",
                   @"Greco",
                   @"HFM",
                   @"Hawaii Beef Producers",
                   @"Loves Bakery",
                   @"Meadow Gold"
                   ];
    }
    return self;
}

//=============(RawPlotData)=====================================================
-(void) loadDataFromBuiltinCSV : (NSString *)fname
{
    [self loadConstants];
    NSError *error;
    NSString *fileContentsAscii;
    NSString *path = [[NSBundle mainBundle] pathForResource:fname ofType:@"txt" inDirectory:@"txt"];
    NSURL *url = [NSURL fileURLWithPath:path];
    fileContentsAscii = [NSString stringWithContentsOfURL:url encoding:NSASCIIStringEncoding error:&error];
    if (error != nil)
    {
        NSLog(@" error reading %@ file",fname);
        return;
    }
    [self processCSVToEXP : fileContentsAscii];
    
} //end loadDataFromCSV

//=============(RawPlotData)=====================================================
-(void) dumpAllStats
{
    for (EXPStats *es in monthlyStats) [es dump];
}

//=============(RawPlotData)=====================================================
-(NSString *) getDumpStringOfAllStats
{
    NSString *dumpit = @"Dump Full Fiscal Year\n\n";
    for (EXPStats *es in monthlyStats)
    {
        dumpit = [dumpit stringByAppendingString:@"==============================\n"];
        dumpit = [dumpit stringByAppendingString:[NSString stringWithFormat:@"%@\n",[es getDumpString]]];
    }
    return dumpit;
}

//=============(RawPlotData)=====================================================
-(void) getStatsFromEXP
{
    int rcount = (int)et.expos.count;  //expos record count
    NSLog(@"getStatsFromEXP...");
    [monthlyStats removeAllObjects];
    
    for (int month = 1; month<=12;month++) //Loop over the year
    {
        EXPStats *estats   = [[EXPStats alloc] init];
        NSString *monthStr = [estats getMonthName:month];
        //NSLog(@"%@===========================================",monthStr );
        [estats clear]; //Clear stats...
        //loop over allll exp objects
        for (int i=0;i<rcount;i++)
        {
            NSString *rmonth = [et getMonth:i];
            if ([rmonth isEqualToString:monthStr]) //Match?
            {
                NSString *vendor   = [et getVendor:i];
                NSString *category = [et getCategory:i];
                category = [category stringByReplacingOccurrencesOfString:@" " withString:@""]; //Trim!
                NSUInteger catIndex = [estats getCategoryIndex : category];
                //asdf
                if (catIndex == NSNotFound) //Wups!
                {
                    NSLog(@" cat [%@] not found!",category);
                }
                int  vindex     = [self getVendorIndex:vendor]; //this is dimensioned by all possible vendors!
                //                if ([category.lowercaseString containsString:@"protein"])
                //                {
                //                    NSLog(@" protein %d",i);
                //                }
                int  amount     = [et getAmount:i];
                BOOL locFlag    = [et getLocal:i];
                BOOL proFlag    = [et getProcessed:i];
                
                [estats addAmount :vindex :amount ];
                if (locFlag)
                {
                    [estats addLAmount :vindex :amount ];
                }
                if (proFlag)
                {
                    [estats addPAmount :vindex :amount ];
                }
                
                if ([estats isFoodItem : category])
                {
                    [estats addFAmount : vindex : amount];
                }
                
                //Update category info too
                [estats addCatAmount :vindex :(int)catIndex :amount : proFlag: locFlag];
            } //end if rmonth
        }    //end for i
        //[estats dump];
        if (estats.allVendorsAmount > 0)
        {
            allVendorsMax  = MAX(allVendorsMax ,estats.allVendorsMax);
            allVendorsLMax = MAX(allVendorsLMax,estats.allVendorsLMax);
            allVendorsPMax = MAX(allVendorsPMax,estats.allVendorsPMax);
            allVendorsFMax = MAX(allVendorsFMax,estats.allVendorsFMax);
            [monthlyStats addObject:estats];
        }
    }       //end for month
    
    NSLog(@" got %d months of stats ",(int)monthlyStats.count);
    [self.delegate didGetStats];

} //end getStatsFromEXP


//=============(RawPlotData)=====================================================
-(void) getStatsFromParse
{
    [monthlyStats removeAllObjects];
    NSLog(@"getStatsFromParse...");

    allVendorsMax = allVendorsLMax = allVendorsPMax = allVendorsFMax = 0;

    for (int month = 1; month<=12;month++) //Loop over the year
    {
        EXPStats *estats   = [[EXPStats alloc] init];
        NSString *monthStr = [estats getMonthName:month];
        NSLog(@"%@===========================================",monthStr );
        [estats clear]; //Clear stats...
        //loop over allll exp objects
        for (int i=0;i<_rcount;i++)
        {
            PFObject *pfo = plotObjects[i];
            NSString *rmonth = pfo[PInv_Month_key];
            if ([rmonth isEqualToString:monthStr]) //Match?
            {
                //NSLog(@"--->rmonth %@ vs ms %@",rmonth,monthStr);
                NSString *vendor   = pfo[PInv_Vendor_key];
                NSString *category = pfo[PInv_Category_key];
                category = [category stringByReplacingOccurrencesOfString:@" " withString:@""]; //Trim!
                NSUInteger catIndex = [estats getCategoryIndex : category];
                //asdf
                if (catIndex == NSNotFound) //Wups!
                {
                    NSLog(@" cat [%@] not found!",category);
                }
                int  vindex     = [self getVendorIndex:vendor]; //this is dimensioned by all possible vendors!
                //                if ([category.lowercaseString containsString:@"protein"])
                //                {
                //                    NSLog(@" protein %d",i);
                //                }
                if (vindex >= 0)
                {
                    NSString *wstr  = pfo[PInv_TotalPrice_key];
                    wstr      = [wstr stringByReplacingOccurrencesOfString:@"$" withString:@""];
                    int  amount     = floor(0.5 + (wstr.floatValue * 100.0));
                    wstr            = pfo[PInv_Local_key];
                    BOOL locFlag    = [wstr.lowercaseString isEqualToString:@"yes"];
                    wstr            = pfo[PInv_Processed_key];
                    BOOL proFlag    = [wstr.lowercaseString isEqualToString:@"processed"];
                    [estats addAmount :vindex :amount ];
                    if (locFlag)
                    {
                        [estats addLAmount :vindex :amount ];
                    }
                    if (proFlag)
                    {
                        [estats addPAmount :vindex :amount ];
                    }
                    if ([estats isFoodItem : category])
                    {
                        [estats addFAmount : vindex : amount];
                    }
                    
                    //Update category info too
                    [estats addCatAmount :vindex :(int)catIndex :amount : proFlag: locFlag];
                    
                }
                else
                {
                    NSLog(@" vendor %@ not found!",vendor);
                }
           } //end if rmonth
        }    //end for i
        //[estats dump];
        //DHS 2/19 ignore empty months... (data had better be sequential!)
        if (estats.allVendorsAmount > 0)
        {
            allVendorsMax  = MAX(allVendorsMax ,estats.allVendorsMax);
            allVendorsLMax = MAX(allVendorsLMax,estats.allVendorsLMax);
            allVendorsPMax = MAX(allVendorsPMax,estats.allVendorsPMax);
            allVendorsFMax = MAX(allVendorsFMax,estats.allVendorsFMax);
            [monthlyStats addObject:estats];
        }
    }       //end for month
    
    NSLog(@" got %d months of stats ",(int)monthlyStats.count);
    [self.delegate didGetStats];

} //end getStatsFromParse

//=============(RawPlotData)=====================================================
// from vendors object
-(int)  getVendorIndex : (NSString *)vname
    {
        NSString *vlc = vname.lowercaseString;
        int i=0;
        for (NSString *vn in vnames)
        {
            if ([vlc containsString:vn.lowercaseString]) return i;//Match?
            i++;
        }
        return -1;
    }

    
//=============(RawPlotData)=====================================================
-(int)  getStatsMonthCount
{
    return (int)monthlyStats.count;
} //end getStatsMonthCount

//=============(RawPlotData)=====================================================
-(int)  getStatsMaxForData : (NSString*)dtype
{
    if ([dtype.lowercaseString isEqualToString:@"all"])
        return allVendorsMax;
    return 0;
} //end getStatsMaxForData


//=============(RawPlotData)=====================================================
-(BOOL)isMonthLegal : (int) m
{
    if (m < 0) return FALSE;
    if (m > 11) return FALSE;
    if (m >= monthlyStats.count) return FALSE;
    return TRUE;
} //end isMonthLegal

//=============(RawPlotData)=====================================================
-(float) getDollarsAndCentsCrappily : (int) i
{
    float fpennies = (float)i;
    return (fpennies / 100.0);
} //end getDollarsAndCentsCrappily

//=============(RawPlotData)=====================================================
-(float) getTotalByMonth : (int) month_0_to_11
{
    if (![self isMonthLegal:month_0_to_11]) return 0.0;
    _expstats = monthlyStats[month_0_to_11];
    return [self getDollarsAndCentsCrappily : _expstats.allVendorsAmount];
} //end getTotalByMonth

//=============(RawPlotData)=====================================================
-(float) getLocalTotalByMonth : (int) month_0_to_11
{
    if (![self isMonthLegal:month_0_to_11]) return 0.0;
    _expstats = monthlyStats[month_0_to_11];
    return [self getDollarsAndCentsCrappily : _expstats.allVendorsLAmount];
} //end getLocalTotalByMonth

//=============(RawPlotData)=====================================================
-(float) getProcessedTotalByMonth : (int) month_0_to_11
{
    if (![self isMonthLegal:month_0_to_11]) return 0.0;
    _expstats = monthlyStats[month_0_to_11];
    return [self getDollarsAndCentsCrappily : _expstats.allVendorsPAmount];
} //end getLocalTotalByMonth


//=============(RawPlotData)=====================================================
-(float) getCatPRSumByMonth : (int) cindex : (int) month_0_to_11
{
    if (![self isMonthLegal:month_0_to_11]) return 0.0;
    _expstats = monthlyStats[month_0_to_11];
    return [self getDollarsAndCentsCrappily : [_expstats getCategoryPRSum:cindex]];
} //end getCatPRSumByMonth


//=============(RawPlotData)=====================================================
-(float) getCatNPRSumByMonth : (int) cindex : (int) month_0_to_11
{
    if (![self isMonthLegal:month_0_to_11]) return 0.0;
    _expstats = monthlyStats[month_0_to_11];
    return [self getDollarsAndCentsCrappily : [_expstats getCategoryNPRSum:cindex]];
} //end getCatNPRSumByMonth

//=============(RawPlotData)=====================================================
-(float) getCatLOSumByMonth : (int) cindex : (int) month_0_to_11
{
    if (![self isMonthLegal:month_0_to_11]) return 0.0;
    _expstats = monthlyStats[month_0_to_11];
    return [self getDollarsAndCentsCrappily : [_expstats getCategoryLOSum:cindex]];
} //end getCatLOSumByMonth


//=============(RawPlotData)=====================================================
-(float) getCatNLOSumByMonth : (int) cindex : (int) month_0_to_11
{
    if (![self isMonthLegal:month_0_to_11]) return 0.0;
    _expstats = monthlyStats[month_0_to_11];
    return [self getDollarsAndCentsCrappily : [_expstats getCategoryNLOSum:cindex]];
} //end getCatNLOSumByMonth



//=============(RawPlotData)=====================================================
-(void) loadConstants
{
    if (pamHeaders != nil) return; //Already loaded?
    pamHeaders  = @[  //Human-readable CSV headers from Excel
                    @"category", @"month", @"item", @"quantity",
                    @"unit of measure", @"bulk/ individual pack", @"vendor name", @"total price",
                    @"price/ uom", @"processed", @"local (l)", @"invoice date",
                    @"line #"
                    ];
    pamKeywords = @[  //matching PARSE column names
                    PInv_Category_key,PInv_Month_key,PInv_ProductName_key,PInv_Quantity_key,
                    PInv_UOM_key,PInv_Bulk_or_Individual_key,PInv_Vendor_key,PInv_TotalPrice_key,
                    PInv_PricePerUOM_key,PInv_Processed_key,PInv_Local_key,PInv_Date_key,
                    PInv_LineNumber_key
                    ];
    
    
} //end loadConstants

//=============(RawPlotData)=====================================================
//Can't break up a CSV string right if it has commas inside quoted names (like vendor!)
-(NSString *) stripCommasFromQuotedStrings : (NSString*) s
{
    NSString *result = @"";
    NSRange theRange;
    BOOL inQuotes = FALSE;
    for ( NSInteger i = 0; i < [s length]; i++) {
        theRange.location = i;
        theRange.length   = 1;
        NSString* nextChar = [s substringWithRange:theRange];
        if ([nextChar isEqualToString:@"\""]) //double quotes? toggle quotes flag
        {
            inQuotes = !inQuotes;
        }
        else if ([nextChar isEqualToString:@","]) //comma? don't append if inside quotes!
        {
            if (!inQuotes) result = [result stringByAppendingString:nextChar];
        } //Not a quote or comma..... just append
        else result = [result stringByAppendingString:nextChar];
    } //end for i
    return result;
} //end stripCommasFromQuotedStrings


//=============(RawPlotData)=====================================================
// Loads string CSV contents, creates EXPTable array of EXPObjects
-(void) processCSVToEXP : (NSString *)s
{
    NSLog(@" processing CSV... get hdr info first:");
    //First check column ordering...
    NSArray  *csvItems = [s componentsSeparatedByString:@"\n"]; //Break up file into lines
    if (csvItems.count < 2)
    {
        NSLog(@" ERROR: no data in CSV File!");
        return;
    }
    NSMutableArray *columnKeys  = [[NSMutableArray alloc] init];
//    [columnKeys removeAllObjects]; //Clear columns...
    NSString *legend      = csvItems[0];
    NSArray  *legendItems = [legend componentsSeparatedByString:@","]; //Break up legend...
    for (NSString *nextHeader in legendItems)
    {
        NSString *hhh = [nextHeader stringByTrimmingCharactersInSet:
                         [NSCharacterSet whitespaceAndNewlineCharacterSet]];
        NSUInteger wherezit = [pamHeaders indexOfObject:hhh.lowercaseString];
        if (wherezit != NSNotFound)
        {
            [columnKeys addObject: [pamKeywords objectAtIndex:wherezit]];
        }
        else if (hhh.length > 1){
            NSLog(@" ERROR: unmatched CSV header title %@",nextHeader);
            return;
        }
    }
    //Work strings...
    int loadCount,writeCount,okCount,errCount;
    BOOL firstRecord = TRUE;
    writeCount = okCount = errCount = 0;
    loadCount  = (int)csvItems.count;
    [et clear];
    for (NSString *nextLine in csvItems)
    {
        if (!firstRecord) //Skip 1st record...
        {
            NSString* noQuotedCommas =  [self stripCommasFromQuotedStrings:nextLine];
            NSArray  *nlItems      = [noQuotedCommas componentsSeparatedByString:@","]; //Break up line...
            NSMutableArray *fields = [[NSMutableArray alloc] init];
            NSMutableArray *values = [[NSMutableArray alloc] init];
            NSDate *idate          = [NSDate date];
            for (int i=0;i<nlItems.count;i++) //Go thru fields...
            {
                if (i >= pamKeywords.count) break; //Out of bounds or extra args on line? skip!
                NSString *nextField = nlItems[i];
                NSString *nextPamKw = pamKeywords[i];
                if ([nextPamKw isEqualToString:PInv_Date_key])
                { //date format: 07/03/2018
                    NSDateFormatter * formatter =  [[NSDateFormatter alloc] init];
                    [formatter setDateFormat:@"MM/dd/yyyy"];
                    idate = [formatter dateFromString:nextField]; //Unpack date
                }
                else{
                    [fields addObject:nextPamKw];
                    [values addObject:nextField];
                }
            } //end for i
            if (values.count > 2) //Did we get something?
            {
                //OK ready to write!
                //if (writeCount % 100 == 0) NSLog(@" write %d/%d [%@]",writeCount,loadCount,values[2]);
                [et addRecordFromArrays : idate :  fields : values];
                writeCount++;
            }
        } //end !first...
        firstRecord = FALSE;
    } //end for loop
    NSLog(@" saved %d records to ET",writeCount);
    
} //end processCSVToEXP



#define LIMIT_SIZE 100
//=============(RawPlotData)=====================================================
// Loads in data LIMIT_SIZE recs at a time, uses "skip" for re=entrant call asdf
-(void) readFullEXPTable : (NSString *) tableName : (int) skip
{
    if (skip == 0) //Start? Clear CSVList and add header
    {
        [plotObjects removeAllObjects];
        _dataLoaded = FALSE;
    }
    //NOTE: the plot table is has a subset of the full EXP tables columns!
    PFQuery *query = [PFQuery queryWithClassName:tableName]; //This may change!
    NSLog(@" read %d to %d",skip,skip+LIMIT_SIZE);
    query.skip = skip;
    query.limit = LIMIT_SIZE;
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) { 
            for( PFObject *pfo in objects)
            {
                [self->plotObjects addObject:pfo];
            }
            NSLog(@" ...got %d records from parse ",(int)objects.count);
            if (objects.count == LIMIT_SIZE) //Maybe more?
            {
                [self readFullEXPTable : tableName : skip+LIMIT_SIZE  ];
            }
            else
            {
                self->_dataLoaded = TRUE;
                [self.delegate didReadFullEXPTable];
                self->_rcount = (int)self->plotObjects.count;
            }
        }
        else
            [self.delegate errorReadingFullEXPTable : error.localizedDescription];
    }];
} //end readFullEXPTable

@end
