//
//  AFHTTPRequestManager.h
//  CategoryTree
//
//  Created by Ilia Isupov on 16.08.15.
//  Copyright (c) 2015 Ilia Isupov. All rights reserved.
//

#import "AFNetworking.h"

@interface AFHTTPRequestOperationManager(SharedManager)

+(void)setupSharedManagerWithURL:(NSURL*)url; //must be a first call before any use of sharedManager
+(instancetype)sharedManager;

@end
