//
//  NetworkController.h
//  MyGitHub
//
//  Created by Michael Tirenin on 8/25/14.
//  Copyright (c) 2014 Michael Tirenin. All rights reserved.
//

//
//Client ID: 93cccb5372dc6d06fd30
//Client Secret: d063e58b1defb545c9317197a60c7f856c4c96e2
//

#import <Foundation/Foundation.h>
#import "Repository.h"

@interface NetworkController : NSObject

//@property (nonatomic, strong) NSString *apiDomain;
//@property (nonatomic, strong) NSString *searchEndpoint;

// func parseSuccessfulResponse(responseData: NSData) -> [Question] {
+(Repository *)parseSuccessfulResponse:(NSData *)responseData;

// func fetchQuestionsForSearchTerm(searchTerm : String, callback: (questions: [Question]?, errorDescription: String?) -> Void) {
+(void)fetchReposForSearchTerm:(NSString *)searchTerm withCallback:(void(^)(Repository *repositories, NSString *errorDescription))callback;

//oauth
-(void)handleCallBackURL:(NSURL *)url;

@end
