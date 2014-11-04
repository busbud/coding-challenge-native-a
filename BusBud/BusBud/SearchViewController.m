//
//  SearchViewController.m
//  BusBud
//
//  Created by Chris Comeau on 2014-11-02.
//  Copyright (c) 2014 Skyriser Media. All rights reserved.
//

#import "SearchViewController.h"

@interface SearchViewController ()
@property (strong, nonatomic) IBOutlet UIWebView *webView;

@end

@implementation SearchViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self updateUI];
}

- (void)viewDidAppear:(BOOL)animated{
    
    [SVProgressHUD showWithStatus:NSLocalizedString(@"kStringSearching", nil)];

    NSString *urlString = [NSString stringWithFormat:kAPISearch, @"en", self.fromString, self.toString];
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:urlString]];
    [self.webView loadRequest:request];
}

-(void) viewWillDisappear:(BOOL)animated {
    
   [SVProgressHUD dismiss];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark -
#pragma mark - UI

- (void)updateUI {
}


#pragma mark -
#pragma mark - Actions




#pragma mark - WebView
- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    return YES;
}

- (void)webViewDidStartLoad:(UIWebView *)webViewParam
{
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
}

- (void)webViewDidFinishLoad:(UIWebView *)webViewParam
{
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    [SVProgressHUD dismiss];

}

- (void)webView:(UIWebView *)webViewParam didFailLoadWithError:(NSError *)error
{
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    [SVProgressHUD showErrorWithStatus:NSLocalizedString(@"kStringConnectionError", nil)];
}


@end
