//
//  CategoriesListAPI.h
//  CategoryTree
//
//  Created by Ilia Isupov on 16.08.15.
//  Copyright (c) 2015 Ilia Isupov. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void(^categories_list_loaded_t)(NSArray* categories);
typedef void(^categories_list_error_t)(NSError* error);

@interface ProductCategoriesListAPI : NSObject

@property (nonatomic, copy) categories_list_loaded_t onCategoriesListLoaded;
@property (nonatomic, copy) categories_list_error_t onError;

-(void)loadCategoriesList;

@end
