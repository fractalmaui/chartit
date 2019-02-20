//
//  RawPlotData.h
//  Chartit
//
//  Created by Dave Scruton on 2/18/19.
//  Copyright © 2019 dcg. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Parse/Parse.h>
#import <UIKit/UIKit.h>
#import "DBKeys.h"
#import "EXPObject.h"
#import "EXPStats.h"
#import "EXPTable.h"
#import "Vendors.h"

@protocol RawPlotDataDelegate;



@interface RawPlotData : NSObject
{
    NSMutableArray *plotObjects;
    NSMutableArray *monthlyStats;
    Vendors *vv;
    int allVendorsMax;
    int allVendorsLMax;
    int allVendorsPMax;
    int allVendorsFMax;
    EXPTable *et;
    NSMutableArray *columnKeys; 
    NSArray *pamHeaders;
    NSArray *pamKeywords;
}

@property (nonatomic,assign) BOOL dataLoaded;
@property (nonatomic,assign) int rcount;
@property (nonatomic,strong) EXPStats *expstats;

@property (nonatomic, unsafe_unretained) id <RawPlotDataDelegate> delegate; // receiver of completion messages

+ (id)sharedInstance;

-(void) getStatsFromEXP;
-(void) getStatsFromParse;
-(int)  getStatsMonthCount;
-(int)  getStatsMaxForData : (NSString*)dtype;
-(float) getTotalByMonth : (int) month_0_to_11;
-(void) loadDataFromBuiltinCSV : (NSString *)fname;

@end

@protocol RawPlotDataDelegate <NSObject>
@required
@optional
-(void) didReadFullComparisonTable;
-(void) errorReadingFullComparisonTable : (NSString *)errmsg;
-(void) didGetStats;
@end


