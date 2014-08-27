//
//  WebViewController.h
//  MyGitHub
//
//  Created by Michael Tirenin on 8/27/14.
//  Copyright (c) 2014 Michael Tirenin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Repository.h"

@interface WebViewController : UIViewController

@property (strong, nonatomic) Repository *repository;

@end
