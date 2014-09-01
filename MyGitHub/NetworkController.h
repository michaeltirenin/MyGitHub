//
//  NetworkController.h
//  MyGitHub
//
//  Created by Michael Tirenin on 8/25/14.
//  Copyright (c) 2014 Michael Tirenin. All rights reserved.
//

#import <Foundation/Foundation.h>
//#import "Repository.h"

@protocol NetworkControllerDelegate <NSObject> // Jeff's solution

@optional
-(void)reposFinishedParsing:(NSArray *)jsonArray;
-(void)followersFinishedParsing:(NSArray *)jsonArray;

@end

@interface NetworkController : NSObject

// func parseSuccessfulResponse(responseData: NSData) -> [Question] { //swift
+(NSArray *)parseSuccessfulResponse:(NSData *)responseData withScope:(NSString *)scope;

// func fetchQuestionsForSearchTerm(searchTerm : String, callback: (questions: [Question]?, errorDescription: String?) -> Void) { //swift
+(void)fetchReposForSearchTerm:(NSString *)searchTerm withScope:(NSString *)scope withCallback:(void(^)(NSArray *repositories, NSString *errorDescription))callback;
//oauth
-(void)handleCallBackURL:(NSURL *)url;

-(void)fetchUserReposAndFollowers; // Jeff's solution
-(void)beginOAuth; // Jeff's solution

-(void)createRepo:(NSString *)repoName;

@property (strong, nonatomic) NSString *repoName;

@property (nonatomic, weak) id<NetworkControllerDelegate> delegate; // Jeff's solution

@end
