//
//  Repository.m
//  MyGitHub
//
//  Created by Michael Tirenin on 8/25/14.
//  Copyright (c) 2014 Michael Tirenin. All rights reserved.
//

#import "Repository.h"

@implementation Repository

-(instancetype)initWithDict:(NSDictionary *)itemDict {
    
    if (self = [super init]) {
        self.repoName = itemDict[@"name"];
        self.repoOwnerName = itemDict[@"login"];
        self.repoDescription = itemDict[@"description"];
        self.repoURL = itemDict[@"html_url"];
        self.repoAvatar = itemDict[@"avatar_url"];
        NSURL *repoAvatarURL = [NSURL URLWithString:self.repoAvatar];
        NSData *repoAvatardata = [[NSData alloc] initWithContentsOfURL:repoAvatarURL];
        self.repoAvatarImage = [UIImage imageWithData:repoAvatardata];
//        self.repoAvatarImage = [UIImage imageWithData:[NSData dataWithContentsOfFile:[NSURL URLWithString:self.repoAvatar]]];
    }
    return self;
}

@end
