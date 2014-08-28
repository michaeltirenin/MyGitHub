//
//  Code.h
//  MyGitHub
//
//  Created by Michael Tirenin on 8/27/14.
//  Copyright (c) 2014 Michael Tirenin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface Code : NSObject

@property (strong, nonatomic) NSString *codeName; //"name"
@property (strong, nonatomic) NSString *codeURL; //"html_url"

-(instancetype)initWithDict:(NSDictionary *)itemDict;

@end
