//
//  Repository.h
//  MyGitHub
//
//  Created by Michael Tirenin on 8/25/14.
//  Copyright (c) 2014 Michael Tirenin. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Repository : NSObject

@property (strong, nonatomic) NSString *repoName; //"name"
@property (strong, nonatomic) NSString *repoOwnerName; //"owner/"login"
@property (strong, nonatomic) NSString *repoDescription; //"description"
@property (strong, nonatomic) NSURL *repoURL; //"owner"/"url



@end
