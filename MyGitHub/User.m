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
        self.userAvatar = itemDict[@"avatar_url"];
        self.userRepoURL = itemDict[@"html_url"];
        
        NSURL *userAvatarURL = [NSURL URLWithString:self.userAvatar];
        NSData *userAvatardata = [[NSData alloc] initWithContentsOfURL:userAvatarURL];
        self.userAvatarImage = [UIImage imageWithData:userAvatardata];

    }
    return self;
}

@end
