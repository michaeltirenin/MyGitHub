//
//  SearchViewController.m
//  MyGitHub
//
//  Created by Michael Tirenin on 8/25/14.
//  Copyright (c) 2014 Michael Tirenin. All rights reserved.
// https://api.github.com/search/repositories?q=tetris+language:assembly&sort=stars&order=desc

#import "SearchViewController.h"
#import "Repository.h"
#import "User.h"
#import "Code.h"
#import "SearchTableViewCell.h"
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
    
    SearchTableViewCell *searchCell = [tableView dequeueReusableCellWithIdentifier:@"SearchCell" forIndexPath:indexPath];
    
    if (self.searchBar.selectedScopeButtonIndex == 0) {
        Repository *searchResult = self.searchResults[indexPath.row];
        searchCell.nameLabel.text = [[[searchResult.repoName stringByAppendingString:@" ("]stringByAppendingString:searchResult.repolanguage]stringByAppendingString:@")"];
        searchCell.descriptionLabel.text = searchResult.repoDescription;
//        searchCell.avatar.image = searchResult.repoAvatarImage;
    } else if (self.searchBar.selectedScopeButtonIndex == 1) {
        User *searchResult = self.searchResults[indexPath.row];
        searchCell.nameLabel.text = searchResult.userName;
        searchCell.descriptionLabel.text = searchResult.userRepoURL;
        searchCell.avatar.image = searchResult.userAvatarImage;
    } else if (self.searchBar.selectedScopeButtonIndex == 2) {
        Code *searchResult = self.searchResults[indexPath.row];
        searchCell.nameLabel.text = searchResult.codeName;
        searchCell.descriptionLabel.text = searchResult.codeURL;
    }
    
    return searchCell;
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    
    self.searchTerm = searchBar.text;
    
    NSLog(@"searchbar clicked");
    
    if (self.searchBar.selectedScopeButtonIndex == 0) {
//        NSString *repositories = @"repositories";
        [NetworkController fetchReposForSearchTerm:self.searchTerm withScope:@"repositories" withCallback:^(NSArray *repositories, NSString *errorDescription) {
        
            [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                self.searchResults = repositories;
                [self.tableView reloadData];
            }];
        }];
    } else if (self.searchBar.selectedScopeButtonIndex == 1) {

        [NetworkController fetchReposForSearchTerm:self.searchTerm withScope:@"users" withCallback:^(NSArray *repositories, NSString *errorDescription) {
            
            [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                self.searchResults = repositories;
                [self.tableView reloadData];
            }];
        }];
    } else if (self.searchBar.selectedScopeButtonIndex == 2) {

        [NetworkController fetchReposForSearchTerm:self.searchTerm withScope:@"code" withCallback:^(NSArray *repositories, NSString *errorDescription) {
            
            [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                self.searchResults = repositories;
                [self.tableView reloadData];
            }];
        }];
    }
    [searchBar resignFirstResponder]; //removes keyboard
}

// clear table w scope button selection
-(void)searchBar:(UISearchBar *)searchBar selectedScopeButtonIndexDidChange:(NSInteger)selectedScope {
    searchBar.text = @"";
    self.searchResults = nil;
    [self.tableView reloadData];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([[segue identifier] isEqualToString:@"ToWebView"]) {
        WebViewController *webViewVC = segue.destinationViewController;
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        if (self.searchBar.selectedScopeButtonIndex == 0) {
            Repository *repository = [self.searchResults objectAtIndex:indexPath.row];
            webViewVC.repository = repository;
        } else if (self.searchBar.selectedScopeButtonIndex == 1) {
            User *repository = [self.searchResults objectAtIndex:indexPath.row];
            webViewVC.userRepository = repository;
        } else if (self.searchBar.selectedScopeButtonIndex == 2) {
            Code *repository = [self.searchResults objectAtIndex:indexPath.row];
            webViewVC.codeRepository = repository;
        }
    }
}

@end
