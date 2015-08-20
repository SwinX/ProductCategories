//
//  ViewController.h
//  CategoryTree
//
//  Created by Ilia Isupov on 13.08.15.
//  Copyright (c) 2015 Ilia Isupov. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ProductCategory;

@interface ProductCategoriesViewController : UIViewController

@property (nonatomic, strong) ProductCategory* parentCategory;


@end

