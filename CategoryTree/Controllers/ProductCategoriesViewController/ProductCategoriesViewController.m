//
//  ViewController.m
//  CategoryTree
//
//  Created by Ilia Isupov on 13.08.15.
//  Copyright (c) 2015 Ilia Isupov. All rights reserved.
//

#import "SVProgressHUD.h"
#import "ProductCategoriesViewController.h"
#import "ProductCategoriesListAPI.h"
#import "Repository.h"
#import "ProductCategory.h"

#import "Constants.h"

NSString* const RootCellId = @"RootCategoryCell";
NSString* const LeafCellId = @"LeafCategoryCell";

@interface ProductCategoriesViewController (Private)

-(void)initialize;
-(void)createLoadCategoriesAPI;
-(void)addRefreshButton;
-(void)loadCategories;

-(void)displaySubcategoriesOfCategory:(ProductCategory*)category;

@end

@interface ProductCategoriesViewController ()<UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, weak) IBOutlet UITableView* table;

@end

@implementation ProductCategoriesViewController {
    ProductCategoriesListAPI* _categoriesListAPI;
    
    NSArray* _categories;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initialize];
}

#pragma mark - UITableViewDataSource implementation
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _categories.count;
}

-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    ProductCategory* category = [_categories objectAtIndex:indexPath.row];
    UITableViewCell* cell;
    
    if (category.childrenAmount) {
        cell = [tableView dequeueReusableCellWithIdentifier:RootCellId forIndexPath:indexPath];
    } else {
        cell = [tableView dequeueReusableCellWithIdentifier:LeafCellId forIndexPath:indexPath];
    }
    
    cell.textLabel.text = category.title;
    
    return cell;
}

#pragma mark - UITableViewDelegate implementation

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    ProductCategory* category = [_categories objectAtIndex:indexPath.row];
    
    if (category.childrenAmount) {
        [self displaySubcategoriesOfCategory:category];
    }
}

@end

@implementation ProductCategoriesViewController (Private)

-(void)initialize {
    [self createLoadCategoriesAPI];
    
    if (!self.parentCategory) {
        self.title = NSLocalizedString(@"Categories", nil);
        [self addRefreshButton];
        
        _categories = [[Repository sharedRepository] primaryCategories];
        if (!_categories.count) {
            [_categoriesListAPI loadCategoriesList];
        }
    } else {
        self.title = self.parentCategory.title;
        _categories = [[Repository sharedRepository] subcategoriesForCategory:self.parentCategory];
    }
}

-(void)createLoadCategoriesAPI {
    __weak ProductCategoriesViewController* weakSelf = self;
    
    _categoriesListAPI = [[ProductCategoriesListAPI alloc] init];
    _categoriesListAPI.onCategoriesListLoaded = ^(NSArray* categoriesList) {
        __strong ProductCategoriesViewController* self = weakSelf;
        [SVProgressHUD dismiss];
        [[Repository sharedRepository] persistProductCategories:categoriesList];
        self->_categories = [[Repository sharedRepository] primaryCategories];
        [weakSelf.table reloadData];
    };
    _categoriesListAPI.onError = ^(NSError* error) {
        [SVProgressHUD dismiss];
        [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error", nil)
                                    message:NSLocalizedString(@"Failed to load categories.", nil)
                                   delegate:nil
                          cancelButtonTitle:NSLocalizedString(@"OK", nil)
                          otherButtonTitles:nil]
         show];
    };
}

-(void)addRefreshButton {
    UIBarButtonItem* button = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh
                                                                            target:self
                                                                            action:@selector(loadCategories)];
    self.navigationItem.rightBarButtonItem = button;
}

-(void)loadCategories {
    [SVProgressHUD showWithStatus:NSLocalizedString(@"Loading categories", nil) maskType:SVProgressHUDMaskTypeGradient];
    [_categoriesListAPI loadCategoriesList];
}

-(void)displaySubcategoriesOfCategory:(ProductCategory*)category {
    UIStoryboard* storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    ProductCategoriesViewController* controller = [storyboard instantiateViewControllerWithIdentifier:CategoriesControllerId];
    
    controller.parentCategory = category;
    
    [self.navigationController pushViewController:controller animated:YES];
}

@end
