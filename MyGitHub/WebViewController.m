//
//  WebViewController.m
//  MyGitHub
//
//  Created by Michael Tirenin on 8/27/14.
//  Copyright (c) 2014 Michael Tirenin. All rights reserved.
//

#import "WebViewController.h"
#import "Repository.h"
#import "SearchViewController.h"

@interface WebViewController () <UIWebViewDelegate>

@property (weak, nonatomic) IBOutlet UIWebView *webView;

@end

@implementation WebViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSURL *url = [[NSURL alloc] initWithString:self.repository.repoURL];
    NSLog(@"THIS IS THE URL: %@",url);
    NSURLRequest *request = [NSURLRequest requestWithURL:url];

    [self.webView loadRequest:request];
    self.webView.delegate = self;
     
    self.navigationItem.title = @"Web Link";
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

-(void)webViewDidStartLoad:(UIWebView *)webView {
    
}

-(void)webViewDidFinishLoad:(UIWebView *)webView {
    
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
