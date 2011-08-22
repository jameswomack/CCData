//
//  SQLiteAccess.m
//
//  Created by Bill Dudney on 3/11/08.
//  Copyright 2008 Gala Factory. All rights reserved.
//

#define DB_NAME @"Notify"
#define DB_EXT @"db"

#import "SQLiteAccess.h"
#import <sqlite3.h>

@implementation SQLiteAccess

static int singleRowCallback(void *queryValuesVP, int columnCount, char **values, char **columnNames) {
    NSMutableDictionary *queryValues = (NSMutableDictionary *)queryValuesVP;
    int i;
    for(i=0; i<columnCount; i++) {
        [queryValues setObject:values[i] ? [NSString stringWithUTF8String:values[i]] : [NSNull null] 
                        forKey:[NSString stringWithFormat:@"%s", columnNames[i]]];
    }
    return 0;
}

static int multipleRowCallback(void *queryValuesVP, int columnCount, char **values, char **columnNames) {
    NSMutableArray *queryValues = (NSMutableArray *)queryValuesVP;
    NSMutableDictionary *individualQueryValues = [NSMutableDictionary dictionary];
    int i;
    for(i=0; i<columnCount; i++) {
        [individualQueryValues setObject:values[i] ? [NSString stringWithUTF8String:values[i]] : [NSNull null] 
                                  forKey:[NSString stringWithFormat:@"%s", columnNames[i]]];
    }
    [queryValues addObject:[NSDictionary dictionaryWithDictionary:individualQueryValues]];
    return 0;
}

+ (NSString *)pathToDB {
	NSString *dbName = DB_NAME;
    NSString *originalDBPath = [[NSBundle mainBundle] pathForResource:dbName ofType:DB_EXT];
    NSString *path = nil;
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *appSupportDir = [paths objectAtIndex:0];
    NSString *dbNameDir = [NSString stringWithFormat:@"%@/sql", appSupportDir];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    BOOL isDir = NO;
    BOOL dirExists = [fileManager fileExistsAtPath:dbNameDir isDirectory:&isDir];
    NSString *dbPath = [NSString stringWithFormat:@"%@/%@.%@", dbNameDir, dbName, DB_EXT];
    if(dirExists && isDir) {
        BOOL dbExists = [fileManager fileExistsAtPath:dbPath];
        if(!dbExists) {
            NSError *error = nil;
            BOOL success = [fileManager copyItemAtPath:originalDBPath toPath:dbPath error:&error];
            if(!success) {
                NSLog(@"error = %@", error);
            } else {
                path = dbPath;
            }
        } else {
            path = dbPath;
        }
    } else if(!dirExists) {
        NSError *error = nil;
		NSError *error2 = nil;
		BOOL success = [fileManager createDirectoryAtPath:dbNameDir withIntermediateDirectories:YES attributes:nil error:&error2];
        if(!success) {
            NSLog(@"failed to create dir");
        }
        success = [fileManager copyItemAtPath:originalDBPath toPath:dbPath error:&error];
        if(!success) {
            NSLog(@"error = %@", error);
        } else {
            path = dbPath;
        }
    }
    return path;
}


+ (void)mergeMainDatabaseWithDatabase:(NSString *)databasePath; {
    BOOL dbExists = [[NSFileManager defaultManager] fileExistsAtPath:databasePath];
	if (!dbExists) {
		ILogPlus(@"This database doesn't exist");
		return;
	}else {
		ILogPlus(@"%@",[self executeSQL:[NSString stringWithFormat:@"ATTACH '%@' AS dbl_db",databasePath] withCallback:NULL context:nil]);
		[self executeSQL:[NSString stringWithFormat:@"insert into main.favorites select * from dbl_db.favorites",databasePath] withCallback:NULL context:nil];
		[self executeSQL:[NSString stringWithFormat:@"insert into main.meals select * from dbl_db.meals",databasePath] withCallback:NULL context:nil];
	}
}


+ (void)createTableWithName:(NSString *)name andColumns:(NSArray *)columns; {
	NSMutableString *m = [[[NSMutableString alloc] init] autorelease];
	[m appendString:@"CREATE TABLE IF NOT EXISTS "];
	[m appendString:name];
	[m appendString:@" ("];
	for (NSDictionary *d in columns) {
		[m appendString:[d objectForKey:@"name"]];
		[m appendString:@""];
		[m appendString:[d objectForKey:@"attributes"]];
	}
	[m appendString:@")"];
	[self executeSQL:[NSString stringWithFormat:@"%@",m] withCallback:NULL context:nil];
}



+ (NSNumber *)executeSQL:(NSString *)sql withCallback:(void *)callbackFunction context:(id)contextObject {
    NSString *path = [self pathToDB];
    sqlite3 *db = NULL;
    int rc = SQLITE_OK;
    NSInteger lastRowId = 0;
    rc = sqlite3_open([path UTF8String], &db);
    if(SQLITE_OK != rc) {
        NSLog(@"Can't open database: %s\n", sqlite3_errmsg(db));
        sqlite3_close(db);
        return nil;
    }else {
        char *zErrMsg = NULL;
        NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
        rc = sqlite3_exec(db, [sql UTF8String], callbackFunction, (void*)contextObject, &zErrMsg);
        if(SQLITE_OK != rc) {
            NSLog(@"Can't run query '%@' error message: %s\n", sql, sqlite3_errmsg(db));
            sqlite3_free(zErrMsg);
        }
        lastRowId = sqlite3_last_insert_rowid(db);
        sqlite3_close(db);
        [pool release];
    }
    NSNumber *lastInsertRowId = nil;
    if(0 != lastRowId) {
        lastInsertRowId = [NSNumber numberWithInteger:lastRowId];
    }
    return lastInsertRowId;
}

+ (NSString *)selectOneValueSQL:(NSString *)sql {
    NSMutableDictionary *queryValues = [NSMutableDictionary dictionary];
    [self executeSQL:sql withCallback:singleRowCallback context:queryValues];
    NSString *value = nil;
    if([queryValues count] == 1) {
        value = [[queryValues objectEnumerator] nextObject];
    }
    return value;
}

+ (NSArray *)selectManyValuesWithSQL:(NSString *)sql {
    NSMutableArray *queryValues = [NSMutableArray array];
    [self executeSQL:sql withCallback:multipleRowCallback context:queryValues];
    NSMutableArray *values = [NSMutableArray array];
    for(NSDictionary *dict in queryValues) {
        [values addObject:[[dict objectEnumerator] nextObject]];
    }
    return values;
}

+ (void)createFTS; {
	NSString *sql = @"CREATE VIRTUAL TABLE fts_documents using FTS3(id, title, category, body);";
	[self executeSQL:sql withCallback:NULL context:nil];
}

+ (NSArray *)searchResultsForTerm:(NSString *)s {	
	NSString *sql1 = [NSString stringWithFormat:@"SELECT * FROM documents WHERE `body` LIKE '%%%@%%'", s];
	DLog(@"%@",[SQLiteAccess selectManyRowsWithSQL:sql1]);
	
	return [SQLiteAccess selectManyRowsWithSQL:sql1];
}

+ (NSDictionary *)selectOneRowWithSQL:(NSString *)sql {
    NSMutableDictionary *queryValues = [NSMutableDictionary dictionary];
    [self executeSQL:sql withCallback:singleRowCallback context:queryValues];
    return [NSDictionary dictionaryWithDictionary:queryValues];    
}

+ (NSArray *)tableColumns:(NSString *)tableName {
	NSMutableArray *ret = [NSMutableArray array];
	NSString *path = [self pathToDB];
    sqlite3 *db = NULL;
    int rc = SQLITE_OK;
    rc = sqlite3_open([path UTF8String], &db);
    if(SQLITE_OK != rc) {
        NSLog(@"Can't open database: %s\n", sqlite3_errmsg(db));
        sqlite3_close(db);
        return nil;
    } else {
        char *zErrMsg = NULL;
        NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
		NSString *sql = [NSString stringWithFormat:@"pragma table_info(%@);", tableName];
        sqlite3_stmt *stmt;
		if (sqlite3_prepare_v2( db,  [sql UTF8String], -1, &stmt, nil) == SQLITE_OK) {
			while (sqlite3_step(stmt) == SQLITE_ROW) {
				const unsigned char *colName = sqlite3_column_text(stmt, 1);
				NSString *colString = [NSString stringWithUTF8String:(const char *)colName];
				[ret addObject:colString];
			}
			sqlite3_finalize(stmt);
		}
		else {
            NSLog(@"Can't run query '%@' error message: %s\n", sql, sqlite3_errmsg(db));
            sqlite3_free(zErrMsg);
        }
        sqlite3_last_insert_rowid(db);
        sqlite3_close(db);
        [pool release];
    }
	
	return ret;	
}

+ (NSArray *)selectManyRowsWithSQL:(NSString *)sql {
    NSMutableArray *queryValues = [NSMutableArray array];
    [self executeSQL:sql withCallback:multipleRowCallback context:queryValues];
    return [NSArray arrayWithArray:queryValues];
}

+ (NSNumber *)insertWithSQL:(NSString *)sql {
    sql = [NSString stringWithFormat:@"BEGIN TRANSACTION; %@; COMMIT TRANSACTION;", sql];
    return [self executeSQL:sql withCallback:NULL context:NULL];
}

+ (void)updateWithSQL:(NSString *)sql {
    sql = [NSString stringWithFormat:@"BEGIN TRANSACTION; %@; COMMIT TRANSACTION;", sql];
    [self executeSQL:sql withCallback:NULL context:nil];
}

+ (void)deleteWithSQL:(NSString *)sql {
    sql = [NSString stringWithFormat:@"BEGIN TRANSACTION; %@; COMMIT TRANSACTION;", sql];
	NSLog(@"deleteWithSQL");
    [self executeSQL:sql withCallback:NULL context:nil];
}

@end
