//
//  SQLiteAccess.h
//
//  Created by Bill Dudney on 3/11/08.
//  Copyright 2008 Gala Factory. All rights reserved.
//



#ifndef String
#define String(fmt,...) [NSString stringWithFormat:fmt,__VA_ARGS__]
#endif

@interface SQLiteAccess : NSObject 

@property (nonatomic, copy) NSString *dbName;
@property (nonatomic, copy) NSString *dbExt;
@property (nonatomic, copy) NSString *dbDir;

+ (SQLiteAccess *)sql;
- (NSNumber *)executeSQL:(NSString *)sql withCallback:(void *)callbackFunction context:(id)contextObject;
- (void)createFTS;
- (NSString *)selectOneValueSQL:(NSString *)sql;
- (NSArray *)selectManyValuesWithSQL:(NSString *)sql;
- (NSDictionary *)selectOneRowWithSQL:(NSString *)sql;
- (NSArray *)selectManyRowsWithSQL:(NSString *)sql;
- (NSNumber *)insertWithSQL:(NSString *)sql;
- (NSArray *)tableColumns:(NSString *)tableName;
- (void)updateWithSQL:(NSString *)sql;
- (void)deleteWithSQL:(NSString *)sql;
- (void) truncateTable:(NSString *)tableName;
- (NSString *)pathToDB;
- (void)createTableWithName:(NSString *)name andColumns:(NSArray *)columns;
- (void)mergeMainDatabaseWithDatabase:(NSString *)databasePath;
- (void)addColumn:(NSString *)c toTable:(NSString *)t;

@end
