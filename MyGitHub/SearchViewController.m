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
#import "SearchCollectionViewCell.h"
#import "NetworkController.h"
#import "Constants.h"
#import "WebViewController.h"

@interface SearchViewController () <UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate, UICollectionViewDataSource, UICollectionViewDelegate/*, NSURLSessionDataDelegate*/>

@property (weak, nonatomic) NSString *searchTerm;
@property (strong, nonatomic) NSArray *searchResults;

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;

@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;

@property (strong, nonatomic) NSOperationQueue *imageQueue; // Jeff and Kirby's solution

@end

@implementation SearchViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.collectionView.hidden = YES;
    self.tableView.hidden = YES;

//    self.tableView.dataSource = self;
//    self.tableView.delegate = self;
//    self.collectionView.dataSource = self;
//    self.collectionView.delegate = self;
    
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
    [self.collectionView reloadData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

// Jeff and Kirby's solution
-(void)fetchUserImages:(NSString *)avatar_url withCompletion:(void (^)(UIImage *avatarImage))completion {
    
    [self.imageQueue addOperationWithBlock:^{
        NSURL *avatarURL = [NSURL URLWithString:avatar_url];
        NSData *data = [NSData dataWithContentsOfURL:avatarURL];
        UIImage *avatarImage = [UIImage imageWithData:data];
        [[NSOperationQueue mainQueue]addOperationWithBlock:^{
            completion(avatarImage);
        }];
    }];
}


// MARK: CollectionView
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    
    if (self.searchResults.count > 0) {
        NSLog(@"YES");
        return self.searchResults.count;
    } else {
        return 0;
    }
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    SearchCollectionViewCell *searchCollCell = [collectionView dequeueReusableCellWithReuseIdentifier:@"SearchCollectionCell" forIndexPath:indexPath];
    
    long currentTag = searchCollCell.tag + 1;
    searchCollCell.tag = currentTag;
    
    if (self.searchBar.selectedScopeButtonIndex == 0) {
//        Repository *searchResult = self.searchResults[indexPath.row];
//        if ((searchResult.repoDescription.length == 0) || (searchResult.repoName.length == 0)) {
//            searchCollCell.nameLabel.text = [[[searchResult.repoName stringByAppendingString:@" ("]stringByAppendingString:searchResult.repolanguage]stringByAppendingString:@")"];
//        } else {
//            searchCollCell.nameLabel.text = [[[searchResult.repoName stringByAppendingString:@" ("]stringByAppendingString:searchResult.repolanguage]stringByAppendingString:@")"];
//        }
    } else if (self.searchBar.selectedScopeButtonIndex == 1) {
        
        User *searchResult = self.searchResults[indexPath.item];
        
        if (searchResult.userAvatarImage == nil) {
            [self fetchUserImages:searchResult.userAvatarURL withCompletion:^(UIImage *avatarImage) {
                if (searchCollCell.tag == currentTag) {
                    searchCollCell.avatar.image = avatarImage;
                    searchResult.userAvatarImage = avatarImage;
                }
            }];
        } else {
            searchCollCell.avatar.image = searchResult.userAvatarImage;
        }
        searchCollCell.nameLabel.text = searchResult.userName;
//        searchCollCell.avatar.image = searchResult.userAvatarImage;
    }
    return searchCollCell;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    if (self.searchResults.count > 0) {
        NSLog(@"%lu", self.searchResults.count);
        return self.searchResults.count;
    } else {
        return 0;
    }
}

// MARK: TableView
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    SearchTableViewCell *searchCell = [tableView dequeueReusableCellWithIdentifier:@"SearchCell" forIndexPath:indexPath];
    
    if (self.searchBar.selectedScopeButtonIndex == 0) {
        Repository *searchResult = self.searchResults[indexPath.row];
        if (([searchResult.repoDescription isEqual: @"n/a"]) || ([searchResult.repoName isEqual: @"n/a"])) {
            searchCell.nameLabel.text = @"n/a";
            searchCell.descriptionLabel.text = @"n/a";
        } else {
            searchCell.nameLabel.text = [[[searchResult.repoName stringByAppendingString:@" ("]stringByAppendingString:searchResult.repoLanguage]stringByAppendingString:@")"];
           searchCell.descriptionLabel.text = searchResult.repoDescription;
//            searchCell.avatar.image = searchResult.repoAvatarImage;
        }
//    } else if (self.searchBar.selectedScopeButtonIndex == 1) {
//        User *searchResult = self.searchResults[indexPath.row];
//        searchCell.nameLabel.text = searchResult.userName;
//        searchCell.descriptionLabel.text = searchResult.userRepoURL;
//        searchCell.avatar.image = searchResult.userAvatarImage;
//    } else if (self.searchBar.selectedScopeButtonIndex == 2) {
//        Code *searchResult = self.searchResults[indexPath.row];
//        searchCell.nameLabel.text = searchResult.codeName;
//        searchCell.descriptionLabel.text = searchResult.codeURL;
    }
    return searchCell;
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    
    self.searchTerm = searchBar.text;
    
    self.collectionView.hidden = YES;
    self.tableView.hidden = NO;
    
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

        self.collectionView.hidden = NO;
        self.tableView.hidden = YES;
        [NetworkController fetchReposForSearchTerm:self.searchTerm withScope:@"users" withCallback:^(NSArray *repositories, NSString *errorDescription) {
            
            [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                self.searchResults = repositories;
                [self.collectionView reloadData];
            }];
        }];
//    } else if (self.searchBar.selectedScopeButtonIndex == 2) {
//
//        [NetworkController fetchReposForSearchTerm:self.searchTerm withScope:@"code" withCallback:^(NSArray *repositories, NSString *errorDescription) {
//            
//            [[NSOperationQueue mainQueue] addOperationWithBlock:^{
//                self.searchResults = repositories;
//                [self.tableView reloadData];
//            }];
//        }];
    }
    [searchBar resignFirstResponder]; //removes keyboard
}

// clear table w scope button selection
-(void)searchBar:(UISearchBar *)searchBar selectedScopeButtonIndexDidChange:(NSInteger)selectedScope {
    searchBar.text = @"";
    self.searchResults = nil;
    self.collectionView.hidden = YES;
    self.tableView.hidden = YES;
    [self.tableView reloadData];
    [self.collectionView reloadData];
}

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    [self performSegueWithIdentifier:@"ToWebView" sender:indexPath];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
        WebViewController *webViewVC = segue.destinationViewController;
        if (self.searchBar.selectedScopeButtonIndex == 0) {
            [[segue identifier] isEqualToString:@"ToWebView"];
            NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
            Repository *repository = [self.searchResults objectAtIndex:indexPath.row];
            webViewVC.repository = repository;
        } else if (self.searchBar.selectedScopeButtonIndex == 1) {
//            SearchCollectionViewCell *cell = sender;
            NSIndexPath *indexPath = sender;
            User *repository = self.searchResults[indexPath.item];
            webViewVC.userRepository = repository;
//        } else if (self.searchBar.selectedScopeButtonIndex == 2) {
//            Code *repository = [self.searchResults objectAtIndex:indexPath.row];
//            webViewVC.codeRepository = repository;
        }
    
}

@end
