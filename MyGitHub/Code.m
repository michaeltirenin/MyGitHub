//
//  Code.m
//  MyGitHub
//
//  Created by Michael Tirenin on 8/27/14.
//  Copyright (c) 2014 Michael Tirenin. All rights reserved.
//

#import "Code.h"

@implementation Code

-(instancetype)initWithDict:(NSDictionary *)itemDict {
    
    if (self = [super init]) {
        self.codeName = itemDict[@"name"];
        self.codeURL = itemDict[@"html_url"];
    }
    return self;
}
@end
