//
//  CCData.m
//
//  Created by James on 3/20/10.
//  Copyright 2010-2011 Cirrostratus Design Company. All rights reserved.
//

#import "CCData.h"
#import "SQLiteAccess.h"
#import <Foundation/Foundation.h> 

@implementation CCData


- (NSArray *)searchResultsForTable:(NSString *)theTable column:(NSString *)theColumn term:(NSString *)theTerm {	
    NSMutableArray *ma = [[[NSMutableArray alloc] init] autorelease];
    ILog();
    NSMutableString *sql1 = [[[NSMutableString alloc] initWithFormat:@"SELECT * FROM %@ WHERE ", theTable] autorelease];
    ILog();
    [sql1 appendFormat:@"`%@` LIKE '%%%@%%' ", theColumn, theTerm];
    ILog();
    NSArray *a1 = [[SQLiteAccess sql] selectManyRowsWithSQL:[NSString stringWithString:sql1]];
    ILog();
    if (a1) {
        ILog();
        [ma addObjectsFromArray:a1];
    }
    ILog();
    [sql1 setString:[NSString stringWithFormat:@"SELECT * FROM %@ WHERE ", theTable]];
    ILog();
    BOOL ran = FALSE;
    NSArray *a = [theTerm componentsSeparatedByString:@" "];
    ILog();
    for (NSString *s in a) {
        if ([s length] > 2) {
            ILog();
            if(ran)[sql1 appendString:@"OR "];
            ILog();
            [sql1 appendFormat:@"`%@` LIKE '%%%@%%' ", theColumn, s];
            ILog();
            if (([s length] > 2)) {
                ILog();
                if ([[s substringFromIndex:[s length]-1] isEqualToString:@"s"]) {
                    ILog();
                    [sql1 appendFormat:@"OR `%@` LIKE '%%%@%%' ", theColumn, [s substringToIndex:[s length] - 1]];
                }
                ILog();
            }
            ran = YES;
            ILog();
        }
    }	
    ILog();
    NSArray *a2 = [[SQLiteAccess sql] selectManyRowsWithSQL:[NSString stringWithString:sql1]];
    ILog();
    if (a2) {
        ILog();
        [ma addObjectsFromArray:a2];
    }
    ILog();
    return [NSArray arrayWithArray:ma];
}
- (NSArray *)searchResultsForTerm:(NSString *)s {	
	return [self searchResultsForTable:@"documents" column:@"body" term:s];
}


- (NSArray *)dataForTable:(NSString *)t {
	NSString *sql = [NSString stringWithFormat:@"SELECT * FROM %@", t];
	return [[SQLiteAccess sql] selectManyRowsWithSQL:sql];
}

- (NSArray *)dataForColumn:(NSString *)theColumn inTable:(NSString *)theTable; {
    NSString *sql = [NSString stringWithFormat:@"SELECT '%@' FROM %@", theColumn, theTable];
	return [[SQLiteAccess sql] selectManyRowsWithSQL:sql];
}

- (NSArray *)dataForTable:(NSString *)t where:(NSString *)w equals:(NSString *)e {
	NSString *sql = [NSString stringWithFormat:@"SELECT * FROM %@ WHERE %@ = '%@'", t, w, e];
	ILogPlus(@"%@",sql);
	return [[SQLiteAccess sql] selectManyRowsWithSQL:sql];
}

- (NSArray *)dataForTable:(NSString *)t params:(NSDictionary *)d; {
	return [self dataForTable:t params:d limitOne:NO];
}

- (id)dataForTable:(NSString *)t params:(NSDictionary *)d limitOne:(BOOL)limit {
    NSMutableString *sql = [[NSMutableString alloc] initWithString:@"SELECT * FROM "];
    [sql appendFormat:@"%@ WHERE ",t];
    for (int i = 0; i<[[d allKeys] count]; i++) {
        [sql appendFormat:@"`%@` = '%@' ",[[d allKeys] objectAtIndex:i], [[d allValues] objectAtIndex:i]];
        if ([[d allKeys] count] > i+1) {
            [sql appendString:@"AND "];
        }
    }
	if (limit) {
		return [[SQLiteAccess sql] selectOneRowWithSQL:[sql autorelease]];
	}
	return [[SQLiteAccess sql] selectManyRowsWithSQL:[sql autorelease]];
}


- (id)dataForTable:(NSString *)t where:(NSString *)w equals:(NSString *)e limitOne:(BOOL)limit;{
	NSString *sql = [NSString stringWithFormat:@"SELECT * FROM %@ WHERE %@ = '%@'", t, w, e];
	if (limit) {
		return [[SQLiteAccess sql] selectOneRowWithSQL:sql];
	}
	return [[SQLiteAccess sql] selectManyRowsWithSQL:sql];
}

- (id)dataForTable:(NSString *)t where:(NSString *)w equals:(NSString *)e isInt:(BOOL)b limitOne:(BOOL)limit; {
	if(!b){
		return [self dataForTable:t where:w equals:e];
	}
	NSString *sql = [NSString stringWithFormat:@"SELECT * FROM %@ WHERE %@ = %i", t, w, [e intValue]];
	DLog(@"%@",sql);
	if (limit) {
		return [[SQLiteAccess sql] selectOneRowWithSQL:sql];
	}
	return [[SQLiteAccess sql] selectManyRowsWithSQL:sql];
}


- (NSArray *)dataForTable:(NSString *)t where:(NSString *)w matches:(NSString *)e {
	NSString *sql = [NSString stringWithFormat:@"SELECT * FROM %@ WHERE %@ MATCH '%@'", t, w, e];
	DLog(@"%@",sql);
	return [[SQLiteAccess sql] selectManyRowsWithSQL:sql];
}


- (NSArray *)dataForTable:(NSString *)t where:(NSString *)w equals:(NSString *)e isInt:(BOOL)b {
	if(!b){
		return [self dataForTable:t where:w equals:e];
	}
	NSString *sql = [NSString stringWithFormat:@"SELECT * FROM %@ WHERE %@ = %i", t, w, [e intValue]];
	DLog(@"%@",sql);
	return [[SQLiteAccess sql] selectManyRowsWithSQL:sql];
}

- (NSDictionary *)detailForID:(NSInteger)i inTable:(NSString *)t {
	NSString *sql = [NSString stringWithFormat:@"SELECT * FROM %@ WHERE id = '%i'", t, i];
	return [[SQLiteAccess sql] selectOneRowWithSQL:sql];
}

- (void)deleteRowInTable:(NSString *)t byID:(NSInteger)i {
	return [self deleteRowInTable:t byID:i idColumnName:@"id"];
}

- (void)deleteRowInTable:(NSString *)t byID:(NSInteger)i idColumnName:(NSString *)n; {
	NSString *sql = [NSString stringWithFormat:@"DELETE FROM %@ WHERE %@ = '%i'", t, n, i];
	return [[SQLiteAccess sql] deleteWithSQL:sql];
}

- (NSNumber *)insertRow:(NSDictionary *)r inTable:(NSString *)t {
	DLog(@"insertRow");
	NSMutableString *mutable_sql = [[[NSMutableString alloc] initWithString:@""] autorelease];
	[mutable_sql appendString:[NSString stringWithFormat:@"INSERT INTO %@ (",t]];
	for (id theKey in r){
		[mutable_sql appendString:[NSString stringWithFormat:@"%@,",theKey]];
	}
	mutable_sql = [NSMutableString stringWithString:[mutable_sql substringToIndex:[mutable_sql length] - 1]];
	[mutable_sql appendString:@") VALUES ("];
	for (id theKey in r){
		NSString *s;
		if ([r objectForKey:theKey] != [NSNull null]) {
			s = [[r objectForKey:theKey] stringByReplacingOccurrencesOfString:@"\"" withString:@"'"];
			[mutable_sql appendString:[NSString stringWithFormat:@"\"%@\",",s]];
		}else {
			[mutable_sql appendString:[NSString stringWithFormat:@"\"%@\",",[r objectForKey:theKey]]];
		}		
	}
	mutable_sql = [NSMutableString stringWithString:[mutable_sql substringToIndex:[mutable_sql length] - 1]];
	[mutable_sql appendString:@")"];
	return [[SQLiteAccess sql] insertWithSQL:[NSString stringWithString:mutable_sql]];
}

- (void)updateRow:(NSDictionary *)r byID:(NSInteger)i inTable:(NSString *)t {
	[self updateRow:r inTable:t where:@"id" equals:String(@"%i",i)];
}

- (void)updateRow:(NSDictionary *)r inTable:(NSString *)t where:(NSString *)w equals:(NSString *)e; {
    NSMutableString *mutable_sql = [[[NSMutableString alloc] initWithString:@""] autorelease];
	[mutable_sql appendString:[NSString stringWithFormat:@"UPDATE %@ SET ",t]];
	for (id theKey in r){
		[mutable_sql appendString:[NSString stringWithFormat:@"%@ = '%@',",theKey,[r objectForKey:theKey]]];
	}
	mutable_sql = [NSMutableString stringWithString:[mutable_sql substringToIndex:[mutable_sql length] - 1]];
	[mutable_sql appendString:[NSString stringWithFormat:@"WHERE %@ = '%@'",w,e]];
	[[SQLiteAccess sql] updateWithSQL:[NSString stringWithString:mutable_sql]];
}

- (NSString *)arrayOfDictionariesToCSV:(NSArray *)arrayOfDictionaries {
	NSMutableString *itemsString = [[[NSMutableString alloc] init] autorelease];
	NSArray *items = arrayOfDictionaries;
	NSUInteger i, count = [items count];
	for (i = 0; i < count; i++) {
		if (i == 0) {
			NSArray *itemKeys = [[items objectAtIndex:i] allKeys];
			NSUInteger n, count2 = [itemKeys count];
			for (n = 0; n < count2; n++) {
				NSString *key = [itemKeys objectAtIndex:n];
				[itemsString appendString:key];
				if (n != count2-1) {
					[itemsString appendString:@","];
				} else {
					[itemsString appendString:@"\n"];
				}
			}
		}
		NSArray *itemValues = [[items objectAtIndex:i] allValues];
		NSUInteger j, count3 = [itemValues count];
		for (j = 0; j < count3; j++) {
			NSString *value = [itemValues objectAtIndex:j];
			[itemsString appendString:value];
			if (j != count3-1) {
				[itemsString appendString:@","];
			} else {
				[itemsString appendString:@"\n"];
			}
		}
		
	}
	return [NSString stringWithFormat:@"%@",itemsString];
}


@end
