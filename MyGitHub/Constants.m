//
//  Constants.m
//  MyGitHub
//
//  Created by Michael Tirenin on 8/26/14.
//  Copyright (c) 2014 Michael Tirenin. All rights reserved.
//
// https://developer.github.com/v3/oauth/ // GET https://github.com/login/oauth/authorize + client_id + redirect_uri + scope (+ state)
//

#import "Constants.h"

NSString *const kGitHubClientID = @"93cccb5372dc6d06fd30";
NSString *const kGitHubClientSecret = @"d063e58b1defb545c9317197a60c7f856c4c96e2";
NSString *const kGitHubCallbackURI = @"MyGitHub://git_callback";
NSString *const kGitHubOAuthURL = @"https://github.com/login/oauth/authorize?client_id=%@&redirect_uri=%@&scope=%@";

@implementation Constants

@end
