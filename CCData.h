//
//  CCData.h
//
//  Created by James on 3/20/10.
//  Copyright 2010-2011 Cirrostratus Design Company. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface CCData : NSObject


- (NSArray *)searchResultsForTerm:(NSString *)s;

- (NSArray *)dataForTable:(NSString *)t;

- (NSArray *)dataForTable:(NSString *)t params:(NSDictionary *)d;

- (id)dataForTable:(NSString *)t params:(NSDictionary *)d limitOne:(BOOL)limit;

- (NSArray *)dataForTable:(NSString *)t where:(NSString *)w equals:(NSString *)e;

- (id)dataForTable:(NSString *)t where:(NSString *)w equals:(NSString *)e limitOne:(BOOL)limit;

- (id)dataForTable:(NSString *)t where:(NSString *)w equals:(NSString *)e isInt:(BOOL)b limitOne:(BOOL)limit;

- (NSArray *)dataForTable:(NSString *)t where:(NSString *)w matches:(NSString *)e;

- (NSArray *)dataForTable:(NSString *)t where:(NSString *)w equals:(NSString *)e isInt:(BOOL)b;

- (NSArray *)dataForColumn:(NSString *)theColumn inTable:(NSString *)theTable;

- (NSDictionary *)detailForID:(NSInteger)i inTable:(NSString *)t;

- (void)deleteRowInTable:(NSString *)t byID:(NSInteger)i;

- (void)deleteRowInTable:(NSString *)t byID:(NSInteger)i idColumnName:(NSString *)n;

- (NSNumber *)insertRow:(NSDictionary *)r inTable:(NSString *)t;

- (void)updateRow:(NSDictionary *)r byID:(NSInteger)i inTable:(NSString *)t;

- (void)updateRow:(NSDictionary *)r inTable:(NSString *)t where:(NSString *)w equals:(NSString *)e;

- (NSString *)arrayOfDictionariesToCSV:(NSArray *)arrayOfDictionaries;

- (NSArray *)searchResultsForTable:(NSString *)theTable column:(NSString *)theColumn term:(NSString *)theTerm;

@end
