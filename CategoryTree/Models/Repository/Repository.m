//
//  Repository.m
//  CategoryTree
//
//  Created by Ilia Isupov on 16.08.15.
//  Copyright (c) 2015 Ilia Isupov. All rights reserved.
//

#import "sqlite3.h"
#import "Repository.h"
#import "ProductCategory.h"

#import "Constants.h"
#import "Queries.h"

static Repository* instance = nil;

@interface Repository(Private)

-(void)initialize;
-(const char*)databasePath;
-(BOOL)isDatabaseExist:(NSString*)DBPath;

-(void)openDBConnection;
-(void)closeDBConnection;

-(NSArray*)loadCategories:(const char*)query;
-(NSString*)buildInsertCategoriesQuery:(NSArray*)categories;
-(void)removeAllCategories;

-(ProductCategory*)categoryFromSQLStatement:(sqlite3_stmt*)statement;
-(NSString*)sqlValuesFromCategory:(ProductCategory*)category;

-(void)throwDBExceptionWithReason:(NSString*)reason;

@end

@implementation Repository {
    sqlite3* dbConnectionHandler;
}

+(instancetype)sharedRepository {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[Repository alloc] init];
    });
    return instance;
}

-(instancetype)init {
    if (self = [super init]) {
        [self initialize];
    }
    return self;
}

-(NSArray*)primaryCategories {
    return [self loadCategories:[LoadPrimaryProductCategoriesQuery UTF8String]];
}

-(NSArray*)subcategoriesForCategory:(ProductCategory*)category {
    return [self loadCategories:[[NSString stringWithFormat:LoadChildProductCategoriesQuery, category.uid] UTF8String]];
}

-(void)persistProductCategories:(NSArray*)categories {
    [self removeAllCategories];
    
    [self openDBConnection];
    
    NSString* query = [self buildInsertCategoriesQuery:categories];
    char* error;
    if (sqlite3_exec(dbConnectionHandler, [query UTF8String], NULL, NULL, &error) != SQLITE_OK) {
        NSString* reason = [NSString stringWithFormat:@"Failed to persits product categories. Reason: %@", [NSString stringWithUTF8String:error]];
        [self throwDBExceptionWithReason:reason];
    }
    
    [self closeDBConnection];
}

@end

@implementation Repository(Private)

-(void)initialize {
    if (![self isDatabaseExist:[NSString stringWithUTF8String:[self databasePath]]]) {
        [self openDBConnection];
        
        char* error;
        if (sqlite3_exec(dbConnectionHandler, [CreateDBQuery UTF8String], NULL, NULL, &error) != SQLITE_OK) {
            NSString* reason = [NSString stringWithFormat:@"Failed to create DB. Reason: %@", [NSString stringWithUTF8String:error]];
            [self throwDBExceptionWithReason:reason];
        }
        
        [self closeDBConnection];
    }
}

-(const char*)databasePath {
    NSArray* dirPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString* docsDir = [dirPaths objectAtIndex:0];
    
    return [[docsDir stringByAppendingPathComponent:DBName] UTF8String];
}

-(BOOL)isDatabaseExist:(NSString *)DBPath {
    return [[NSFileManager defaultManager] fileExistsAtPath:DBPath];
}

-(void)openDBConnection {
    if (sqlite3_open([self databasePath], &dbConnectionHandler) != SQLITE_OK) {
        [self throwDBExceptionWithReason:@"Failed to open DB connection. Reason: UNKNOWN"];
    }
}

-(void)closeDBConnection {
    sqlite3_close(dbConnectionHandler);
}

-(NSArray*)loadCategories:(const char*)query {
    [self openDBConnection];
    
    NSMutableArray* result = [NSMutableArray array];
    sqlite3_stmt* statement;
    
    if (sqlite3_prepare_v2(dbConnectionHandler, query, -1, &statement, NULL) == SQLITE_OK) {
        while (sqlite3_step(statement) == SQLITE_ROW) {
            [result addObject:[self categoryFromSQLStatement:statement]];
        }
        sqlite3_finalize(statement);
    } else {
        [self throwDBExceptionWithReason:@"Failed to load categories. Reason: UNKNOWN"];
    }
    
    [result sortUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        ProductCategory* first = (ProductCategory*)obj1;
        ProductCategory* second = (ProductCategory*)obj2;
        
        return [first.title compare:second.title];
    }];
    
    [self closeDBConnection];
    
    return result;
}

-(NSString*)buildInsertCategoriesQuery:(NSArray*)categories {
    NSMutableArray* sqliteData = [NSMutableArray array];
    
    __weak Repository* weakSelf = self;
    [categories enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                                     [sqliteData addObject:[weakSelf sqlValuesFromCategory:obj]];
                                 }];
    return [NSString stringWithFormat:InsertProductsQuery, [sqliteData componentsJoinedByString:@","]];
}

-(void)removeAllCategories {
    [self openDBConnection];
    
    char* error;
    if (sqlite3_exec(dbConnectionHandler, [DeleteProductCategoriesQuery UTF8String], NULL, NULL, &error) != SQLITE_OK) {
        NSString* reason = [NSString stringWithFormat:@"Failed to delete product categories. Reason: %@",
                            [NSString stringWithUTF8String:error]];
        [self throwDBExceptionWithReason:reason];
    }
    
    [self closeDBConnection];
}

-(ProductCategory*)categoryFromSQLStatement:(sqlite3_stmt*)statement {
    const unsigned char* uid = sqlite3_column_text(statement, 0);
    const unsigned char* parentUid = sqlite3_column_text(statement, 1);
    int childrenAmount = sqlite3_column_int(statement, 2);
    int categoryId = sqlite3_column_int(statement, 3);
    const unsigned char* title = sqlite3_column_text(statement, 4);
    
    NSString* parentUidConv = [NSString stringWithUTF8String:(const char*)parentUid];
    
    return [[ProductCategory alloc] initWithUid:[NSString stringWithUTF8String:(const char*)uid]
                                      parentUid:parentUidConv
                                 childrenAmount:childrenAmount
                                     categoryId:categoryId
                                          title:[NSString stringWithUTF8String:(const char*)title]];
}

-(NSString*)sqlValuesFromCategory:(ProductCategory*)category {
    NSString* parentUid = category.parentUid.length ? category.parentUid : @"";
    return [NSString stringWithFormat:@"(\"%@\", \"%@\", %ld, %ld, \"%@\")",
            category.uid, parentUid, (long)category.childrenAmount, (long)category.categoryId, category.title];
}

-(void)throwDBExceptionWithReason:(NSString*)reason {
    NSAssert(false, reason);
}

@end
