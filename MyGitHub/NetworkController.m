//
//  NetworkController.m
//  MyGitHub
//
//  Created by Michael Tirenin on 8/25/14.
//  Copyright (c) 2014 Michael Tirenin. All rights reserved.
//

#import "NetworkController.h"
#import "Repository.h"
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
    [request setURL:[NSURL URLWithString:@"https://github.com/login/oauth//access_token"]]; // POST https://developer.github.com/v3/oauth/ (2)
    [request setHTTPMethod:@"POST"];
    // length of the data we are posting
    [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
    // tell it the type of data
    [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Length"];
    [request setHTTPBody:data];
    
    NSURLSessionDataTask *postDataTask = [self.session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        
        // log error
        if (error) {
            NSLog(@" %@", error.localizedDescription);
        } else {
            NSLog(@" %@", response);
            self.token = [self convertDataToToken:data];
            NSLog(@"%@",self.token);
           
            // why are we calling this here again?
            NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
            
            // once we set this field, all calls made with this session are authenticated
            // https://developer.github.com/v3/oauth/ (#3)
            [configuration setHTTPAdditionalHeaders:@{@"Authorization": [NSString stringWithFormat:@"token %@", self.token]}];
            
            self.session = [NSURLSession sessionWithConfiguration:configuration];
            
            [self fetchUserRepos];
        }
    }];
    [postDataTask resume];
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

-(void)fetchUserRepos {
    
    NSURL *repoURL = [[NSURL alloc] initWithString:@"https://api.github.com/user/repos"];
    [[self.session dataTaskWithURL:repoURL completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {  //1. another way to write this (without declaring it), then ...
        
        if (error) {
            NSLog(@"%@", error.localizedDescription);
        } else {
            NSLog(@"%@", response);
        }
        
        NSDictionary *JSON = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
        
        
    }] resume]; // 2. another way to call the resume (of the task) -- instead of "[task resume]"
}

// parse
+(NSArray *)parseSuccessfulResponse:(NSData *)responseData {
    
    NSMutableArray *results = [[NSMutableArray alloc] init];
    
    NSDictionary *responseDict = [NSJSONSerialization JSONObjectWithData:responseData options:0 error:nil];
    
    NSArray *items = responseDict[@"items"];
    NSDictionary *resultsDict = [[NSDictionary alloc] init];
    
    for (resultsDict in items) {
        
        Repository *repositories = [[Repository alloc] initWithDict:resultsDict];
        [results addObject:repositories];
    }
//    return nil;
    return results;
}

// network fetch
// func fetchQuestionsForSearchTerm(searchTerm : String, callback: (questions: [Question]?, errorDescription: String?) -> Void) {
+(void)fetchReposForSearchTerm:(NSString *)searchTerm withCallback:(void(^)(Repository *repositories, NSString *errorDescription))callback {
    
    NSString *apiDomain = @"https://api.github.com";
    NSString *repoEndpoint = @"/search/repositories?q=";
    NSString *urlString = [[apiDomain stringByAppendingString:repoEndpoint]stringByAppendingString:searchTerm];
    
    NSLog(@"%@", urlString);

    // set up URL
    NSURL *url = [[NSURL alloc] initWithString:urlString];
    
    // set up NSURLSession
    NSURLSessionConfiguration *sessionConfiguration = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSURLSession *fetchSession = [NSURLSession sessionWithConfiguration:sessionConfiguration delegate:nil delegateQueue:nil];
    
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
                        callback([NetworkController parseSuccessfulResponse:data], nil);
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

@end