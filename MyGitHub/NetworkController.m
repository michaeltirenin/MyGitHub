//
//  NetworkController.m
//  MyGitHub
//
//  Created by Michael Tirenin on 8/25/14.
//  Copyright (c) 2014 Michael Tirenin. All rights reserved.
//

#import "NetworkController.h"
#import "Repository.h"
#import "User.h"
//#import "Code.h"
#import "Constants.h"

@interface NetworkController()

@property (strong, nonatomic) NSURLSession *session;
@property (strong, nonatomic) NSString *token;

@end

@implementation NetworkController

// initialized NSURLSession
-(instancetype)init {
    if (self = [super init]) {
        self.session = [NSURLSession sessionWithConfiguration: [NSURLSessionConfiguration defaultSessionConfiguration]];
    }
    return self;
}

// see appDelegate
-(void)handleCallBackURL:(NSURL *)url {
    NSLog(@"%@", url);
    
    // parsing the url given back to us after login
    NSString *query = url.query;
    NSArray *components = [query componentsSeparatedByString:@"code="];
    
    // returns temp code:
    NSString *code = components.lastObject;
    
    // seting up parameters for POST call
    NSString *postString = [NSString stringWithFormat:@"client_id=%@&client_secret=%@&code=%@", kGitHubClientID, kGitHubClientSecret, code];
    
    // converts parameters to data for sending
    NSData *data = [postString dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES]; // why lossy? check into this ...
    
    // gets the length
    NSString *postLength = [NSString stringWithFormat:@"%lu", (unsigned long)[data length]];
    
    // create request for our data task
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    
    // set a bunch of properties on our request
    [request setURL:[NSURL URLWithString:@"https://github.com/login/oauth/access_token"]]; // POST https://developer.github.com/v3/oauth/ (2)
    [request setHTTPMethod:@"POST"];
    // length of the data we are posting
    [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
    // tell it the type of data
    [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-type"];
    [request setHTTPBody:data];
    
   [[self.session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        
        // log error
        if (error) {
            NSLog(@" %@", error.localizedDescription);
        } else {
            NSLog(@" %@", response);
            self.token = [self convertDataToToken:data];
            [[NSUserDefaults standardUserDefaults]setObject:self.token forKey:kGitHubAuthToken]; // removes need to re-authorize
            NSLog(@"%@",self.token);
           
            // why are we calling this here again?
            NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
            
            // once we set this field, all calls made with this session are authenticated
            // https://developer.github.com/v3/oauth/ (#3)
            [configuration setHTTPAdditionalHeaders:@{@"Authorization": [NSString stringWithFormat:@"token %@", self.token]}];
            
            self.session = [NSURLSession sessionWithConfiguration:configuration];
            
            [self fetchUserReposAndFollowers];
        }
    }] resume];
}

-(NSString *)convertDataToToken:(NSData *)data {
    
    // parsing the data we got back, turning it into a string first
    NSString *response = [[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding];
    NSLog(@" %@", response);
          
    // cutting it in half at the &
    NSArray *tokenComponents = [response componentsSeparatedByString:@"&"];
    NSString *tokenWithCode = tokenComponents[0];
    NSLog(@" %@", tokenWithCode);
    
    // cutting in half again at the =
    NSArray *tokenArray = [tokenWithCode componentsSeparatedByString:@"="];
    NSString *tokenArrayString = tokenArray[0];
    NSLog(@" %@", tokenArray);
    NSLog(@" %@", tokenArrayString);
    return tokenArray.lastObject;
}

-(void)fetchUserReposAndFollowers { // Brad and Jeff
    
    NSURL *repoURL = [[NSURL alloc] initWithString:@"https://api.github.com/user/repos"];
    NSURL *followerURL = [[NSURL alloc] initWithString:@"https://api.github.com/user/followers"];
    [[self.session dataTaskWithURL:repoURL completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {  //1. another way to write this (without declaring it), then ...
        if (error) {
            NSLog(@"%@", error.localizedDescription);
        } else {
            NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
            switch (httpResponse.statusCode) {
                case 200: NSLog(@"[Status 200] OK: HTTP request successful");
                    break;
                case 400: NSLog(@"[Status 400] Bad: Bad request; check syntax");
                    break;
                case 401: NSLog(@"[Status 401] Unauthorized: Authentication was required but not provided");
                    break;
                case 403: NSLog(@"Status 403] Forbidden: Request was valid, but server refuses to respond");
                    break;
                case 404: NSLog(@"[Status 404] Not found: Requested resource not found");
                    break;
                case 429: NSLog(@"[Status 429] Too Many Requests: Rate limited");
                    break;
                default: NSLog(@"Sorry. Try again");
                    break;
            }
            NSLog(@"%@", response);
        }
        NSArray *reposJson = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
        
        if (self.delegate && [self.delegate respondsToSelector:@selector(reposFinishedParsing:)]) {
            [self.delegate reposFinishedParsing:reposJson];
        }
    }] resume]; // 2. another way to call the resume (of the task) -- instead of "[task resume]"
    
    [[self.session dataTaskWithURL:followerURL completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) { 
        if (error) {
            NSLog(@"%@", error.localizedDescription);
        } else {
            NSLog(@"%@", response);
        }
        NSArray *followersJson = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
        
        if (self.delegate && [self.delegate respondsToSelector:@selector(followersFinishedParsing:)]) {
            [self.delegate followersFinishedParsing:followersJson];
        }
    }] resume];
}

// parse
+(NSArray *)parseSuccessfulResponse:(NSData *)responseData withScope:(NSString *)scope {
    
    NSMutableArray *results = [[NSMutableArray alloc] init];
    
    NSDictionary *responseDict = [NSJSONSerialization JSONObjectWithData:responseData options:0 error:nil];
    
    NSArray *items = responseDict[@"items"];
    NSDictionary *resultsDict = [[NSDictionary alloc] init];
    
    for (resultsDict in items) {
        if ([scope isEqualToString:@"repositories"]) {
             Repository *repositories = [[Repository alloc] initWithDict:resultsDict];
             [results addObject:repositories];
        } else if ([scope isEqualToString:@"users"]) {
            User *users = [[User alloc] initWithDict:resultsDict];
            [results addObject:users];
//        } else if ([scope isEqualToString:@"code"]) {
//            Code *code = [[Code alloc] initWithDict:resultsDict];
//            [results addObject:code];
        }
    }
//    return nil;
    return results;
}

// network fetch
// func fetchQuestionsForSearchTerm(searchTerm : String, callback: (questions: [Question]?, errorDescription: String?) -> Void) {
+(void)fetchReposForSearchTerm:(NSString *)searchTerm withScope:(NSString *)scope withCallback:(void(^)(NSArray *repositories, NSString *errorDescription))callback {
    //https://api.github.com/search/repositories?q=tetris
    //https://api.github.com/search/code?q=addClass+in:file+language:js+repo:jquery/jquery
    //https://api.github.com/search/users?q=tom
    
    NSString *apiDomain = @"https://api.github.com/search/";
    NSString *scopeTerm = (@"%@", scope);
    
    NSString *urlString = [[[apiDomain stringByAppendingString:scopeTerm]stringByAppendingString:@"?q="]stringByAppendingString:searchTerm];
    
    NSLog(@"%@", urlString);

    // set up URL
    NSURL *url = [[NSURL alloc] initWithString:urlString];
    
    // set up NSURLSession
    NSURLSessionConfiguration *sessionConfiguration = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSURLSession *fetchSession = [NSURLSession sessionWithConfiguration:sessionConfiguration delegate:nil delegateQueue:nil];
//    NSURLSession *fetchSession = [NSURLSession sharedSession]; // what's the difference?
    
    // set up task (data task for JSON fetch)
    NSURLSessionDataTask *task = [fetchSession dataTaskWithURL:url completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        
        if (error) {
            //general error - tell the user try again later or check if they have connection
            //execute callback, passing an error and no questions
            callback(nil, @"Error. Try again.");
            NSLog(@"general error - try again later or check your connection");
        } else {
        //you know your request, so now you want to dig into the response object
//        if let httpResponse = response as? NSHTTPURLResponse {
//            NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
//            int code = [httpResponse statusCode];
            if ([response isKindOfClass: [NSHTTPURLResponse class]]) {
                NSInteger statusCode = [(NSHTTPURLResponse *) response statusCode];
            
                switch (statusCode) {
                    case 200: NSLog(@"[Status 200] OK: HTTP request successful");
//                      var questions = self.parseSuccessfulResponse(data);
                        callback([NetworkController parseSuccessfulResponse:data withScope:scope], nil);
                        //callback(questions: questions, errorDescription: nil);
//                        callback(repositories, nil);
                        break;
                
                    case 400: NSLog(@"[Status 400] Bad: Bad request; check syntax");
                        callback(nil, @"[Status 400] Bad: Bad request; check syntax");
                        break;
                
                    case 401: NSLog(@"[Status 401] Unauthorized: Authentication was required but not provided");
                        callback(nil, @"[Status 401] Unauthorized: Authentication was required but not provided");
                        break;

                    case 403: NSLog(@"Status 403] Forbidden: Request was valid, but server refuses to respond");
                        callback(nil, @"[Status 403] Forbidden: Request was valid, but server refuses to respond");
                        break;

                    case 404: NSLog(@"[Status 404] Not found: Requested resource not found");
                        callback(nil, @"[Status 404] Not found: Requested resource not found");
                        break;
                        
                    case 429: NSLog(@"[Status 429] Too Many Requests: Rate limited");
                        callback(nil, @"[Status 429] Too Many Requests: Rate limited");
                        break;
                        
                    default: NSLog(@"Sorry. Try again");
                        callback(nil, @"Sorry. Try again");
                        break;
                }
            }
        }
    }];
    [task resume];
}

-(void)beginOAuth {
    self.token = [[NSUserDefaults standardUserDefaults]objectForKey:kGitHubAuthToken];
    if (!self.token) {
        NSString *urlString = [NSString stringWithFormat:kGitHubOAuthURL, kGitHubClientID, kGitHubCallbackURI, @"user,repo"];
        NSLog(@"%@", urlString);
        [[UIApplication sharedApplication]openURL:[NSURL URLWithString:urlString]];
    } else {
        NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
        [configuration setHTTPAdditionalHeaders:@{@"Authorization": [NSString stringWithFormat:@"token %@", self.token]}];
        self.session = [NSURLSession sessionWithConfiguration:configuration];
        [self fetchUserReposAndFollowers];
    }
}

-(void)createRepo:(NSString *)repoName {
    NSDictionary *post = @{@"name":repoName};
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:post options:0 error:nil];
    NSString *postLength = [NSString stringWithFormat:@"%lu", (unsigned long)[jsonData length]];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    
    [request setURL:[NSURL URLWithString:@"https://api.github.com/user/repos"]];
    [request setHTTPMethod:@"POST"];
    [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
    [request setValue:[NSString stringWithFormat:@"token %@", self.token] forHTTPHeaderField:@"Authorization"];
    [request setValue:@"text/plain" forHTTPHeaderField:@"Content-type"];
    [request setHTTPBody:jsonData];
    
    NSURLResponse *response;
    NSError *error;
    NSData *responseData = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
    NSLog(@"error: %@", error);
}

@end