//
//   ____                ____  _       _   ____        _
//  |  _ \ __ ___      _|  _ \| | ___ | |_|  _ \  __ _| |_ __ _
//  | |_) / _` \ \ /\ / / |_) | |/ _ \| __| | | |/ _` | __/ _` |
//  |  _ < (_| |\ V  V /|  __/| | (_) | |_| |_| | (_| | || (_| |
//  |_| \_\__,_| \_/\_/ |_|   |_|\___/ \__|____/ \__,_|\__\__,_|
//
//  RawPlotData.h
//  Chartit
//
//  Created by Dave Scruton on 2/18/19.
//  Copyright © 2019 Beyond Green Partners. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Parse/Parse.h>
#import <UIKit/UIKit.h>
#import "DBKeys.h"
#import "EXPObject.h"
#import "EXPStats.h"
#import "EXPTable.h"
//#import "Vendors.h"

@protocol RawPlotDataDelegate;



@interface RawPlotData : NSObject
{
    NSMutableArray *plotObjects;
    NSMutableArray *monthlyStats;
    //Vendors *vv;
    int allVendorsMax;
    int allVendorsLMax;
    int allVendorsPMax;
    int allVendorsFMax;
    EXPTable *et;
    NSMutableArray *columnKeys; 
    NSArray *pamHeaders;
    NSArray *pamKeywords;
    NSArray *vnames;

}

@property (nonatomic,assign) BOOL dataLoaded;
@property (nonatomic,assign) int rcount;
@property (nonatomic,assign) int categoryCount;
@property (nonatomic,strong) EXPStats *expstats;

@property (nonatomic, unsafe_unretained) id <RawPlotDataDelegate> delegate; // receiver of completion messages

+ (id)sharedInstance;

-(void) getStatsFromEXP;
-(void) getStatsFromParse;
-(int)  getStatsMonthCount;
-(int)  getStatsMaxForData : (NSString*)dtype;
-(void) loadDataFromBuiltinCSV : (NSString *)fname;

-(float) getTotalByMonth : (int) month_0_to_11;
-(float) getLocalTotalByMonth : (int) month_0_to_11;
-(float) getProcessedTotalByMonth : (int) month_0_to_11;
-(float) getCatPRSumByMonth : (int) cindex : (int) month_0_to_11;
-(float) getCatNPRSumByMonth : (int) cindex : (int) month_0_to_11;
-(float) getCatLOSumByMonth : (int) cindex : (int) month_0_to_11;
-(float) getCatNLOSumByMonth : (int) cindex : (int) month_0_to_11;


@end

@protocol RawPlotDataDelegate <NSObject>
@required
@optional
-(void) didReadFullComparisonTable;
-(void) errorReadingFullComparisonTable : (NSString *)errmsg;
-(void) didGetStats;
@end


