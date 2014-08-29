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
        if ([self.repoName isEqual:[NSNull null]]) { // Jeff's solution to finding null
            self.repoName = @"n/a";
        }
        self.repoOwnerName = itemDict[@"login"];
        if ([self.repoOwnerName isEqual:[NSNull null]]) {
            self.repoOwnerName = @"n/a";
        }
        self.repoDescription = itemDict[@"description"];
        if ([self.repoDescription isEqual:[NSNull null]]) {
            self.repoDescription = @"n/a";
        }
        self.repoURL = itemDict[@"html_url"];
        self.repoAvatar = itemDict[@"avatar_url"];
        NSURL *repoAvatarURL = [NSURL URLWithString:self.repoAvatar];
        NSData *repoAvatardata = [[NSData alloc] initWithContentsOfURL:repoAvatarURL];
        self.repoAvatarImage = [UIImage imageWithData:repoAvatardata];
//        self.repoAvatarImage = [UIImage imageWithData:[NSData dataWithContentsOfFile:[NSURL URLWithString:self.repoAvatar]]];
        self.repoLanguage = itemDict[@"language"];
        if ([self.repoLanguage isEqual:[NSNull null]]) {
            self.repoLanguage = @"n/a";
        }
    }
    return self;
}

@end
