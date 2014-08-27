//
//  SearchViewController.m
//  MyGitHub
//
//  Created by Michael Tirenin on 8/25/14.
//  Copyright (c) 2014 Michael Tirenin. All rights reserved.
// https://api.github.com/search/repositories?q=tetris+language:assembly&sort=stars&order=desc

#import "SearchViewController.h"
#import "Repository.h"
#import "NetworkController.h"
#import "Constants.h"
#import "WebViewController.h"

@interface SearchViewController () <UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate/*, NSURLSessionDataDelegate*/>

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

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.tableView reloadData];
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
    //swift example
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

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([[segue identifier] isEqualToString:@"ToWebView"]) {
        WebViewController *webViewVC = segue.destinationViewController;
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        Repository *repository = [self.searchResults objectAtIndex:indexPath.row];
        webViewVC.repository = repository;
    }
}

@end
