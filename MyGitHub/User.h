//
//  User.h
//  MyGitHub
//
//  Created by Michael Tirenin on 8/27/14.
//  Copyright (c) 2014 Michael Tirenin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface User : NSObject

@property (strong, nonatomic) NSString *userName; //"login"
@property (strong, nonatomic) NSString *userAvatarURL; //"avatar_url"
@property (strong, nonatomic) NSString *userRepoURL; //"html_url"
@property (strong, nonatomic) NSString *userFollowersURL; //"followers_url"
@property (strong, nonatomic) UIImage *userAvatarImage; //


-(instancetype)initWithDict:(NSDictionary *)itemDict;

@end
