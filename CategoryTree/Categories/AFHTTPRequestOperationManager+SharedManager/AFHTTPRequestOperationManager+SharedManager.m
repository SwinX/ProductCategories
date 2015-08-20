//
//  AFHTTPRequestManager.m
//  CategoryTree
//
//  Created by Ilia Isupov on 16.08.15.
//  Copyright (c) 2015 Ilia Isupov. All rights reserved.
//

#import "AFHTTPRequestOperationManager+SharedManager.h"

static AFHTTPRequestOperationManager* instance = nil;

@implementation AFHTTPRequestOperationManager(SharedManager)

+(void)setupSharedManagerWithURL:(NSURL*)url {
    instance = [[AFHTTPRequestOperationManager alloc] initWithBaseURL:url]; //may be restricted for single setup only
}

+(instancetype)sharedManager {
    return instance;
}

@end
