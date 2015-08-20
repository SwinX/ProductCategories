//
//  Queries.m
//  CategoryTree
//
//  Created by Ilia Isupov on 17.08.15.
//  Copyright (c) 2015 Ilia Isupov. All rights reserved.
//

#import "Queries.h"

NSString* const CreateDBQuery = @"CREATE TABLE IF NOT EXISTS PRODUCT_CATEGORIES (ID TEXT PRIMARY KEY, PARENT_ID TEXT, CHILDREN_AMOUNT INTEGER, CATEGORY_ID INTEGER, TITLE TEXT)";
NSString* const LoadPrimaryProductCategoriesQuery = @"SELECT * FROM PRODUCT_CATEGORIES WHERE PARENT_ID IS NULL OR PARENT_ID = ''";
NSString* const LoadChildProductCategoriesQuery = @"SELECT * FROM PRODUCT_CATEGORIES WHERE PARENT_ID = \"%@\"";
NSString* const DeleteProductCategoriesQuery = @"DELETE FROM PRODUCT_CATEGORIES";
NSString* const InsertProductsQuery = @"INSERT INTO PRODUCT_CATEGORIES (ID, PARENT_ID, CHILDREN_AMOUNT, CATEGORY_ID, TITLE) VALUES %@ ;";