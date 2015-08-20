//
//  Category.h
//  CategoryTree
//
//  Created by Ilia Isupov on 16.08.15.
//  Copyright (c) 2015 Ilia Isupov. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "sqlite3.h"

@interface ProductCategory : NSObject

@property (nonatomic, copy) NSString* uid;
@property (nonatomic, copy) NSString* parentUid;
@property (nonatomic) NSInteger childrenAmount;

@property (nonatomic) NSInteger categoryId;
@property (nonatomic, copy) NSString* title;

-(instancetype)initWithUid:(NSString*)uid
                 parentUid:(NSString*)parentUid
            childrenAmount:(NSInteger)childrenAmount
                categoryId:(NSInteger)categoryId
                     title:(NSString*)title;

@end
