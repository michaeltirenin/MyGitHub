//
//  SearchViewController.m
//  MyGitHub
//
//  Created by Michael Tirenin on 8/25/14.
//  Copyright (c) 2014 Michael Tirenin. All rights reserved.
// https://api.github.com/search/repositories?q=tetris+language:assembly&sort=stars&order=desc

#import "SearchViewController.h"
#import "SearchTableViewCell.h"
#import "Repository.h"
#import "NetworkController.h"
#import "Constants.h"

//#define GITHUB_CLIENT_ID @"93cccb5372dc6d06fd30"
//#define GITHUB_CLIENT_SECRET @"d063e58b1defb545c9317197a60c7f856c4c96e2"
//#define GITHUB_CALLBACK_URI @"MyGitHub://git_callback"
//#define GITHUB_OAUTH_URL @"https://github.com/login/oauth/authorize?client_id=%@&redirect_uri=%@&scope=%@"

@interface SearchViewController () <UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate, NSURLSessionDataDelegate>

//@property (weak, nonatomic) Repository *repositories;
//@property (weak, nonatomic) NetworkController *networkController;

@property (weak, nonatomic) NSString *searchTerm;
@property (strong, nonatomic) NSArray *searchResults;

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;

@end

@implementation SearchViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
//    self.tableView.dataSource = self;
//    self.tableView.delegate = self;
    
    self.searchBar.delegate = self;
    
    self.navigationItem.title = @"Search GitHub";
}

-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    NSString *urlString = [NSString stringWithFormat:kGitHubOAuthURL,kGitHubClientID,kGitHubCallbackURI,@"user,repo"];
    
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:urlString]];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return self.searchResults.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *searchCell = [tableView dequeueReusableCellWithIdentifier:@"SearchCell" forIndexPath:indexPath];
    
    Repository *searchResult = self.searchResults[indexPath.row];
    
    searchCell.textLabel.text = searchResult.repoName;
    searchCell.detailTextLabel.text = searchResult.repoDescription;
    
    return searchCell;
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    
    self.searchTerm = searchBar.text;
    
    NSLog(@"searchbar clicked");
    
    [NetworkController fetchReposForSearchTerm:self.searchTerm withCallback:^(Repository *repositories, NSString *errorDescription) {
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            self.searchResults = repositories;
            [self.tableView reloadData];
        }];
    }];
//    self.networkController.fetchQuestionsForSearchTerm(searchTerm, callback: {(questions: [Question]?, errorDescription: String?) -> Void in
//        
//        //            if errorDescription // how it was written for XCode 6 Beta 4
//        if (errorDescription != nil) {
//            // alert user of error
//            println("error")
//        } else {
//            // put back on main thread
//            NSOperationQueue.mainQueue().addOperationWithBlock( {() -> Void in
//                self.questions = questions
//                self.tableView.reloadData()
//                //                    println(self.questions!.count)
//            })
//        }
//    })
    [searchBar resignFirstResponder]; //removes keyboard
    
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
