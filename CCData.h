//
//  CCData.h
//  Pocket Constitution
//
//  Created by James on 3/20/10.
//  Copyright 2010 Cirrostratus Design Company. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface CCData : NSObject {

}

- (NSArray *)dataForTable:(NSString *)t;

- (NSArray *)dataForTable:(NSString *)t where:(NSString *)w equals:(NSString *)e;

- (id)dataForTable:(NSString *)t where:(NSString *)w equals:(NSString *)e limitOne:(BOOL)limit;

- (NSArray *)dataForTable:(NSString *)t where:(NSString *)w matches:(NSString *)e;

- (NSArray *)dataForTable:(NSString *)t where:(NSString *)w equals:(NSString *)e isInt:(BOOL)b;


- (NSDictionary *)detailForID:(NSInteger)i inTable:(NSString *)t;

- (void)deleteRowInTable:(NSString *)t byID:(NSInteger)i;

- (NSNumber *)insertRow:(NSMutableDictionary *)r inTable:(NSString *)t;

- (void)updateRow:(NSMutableDictionary *)r byID:(NSInteger)i inTable:(NSString *)t;

- (NSString *)arrayOfDictionariesToCSV:(NSArray *)arrayOfDictionaries;

@end
