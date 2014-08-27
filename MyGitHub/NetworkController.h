//
//  NetworkController.h
//  MyGitHub
//
//  Created by Michael Tirenin on 8/25/14.
//  Copyright (c) 2014 Michael Tirenin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Repository.h"

@interface NetworkController : NSObject

// func parseSuccessfulResponse(responseData: NSData) -> [Question] { //swift
+(Repository *)parseSuccessfulResponse:(NSData *)responseData;

// func fetchQuestionsForSearchTerm(searchTerm : String, callback: (questions: [Question]?, errorDescription: String?) -> Void) { //swift
+(void)fetchReposForSearchTerm:(NSString *)searchTerm withCallback:(void(^)(Repository *repositories, NSString *errorDescription))callback;

//oauth
-(void)handleCallBackURL:(NSURL *)url;

@end
