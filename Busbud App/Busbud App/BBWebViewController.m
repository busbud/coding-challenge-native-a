//
//  BBWebViewController.m
//  Busbud App
//
//  Created by Dan Greencorn on 3/1/2014.
//  Copyright (c) 2014 Dan Greencorn. All rights reserved.
//

#import "BBWebViewController.h"

@interface BBWebViewController ()

@end

@implementation BBWebViewController

@synthesize url = _url;

#pragma mark - Property overrides
-(void) setUrl:(NSString *)url {
    _url = url;
    
    // reload the webview
    [self.webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:self.url]]];
}

#pragma mark - UIViewController
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    if (self.url) {
        [self.webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:self.url]]];
        NSLog(@"Loading URL: %@", self.url);
    } else {
        NSLog(@"No url set");
    }
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
