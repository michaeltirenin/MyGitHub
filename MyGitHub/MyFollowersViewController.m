//
//  MyFollowersViewController.m
//  MyGitHub
//
//  Created by Michael Tirenin on 8/25/14.
//  Copyright (c) 2014 Michael Tirenin. All rights reserved.
//

#import "MyFollowersViewController.h"
#import "MyFollowerCollectionViewCell.h"
#import "AppDelegate.h"
//#import "Repository.h"
#import "User.h"
#import "NetworkController.h"
//#import "Constants.h"

@interface MyFollowersViewController () <UICollectionViewDataSource, UICollectionViewDelegate, NetworkControllerDelegate>

@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (strong, nonatomic) NSArray *myFollowers;
@property (weak, nonatomic) NetworkController *appDelegateNetworkController; // Jeff's solution

@end

@implementation MyFollowersViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.title = @"My Followers";
    
    AppDelegate *appDelegate = [UIApplication sharedApplication].delegate; //Jeff's solution
    appDelegate.networkController.delegate = self;
    self.appDelegateNetworkController = appDelegate.networkController;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self.appDelegateNetworkController beginOAuth];
    
//    [self.collectionView reloadData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

-(void)followersFinishedParsing:(NSArray *)jsonArray { // Jeff's solution
    NSMutableArray *followers = [[NSMutableArray alloc] init];
    
    for (NSDictionary *followerDict in jsonArray) {
        User *follower = [[User alloc] initWithDict:followerDict];
        [followers addObject:follower];
    }
    self.myFollowers = followers;
    
    [[NSOperationQueue mainQueue]addOperationWithBlock:^{
        [self.collectionView reloadData];
    }];
}

// MARK: CollectionView
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    
    return self.myFollowers.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    MyFollowerCollectionViewCell *followerCollCell = [collectionView dequeueReusableCellWithReuseIdentifier:@"FollowerCollectionCell" forIndexPath:indexPath];
    
    User *follower = self.myFollowers[indexPath.row];
    followerCollCell.nameLabel.text = follower.userName;
    NSLog(@"yes?");
    followerCollCell.avatar.image = follower.userAvatarImage;
    
    return followerCollCell;
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
