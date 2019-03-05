//
//   _______  ______  ____  _        _
//  | ____\ \/ /  _ \/ ___|| |_ __ _| |_ ___
//  |  _|  \  /| |_) \___ \| __/ _` | __/ __|
//  | |___ /  \|  __/ ___) | || (_| | |_\__ \
//  |_____/_/\_\_|   |____/ \__\__,_|\__|___/
//
//  EXPStats.m
//  testOCR
//
//  Created by Dave Scruton on 2/2/19.
//  Copyright © 2018 Beyond Green Partners. All rights reserved.
//

#import "EXPStats.h"

@implementation EXPStats

//=============(EXPStats)=====================================================
-(instancetype) init
{
    if (self = [super init])
    {
        //vv  = [Vendors sharedInstance];
        //NSLog(@" estats init vendors %@",vv);
        //_versionNumber    = [[NSBundle mainBundle] objectForInfoDictionaryKey:(NSString *)kCFBundleVersionKey];
        [self loadConstants];
        [self clear];
    }
    return self;
}

//=============(EXPStats)=====================================================
-(void) clear
{
    for (int i=0;i<MAX_CVENDORS;i++)
    {
        amounts[i] = 0;
        counts[i] = 0;
        amounts[i] = 0;
        lcounts[i] = 0;
        lamounts[i] = 0;
        pcounts[i] = 0;
        pamounts[i] = 0;
        fcounts[i] = 0;
        famounts[i] = 0;
        for (int j=0;j<MAX_CCATEGORIES;j++)
        {
            catPRAmounts[i][j] = 0;
            catPRCounts[i][j] = 0;
            catNPRAmounts[i][j] = 0;
            catNPRCounts[i][j] = 0;
            catLOAmounts[i][j] = 0;
            catLOCounts[i][j] = 0;
            catNLOAmounts[i][j] = 0;
            catNLOCounts[i][j] = 0;
        }
    }
    
    _allVendorsAmount  = _allVendorsCount  = _allVendorsMax  = 0;
    _allVendorsLAmount = _allVendorsLCount = _allVendorsLMax = 0;
    _allVendorsPAmount = _allVendorsPCount = _allVendorsPMax = 0;
    _allVendorsFAmount = _allVendorsFCount = _allVendorsFMax = 0;

    for (int j=0;j<MAX_CCATEGORIES;j++)
    {
        catPRSums[j]  = 0;
        catPRCSums[j] = 0;
        catNPRSums[j]  = 0;
        catNPRCSums[j] = 0;
        catLOSums[j]  = 0;
        catLOCSums[j] = 0;
        catNLOSums[j]  = 0;
        catNLOCSums[j] = 0;
    }
    foodSum = processedSum = localSum = 0;
    nonprocessedSum = nonlocalSum = 0;

} //end clear


//=============(EXPStats)=====================================================
-(void) loadConstants
{
    categories = @[
                   @"beverage",
                   @"bread",
                   @"dairy",
                   @"drygoods",
                   @"produce",
                   @"protein",
                   @"snacks",
                   @"labor",
                   @"misc",
                   @"papergoods",
                   @"supplement",
                   @"supplies"
                   ];
    foodCategories = @[
                   @"beverage",
                   @"bread",
                   @"dairy",
                   @"drygoods",
                   @"produce",
                   @"protein",
                   @"snacks"
                   ];
    monthNames = @[
                   @"01-JUL",
                   @"02-AUG",
                   @"03-SEP",
                   @"04-OCT",
                   @"05-NOV",
                   @"06-DEC",
                   @"07-JAN",
                   @"08-FEB",
                   @"09-MAR",
                   @"10-APR",
                   @"11-MAY",
                   @"12-JUN"
                  ];
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

} //end loadConstants

//=============(EXPStats)=====================================================
-(NSUInteger) getCategoryIndex : (NSString*) catstr
{
    return [categories indexOfObject:catstr.lowercaseString];
}

//=============(EXPStats)=====================================================
-(int)  getCategoryLOSum : (int) cindex
{
    if (cindex < 0 || cindex >= MAX_CCATEGORIES) return 0;
    return catLOSums[cindex];
}

//=============(EXPStats)=====================================================
-(int)  getCategoryNLOSum : (int) cindex
{
    if (cindex < 0 || cindex >= MAX_CCATEGORIES) return 0;
    return catNLOSums[cindex];
}


//=============(EXPStats)=====================================================
-(int)  getCategoryPRSum : (int) cindex
{
    if (cindex < 0 || cindex >= MAX_CCATEGORIES) return 0;
    return catPRSums[cindex];
}

//=============(EXPStats)=====================================================
-(int)  getCategoryNPRSum : (int) cindex
{
    if (cindex < 0 || cindex >= MAX_CCATEGORIES) return 0;
    return catNPRSums[cindex];
}

//=============(EXPStats)=====================================================
-(NSString *) getMonthName : (int) index1To12
{
    if (index1To12 < 1 || index1To12 > 12) return @"";
    return monthNames[index1To12-1];
}


//=============(EXPStats)=====================================================
-(BOOL) isIndexLegal : (int) index
{
    if (index < 0) return FALSE;
    if (index >=MAX_CVENDORS) return FALSE;
    return TRUE;
}

//=============(EXPStats)=====================================================
-(BOOL) isCatIndexLegal : (int) index
{
    if (index < 0) return FALSE;
    if (index >=MAX_CCATEGORIES) return FALSE;
    return TRUE;
}

//=============(EXPStats)=====================================================
-(void) addAmount : (int) index : (int) a
{
    if ([self isIndexLegal:index])
    {
        amounts[index] += a;
        counts[index]++;
        _allVendorsAmount+=a;
        _allVendorsCount++;
        _allVendorsMax = MAX(_allVendorsMax,a);
    }
}

//=============(EXPStats)=====================================================
-(void) addLAmount : (int) index : (int) a
{
    if ([self isIndexLegal:index])
    {
        lamounts[index] += a;
        lcounts[index]++;
        localSum+=a;
        _allVendorsLAmount+=a;
        _allVendorsLCount++;
        _allVendorsLMax = MAX(_allVendorsLMax,a);
    }
}

//=============(EXPStats)=====================================================
-(void) addPAmount : (int) index : (int) a
{
    if ([self isIndexLegal:index])
    {
        pamounts[index] += a;
        pcounts[index]++;
        processedSum+=a;
        _allVendorsPAmount+=a;
        _allVendorsPCount++;
        _allVendorsPMax = MAX(_allVendorsPMax,a);
    }
}

//=============(EXPStats)=====================================================
// Food/NonFood
-(void) addFAmount : (int) index : (int) a
{
    if ([self isIndexLegal:index])
    {
        famounts[index] += a;
        fcounts[index]++;
        foodSum+=a;
        _allVendorsFAmount+=a;
        _allVendorsFCount++;
        _allVendorsFMax = MAX(_allVendorsFMax,a);
    }
}


//=============(EXPStats)=====================================================
-(void) addCatAmount : (int) vindex : (int) cindex : (int) a : (BOOL) proFlag : (BOOL) locFlag
{
    if ([self isIndexLegal:vindex] && [self isCatIndexLegal:cindex])
    {
        if (proFlag)
        {
            catPRAmounts[vindex][cindex]+=a;
            catPRCounts[vindex][cindex]++;
            catPRSums[cindex]+=a;
            catPRCSums[cindex]++;
        }
        else
        {
            catNPRAmounts[vindex][cindex]+=a;
            catNPRCounts[vindex][cindex]++;
            catNPRSums[cindex]+=a;
            catNPRCSums[cindex]++;
        }
        if (locFlag)
        {
            catLOAmounts[vindex][cindex]+=a;
            catLOCounts[vindex][cindex]++;
            catLOSums[cindex]+=a;
            catLOCSums[cindex]++;
        }
        else
        {
            catNLOAmounts[vindex][cindex]+=a;
            catNLOCounts[vindex][cindex]++;
            catNLOSums[cindex]+=a;
            catNLOCSums[cindex]++;
        }
    }
}

//=============(EXPStats)=====================================================
-(BOOL) isFoodItem : (NSString *) cat
{
    return ([foodCategories indexOfObject:cat.lowercaseString] != NSNotFound);
}


//=============(EXPStats)=====================================================
-(void) dump
{
    NSLog(@"%@",[self getDumpString]);
}

//=============(EXPStats)=====================================================
-(NSString*) getDumpString
{
    //Dumpit
    NSString *dumpit = [NSString stringWithFormat:@"Stats : %d/%d\n" ,_month,_year];
    if (foodSum == 0) //Nuttin?
    {
        dumpit = [dumpit stringByAppendingString:@" ...empty\n"];
        return dumpit;
    }
    smartp = [[smartProducts alloc] init];
    NSString *tstr;
    NSString *tstr2;
    for (int i=0;i<MAX_CVENDORS;i++)
    {
        if (amounts[i] > 0) //Got somethign for this vendor?
        {
            dumpit = [dumpit stringByAppendingString:[NSString stringWithFormat:@"Vendor: %@\n",vnames[i]]];
            float ftotal = (float)amounts[i] / 100.0;
            tstr = [smartp getDollarsAndCentsString:ftotal];
            dumpit = [dumpit stringByAppendingString:[NSString stringWithFormat:@" Total $%@\n",tstr]];
            //int lct  = lcounts[i];
            int lam  = (float)lamounts[i] / 100.0;
            int nlam = (float)(amounts[i]-lamounts[i])/ 100.0;
            tstr = [smartp getDollarsAndCentsString:lam];
            tstr2 = [smartp getDollarsAndCentsString:nlam];
            dumpit = [dumpit stringByAppendingString:[NSString stringWithFormat:@" Local:$%@ vs NonLocal:$%@\n",tstr,tstr2]];
            //int pct  = pcounts[i];
            int pam  = (float)pamounts[i] / 100.0;
            int npam = (float)(amounts[i]-pamounts[i])/ 100.0;
            tstr = [smartp getDollarsAndCentsString:pam];
            tstr2 = [smartp getDollarsAndCentsString:npam];
            dumpit = [dumpit stringByAppendingString:[NSString stringWithFormat:@" Processed:$%@ vs NonProcessed:$%@\n",tstr,tstr2]];
            int fam = (float)famounts[i] / 100.0;
            int fct = fcounts[i];
            tstr = [smartp getDollarsAndCentsString:fam];
            dumpit = [dumpit stringByAppendingString:[NSString stringWithFormat:@" Food Items %d : $%@\n",fct,tstr]];
            tstr = [smartp getDollarsAndCentsString:(ftotal-fam)];
            dumpit = [dumpit stringByAppendingString:[NSString stringWithFormat:@" Non-Food Items %d : $%@\n",counts[i]-fct,tstr]];

            float cPRtotal = 0.0;
            float cNPRtotal = 0.0;
            float fPRtotal = 0.0;
            float fNPRtotal = 0.0;
            for (int j=0;j<(int)categories.count;j++)
            {
                fPRtotal = (float)catPRAmounts[i][j]/ 100.0;
                fNPRtotal = (float)catNPRAmounts[i][j]/ 100.0;
                if (fPRtotal > 0 || fNPRtotal > 0) //Only print out if there is data
                {
                    cPRtotal += fPRtotal;
                    cNPRtotal += fNPRtotal;
                    tstr = [smartp getDollarsAndCentsString:fPRtotal];
                    dumpit = [dumpit stringByAppendingString:[NSString stringWithFormat:@"  ...Cat[%@] proc:     $%@\n",categories[j],tstr]];
                    tstr = [smartp getDollarsAndCentsString:fNPRtotal];
                    dumpit = [dumpit stringByAppendingString:[NSString stringWithFormat:@"  ...Cat[%@] non-proc: $%@\n",categories[j],tstr]];
                }
            } //end for j
            tstr = [smartp getDollarsAndCentsString:cPRtotal];
            dumpit = [dumpit stringByAppendingString:[NSString stringWithFormat:@"  Processed Total: $%@\n",tstr]];
            tstr = [smartp getDollarsAndCentsString:cNPRtotal];
            dumpit = [dumpit stringByAppendingString:[NSString stringWithFormat:@"  Non-Processed Total: $%@\n",tstr]];

        }    //end if amounts..
    }       //end for i
    dumpit = [dumpit stringByAppendingString:[NSString stringWithFormat:@"  Category sums:\n"]];
    for (int j=0;j<(int)categories.count;j++)
    {
        float ftotal,fsum;
        NSString *catstr = categories[j];
        dumpit = [dumpit stringByAppendingString:[NSString stringWithFormat:@"   Cat[%@] ........... \n",catstr]];
        ftotal = fsum = 0.0;
        if ([self isFoodItem:catstr])
        {
            fsum   = (float)(catPRSums[j] + catNPRSums[j])/ 100.0;
            tstr = [smartp getDollarsAndCentsString:fsum];
            dumpit = [dumpit stringByAppendingString:[NSString stringWithFormat:@"  ... Total             $%@\n",tstr]];
            ftotal = (float)catPRSums[j]/ 100.0;
            tstr = [smartp getDollarsAndCentsString:ftotal];
            dumpit = [dumpit stringByAppendingString:[NSString stringWithFormat:@"  ... Processed     sum $%@\n",tstr]];
            ftotal = (float)catNPRSums[j]/ 100.0;
            tstr = [smartp getDollarsAndCentsString:ftotal];
            dumpit = [dumpit stringByAppendingString:[NSString stringWithFormat:@"  ... Non-Processed sum $%@\n",tstr]];
        }
        else{
            ftotal = (float)catNPRSums[j]/ 100.0;
            tstr = [smartp getDollarsAndCentsString:ftotal];
            dumpit = [dumpit stringByAppendingString:[NSString stringWithFormat:@"  ...Cat[%@]sum $%@\n",catstr,tstr]];
        }
    }
    
    dumpit = [dumpit stringByAppendingString:[NSString stringWithFormat:@"    ........... \n"]];
    float prtotal = (float)processedSum/ 100.0;
    tstr  = [smartp getDollarsAndCentsString:prtotal];
    dumpit = [dumpit stringByAppendingString:[NSString stringWithFormat:@" Overall Processed sum : %@\n",tstr]];
    float lototal = (float)localSum/ 100.0;
    tstr = [smartp getDollarsAndCentsString:lototal];
    dumpit = [dumpit stringByAppendingString:[NSString stringWithFormat:@" Overall Local    sum : %@\n",tstr]];
    float fototal = (float)foodSum/ 100.0;
    tstr = [smartp getDollarsAndCentsString:fototal];
    dumpit = [dumpit stringByAppendingString:[NSString stringWithFormat:@" Overall Food     sum : %@\n",tstr]];
    return dumpit;
    
} //end dump


@end
