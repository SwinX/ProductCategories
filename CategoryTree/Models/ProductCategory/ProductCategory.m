//
//  Category.m
//  CategoryTree
//
//  Created by Ilia Isupov on 16.08.15.
//  Copyright (c) 2015 Ilia Isupov. All rights reserved.
//

#import "ProductCategory.h"

@implementation ProductCategory

-(instancetype)initWithUid:(NSString*)uid
                 parentUid:(NSString*)parentUid
            childrenAmount:(NSInteger)childrenAmount
                categoryId:(NSInteger)categoryId
                     title:(NSString*)title {
    if (self = [super init]) {
        _uid = uid;
        _parentUid = parentUid;
        _childrenAmount = childrenAmount;
        _categoryId = categoryId;
        _title = title;
    }
    return self;
}


@end
