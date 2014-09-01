//
//  Repository.h
//  MyGitHub
//
//  Created by Michael Tirenin on 8/25/14.
//  Copyright (c) 2014 Michael Tirenin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface Repository : NSObject

@property (strong, nonatomic) NSString *repoName; //"name"
@property (strong, nonatomic) NSString *repoOwnerName; //"owner/"login"
@property (strong, nonatomic) NSString *repoDescription; //"description"
@property (strong, nonatomic) NSString *repoURL; //"owner"/"url"
@property (strong, nonatomic) NSString *repoAvatarURL; //"owner"/"avatar_url"
@property (strong, nonatomic) UIImage *repoAvatarImage;
@property (strong, nonatomic) NSString *repoLanguage; //"language"


-(instancetype)initWithDict:(NSDictionary *)itemDict;

@end
