//
//  Repository.h
//  CategoryTree
//
//  Created by Ilia Isupov on 16.08.15.
//  Copyright (c) 2015 Ilia Isupov. All rights reserved.
//

#import <Foundation/Foundation.h>

@class ProductCategory;

@interface Repository : NSObject

+(instancetype)sharedRepository;

/**
 For now only supported quering primary and children of categories. In case when subtree query needed may add material path to categories.
 */
-(NSArray*)primaryCategories;
-(NSArray*)subcategoriesForCategory:(ProductCategory*)category;

-(void)persistProductCategories:(NSArray*)list;

@end
