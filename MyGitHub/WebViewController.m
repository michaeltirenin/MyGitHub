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
#import <WebKit/WebKit.h>

@interface WebViewController () <UIWebViewDelegate>

@property (weak, nonatomic) IBOutlet UIWebView *webViewOutlet;

@end

@implementation WebViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // using WebKit instead of UIWebView
//    WKWebView *webView = [[WKWebView alloc] initWithFrame:_webViewOutlet.frame]; // using the frame already set up w UIWebView (storyboard)
//    [webView removeFromSuperview];
//    
//    [self.view addSubview:webView];
    
    if (self.repository.repoURL != nil) {
        NSURL *url = [[NSURL alloc] initWithString:self.repository.repoURL];
        NSLog(@"THIS IS THE URL: %@",url);
        NSURLRequest *request = [NSURLRequest requestWithURL:url];
        [self.webViewOutlet loadRequest:request]; //use webView here if going w WebKit

    } else if (self.userRepository.userRepoURL != nil) {
        NSURL *url = [[NSURL alloc] initWithString:self.userRepository.userRepoURL];
        NSLog(@"THIS IS THE URL: %@",url);
        NSURLRequest *request = [NSURLRequest requestWithURL:url];
        [self.webViewOutlet loadRequest:request];

//    } else if (self.codeRepository.codeURL != nil) {
//        NSURL *url = [[NSURL alloc] initWithString:self.codeRepository.codeURL];
//        NSLog(@"THIS IS THE URL: %@",url);
//        NSURLRequest *request = [NSURLRequest requestWithURL:url];
//        [self.webViewOutlet loadRequest:request];
    }

    self.webViewOutlet.delegate = self; // not necessary when using WebKit
    
    self.navigationItem.title = @"Web Link";
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

//-(void)webViewDidStartLoad:(UIWebView *)webView {
//    
//}
//
//-(void)webViewDidFinishLoad:(UIWebView *)webView {
//    
//}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
