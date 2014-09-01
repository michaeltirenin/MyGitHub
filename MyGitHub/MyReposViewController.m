//
//  MyReposViewController.m
//  MyGitHub
//
//  Created by Michael Tirenin on 8/25/14.
//  Copyright (c) 2014 Michael Tirenin. All rights reserved.
//

#import "MyReposViewController.h"
#import "MyRepoTableViewCell.h"
#import "AppDelegate.h"
#import "Repository.h"
#import "User.h"
#import "NetworkController.h"
#import "Constants.h"
#import "WebViewController.h"

@interface MyReposViewController () <UITableViewDataSource, UITableViewDelegate, NetworkControllerDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) NSMutableArray *myRepositories;
@property (weak, nonatomic) NetworkController *appDelegateNetworkController;

- (IBAction)addRepo:(UIBarButtonItem *)sender;

@end

@implementation MyReposViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    AppDelegate *appDelegate = [UIApplication sharedApplication].delegate; //Jeff's solution
    appDelegate.networkController.delegate = self;
    self.appDelegateNetworkController = appDelegate.networkController;
    
    self.navigationItem.title = @"My Repos";
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    [self.appDelegateNetworkController beginOAuth];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    return self.myRepositories.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {

    UITableViewCell *repoCell = [tableView dequeueReusableCellWithIdentifier:@"RepoCell" forIndexPath:indexPath];

    Repository *repo =self.myRepositories[indexPath.row];
    
    repoCell.textLabel.text = repo.repoName;
    repoCell.detailTextLabel.text = repo.repoLanguage;

    return repoCell;
}

-(void)reposFinishedParsing:(NSArray *)jsonArray {
    NSMutableArray *repositories = [[NSMutableArray alloc] init];
    
    for (NSDictionary *repoDict in jsonArray) {
        Repository *repository = [[Repository alloc]initWithDict:repoDict];
        [repositories addObject:repository];
    }
    self.myRepositories = repositories;
    [[NSOperationQueue mainQueue]addOperationWithBlock:^{
        [self.tableView reloadData];
    }];
};

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    [[segue identifier] isEqualToString:@"ToWebView"];
    WebViewController *webViewVC = segue.destinationViewController;
    NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
    Repository *repository = self.myRepositories[indexPath.row];
    webViewVC.repository = repository;
}

- (IBAction)addRepo:(UIBarButtonItem *)sender {
    
    UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"New Repo"
                                                     message:@"Enter the name of your new repo:"
                                                    delegate:self
                                           cancelButtonTitle:@"Cancel"
                                           otherButtonTitles:@"Create",nil];
    alert.alertViewStyle = UIAlertViewStylePlainTextInput;
    alert.tag = 1;
    [alert show];
}

- (void) alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == 0){
        if (buttonIndex == 1) {
        }
    } else if (alertView.tag == 1 ) {
        if (buttonIndex == 1 ) {
            UITextField *repoName = [alertView textFieldAtIndex:0];
            [self.appDelegateNetworkController createRepo:repoName.text];
            [self.appDelegateNetworkController fetchUserReposAndFollowers];
            [self dismissViewControllerAnimated:YES completion:nil];
        }
    }
}

@end