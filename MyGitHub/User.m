//
//  User.m
//  MyGitHub
//
//  Created by Michael Tirenin on 8/27/14.
//  Copyright (c) 2014 Michael Tirenin. All rights reserved.
//

#import "User.h"

@implementation User

-(instancetype)initWithDict:(NSDictionary *)itemDict {
    
    if (self = [super init]) {
        self.userName = itemDict[@"login"];
        if ([self.userName isEqual:[NSNull null]]) {
            self.userName = @"n/a";
        }
        self.userAvatarURL = itemDict[@"avatar_url"];
        self.userRepoURL = itemDict[@"html_url"];
        self.userFollowersURL = itemDict[@"followers_url"];
        
        NSURL *userAvatar_URL = [NSURL URLWithString:self.userAvatarURL];
        NSData *userAvatardata = [[NSData alloc] initWithContentsOfURL:userAvatar_URL];
        self.userAvatarImage = [UIImage imageWithData:userAvatardata];

    }
    return self;
}

@end
