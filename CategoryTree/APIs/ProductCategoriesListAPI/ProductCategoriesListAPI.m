//
//  CategoriesListAPI.m
//  CategoryTree
//
//  Created by Ilia Isupov on 16.08.15.
//  Copyright (c) 2015 Ilia Isupov. All rights reserved.
//

#import "ProductCategoriesListAPI.h"

#import "AFHTTPRequestOperationManager+SharedManager.h"
#import "ProductCategory.h"
#import "Constants.h"

@interface ProductCategoriesListAPI (Private)

-(NSArray*)categoriesListFromJSON:(NSArray*)json withParentCategory:(NSString*)parentUid;
-(ProductCategory*)categoryFromJSON:(NSDictionary*)json withParentCategory:(NSString*)parentUid;

@end

@implementation ProductCategoriesListAPI

-(void)loadCategoriesList {
    __weak ProductCategoriesListAPI* weakSelf = self;
    [[AFHTTPRequestOperationManager sharedManager] GET:@"categories-list"
                                      parameters:nil
                                         success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                             if (weakSelf.onCategoriesListLoaded) {

                                                 weakSelf.onCategoriesListLoaded([self categoriesListFromJSON:responseObject
                                                                                           withParentCategory:nil]);
                                             }
                                         }
                                         failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                             if (weakSelf.onError) {
                                                 weakSelf.onError(error);
                                             }
                                         }];
}

@end

@implementation ProductCategoriesListAPI (Private)

-(NSArray*)categoriesListFromJSON:(NSArray*)json withParentCategory:(NSString*)parentUid {
    NSMutableArray* result = [NSMutableArray array];
    
    for (NSDictionary* entry in json) {
        ProductCategory* category = [self categoryFromJSON:entry withParentCategory:parentUid];
        [result addObject:category];
        [result addObjectsFromArray:[self categoriesListFromJSON:entry[@"subs"] withParentCategory:category.uid]];
    }
    
    return result;
}

-(ProductCategory*)categoryFromJSON:(NSDictionary*)json withParentCategory:(NSString*)parentUid {
    return [[ProductCategory alloc] initWithUid:[[NSUUID UUID] UUIDString]
                                      parentUid:parentUid
                                 childrenAmount:[json[@"subs"] count]
                                     categoryId:[json[@"id"] integerValue]
                                          title:json[@"title"]];
}

@end
