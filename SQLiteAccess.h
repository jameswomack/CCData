//
//  SQLiteAccess.h
//  IceSlide
//
//  Created by Bill Dudney on 3/11/08.
//  Copyright 2008 Gala Factory. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SQLiteAccess : NSObject {
}

+ (NSNumber *)executeSQL:(NSString *)sql withCallback:(void *)callbackFunction context:(id)contextObject;
+ (void)createFTS;
+ (NSString *)selectOneValueSQL:(NSString *)sql;
+ (NSArray *)selectManyValuesWithSQL:(NSString *)sql;
+ (NSDictionary *)selectOneRowWithSQL:(NSString *)sql;
+ (NSArray *)selectManyRowsWithSQL:(NSString *)sql;
+ (NSNumber *)insertWithSQL:(NSString *)sql;
+ (NSArray *)tableColumns:(NSString *)tableName;
+ (void)updateWithSQL:(NSString *)sql;
+ (void)deleteWithSQL:(NSString *)sql;
+ (NSString *)pathToDB;
+ (NSArray *)searchResultsForTerm:(NSString *)s;

@end
